local mod = get_mod("true_level")
local ProfileUtils = require("scripts/utilities/profile_utils")
local ref = "group_finder"

-- initialize

mod:hook_safe(CLASS.GroupFinderView, "init", function(self)
    mod.desynced(ref)
end)

local _set_modified = function(widget, is_modified)
    widget.tl_modified = is_modified
    -- widget.wru_modified = is_modified
end

-- desync

mod:hook_safe(CLASS.GroupFinderView, "_update_listed_group", function(self)
    mod.debug.echo("desync: listed group")
    mod.desynced(ref)

    local widgets = self._widgets_by_name

    for i = 1, 4 do
        local widget = widgets["team_member_" .. i]

        if widget then
            _set_modified(widget, false)
        end
    end
end)

mod:hook_safe(CLASS.GroupFinderView, "_populate_player_request_grid", function(self)
    mod.debug.echo("desync: request")
    mod.desynced(ref)

    local grid = self._player_request_grid
    local widgets = grid and grid:widgets() or {}

    for i = 1, #widgets do
        _set_modified(widgets[i], false)
    end
end)

mod:hook_safe(CLASS.GroupFinderView, "_populate_preview_grid", function(self)
    mod.debug.echo("desync: preview")
    mod.desynced(ref)

    local grid = self._preview_grid
    local widgets = grid and grid:widgets() or {}

    for i = 1, #widgets do
        _set_modified(widgets[i], false)
    end
end)

-- update

local _get_player_info = function(account_id)
    local social_service = Managers.data_service.social

    return account_id and social_service and social_service:get_player_info_by_account_id(account_id)
end

local _add_level = function(widget, profile)
    local content = widget and widget.content
    local character_id = profile and profile.character_id
    local true_levels = mod.get_true_levels(character_id)

    if true_levels then
        local character_archetype = ProfileUtils.character_archetype_title(profile)

        content.character_archetype_title = mod.replace_level(character_archetype, true_levels, ref, true)
        widget.tl_modified = true
    end
end

local _replace_listed_group = function(self)
    local own_group = self._own_group_visualization
    local members = own_group.members
    local widgets = self._widgets_by_name

    for i = 1, #members do
        local member = members[i]

        if member then
            local widget = widgets["team_member_" .. i]
            local player_info = _get_player_info(member.account_id)
            local profile = player_info and player_info:profile()

            _add_level(widget, profile)
        end
    end
end

local _replace_grid = function(grid)
    local widgets = grid and grid:widgets() or {}

    for i = 1, #widgets do
        local widget = widgets[i]
        local element = widget.content.element
        local presence_info = element and element.presence_info

        if presence_info then
            local profile = presence_info.profile

            _add_level(widget, profile)
        end
    end
end

local _replace_preview_grid = function(self)
    local grid = self._preview_grid

    _replace_grid(grid)
end

local _replace_request_grid = function(self)
    local grid = self._player_request_grid

    _replace_grid(grid)
end

mod:hook_safe(CLASS.GroupFinderView, "update", function(self)
    if not mod.should_replace(ref) then
        return
    end

    local state = self._state

    if state == "browsing" then -- preview
        _replace_preview_grid(self)
        mod.synced(ref)
        mod.debug.echo("synced: browsing")
    elseif state == "advertising" then -- own group / requests
        _replace_listed_group(self)
        _replace_request_grid(self)
        mod.synced(ref)
        mod.debug.echo("synced: advertising")
    end
end)
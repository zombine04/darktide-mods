local mod = get_mod("true_level")
local MainMenuViewSettings = require("scripts/ui/views/main_menu_view/main_menu_view_settings")
local ProfileUtils = require("scripts/utilities/profile_utils")
local ref = "main_menu"
local cache = mod._self

local _get_all_progression = function(self)
    local backend_interface = Managers.backend.interfaces
    local promise = backend_interface.progression:get_entity_type_progression("character")

    self._tl_promise = promise

    promise:next(function(characters_progression)
        for _, data in ipairs(characters_progression) do
            mod.cache_true_levels(cache, data.id, data)
        end

        self._tl_promise = nil
        mod.desync(ref)
        mod.debug.dump(mod._self, "backend_progression")
    end)
end

local _get_character_progression = function(self, character_id)
    local backend_interface = Managers.backend.interfaces
    local promise = backend_interface.progression:get_progression("character", character_id)

    self._tl_promise = promise

    promise:next(function(data)
        mod.cache_true_levels(mod._self, character_id, data)
        self._tl_promise = nil
    end)
end

local _get_account_level = function(widgets)
    local account_level = 0

    for _, widget in pairs(widgets) do
        local content = widget.content
        local profile = content.profile
        local character_id = profile and profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            account_level = account_level + (true_levels.true_level or true_levels.current_level)
        end
    end

    return account_level
end

local _get_title = function(profile)
    return string.format("%s %s", ProfileUtils.character_archetype_title(profile), tostring(profile.current_level) .. " " .. mod.get_symbol("level"))
end

mod:hook_safe(CLASS.MainMenuView, "init", function(self)
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.MainMenuView, "_event_profiles_changed", function(self)
    if not self._tl_promise then
        _get_all_progression(self)
    end
end)

mod:hook_safe(CLASS.MainMenuView, "update", function(self)
    if not mod.should_replace(ref) then
        return
    end

    local character_widgets = self._character_list_widgets
    local num_characters = character_widgets and #character_widgets or 0

    if num_characters and not self._tl_promise then
        -- character slots
        for _, widget in ipairs(character_widgets) do
            local content = widget.content
            local profile = content.profile
            local character_id = profile and profile.character_id
            local true_levels = mod.get_true_levels(character_id)

            if true_levels then
                local title = _get_title(profile)

                content.character_archetype_title = mod.replace_level(title, true_levels, "main_menu")
            else
                _get_character_progression(self, character_id)
                return
            end
        end

        -- character detail
        local selected_character_list_index = self._selected_character_list_index

        if selected_character_list_index then
            self:_set_selected_character_list_index(selected_character_list_index)
        end

        -- account level
        local account_level = _get_account_level(character_widgets)
        local max_num_characters = MainMenuViewSettings.max_num_characters
        local slots_remaining = num_characters < max_num_characters and max_num_characters - num_characters or 0
        local footer_text = Localize("loc_main_menu_slots_remaining", true, {
            count = slots_remaining
        })

        self._widgets_by_name.slots_count.content.text = footer_text .. "\n" .. mod:localize("account_level", account_level)

        -- end
        mod.synced(ref)
    end
end)

mod:hook_safe(CLASS.MainMenuView, "_set_selected_character_list_index", function(self, index)
    if not mod.is_enabled_feature(ref) then
        return
    end

    local character_widgets = self._character_list_widgets
    local selected_widget = character_widgets[index]
    local selected_profile = selected_widget.content.profile
    local selected_character_id = selected_profile.character_id
    local true_levels = cache[selected_character_id]

    if true_levels then
        local content = self._widgets_by_name.character_info.content
        local title = _get_title(selected_profile)

        content.character_archetype_title = mod.replace_level(title, true_levels, "main_menu")
    end
end)
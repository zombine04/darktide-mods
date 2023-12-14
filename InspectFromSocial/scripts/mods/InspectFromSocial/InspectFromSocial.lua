--[[
    title: InspectFromSocial
    author: Zombine
    date: 2023/12/15
    version: 1.0.4
]]
local mod = get_mod("InspectFromSocial")
local SocialConstants = require("scripts/managers/data_service/services/social/social_constants")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local OnlineStatus = SocialConstants.OnlineStatus

mod:hook(CLASS.ViewElementPlayerSocialPopup, "_set_player_info", function(func, self, parent, player_info, menu_items, num_menu_items, ...)
    local is_own_player = player_info:is_own_player()
    local enable_self_inspect = mod:get("enable_self_inspect")

    if is_own_player and not enable_self_inspect then
        -- do nothing
    else
        table.insert(menu_items, 1, {
            label = "divider_inspect_player",
            blueprint = "group_divider"
        })
        table.insert(menu_items, 1, {
            label = Localize("loc_lobby_entry_inspect"),
            on_pressed_sound = UISoundEvents.social_menu_see_player_profile,
            blueprint = "button",
            is_disabled = player_info:online_status() ~= OnlineStatus.online,
            callback = callback(parent, "cb_inspect_operative", player_info)
        })

        num_menu_items = num_menu_items + 2
    end

    func(self, parent, player_info, menu_items, num_menu_items, ...)
end)

local _open_inventory = function(parent, player)
    parent._ifs_peer_id = player:peer_id()
    parent._ifs_local_player_id = player:local_player_id()

    Managers.ui:open_view("inventory_background_view", nil, nil, nil, nil, {
        is_readonly = true,
        player = player
    })
end

mod:hook_safe(CLASS.SocialMenuRosterView, "init", function(self)
    function self:cb_inspect_operative(player_info)
        local unique_id = player_info._player_unique_id
        local player = unique_id and Managers.player:player_from_unique_id(unique_id)

        if not player then
            player = table.clone_instance(player_info)
            player.local_player_id = function()
                return 1
            end
            player.peer_id = function()
                return Managers.player:local_player(1):peer_id()
            end
            player.name = player.character_name
        end

        if player and player.profile then
            local profile = player:profile()

            if profile then
                _open_inventory(self, player)
            else
                self._ifs_queue = player
            end
        end
    end
end)

mod:hook_safe(CLASS.SocialMenuRosterView, "update", function(self, ...)
    if not Managers.player:player(self._ifs_peer_id, self._ifs_local_player_id) then
        if Managers.ui:view_active("inventory_background_view") then
            Managers.ui:close_view("inventory_background_view")
        end
    end

    if self._ifs_queue then
        local player = self._ifs_queue
        local profile = player:profile()

        if profile then
            _open_inventory(self, player)
            self._ifs_queue = nil
        end
    end
end)

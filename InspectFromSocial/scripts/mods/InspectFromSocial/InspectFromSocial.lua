--[[
    title: InspectFromSocial
    author: Zombine
    date: 2023/11/24
    version: 1.0.1
]]
local mod = get_mod("InspectFromSocial")
local SocialConstants = require("scripts/managers/data_service/services/social/social_constants")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local OnlineStatus = SocialConstants.OnlineStatus

mod:hook_require("scripts/ui/view_elements/view_element_player_social_popup/view_element_player_social_popup_content_list", function(content_list)
    mod:hook(content_list, "from_player_info", function(func, parent, player_info)
        local popup_menu_items, _num_menu_items = func(parent, player_info)
        local is_own_player = player_info:is_own_player()

        if not is_own_player then
            table.insert(popup_menu_items, 1, {
                label = "divider_inspect_plaer",
                blueprint = "group_divider"
            })
            table.insert(popup_menu_items, 1, {
                label = Localize("loc_lobby_entry_inspect"),
                on_pressed_sound = UISoundEvents.social_menu_see_player_profile,
                blueprint = "button",
                is_disabled = player_info:online_status() ~= OnlineStatus.online,
                callback = callback(parent, "cb_inspect_operative", player_info)
            })
        end

        _num_menu_items = _num_menu_items + 2

        return popup_menu_items, _num_menu_items
    end)
end)

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
            self._ifs_peer_id = player:peer_id()
            self._ifs_local_player_id = player:local_player_id()

            Managers.ui:open_view("inventory_background_view", nil, nil, nil, nil, {
                is_readonly = true,
                player = player
            })
        end
    end
end)

mod:hook_safe(CLASS.SocialMenuRosterView, "update", function(self, ...)
    if not Managers.player:player(self._ifs_peer_id, self._ifs_local_player_id) then
        if Managers.ui:view_active("inventory_background_view") then
            Managers.ui:close_view("inventory_background_view")
        end
    end
end)
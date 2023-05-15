--[[
    title: quick_chat
    author: Zombine
    date: 15/05/2023
    version: 1.0.0
]]
local mod = get_mod("quick_chat")
local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
local UISettings = require("scripts/settings/ui/ui_settings")

mod._memory = mod:persistent_table("quick_chat")

for _, setting in ipairs(mod._messages) do
    local id = setting.id

    mod["trigger_" .. id] = function()
        local ui_manager = Managers.ui

        if not ui_manager:chat_using_input() and
           not ui_manager:view_active("dmf_options_view") and
           not ui_manager:view_active("options_view") then
            mod.send_preset_message(id, nil, nil, true)
        end
    end
end

mod._get_message_by_id = function(id)
    for _, setting in ipairs(mod._messages) do
        if setting.id == id then
            return setting.message
        end
    end
end

mod._replace_place_holder = function(message, character_name, color)
    if not character_name then
        local player = Managers.player:local_player(1)
        character_name = player:name()
    end

    if color then
        character_name = string.format("{#color(%s,%s,%s)}%s{#reset()}", color[2], color[3], color[4], character_name)
    end

    if character_name then
        message = string.gsub(message, "%[name%]", character_name)
    end


    return message
end

mod.send_preset_message = function(id, character_name, color, need_interval)
    local t = Managers.time:time("main")
    local message = mod._get_message_by_id(id)
    local channel_handle = mod._memory.channel_handle

    if not t or
       not channel_handle or
       not message or
       #message == 0 or
       (need_interval and mod._latest_t and t - mod._latest_t < mod._interval) then
        return
    end

    mod._latest_t = t
    message = mod._replace_place_holder(message, character_name, color)

    if mod:get("enable_check_mode") then
        mod:echo(message)
    else
        Managers.chat:send_channel_message(channel_handle, message)
    end
end

local get_channel_handle = function(self)
    mod._memory.channel_handle = self._selected_channel_handle
end

mod:hook_safe("ConstantElementChat", "_on_disconnect_from_channel", get_channel_handle)
mod:hook_safe("ConstantElementChat", "_next_connected_channel_handle", get_channel_handle)

-- ##################################################
-- Events
-- ##################################################

local send_message_on_event = function(setting_id, character_name, color)
    local message_id = mod:get(setting_id)

    if message_id ~= "none" then
        mod.send_preset_message(message_id, character_name, color)
    end
end

-- player join

mod:hook_safe("ConstantElementChat", "cb_chat_manager_participant_added", function(self, channel_handle, participant)
    local channel = Managers.chat:sessions()[channel_handle]

    if channel.tag ~= ChatManagerConstants.ChannelTag.HUB and not participant.is_text_muted_for_me then
        send_message_on_event("auto_player_joined", participant.displayname)
    end

end)

mod:hook_safe("ConstantElementChat", "_on_connect_to_channel", function(self, channel_handle)
    get_channel_handle(self)

    local channel = Managers.chat:sessions()[channel_handle]

    if channel.tag == ChatManagerConstants.ChannelTag.MISSION then
        send_message_on_event("auto_late_joined")
    end
end)

-- Intro, Outro

mod:hook_safe("CinematicSceneExtension", "setup_from_component", function(self)
    local name = self._cinematic_name

    if string.match(name, "[io][nu]tro_") then
        if mod._cutscene_loaded[name] then
            if name == "intro_abc" then
                send_message_on_event("auto_mission_started")
            elseif name == "outro_win" then
                send_message_on_event("auto_mission_completed")
            elseif name == "outro_fail" then
                send_message_on_event("auto_mission_failed")
            end
        else
            mod._cutscene_loaded[name] = true
        end
    end
end)

mod.on_all_mods_loaded = function()
    mod._cutscene_loaded = {}
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        mod._cutscene_loaded = {}
    end
end
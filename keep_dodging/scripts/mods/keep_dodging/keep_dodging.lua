--[[
    title: keep_dodging
    author: Zombine
    date: 10/06/2023
    version: 1.0.0
]]
local mod = get_mod("keep_dodging")

local path = "keep_dodging/scripts/mods/keep_dodging/keep_dodging_elements"
local element = {
    package = "packages/ui/views/inventory_view/inventory_view",
    use_hud_scale = true,
    class_name = "HudElementKeepDodging",
    filename = path,
    visibility_groups = {
        "alive"
    }
}

local recreate_hud = function()
    local ui_manager = Managers.ui
    local hud = ui_manager and ui_manager._hud

    if hud then
        local player = Managers.player:local_player(1)
        local peer_id = player:peer_id()
        local local_player_id = player:local_player_id()
        local elements = hud._element_definitions
        local visibility_groups = hud._visibility_groups

        hud:destroy()
        ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
    end
end

local add_element = function(elements)
    if not table.find_by_key(elements, "class_name", element.class_name) then
        table.insert(elements, element)
    end
end

mod:io_dofile(path)
mod:add_require_path(path)

mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", add_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", add_element)

mod:hook("InputService", "get", function(func, self, action_name)
    local out = func(self, action_name)

    if action_name == "dodge" and mod._is_active then
        return true
    end

    return out
end)

mod.hold_keep_dodging = function(is_pressed)
    mod._is_active = is_pressed
end

mod.toggle_keep_dodging = function()
    mod._is_active = not mod._is_active
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" and status == "enter" then
        mod._is_active = mod:get("enable_on_start")
    end
end

mod.on_all_mods_loaded = function()
    recreate_hud()

    if not mod._is_in_hub() then
        mod._is_active = mod:get("enable_on_start")
    end
end

mod.on_setting_changed = function()
    recreate_hud()

    if not mod._is_in_hub() then
        mod._is_active = mod:get("enable_on_start")
    end
end

mod._is_in_hub = function()
    local game_mode = Managers.state.game_mode

    if not game_mode then
        return false
    end

    local game_mode_name = game_mode:game_mode_name()

    return game_mode_name == "hub"
end
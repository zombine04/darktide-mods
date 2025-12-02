local mod = get_mod("keep_dodging")

mod._info = {
    title = "Keep Dodging",
    author = "Zombine",
    date = "2025/12/03",
    version = "1.1.3"
}
mod:info("Version " .. mod._info.version)

-- ############################################################
-- Register Hud Element
-- ############################################################

local element = {
    package = "packages/ui/views/inventory_view/inventory_view",
    use_hud_scale = true,
    class_name = "HudElementKeepDodging",
    filename = "keep_dodging/scripts/mods/keep_dodging/keep_dodging_elements",
    visibility_groups = {
        "alive"
    }
}

mod:register_hud_element(element)

-- ############################################################
-- Hook Input Service
-- ############################################################

local _input_hook = function(func, self, action_name, ...)
    local out = func(self, action_name, ...)

    if action_name == "dodge" and mod._is_active then
        return true
    end

    return out
end

mod:hook("InputService", "_get", _input_hook)
mod:hook("InputService", "_get_simulate", _input_hook)
mod:hook("PlayerUnitInputExtension", "get", function(func, self, action)
    if action == "stationary_dodge" and mod:get("disable_sd_while_active") and (mod._is_active or mod._was_active) then
        return false
    end

    return func(self, action)
end)

-- ############################################################
-- Activation
-- ############################################################

local _set_was_active = function(delay)
    mod._was_active = true
    Promise.delay(delay):next(function()
        mod._was_active = false
    end)
end

mod.hold_keep_dodging = function(is_pressed)
    mod._is_active = is_pressed

    if not mod._is_active then
        _set_was_active(0.5)
    end
end

mod.toggle_keep_dodging = function()
    mod._is_active = not mod._is_active

    if not mod._is_active then
        _set_was_active(0.5)
    end
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" and status == "enter" then
        mod._is_active = mod:get("enable_on_start")
    end
end

-- ############################################################
-- Sync
-- ############################################################

local _override_input_settings = function(allow_stationary_dodge)
    local save_manager = Managers.save
    local save_data = save_manager:account_data()
    local input_settings = save_data.input_settings

    input_settings.stationary_dodge = allow_stationary_dodge
    save_manager:queue_save()
end

mod:hook_safe(CLASS.SaveManager, "cb_save_done", function(self)
    if self._state == "idle" then
        local save_manager = Managers.save
        local save_data = save_manager:account_data()
        local input_settings = save_data.input_settings
        local allow_stationary_dodge = input_settings.stationary_dodge

        mod:set("enable_stationary_dodge", allow_stationary_dodge)
    end
end)

mod.on_all_mods_loaded = function()
    _override_input_settings(mod:get("enable_stationary_dodge"))

    if not mod._is_in_hub() then
        mod._is_active = mod:get("enable_on_start")
    end
end

mod.on_setting_changed = function()
    _override_input_settings(mod:get("enable_stationary_dodge"))

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

local mod = get_mod("always_first_attack")

mod.is_in_hub = function()
    local game_mode = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()

	return game_mode and game_mode == "hub"
end

mod.get_local_player_unit = function()
    if mod._local_player_unit then
        return mod._local_player_unit
    end

    local local_player = Managers.player:local_player(1)

    return local_player and local_player.player_unit
end

mod.recreate_hud = function()
    local ui_manager = Managers.ui
    local hud = ui_manager and ui_manager._hud

    if hud then
        local player_manager = Managers.player
        local player = player_manager:local_player(1)
        local peer_id = player:peer_id()
        local local_player_id = player:local_player_id()
        local elements = hud._element_definitions
        local visibility_groups = hud._visibility_groups

        hud:destroy()
        ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
    end
end

mod.debug = {
    action_disabled = function(s)
        if mod._debug_mode then
            mod:echo("{#color(255,255,60)}ACTION DISABLED: {#reset()}" .. s)
        end
    end,
    attack_aborted = function()
        if mod._debug_mode then
            mod:echo("{#color(255,100,100)}SECOND ATTACK ABORTED{#reset()}")
        end
    end,
    dump = function(table, name, depth)
        if mod._debug_mode then
            mod:dump(table, name, depth)
        end
    end,
    echo = function(s)
        if mod._debug_mode then
            mod:echo(s)
        end
    end,
    finish_action = function(reason, data)
        if mod._debug_mode then
            mod:echo("{#color(0,255,60)}FINISH ACTION: {#reset()}\nreason: " ..
                      reason .. "\nkind: " .. data.new_action_kind .. "\ntransition: " .. data.transition_type)
        end
    end,
    request = function(s)
        if mod._debug_mode then
            mod:echo("{#color(0,160,255)}REQUEST: {#reset()}" .. s)
        end
    end,
    stop_auto = function()
        if mod._debug_mode then
            if mod._canceled then
                mod:echo("CANCELED")
            elseif mod._is_heavy then
                mod:echo("IS HEAVY ATTACK")
            end
        end
    end,
}
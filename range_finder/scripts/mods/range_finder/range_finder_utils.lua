local mod = get_mod("range_finder")

mod.is_in_hub = function()
    local game_mode_name = Managers.state.game_mode:game_mode_name()
    local is_in_hub = game_mode_name == "hub"

    return is_in_hub
end

mod.get_local_player_unit = function()
    local local_player = Managers.player:local_player(1)
    local local_player_unit = local_player and local_player.player_unit

    return local_player_unit
end
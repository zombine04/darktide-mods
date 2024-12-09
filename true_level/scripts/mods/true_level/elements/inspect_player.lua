local mod = get_mod("true_level")
local ref = "inspect_player"

mod:hook_safe(CLASS.PlayerCharacterOptionsView, "init", function(self)
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.PlayerCharacterOptionsView, "update", function(self)
    if not mod.should_replace(ref) then
        return
    end

    local player = self._inspected_player
    local content = self._widgets_by_name.player_name.content
    local profile = player and player:profile()
    local character_id = profile and profile.character_id
    local true_levels = mod.get_true_levels(character_id)

    if true_levels then
        local player_name = player:name()
        local current_level = true_levels.current_level

        self:_set_player_name(player_name, current_level)
        content.text = mod.replace_level(content.text, true_levels, ref, true)
        mod.synced(ref)
    end
end)
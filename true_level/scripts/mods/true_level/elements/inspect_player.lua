local mod = get_mod("true_level")
local ref = "inspect_player"

mod:hook_safe(CLASS.PlayerCharacterOptionsView, "init", function(self)
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.PlayerCharacterOptionsView, "update", function(self)
    if not mod.should_replace(ref) then
        return
    end

    local content = self._widgets_by_name.player_name.content
    local character_name = content.text
    local player_info = self._player_info
    local profile = player_info and player_info:profile()
    local character_id = profile and profile.character_id
    local true_levels = mod.get_true_levels(character_id)

    if true_levels then
        content.text = mod.replace_level(character_name, true_levels, ref)
        mod.synced(ref)
    end
end)
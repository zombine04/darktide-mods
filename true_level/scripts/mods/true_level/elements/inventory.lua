local mod = get_mod("true_level")
local ref = "inventory"

mod:hook_safe(CLASS.InventoryBackgroundView, "init", function(self)
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.InventoryBackgroundView, "update", function(self)
    if not mod.should_replace(ref) then
        return
    end

    local player = self._preview_player
    local profile = self._presentation_profile

    if player and profile then
        local character_id = profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            self:_set_player_profile_information(player)

            local content = self._widgets_by_name.character_name.content
            local character_name = content.text

            content.text = mod.replace_level(character_name, true_levels, ref, true)
            mod.synced(ref)
        end
    end
end)

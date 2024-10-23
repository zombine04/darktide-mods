local mod = get_mod("true_level")
local ref = "lobby"

mod:hook_safe(CLASS.LobbyView, "update", function(self)
    if mod.should_replace(ref) then
        local spawn_slots = self._spawn_slots

        for _, slot in ipairs(spawn_slots) do
            local profile = slot.profile

            if profile then
                local content = slot.panel_widget.content
                local character_name =  profile.name or ""
                local character_level = tostring(profile.current_level) .. " " .. mod.get_symbol()

                content.character_name = string.format("%s %s", character_level, character_name)
                slot.wru_modified = false
                slot.tl_modified = false
            end
        end

        self:_sync_players()
        mod.synced(ref)
    end
end)

mod:hook_safe(CLASS.LobbyView, "_sync_player", function(self, unique_id, player)
    local spawn_slots = self._spawn_slots
    local slot_id = self:_player_slot_id(unique_id)
    local slot = spawn_slots[slot_id]
    local is_waiting = slot and mod.is_ready(slot, ref)

    if is_waiting then
        local profile = player:profile()
        local character_id = profile and profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            local content = slot.panel_widget.content
            local character_name = content.character_name

            content.character_name = mod.replace_level(character_name, true_levels, ref)
            slot.tl_modified = true
        end
    end
end)
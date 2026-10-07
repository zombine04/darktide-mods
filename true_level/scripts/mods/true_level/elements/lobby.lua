local mod = get_mod("true_level")
local ref = "lobby"
local NAME_GAP = 40

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

local _name_max_width = function(self)
    local spawn_slots = self._spawn_slots
    local max_width = self:_scenegraph_size("panel")

    for i = 2, #spawn_slots do
        local spacing = math.abs(spawn_slots[i].panel_widget.offset[1] - spawn_slots[i - 1].panel_widget.offset[1])

        if spacing < max_width then
            max_width = spacing
        end
    end

    return max_width - NAME_GAP
end

mod:hook_safe(CLASS.LobbyView, "_sync_player", function(self, unique_id, player)
    local spawn_slots = self._spawn_slots
    local slot_id = self:_player_slot_id(unique_id)
    local slot = spawn_slots[slot_id]

    if not slot then
        return
    end

    local panel_widget = slot.panel_widget
    local content = panel_widget.content

    if mod.is_ready(slot, ref) then
        local profile = player:profile()
        local character_id = profile and profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            content.character_name = mod.replace_level(content.character_name, true_levels, ref)
            slot.tl_levels_text = table.concat(mod.get_level_texts(), " ")
            slot.tl_modified = true
        end
    end

    local character_name = content.character_name

    if character_name ~= slot.tl_fitted_name and mod.is_enabled_feature(ref) then
        local fitted_name = mod.fit_name(self._ui_renderer, character_name, slot.tl_levels_text, panel_widget.style.character_name, _name_max_width(self))

        content.character_name = fitted_name
        slot.tl_fitted_name = fitted_name
    end
end)
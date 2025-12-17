--[[
    title: RememberDifficulty
    author: Zombine
    date: 2025/03/27
    version: 1.0.1
]]
local mod = get_mod("RememberDifficulty")

local _save_selected_difficulty_index = function(self, index)
    local view_name = self.view_name

    if view_name then
        mod:set(view_name, index)
    end
end

local _load_last_selected_difficulty_index = function(self)
    local view_name = self.view_name
    local index = view_name and mod:get(view_name)

    if index then
        local ignore_sound = true

        self:_set_selected_option(index, ignore_sound)
    end
end

-- save
mod:hook_safe(CLASS.HordePlayView, "_cb_on_options_button_pressed", _save_selected_difficulty_index)
mod:hook_safe(CLASS.StoryMissionPlayView, "_cb_on_options_button_pressed", _save_selected_difficulty_index)
-- load
mod:hook_safe(CLASS.HordePlayView, "_fetch_success", _load_last_selected_difficulty_index)
mod:hook_safe(CLASS.StoryMissionPlayView, "_fetch_success", _load_last_selected_difficulty_index)
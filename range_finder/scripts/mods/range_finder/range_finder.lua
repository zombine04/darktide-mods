--[[
    title: range_finder
    author: kanateko
    date: 16/04/2023
    version: 1.1.1
]]

local mod = get_mod("range_finder")

mod:io_dofile("range_finder/scripts/mods/range_finder/range_finder_utils")

local classname = "HudElementRangeFinder"
local filename = "range_finder/scripts/mods/range_finder/range_finder_elements"

mod:add_require_path(filename)

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
    if not table.find_by_key(elements, "class_name", classname) then
        table.insert(elements, {
            class_name = classname,
            filename = filename,
            use_hud_scale = true,
            visibility_groups = {
                "alive",
            },
        })
    end

	return func(self, elements, visibility_groups, params)
end)

local function recreate_hud()
	local ui_manager = Managers.ui
	if ui_manager then
		local hud = ui_manager._hud
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
end

mod.on_all_mods_loaded = function()
	recreate_hud()
end

mod:hook_safe("UIViewHandler", "close_view", function(self, view_name)
    if view_name == "dmf_options_view" then
        recreate_hud()
    end
end)

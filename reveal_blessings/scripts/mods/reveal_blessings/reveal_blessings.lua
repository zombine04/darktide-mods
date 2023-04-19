--[[
	title: reveal_blessings
	author: Zombine
	date: 20/04/2023
	version: 1.0.0
]]
local mod = get_mod("reveal_blessings")

local debug_mode = mod:get("enable_debug_mode")
local ItemUtils = require("scripts/utilities/items")

local get_new_blueprints = function(blueprints)
	local blueprints_new = {}
    blueprints_new = table.clone(blueprints)
    blueprints_new.unknown_trait = table.clone(blueprints.trait)

    local unknown_trait = blueprints_new.unknown_trait

    unknown_trait.init = function (parent, widget, config, callback_name)
		local content = widget.content
		local style = widget.style
		local trait_item = config.trait_item
		local trait_rarity = config.trait_rarity
		content.config = config
		content.parent = parent
		local texture_icon, texture_frame = ItemUtils.trait_textures(trait_item, trait_rarity)
		local icon_material_values = style.icon.material_values
		icon_material_values.icon = texture_icon
		icon_material_values.frame = texture_frame
	end

    local pass_template = unknown_trait.pass_template

    for i, template in ipairs(pass_template) do
        local pass_type = template.pass_type
        local style_id = template.style_id

        if pass_type == "hotspot" then
            pass_template[i].content.on_pressed_sound = nil
        elseif style_id == "background_gradient" then
            pass_template[i].style.default_color = Color.terminal_grid_background_gradient(nil, true)
        elseif style_id == "icon" then
            pass_template[i].style.color = Color.terminal_icon(100, true)
        end
    end

	return blueprints_new
end

local get_new_layout = function(rank, sticker_book)
    local profile = Managers.player:local_player_backend_profile()
	local character_id = profile and profile.character_id

	local layout_new = {
		{ widget_type = "spacing_vertical_small" }
	}

	for trait_name, seen_status in pairs(sticker_book) do
		local status = seen_status[rank]
		local widget_type = "invalid"

        if status == "seen" then
            widget_type = "trait"
        elseif status == "unseen" then
			widget_type = "unknown_trait"
		end

        if widget_type ~= "invalid" then
            local fake_trait = {
                count = 1,
                characterId = character_id,
                masterDataInstance = {
                    id = trait_name,
                    overrides = {
                        rarity = rank
                    }
                },
                trait_name = trait_name,
                uuid = math.uuid(),
                weapon = string.match(trait_name, "^content/items/traits/([%w_]+)/")
            }
            local MasterItems = require("scripts/backend/master_items")
            local trait_stack_item = MasterItems.get_item_instance(fake_trait, fake_trait.uuid)
            layout_new[#layout_new + 1] = {
                trait_amount = 1,
                widget_type = widget_type,
                trait_item = trait_stack_item,
                trait_rarity = rank
            }
        end
	end

	layout_new[#layout_new + 1] = {
		widget_type = "spacing_vertical"
	}

    return layout_new
end

mod:hook("ViewElementTraitInventory", "init", function(func, ...)
    if debug_mode then
        Managers.data_service.crafting:reset()
    end

    func(...)
end)

mod:hook("ViewElementTraitInventory", "present_grid_layout", function(func, self, layout, blueprints, ...)
	if not self._sticker_book then
		func(self, layout, blueprints, ...)
		return
	end

	local blueprints_new = get_new_blueprints(blueprints)
	local rank = self._rank
    local layout_new = get_new_layout(rank, self._sticker_book)

    if debug_mode then
	    mod:dump(layout_new, "layout", 3)
    end

	func(self, layout_new, blueprints_new, ...)
end)

mod.on_setting_changed = function()
    debug_mode = mod:get("enable_debug_mode")
end
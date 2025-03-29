--[[
    title: TeamBuildOverlay
    author: Zombine
    date: 2025/03/30
    version: 0.1.0
]]
local mod = get_mod("TeamBuildOverlay")
local ArchetypeTalents = require("scripts/settings/ability/archetype_talents/archetype_talents")
local CharacterSheet = require("scripts/utilities/character_sheet")
local HordeBuffsData = require("scripts/settings/buff/hordes_buffs/hordes_buffs_data")
local MissionBuffsParser = require("scripts/ui/constant_elements/elements/mission_buffs/utilities/mission_buffs_parser")
local TalentLayoutParser = require("scripts/ui/views/talent_builder_view/utilities/talent_layout_parser")
local TalentBuilderViewSettings = require("scripts/ui/views/talent_builder_view/talent_builder_view_settings")
local TextUtilities = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")

-- ##################################################
-- Hotkey Function
-- ##################################################

mod.on_cycle_player_pressed = function()
    mod._cycle_player = true
end

-- ##################################################
-- Setup
-- ##################################################

local _init = function(self)
    self._ti_current_index = 1
    self._ti_current_player = Managers.player:local_player(1)
    mod._cycle_player = false
end

mod:hook_safe(CLASS.HudElementTacticalOverlay, "init", function(self)
    _init(self)
end)

mod:hook_safe(CLASS.HudElementTacticalOverlay, "_sync_mission_info", function(self)
    _init(self)
end)

-- ##################################################
-- Cycle Player with Hotkey
-- ##################################################

local _cycle_player_display_buffs = function(self, ui_renderer)
    if not mod:get("enable_in_hub") and (self._game_mode_name == "hub" or self._game_mode_name == "prologue_hub") then
        return
    end

    local player_manager = Managers.player
    local current_player = self._ti_current_player

    if current_player and not current_player.__deleted then
        local local_player = player_manager:local_player(1)
        local side_system = Managers.state.extension:system("side_system")
        local side_name = side_system:get_default_player_side_name()
        local side = side_system:get_side_from_name(side_name)
        local player_units = side:added_player_units()

        local human_players = {
            local_player
        }

        for i = 1, #player_units do
            local player_unit = player_units[i]
            local player = player_manager:player_by_unit(player_unit)

            if player and player:is_human_controlled() and player:unique_id() ~= local_player:unique_id() then
                human_players[#human_players + 1] = player
            end
        end

        local num_human_players = #human_players
        self._ti_current_index = self._ti_current_index + 1

        if self._ti_current_index > num_human_players then
            self._ti_current_index = 1
        end

        self._ti_current_player = human_players[self._ti_current_index]
    else
        _init(self)
    end

    self:_setup_buffs_presentation(ui_renderer)
end

mod:hook_safe(CLASS.HudElementTacticalOverlay, "update", function(self, dt, t, ui_renderer, render_settings, input_service)
    local ignore_hud_input = true
    local is_input_blocked = Managers.ui:using_input(ignore_hud_input)
    local service_type = "Ingame"

    input_service = is_input_blocked and input_service:null_service() or Managers.input:get_input_service(service_type)

    local active = false

    if not input_service:is_null_service() and input_service:get("tactical_overlay_hold") then
        active = true
    end

    if active and mod._cycle_player then
        mod._cycle_player = false
        _cycle_player_display_buffs(self, ui_renderer)
    end
end)

-- ##################################################
-- Overwrite Profile
-- ##################################################

--[[
local _overwrite_profile = function(func, self, display_buffs, profile)
    local player = self._ti_current_player

    if player and not player.__deleted then
        profile = player.profile and player:profile() or profile
    end

    func(self, display_buffs, profile)
end

mod:hook(CLASS.HudElementTacticalOverlay, "_add_class_buffs_data", _overwrite_profile)
mod:hook(CLASS.HudElementTacticalOverlay, "_add_items_buffs_data", _overwrite_profile)
]]

local default_material = "content/ui/materials/base/ui_default_base"
local default_texture = "content/ui/textures/placeholder_texture"
local default_gradient = "content/ui/textures/color_ramps/talent_ability"
local default_title = ""
local default_description = ""

mod:hook_origin(CLASS.HudElementTacticalOverlay, "_add_player_buffs", function(self)
    local player = self._ti_current_player
    local player_unit = player and player.player_unit
    local buff_extension = player_unit and ScriptUnit.has_extension(player_unit, "buff_system")

    if not buff_extension then
        local extensions = self._parent:player_extensions()
        buff_extension = extensions and extensions.buff
    end

    local buffs = buff_extension:buffs()
    local display_buffs = {}

    if not buffs then
        return display_buffs
    end

    local profile = player and player:profile()
    local display_buffs = {}

    self:_add_class_buffs_data(display_buffs, profile)
    self:_add_items_buffs_data(display_buffs, profile)

    for i = 1, #buffs do
        local buff = buffs[i]

        if not buff:is_negative() then
            local buff_template = buff:template()
            local buff_hud_data = buff:get_hud_data()
            local buff_category = buff_template and buff_template.buff_category
            local buff_name = buff_hud_data.title
            local buff_description = buff_hud_data.description
            local buff_icon = buff_template and buff_template.icon
            local buff_hud_icon = buff_hud_data and buff_hud_data.hud_icon
            local buff_hud_icon_gradient_map = buff_hud_data and buff_hud_data.hud_icon_gradient_map
            local is_talent = buff_category == "talents" or buff_category == "talents_secondary"
            local is_gadget = buff_category == "gadget"
            local is_weapon = buff_category == "weapon_traits"
            local is_generic = buff_category == "generic"
            local is_aura = buff_category == "aura"
            local is_horde = buff_category == "hordes_buff"
            local is_horde_sub_buff = buff_category == "hordes_sub_buff"
            local has_hud = buff:has_hud()
            local is_active = buff_hud_data.show

            if not is_generic and not is_weapon and not is_gadget and not is_aura and not is_talent and not is_horde_sub_buff or has_hud then
                local skip_buff = false
                local material

                if buff_icon == "content/ui/materials/icons/abilities/default" or not buff_icon then
                    material = default_material
                else
                    material = buff_icon
                end

                local texture, gradient, material_values

                if buff_hud_icon and buff_hud_icon_gradient_map then
                    material = "content/ui/materials/icons/buffs/hud/buff_container_with_background"
                    material_values = {
                        opacity = 1,
                        texture_map = "",
                        progress = 1,
                        talent_icon = buff_hud_icon,
                        gradient_map = buff_hud_icon_gradient_map
                    }
                elseif buff_hud_icon then
                    texture = buff_hud_icon
                else
                    texture = default_texture
                    gradient = default_gradient
                end

                local title = buff_name and buff_name ~= "" and buff_name or default_title
                local description = buff_description and buff_description ~= "" and buff_description or default_description
                local category_id, sub_category_id, size, offset

                if is_horde then
                    category_id = "horde"

                    local buff_data = HordeBuffsData[buff_name]

                    sub_category_id = buff_data.is_family_buff and "hordes_minor_buff" or "hordes_major_buff"
                    title = buff_data and buff_data.title and buff_data.title ~= "" and Localize(buff_data.title) or title
                    description = buff_data and MissionBuffsParser.get_formated_buff_description(buff_data, Color.ui_terminal(255, true)) or description
                    material = "content/ui/materials/frames/talents/talent_icon_container"
                    material_values = {
                        intensity = 0,
                        saturation = 1,
                        icon_mask = "content/ui/textures/frames/horde/hex_frame_horde_mask",
                        frame = "content/ui/textures/frames/horde/hex_frame_horde",
                        texture_map = "",
                        icon = buff_data and buff_data.icon and buff_data.icon ~= "" and buff_data.icon or default_texture,
                        gradient_map = buff_data and buff_data.gradient and buff_data.gradient ~= "" and buff_data.gradient or default_gradient
                    }
                    texture = ""
                    size = {
                        60,
                        60
                    }
                    offset = {
                        -10,
                        -10
                    }
                elseif is_talent or is_aura then
                    local found_buff = false
                    local buff_related_talent = buff_template.related_talents and buff_template.related_talents[1]

                    for player_archetype, archetype_talents in pairs(ArchetypeTalents) do
                        for talent_name, definition in pairs(archetype_talents) do
                            local talent_buff_passive_template_name = definition.passive and definition.passive.buff_template_name
                            local talent_buff_coherency_template_name = definition.coherency and definition.coherency.buff_template_name

                            if talent_buff_passive_template_name == buff_name or talent_buff_coherency_template_name == buff_name or talent_name == buff_related_talent then
                                title = definition.display_name and Localize(definition.display_name) or title
                                description = TalentLayoutParser.talent_description(definition, 1) or description

                                for j = 1, #display_buffs do
                                    local display_buff = display_buffs[j]

                                    if display_buff.category == "talents" then
                                        local trait_title = display_buff.title

                                        if trait_title == title then
                                            if is_active then
                                                display_buff.category = "active_buffs"
                                                display_buff.material = "content/ui/materials/icons/buffs/hud/buff_container_with_background"
                                                display_buff.texture = ""
                                                display_buff.gradient = nil
                                                display_buff.material_values = {
                                                    opacity = 1,
                                                    texture_map = "",
                                                    progress = 1,
                                                    talent_icon = buff_hud_icon,
                                                    gradient_map = buff_hud_icon_gradient_map
                                                }
                                                display_buff.size = nil
                                                display_buff.offset = nil
                                            end

                                            skip_buff = true

                                            break
                                        end
                                    end
                                end

                                if not skip_buff and is_talent then
                                    category_id = "talents"
                                    sub_category_id = "other_talents"
                                end

                                found_buff = true

                                break
                            end
                        end

                        if found_buff then
                            break
                        end
                    end
                elseif is_weapon then
                    if is_active then
                        for j = 1, #display_buffs do
                            local display_buff = display_buffs[j]

                            if display_buff.category == "items" then
                                local trait_name = display_buff.item.trait
                                local trait_name_added_suffix = string.format("%s_parent", trait_name)

                                if buff_template.name == trait_name or buff_template.name == trait_name_added_suffix then
                                    display_buff.category = "active_buffs"
                                    display_buff.material = "content/ui/materials/icons/buffs/hud/buff_container_with_background"
                                    display_buff.texture = ""
                                    display_buff.gradient = nil
                                    display_buff.material_values = {
                                        opacity = 1,
                                        texture_map = "",
                                        progress = 1,
                                        talent_icon = buff_hud_icon,
                                        gradient_map = buff_hud_icon_gradient_map
                                    }
                                end
                            end
                        end
                    end

                    skip_buff = true
                end

                if not is_horde and is_active then
                    category_id = "active_buffs"
                    sub_category_id = sub_category_id or "other_buffs"
                end

                if not skip_buff then
                    display_buffs[#display_buffs + 1] = {
                        material = material,
                        texture = texture,
                        gradient = gradient,
                        material_values = material_values,
                        title = title,
                        description = description,
                        category = category_id,
                        sub_category = sub_category_id,
                        size = size
                    }
                end
            end
        end
    end

    return display_buffs
end)

-- ##################################################
-- Insert Player Name
-- ##################################################

local _get_player_name = function(self)
    local player_name = "player_name"
    local player = self._ti_current_player
    local profile = player and player:profile()

    if profile then
        local archetype = profile and profile.archetype
        local archetype_name = archetype and archetype.name
        local string_symbol = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""

        player_name = string_symbol .. " " .. player:name()

        local player_slot = player and player.slot and player:slot()
        local player_slot_colors = UISettings.player_slot_colors
        local player_slot_color = player_slot and player_slot_colors[player_slot]

        if player_name and player_slot_color then
            player_name = TextUtilities.apply_color_to_text(player_name, player_slot_color)
        end
    end

    return player_name
end

mod:hook(CLASS.HudElementTacticalOverlay, "_generate_buffs_layout", function(func, self, display_buffs)
    local layout = func(self, display_buffs)

    if #layout > 0 then
        local new_layout = {
            {
                blueprint = "buff_title",
                title = _get_player_name(self)
            },
            {
                blueprint = "buff_spacing"
            }
        }

        table.append(new_layout, layout)

        return new_layout
    end

    return layout
end)

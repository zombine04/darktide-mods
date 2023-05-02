--[[
    title: contracts_overlay
    author: Zombine
    date: 02/05/2023
    version: 1.1.5
]]
local mod = get_mod("contracts_overlay")

local MissionTemplates = require("scripts/settings/mission/mission_templates")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ViewSettings = require("scripts/ui/views/contracts_view/contracts_view_settings")
local WalletSettings = require("scripts/settings/wallet_settings")
local debug_mode = mod:get("enable_debug_mode")
local live_update = mod:get("enable_live_update")

local margin = 20
local font_size = 20
local contract_base_size = font_size + 5
local contract_total_size = contract_base_size

-- ##############################
-- functions
-- ##############################

local get_new_definitions = function()
    local Definitions = require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_definitions")
    local scenegraph = Definitions.scenegraph_definition

    scenegraph.contract_pivot = {
        vertical_alignment = "top",
        parent = "left_panel",
        horizontal_alignment = "left",
        size = {
            0,
            0
        },
        position = {
            0,
            0,
            1
        }
    }
    scenegraph.contract_info_panel = {
        vertical_alignment = "top",
        parent = "contract_pivot",
        horizontal_alignment = "left",
        size = {
            scenegraph.diamantine_info_panel.size[1] - 50,
            400,
        },
        position = {
            0,
            0,
            1
        }
    }

    local contract_definitions = {
        {
            style_id = "contract_header",
            value_id = "contract_header",
            pass_type = "text",
            value = Localize("loc_contracts_list_title"),
            style = {
                visible = false,
                vertical_alignment = "top",
                text_vertical_alignment = "top",
                horizontal_alignment = "left",
                text_horizontal_alignment = "left",
                font_size = font_size + 5,
                offset = {
                    0,
                    0,
                    10
                },
                size = {
                    400,
                    30
                },
                text_color = Color.terminal_text_header(255, true)
            }
        }
    }

    for i = 1, 5 do
        contract_definitions[#contract_definitions + 1] = {
            style_id = "contract_desc_" .. i,
            value_id = "contract_desc_" .. i,
            pass_type = "text",
            value = "<contract_desc_" .. i .. ">",
            style = {
                visible = false,
                vertical_alignment = "top",
                text_vertical_alignment = "center",
                horizontal_alignment = "left",
                text_horizontal_alignment = "left",
                font_size = font_size,
                offset = {
                    0,
                    (margin + font_size) * i + margin,
                    10
                },
                size = {
                    400,
                    font_size
                },
                text_color = Color.terminal_text_body(255, true)
            }
        }
    end
    for i = 1, 5 do
        contract_definitions[#contract_definitions + 1] = {
            style_id = "contract_count_" .. i,
            value_id = "contract_count_" .. i,
            pass_type = "text",
            value = "1000/1000",
            style = {
                visible = false,
                vertical_alignment = "top",
                text_vertical_alignment = "center",
                horizontal_alignment = "left",
                text_horizontal_alignment = "left",
                font_size = font_size,
                offset = {
                    400,
                    (margin + font_size) * i + margin,
                    10
                },
                size = {
                    200,
                    font_size
                },
                text_color = Color.dark_khaki(255, true)
            }
        }
    end

    Definitions.left_panel_widgets_definitions.contract_info = UIWidget.create_definition(contract_definitions, "contract_info_panel")

    return Definitions
end

local _init_counter = function(tasks)
    mod._live_counter = mod:persistent_table("live_counter")

    if not table.is_empty(mod._live_counter) then
        return
    end

    local live_counter = mod._live_counter

    for _, task in pairs(tasks) do
        if not task.rewarded then
            local criteria = task.criteria
            local task_type = criteria.taskType

            if task_type == "CollectResource" then
                local resource_type = criteria.resourceType or criteria.resourceTypes[1]

                if not live_counter.resource then
                    live_counter.resource = {}
                end

                live_counter.resource[resource_type] = 0
            elseif task_type == "KillBosses" or task_type == "KillMinions" then
                if not live_counter.kill then
                    live_counter.kill = {}
                end

                if task_type == "KillBosses" then
                    live_counter.kill.boss = 0
                elseif task_type == "KillMinions" then
                    local enemy_type = criteria.enemyType
                    local weapon_type = criteria.weaponType

                    live_counter.kill[enemy_type .. "_" .. weapon_type] = 0
                end
            end
        end
    end

    if debug_mode then
        mod:echo("counter initialized")
        mod:dump(mod._live_counter, "coutner", 2)
    end
end

local fetch_task_list = function()
    local profile = Managers.player:local_player_backend_profile()
    local character_id = profile and profile.character_id

    if mod._character_id ~= character_id then
        mod._completed = false
    end

    mod._character_id = character_id

    if mod._completed then
        if debug_mode then
            mod:echo("contract completed")
        end
        return
    end

    local promise = Managers.backend.interfaces.contracts:get_current_contract(character_id)

    if not promise then
        return
    end

    promise:next(function(data)
        mod._contract_data = data
        mod._update_tasks_list = true

        if live_update and not mod._live_counter then
            _init_counter(data.tasks)
        end

        if debug_mode then
            mod:echo("contract fetched")
            mod:dump(mod._contract_data, "contract", 4)
        end
    end):catch(function(e)
        mod:dump(e, "error_fetch_task_list", 3)
    end)
end

local _get_task_description_and_target = function(task_criteria)
    local task_parameter_strings = ViewSettings.task_parameter_strings
    local task_type = task_criteria.taskType
    local target_value = task_criteria.count
    local params = {
        count = target_value
    }
    local title_loc, desc_loc = nil, nil

    if task_type == "KillBosses" then
        title_loc = ViewSettings.task_label_kill_bosses
        desc_loc = ViewSettings.task_description_kill_bosses
    elseif task_type == "CollectPickup" then
        local param_loc = task_parameter_strings[task_criteria.pickupType]

        if not param_loc then
            local task_criteria_types = task_criteria.pickupTypes

            if #task_criteria_types > 1 then
                param_loc = task_parameter_strings.tome_or_grimoire
            else
                param_loc = task_parameter_strings[task_criteria_types[1]]
            end
        end

        params.kind = Localize(param_loc or "")
        title_loc = ViewSettings.task_label_collect_pickups
        desc_loc = ViewSettings.task_description_collect_pickups
    elseif task_type == "CollectResource" then
        local wallet_settings = WalletSettings[task_criteria.resourceType]

        if not wallet_settings then
            local task_criteria_types = task_criteria.resourceTypes

            if task_criteria_types and #task_criteria_types > 0 then
                wallet_settings = WalletSettings[task_criteria_types[1]]
            end
        end

        params.kind = wallet_settings and Localize(wallet_settings.display_name) or ""
        title_loc = ViewSettings.task_label_collect_resources
        desc_loc = ViewSettings.task_description_collect_resources
    elseif task_type == "KillMinions" then
        params.enemy_type = Localize(task_parameter_strings[task_criteria.enemyType] or "")
        params.weapon_type = Localize(task_parameter_strings[task_criteria.weaponType] or "")
        title_loc = ViewSettings.task_label_kill_minions
        desc_loc = ViewSettings.task_description_kill_minions
    elseif task_type == "BlockDamage" then
        title_loc = ViewSettings.task_label_block_damage
        desc_loc = ViewSettings.task_description_block_damage
    elseif task_type == "CompleteMissions" then
        title_loc = ViewSettings.task_label_complete_missions
        desc_loc = ViewSettings.task_description_complete_missions
    elseif task_type == "CompleteMissionsNoDeath" then
        title_loc = ViewSettings.task_label_complete_mission_no_death
        desc_loc = ViewSettings.task_description_complete_mission_no_death
    elseif task_type == "CompleteMissionsByName" then
        local mission_template = MissionTemplates[task_criteria.name]
        params.map = mission_template and Localize(mission_template.mission_name) or ""
        title_loc = ViewSettings.task_label_complete_missions_by_name
        desc_loc = ViewSettings.task_description_complete_missions_by_name
    else
        title_loc = "loc_" .. task_type
        desc_loc = "loc_" .. task_type
    end

    local title = Localize(title_loc, true, params)
    local description = Localize(desc_loc, true, params)

    return title, description, target_value
end

local _is_countable = function(task_type)
    return task_type == "CollectResource" or task_type == "KillBosses" or task_type == "KillMinions"
end

local _update_count = function(criteria)
    local task_type = criteria.taskType
    local value = criteria.value
    local live_counter = nil

    if task_type == "CollectResource" then
        local resource_type = criteria.resourceType or criteria.resourceTypes[1]
        live_counter = mod._live_counter.resource[resource_type]
    elseif task_type == "KillBosses" then
        live_counter = mod._live_counter.kill.boss
    elseif task_type == "KillMinions" then
        local enemy_type = criteria.enemyType
        local weapon_type = criteria.weaponType
        live_counter = mod._live_counter.kill[enemy_type .. "_" .. weapon_type]
    end

    if live_counter then
        value = value + live_counter
    end

    return value
end

local update_contract_list = function(self)
    local widgets = self._widgets_by_name

    if not (mod._contract_data and mod._update_tasks_list) or not widgets.contract_info then
        return
    end

    mod._update_tasks_list = false

    if debug_mode then
        mod:echo("task updated")
    end

    local contract_info = widgets.contract_info
    local content = contract_info.content
    local style = contract_info.style
    style.contract_header.visible = true
    local tasks = mod._contract_data.tasks
    local remained = 5
    local index = 1

    for _, task in ipairs(tasks) do
        if task.rewarded then
            remained = remained - 1
        else
            local criteria = task.criteria
            local title, _, target = _get_task_description_and_target(criteria)
            local value = criteria.value
            local key_desc = "contract_desc_" .. index
            local key_count = "contract_count_" .. index

            if live_update and mod._live_counter and _is_countable(criteria.taskType) then
                value = _update_count(criteria)
            end

            content[key_desc] = title
            content[key_count] = string.format("%d/%d", value, target)
            style[key_desc].visible = true
            style[key_count].visible = true

            if value >= target then
                style[key_desc].text_color = Color.dark_slate_gray(230, true)
                style[key_count].text_color = Color.dark_slate_gray(230, true)
            end

            index = index + 1
        end
    end

    if remained == 0 then
        contract_total_size = contract_base_size
        mod._completed = true
        content.contract_header = content.contract_header .. ": " .. Localize("loc_contracts_task_completed")
    else
        contract_total_size = (font_size + margin) * remained + (contract_base_size * 2)
    end
end

local counter_update_notification = function(type, count)
    mod:echo("counter updated: " .. type .. " (" .. count .. ")")
end

-- ##############################
-- hooks
-- ##############################

-- update tactical overlay

mod:hook("HudElementTacticalOverlay", "init", function(func, ...)
    fetch_task_list()
    Definitions = get_new_definitions()

    func(...)
end)

mod:hook_safe("HudElementTacticalOverlay", "set_scenegraph_position", function(self, id, _, y)
    if id == "crafting_pickup_pivot" and contract_base_size then
        local scenegraph = self._ui_scenegraph
        local size = scenegraph.plasteel_info_panel.size[2] * 2 + contract_base_size

        self:set_scenegraph_position("contract_pivot", nil, y + size)
    end
end)

mod:hook("HudElementTacticalOverlay", "_set_scenegraph_size", function(func, self, id, width, height)
    if id == "left_panel" and contract_total_size then
        height = height + contract_total_size
    end

    func(self, id, width, height)
end)

mod:hook_safe("HudElementTacticalOverlay", "update", function(self, ...)
    if not mod._completed then
        update_contract_list(self)
    end
end)

mod:hook_safe("HudElementTacticalOverlay", "_start_animation", function(self, animation_sequence_name)
    if animation_sequence_name == "enter" and mod._ready_to_update_tasks_list then
        if mod._contract_data and mod._contract_data.tasks then
            mod._update_tasks_list = true
            mod._ready_to_update_tasks_list = false
        else
            fetch_task_list()
        end
    end
end)

-- update live counters

mod:hook_safe("HudElementTacticalOverlay", "_update_materials_collected", function(self)
    local resource_counter = mod._live_counter and mod._live_counter.resource

    if live_update and resource_counter then
        for resource_type, count in pairs(resource_counter) do
            if resource_type == "plasteel" or resource_type == "diamantine" then
                local collected_amount = self._widgets_by_name[resource_type .. "_info"].content[resource_type .. "_amount_id"]

                if resource_counter[resource_type] ~= collected_amount then
                    resource_counter[resource_type] = collected_amount
                    mod._update_tasks_list = true

                    if debug_mode then
                        counter_update_notification(resource_type, collected_amount)
                    end
                end
            end
        end
    end
end)

mod:hook_safe("AttackReportManager", "add_attack_result", function(self, _, unit, _, _, _, _, _, attack_result, attack_type)
    if attack_result ~= "died" then
        return
    end

    local kill_counter = mod._live_counter and mod._live_counter.kill

    if live_update and kill_counter then
        local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
        local breed = unit_data_extension and unit_data_extension:breed()
        local sub_faction = breed and breed.sub_faction_name

        if not sub_faction then
            return
        end

        for task_type, count in pairs(kill_counter) do
            if task_type == "boss" then
                if breed.tags.monster or breed.tags.captain then
                    kill_counter.boss = count + 1
                    mod._ready_to_update_tasks_list = true

                    if debug_mode then
                        counter_update_notification(task_type,  kill_counter[task_type])
                    end
                end
            elseif sub_faction ~= "chaos" and attack_type then
                if task_type == sub_faction .. "_" .. attack_type then
                    kill_counter[task_type] = count + 1
                    mod._ready_to_update_tasks_list = true

                    if debug_mode then
                        counter_update_notification(task_type, kill_counter[task_type])
                    end
                end
            end
        end
    end
end)

-- ##############################
-- utility
-- ##############################

local function recreate_hud()
    local ui_manager = Managers.ui
    local hud = ui_manager and ui_manager._hud

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

mod.on_all_mods_loaded = function()
    recreate_hud()
end

mod.on_setting_changed = function()
    debug_mode = mod:get("enable_debug_mode")
    live_update = mod:get("enable_live_update")
    recreate_hud()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        if mod._live_counter then
            for k, _ in pairs(mod._live_counter) do
                mod._live_counter[k] = nil
            end
        end

        mod._live_counter = nil
        mod._contract_data = nil

        if debug_mode then
            mod:echo("counter destroyed")
        end
    end
end
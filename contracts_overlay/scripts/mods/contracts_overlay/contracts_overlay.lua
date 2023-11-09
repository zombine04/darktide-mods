--[[
    title: contracts_overlay
    author: Zombine
    date: 09/11/2023
    version: 1.3.1
]]
local mod = get_mod("contracts_overlay")

local MissionTemplates = require("scripts/settings/mission/mission_templates")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ViewSettings = require("scripts/ui/views/contracts_view/contracts_view_settings")
local WalletSettings = require("scripts/settings/wallet_settings")
local debug_mode = mod:get("enable_debug_mode")
local live_update = mod:get("enable_live_update")
local notify_completion = mod:get("enable_complete_notif")

local margin = 20
local font_size = 20
local contract_base_size = font_size + 5
local contract_total_size = contract_base_size

-- ##############################
-- functions
-- ##############################

local _get_materials_amount = function ()
    mod._materials_amount = mod:persistent_table("materials_amount")

    if table.is_empty(mod._materials_amount) then
        Managers.backend.interfaces.crafting:get_collected_materials_amount():next(function (materials_amount)
            mod._materials_amount.large = materials_amount.large
            mod._materials_amount.small = materials_amount.small

            if debug_mode then
                mod:echo("materials amount fetched")
                mod:dump(mod._materials_amount, "materials_amount", 2)
            end
        end)
    end
end

local _get_new_definitions = function()
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

local _create_notification = function(task, task_type, i)
    mod._task_index = i
    Managers.contracts:notify_contract_task_complete(task.id)

    if debug_mode then
        mod:echo("{#color(60,230, 60)}task completed: {#reset()}" .. task_type)
        mod:dump(task, "completed", 3)
    end
end

local _check_task_progress = function(task_types, disable_notification)
    local tasks = mod._contract_data.tasks

    for _, task_type in ipairs(task_types) do
        for i, task in ipairs(tasks) do
            local counter = mod._live_counter
            local criteria = task.criteria
            local add_val = nil

            if not task.co_notified and criteria.taskType == task_type then
                if task_type == "KillBosses" then
                    add_val = counter.kill.boss
                elseif task_type == "KillMinions" then
                    local key = criteria.enemyType .. "_" .. criteria.weaponType
                    add_val = counter.kill[key]
                elseif task_type == "CollectResource" then
                    local key = criteria.resourceType or criteria.resourceTypes[1]
                    add_val = counter.resource[key]
                elseif task_type == "CollectPickup" then
                    add_val = counter.pickup
                elseif string.match(task_type, "CompleteMissions") then
                    add_val = 1
                end

                if add_val and criteria.value + add_val >= criteria.count then
                    if not disable_notification then
                        _create_notification(task, task_type, i)
                    end

                    tasks[i].co_notified = true
                end
            end
        end
    end
end

local _check_no_death_progress = function(new_data)
    local current_tasks = mod._contract_data.tasks

    for i, task in ipairs(current_tasks) do
        local criteria = task.criteria
        local task_type = criteria.taskType

        if task_type == "CompleteMissionsNoDeath" then
            local new_tasks = new_data.tasks
            local should_notify = new_tasks[i].fulfilled and not task.co_notified

            if live_update and notify_completion and should_notify then
                _create_notification(task, task_type, i)

                if debug_mode then
                    mod:echo("{#color(230,230,60)}no death count compensation{#reset()}")
                end
            end

            break
        end
    end
end

local _init_counter = function(tasks)
    mod._live_counter = mod:persistent_table("live_counter")

    if not table.is_empty(mod._live_counter) then
        for i, task in ipairs(tasks) do
            local task_types = { task.criteria.taskType }

            _check_task_progress(task_types, true)
        end

        return
    end

    local live_counter = mod._live_counter

    for _, task in ipairs(tasks) do
        if not task.rewarded then
            local criteria = task.criteria
            local task_type = criteria.taskType

            if task_type == "CollectResource" then
                local resource_type = criteria.resourceType or criteria.resourceTypes[1]

                if not live_counter.resource then
                    live_counter.resource = {}
                end

                live_counter.resource[resource_type] = 0
            elseif task_type == "CollectPickup" then
                live_counter.pickup = 0
            elseif task_type == "CompleteMissions" then
                live_counter.win = 0
            elseif task_type == "CompleteMissionsNoDeath" then
                live_counter.death = 1 -- set 0 when opening cinematic played
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

local _fetch_task_list = function()
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

    mod._contract_data = mod:persistent_table("contract_data")

    if not mod._contract_promise then
        mod._contract_promise = Managers.backend.interfaces.contracts:get_current_contract(character_id)

        if not mod._contract_promise then
            return
        end

        mod._contract_promise:next(function(data)
            mod._contract_promise = nil

            if not table.is_empty(mod._contract_data) then
                _check_no_death_progress(data)
            end

            mod._contract_data.tasks = data.tasks
            mod._update_tasks_list = true

            for i, task in ipairs(mod._contract_data.tasks) do
                if task.fulfilled then
                    mod._contract_data.tasks[i].co_notified = true
                end
            end

            if live_update then
                _init_counter(data.tasks)
            end

            if debug_mode then
                mod:echo("contract fetched")
                mod:dump(mod._contract_data, "contract", 4)
                --mod:echo("{#color(120,180,230)}Notification Test...{#reset()}")
                --mod._task_index = math.random(5)
                --Managers.contracts:notify_contract_task_complete(mod._contract_data.tasks[mod._task_index].id)
            end
        end):catch(function(e)
            mod:dump(e, "error__fetch_task_list", 3)
        end)
    end
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
        local param_loc = task_parameter_strings[task_criteria.pickupTypes]

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

    if task_type == "CollectResource" and mod._live_counter.resource then
        local resource_type = criteria.resourceType or criteria.resourceTypes[1]
        live_counter = mod._live_counter.resource[resource_type]
    elseif task_type == "KillBosses" and mod._live_counter.kill then
        live_counter = mod._live_counter.kill.boss
    elseif task_type == "KillMinions" and mod._live_counter.kill then
        local enemy_type = criteria.enemyType
        local weapon_type = criteria.weaponType
        live_counter = mod._live_counter.kill[enemy_type .. "_" .. weapon_type]
    end

    if live_counter then
        value = value + live_counter
    end

    return value
end

local _update_contract_list = function(self)
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

local _counter_update_notification = function(type, count)
    mod:echo("counter updated: " .. type .. " (" .. count .. ")")
end

-- ##############################
-- hooks
-- ##############################

-- update tactical overlay

mod:hook("HudElementTacticalOverlay", "init", function(func, ...)
    _fetch_task_list()
    Definitions = _get_new_definitions()

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
        _update_contract_list(self)
    end
end)

mod:hook_safe("HudElementTacticalOverlay", "_start_animation", function(self, animation_sequence_name)
    if animation_sequence_name == "enter" and mod._ready_to_update_tasks_list then
        if mod._contract_data and mod._contract_data.tasks then
            mod._update_tasks_list = true
            mod._ready_to_update_tasks_list = false
        else
            _fetch_task_list()
        end
    end
end)

-- update live counters and check progression

-- # Crafting Materials

mod:hook_safe("PickupSystem", "rpc_player_collected_materials", function(self, _, _, type_lookup, size_lookup)
    local type = NetworkLookup.material_type_lookup[type_lookup]
    local size = NetworkLookup.material_size_lookup[size_lookup]
    local amount = mod._materials_amount
    local resource_counter = mod._live_counter and mod._live_counter.resource
    local task_types = {}

    if table.is_empty(amount) then
        amount.large = 25
        amount.small = 10
    end

    if live_update and resource_counter and resource_counter[type] then
        resource_counter[type] = resource_counter[type] + amount[size]
        mod._update_tasks_list = true
        task_types[#task_types + 1] = "CollectResource"

        if notify_completion and not table.is_empty(task_types) then
            _check_task_progress(task_types)
        end

        if debug_mode then
            _counter_update_notification(type, resource_counter[type])
        end
    end
end)

-- # Side Objectives

mod:hook_safe("HudElementMissionObjectiveFeed", "_synchronize_widget_with_hud_objective", function(self, objective_name)
    if string.match(objective_name, "side_mission_") then
        local hud_objective = self._hud_objectives[objective_name]
        local current_amount = hud_objective:current_counter_amount()
        local pickup_counter = mod._live_counter and mod._live_counter.pickup

        if live_update and pickup_counter and current_amount then
            mod._live_counter.pickup = current_amount

            if debug_mode then
                _counter_update_notification("pickup", current_amount)
            end
        end
    end
end)

-- # Complete Missions (includes side objectives)

mod:hook_safe("UIManager", "close_view", function(self, view)
    if view == "cutscene_view" and mod._play_intro then
        local live_counter = mod._live_counter

        if live_update and live_counter and live_counter.death then
            live_counter.death = 0 -- fail no death challenge when late joined

            if debug_mode then
                mod:echo("reset death counter")
            end
        end
    end
end)

--[[
mod:hook_safe("ConstantElementChat", "cb_chat_manager_participant_removed", function(self)
    local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
    local live_counter = mod._live_counter

    if game_mode_name == "coop_complete_objective" and live_update and live_counter and live_counter.death then
        live_counter.death = live_counter.death + 1 -- fail no death challenge when player left and bot spawned

        if debug_mode then
            _counter_update_notification("player_death",  live_counter.death)
        end
    end
end)
]]

local track_player_death = function(func, self, ...)
    local component = self._character_state_component or self._character_state_read_component

    if component then
        local is_dead = PlayerUnitStatus.is_dead(component)

        if not self.co_player_died and is_dead then
            local live_counter = mod._live_counter

            if live_update and live_counter and live_counter.death then
                live_counter.death = live_counter.death + 1

                if debug_mode then
                    _counter_update_notification("player_death",  live_counter.death)
                end
            end
        end

        self.co_player_died = is_dead
    end

    func(self, ...)
end

mod:hook("PlayerUnitHealthExtension", "fixed_update", track_player_death)
mod:hook("PlayerHuskHealthExtension", "fixed_update", track_player_death)

mod:hook_safe("CinematicSceneExtension", "setup_from_component", function(self)
    local name = self._cinematic_name
    local live_counter = mod._live_counter
    local task_types = {}

    if name == "intro_abc" then
        mod._play_intro = true
    end

    if live_update and live_counter then
        if name == "outro_win" and notify_completion then
            if debug_mode then
                mod:echo("check tasks on mission end")
            end

            if live_counter.pickup then
                task_types[#task_types + 1] = "CollectPickup"
            end

            if live_counter.win then
                live_counter.win = 1
                task_types[#task_types + 1] = "CompleteMissions"

                if debug_mode then
                    _counter_update_notification("complete_mission",  1)
                end
            end

            if live_counter.death and live_counter.death == 0 then
                task_types[#task_types + 1] = "CompleteMissionsNoDeath"

                if debug_mode then
                    _counter_update_notification("no_death",  1)
                end
            end

            if not table.is_empty(task_types) then
                _check_task_progress(task_types)
            end
        end
    end
end)

-- # Kills

mod:hook_safe("AttackReportManager", "add_attack_result", function(self, _, unit, _, _, _, _, _, attack_result, attack_type)
    if attack_result ~= "died" then
        return
    end

    local kill_counter = mod._live_counter and mod._live_counter.kill

    if live_update and kill_counter then
        local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
        local breed = unit_data_extension and unit_data_extension:breed()
        local sub_faction = breed and breed.sub_faction_name
        local task_types = {}

        if not sub_faction then
            return
        end

        for task_type, count in pairs(kill_counter) do
            if task_type == "boss" then
                if breed.tags.monster or breed.tags.captain then
                    kill_counter.boss = count + 1
                    task_types[#task_types + 1] = "KillBosses"
                    mod._ready_to_update_tasks_list = true

                    if debug_mode then
                        _counter_update_notification(task_type,  kill_counter[task_type])
                    end
                end
            end

            if sub_faction ~= "chaos" and attack_type then
                if task_type == sub_faction .. "_" .. attack_type then
                    kill_counter[task_type] = count + 1
                    task_types[#task_types + 1] = "KillMinions"
                    mod._ready_to_update_tasks_list = true

                    if debug_mode then
                        _counter_update_notification(task_type, kill_counter[task_type])
                    end
                end
            end
        end

        if notify_completion and not table.is_empty(task_types) then
            _check_task_progress(task_types)
        end
    end
end)

-- Modify Notification

mod:hook("ConstantElementNotificationFeed", "_add_notification_message", function(func, self, type, data, cb, sound_event, ...)
    if type == "contract" then
        sound_event = "wwise/events/ui/play_hud_notifications_item_tier_1"
    end

    func(self, type, data, cb, sound_event, ...)
end)

mod:hook("ConstantElementNotificationFeed", "_create_notification_entry", function(func, self, data)
    local material_values = data.icon_material_values

    if material_values and material_values.contract_type then
        local tasks = mod._contract_data.tasks
        local index = mod._task_index

        if index then
            local criteria = tasks[index] and tasks[index].criteria
            local title = criteria and _get_task_description_and_target(criteria)

            if title then
                data.texts[1].display_name = title
            end

            mod._task_index = nil
        end
    end

    return func(self, data)
end)

-- Overlay in Hub

mod:hook_require("scripts/ui/hud/hud_elements_player_hub", function(elements)
    elements[#elements + 1] = {
        package = "packages/ui/hud/tactical_overlay/tactical_overlay",
        use_hud_scale = false,
        class_name = "HudElementTacticalOverlay",
        filename = "scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay",
        visibility_groups = {
            "tactical_overlay",
            "alive",
            "communication_wheel",
        }
    }
end)

-- DarkCache Compatibility

mod:hook_safe("EndView", "init", function()
    local cache = DarkCache and DarkCache.get_current_char_cache()
    local item = cache and cache:get("contracts_list")

    if item then
        item:expire()
        if debug_mode then
            mod:echo("Cleaned up contract cache (DarkCache Compatibility)")
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
    _get_materials_amount()
    recreate_hud()
end

mod.on_setting_changed = function()
    debug_mode = mod:get("enable_debug_mode")
    live_update = mod:get("enable_live_update")
    notify_completion = mod:get("enable_complete_notif")
    _get_materials_amount()
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
        mod._play_intro = nil
        mod._task_index = nil

        _get_materials_amount()

        if debug_mode then
            mod:echo("counter destroyed")
        end
    end
end
--[[
    title: InspectFromPartyFinder
    author: Zombine
    date: 2024/12/16
    version: 1.0.2
]]
local mod = get_mod("InspectFromPartyFinder")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local function player_request_terminal_button_change_function_inspect(content, style)
    local optional_hotspot_id = "inspect_hotspot"

    ButtonPassTemplates.terminal_button_change_function(content, style, optional_hotspot_id)
end

local function player_request_terminal_button_hover_change_function_inspect(content, style)
	local optional_hotspot_id = "inspect_hotspot"

	ButtonPassTemplates.terminal_button_hover_change_function(content, style, optional_hotspot_id)
end

mod:hook_require("scripts/ui/views/group_finder_view/group_finder_view_definitions", function(definitions)
    local pass_template = definitions.grid_blueprints.player_request_entry.pass_template

    if table.find_by_key(pass_template, "style_id", "inspect_hotspot") then
        return
    end

    local inspect_button = {
        {
            style_id = "inspect_hotspot",
            pass_type = "hotspot",
            content_id = "inspect_hotspot",
            content = {},
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "right",
                offset = {
                    -140,
                    0,
                    5
                },
                size = {
                    40,
                    40
                }
            },
            visibility_function = function (content, style)
                return not content.parent.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
        {
            pass_type = "texture",
            style_id = "inspect_background",
            value = "content/ui/materials/backgrounds/default_square",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "right",
                offset = {
                    -140,
                    0,
                    5
                },
                size = {
                    40,
                    40
                },
                default_color = Color.terminal_background(nil, true),
                selected_color = Color.terminal_background_selected(nil, true)
            },
            change_function = player_request_terminal_button_change_function_inspect,
            visibility_function = function (content, style)
                return not content.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
        {
            pass_type = "texture",
            style_id = "inspect_background_gradient",
            value = "content/ui/materials/gradients/gradient_vertical",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "right",
                offset = {
                    -140,
                    0,
                    6
                },
                size = {
                    40,
                    40
                },
                color = Color.terminal_background_gradient(nil, true)
            },
            change_function = player_request_terminal_button_hover_change_function_inspect,
            visibility_function = function (content, style)
                return not content.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
        {
            style_id = "inspect_icon",
            pass_type = "texture",
            value = "content/ui/materials/icons/system/escape/party_finder",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "right",
                offset = {
                    -140,
                    0,
                    7
                },
                size = {
                    40,
                    40
                }
            },
            visibility_function = function (content, style)
                return not content.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
        {
            pass_type = "texture",
            style_id = "inspect_frame",
            value = "content/ui/materials/frames/frame_tile_2px",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "right",
                offset = {
                    -140,
                    0,
                    7
                },
                size = {
                    40,
                    40
                },
                default_color = Color.terminal_frame(nil, true),
                selected_color = Color.terminal_frame_selected(nil, true)
            },
            change_function = player_request_terminal_button_change_function_inspect,
            visibility_function = function (content, style)
                return not content.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
        {
            pass_type = "texture",
            style_id = "inspect_corner",
            value = "content/ui/materials/frames/frame_corner_2px",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "right",
                offset = {
                    -140,
                    0,
                    8
                },
                size = {
                    40,
                    40
                },
                default_color = Color.terminal_corner(nil, true),
                selected_color = Color.terminal_corner_selected(nil, true)
            },
            change_function = player_request_terminal_button_change_function_inspect,
            visibility_function = function (content, style)
                return not content.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
        {
            style_id = "inspect_outer_shadow",
            pass_type = "texture",
            value = "content/ui/materials/frames/dropshadow_medium",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "right",
                offset = {
                    -130,
                    0,
                    8
                },
                size = {
                    40,
                    40
                },
                size_addition = {
                    20,
                    20
                },
                color = Color.black(200, true)
            },
            visibility_function = function (content, style)
                return not content.element.is_preview and Managers.ui:using_cursor_navigation()
            end
        },
    }

    table.append(pass_template, inspect_button)
end)

local _get_player_info = function(account_id)
    local social_service = Managers.data_service.social

    return account_id and social_service and social_service:get_player_info_by_account_id(account_id)
end

local _open_inventory = function(parent, player)
    parent._ifpf_peer_id = player:peer_id()
    parent._ifpf_local_player_id = player:local_player_id()

    Managers.ui:open_view("inventory_background_view", nil, nil, nil, nil, {
        is_readonly = true,
        player = player
    })
end

local _add_pressed_callback = function(self, hotspot, account_id)
    if hotspot and not hotspot.pressed_callback then
        hotspot.pressed_callback = callback(self, "cb_on_player_inspect_pressed", account_id)
    end
end

mod:hook_safe(CLASS.GroupFinderView, "init", function(self)
    self.cb_on_player_inspect_pressed = function(self, account_id)
        local player_info = account_id and _get_player_info(account_id)

        if player_info then
            local unique_id = player_info._player_unique_id
            local player = unique_id and Managers.player:player_from_unique_id(unique_id)

            if not player then
                player = table.clone_instance(player_info)
                player.local_player_id = function()
                    return 1
                end
                player.peer_id = function()
                    return Managers.player:local_player(1):peer_id()
                end
                player.name = player.character_name
            end

            if player and player.profile then
                local profile = player:profile()

                if profile then
                    _open_inventory(self, player)
                else
                    self._ifpf_queue = player
                end
            end
        end
    end
end)

-- listed_group

mod:hook_safe(CLASS.GroupFinderView, "_update_listed_group", function(self)
    local own_group = self._own_group_visualization
    local members = own_group.members
    local widgets = self._widgets_by_name

    for i = 1, #members do
        local member = members[i]

        if member then
            local widget = widgets["team_member_" .. i]
            local content = widget.content
            local hotspot = content.hotspot
            local account_id = member.account_id

            _add_pressed_callback(self, hotspot, account_id)
        end
    end
end)

-- preview_grid

mod:hook_safe(CLASS.GroupFinderView, "_populate_preview_grid", function(self)
    local grid = self._preview_grid
    local widgets = grid and grid:widgets()

    if widgets then
        for i = 1, #widgets do
            local widget = widgets[i]
            local content = widget.content
            local element = content.element
            local hotspot = content.hotspot
            local account_id = element and element.account_id

            _add_pressed_callback(self, hotspot, account_id)
        end
    end
end)

mod:hook_safe(CLASS.GroupFinderView, "update", function(self)
    if not Managers.player:player(self._ifpf_peer_id, self._ifpf_local_player_id) then
        if Managers.ui:view_active("inventory_background_view") then
            Managers.ui:close_view("inventory_background_view")
        end
    end

    if self._ifpf_queue then
        local player = self._ifpf_queue
        local profile = player:profile()

        if profile then
            _open_inventory(self, player)
            self._ifpf_queue = nil
        end
    end

    -- player_request_grid

    local grid = self._player_request_grid
    local widgets = grid and grid:widgets()

    if widgets then
        for i = 1, #widgets do
            local widget = widgets[i]
            local content = widget.content
            local element = content.element
            local hotspot = content.inspect_hotspot
            local account_id = element and element.account_id

            _add_pressed_callback(self, hotspot, account_id)
        end
    end
end)
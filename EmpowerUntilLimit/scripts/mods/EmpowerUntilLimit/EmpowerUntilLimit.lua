--[[
    name: EmpowerUntilLimit
    author: Zombine
    date: 2024/10/05
    version: 1.0.2
]]
local mod = get_mod("EmpowerUntilLimit")
local InputUtils = require("scripts/managers/input/input_utils")
local NotifSettings = require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_settings")

-- ##################################################
-- Adjust upgrade button
-- ##################################################

mod:hook_safe(CLASS.ViewElementCraftingRecipe, "init", function(self)
    local widget = self._widgets_by_name.continue_button_hold
    local passes = widget.passes

    widget.content.timer = 0.01
    mod._do_upgrade = false

    for i = 1, #passes do
        local pass_info = passes[i]

        if pass_info.value_id and pass_info.value_id == "text" then
            pass_info.change_function = function(content, style)
                local hotspot = content.hotspot

                if widget.visible and not hotspot.disabled then
                    local button_text = content.original_text or ""
                    local gamepad_action = content.input_action
                    local service_type = "View"
                    local alias_key = Managers.ui:get_input_alias_key(gamepad_action, service_type)
                    local input_text = InputUtils.input_text_for_current_input_device(service_type, alias_key)

                    content.text = string.format("{#color(226,199,126)}%s{#reset()} %s", input_text, button_text)
                end
            end

            break
        end
    end
end)

-- ##################################################
-- Countinuous upgrade
-- ##################################################

local _clear_notifications = function(force_clear)
    local constant_elements = Managers.ui._ui_constant_elements
    local elements = constant_elements._elements
    local notification = elements.ConstantElementNotificationFeed
    local num_notifications = #notification._notifications

    if force_clear or NotifSettings.max_visible_notifications <= num_notifications then
        Managers.event:trigger("event_clear_notifications")
    end
end

mod:hook_safe(CLASS.ViewElementCraftingRecipe, "set_continue_button_force_disabled", function(self, is_disabled)
    if not mod._do_upgrade and not is_disabled then
        mod._do_upgrade = true
        _clear_notifications()
    end
end)

mod:hook_safe(CLASS.CraftingMechanicusUpgradeExpertiseView, "update", function(self)
    if mod._do_upgrade and not self._craft_promise and self._crafting_recipe and self._crafting_recipe:can_craft() then
        mod._do_upgrade = false
        self:cb_on_main_button_pressed()
    end
end)
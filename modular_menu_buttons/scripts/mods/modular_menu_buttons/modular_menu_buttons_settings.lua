local mod = get_mod("modular_menu_buttons")

mod._state = {
    "main_menu",
    "hub",
    "shooting_range",
    "lobby",
    "coop_complete_objective",
}

mod._content_list = {
    {
        name = "credits_vendor_background_view",
        text = "loc_vendor_view_title",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/credits_store",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
    {
        name = "cosmetics_vendor_background_view",
        text = "loc_cosmetics_vendor_view_title",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/cosmetics_store",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
    {
        name = "contracts_background_view",
        text = "loc_marks_vendor_view_title",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/contracts",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
    {
        name = "crafting_view",
        text = "loc_crafting_view",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/forge",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
        }
    },
    {
        name = "mission_board_view",
        text = "loc_mission_board_view",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/mission_board",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
        }
    },
    {
        name = "training_grounds_view",
        text = "loc_training_ground_view",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/training_grounds",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
    {
        name = "barber_vendor_background_view",
        text = "loc_body_shop_view_display_name",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/barber",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
        }
    },
    {
        name = "store_view",
        text = "loc_store_view_display_name",
        type = "button",
        icon = "content/ui/materials/icons/system/escape/premium_store",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
}

mod._content_list_default = {
    {
        name = "inventory_background_view",
        text = "loc_character_view_display_name",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
        }
    },
    {
        name = "account_profile_view",
        text = "loc_achievements_view_display_name",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
    {
        name = "social_menu_view",
        text = "loc_social_view_display_name",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
    {
        name = "group_finder_view",
        text = "loc_group_finder_menu_title",
        group = {
            "main_menu",
            "hub",
            "shooting_range",
        }
    },
}

mod._content_list_main_menu = {
    {
        name = "credits_view",
        text = "loc_credits_view_title",
        group = {
            "main_menu",
        }
    },
    {
        name = "main_menu_view",
        text = "loc_exit_to_main_menu_display_name",
        group = {
            "hub",
            "shooting_range",
            "lobby",
            "coop_complete_objective",
        }
    },
}

local default = table.clone(mod._content_list_default)
local main_menu = table.clone(mod._content_list_main_menu)

mod._content_list_existed = table.append(default, main_menu)
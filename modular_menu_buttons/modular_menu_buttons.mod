return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`modular_menu_buttons` encountered an error loading the Darktide Mod Framework.")

		new_mod("modular_menu_buttons", {
			mod_script       = "modular_menu_buttons/scripts/mods/modular_menu_buttons/modular_menu_buttons",
			mod_data         = "modular_menu_buttons/scripts/mods/modular_menu_buttons/modular_menu_buttons_data",
			mod_localization = "modular_menu_buttons/scripts/mods/modular_menu_buttons/modular_menu_buttons_localization",
		})
	end,
	packages = {},
}

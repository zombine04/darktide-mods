return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`true_level` encountered an error loading the Darktide Mod Framework.")

		new_mod("true_level", {
			mod_script       = "true_level/scripts/mods/true_level/true_level",
			mod_data         = "true_level/scripts/mods/true_level/true_level_data",
			mod_localization = "true_level/scripts/mods/true_level/true_level_localization",
		})
	end,
	packages = {},
}

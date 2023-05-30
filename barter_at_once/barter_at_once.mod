return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`barter_at_once` encountered an error loading the Darktide Mod Framework.")

		new_mod("barter_at_once", {
			mod_script       = "barter_at_once/scripts/mods/barter_at_once/barter_at_once",
			mod_data         = "barter_at_once/scripts/mods/barter_at_once/barter_at_once_data",
			mod_localization = "barter_at_once/scripts/mods/barter_at_once/barter_at_once_localization",
		})
	end,
	packages = {},
}

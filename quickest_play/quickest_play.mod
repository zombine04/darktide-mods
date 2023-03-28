return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`quickest_play` encountered an error loading the Darktide Mod Framework.")

		new_mod("quickest_play", {
			mod_script       = "quickest_play/scripts/mods/quickest_play/quickest_play",
			mod_data         = "quickest_play/scripts/mods/quickest_play/quickest_play_data",
			mod_localization = "quickest_play/scripts/mods/quickest_play/quickest_play_localization",
		})
	end,
	packages = {},
}

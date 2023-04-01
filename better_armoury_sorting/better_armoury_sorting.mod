return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`better_armoury_sorting` encountered an error loading the Darktide Mod Framework.")

		new_mod("better_armoury_sorting", {
			mod_script       = "better_armoury_sorting/scripts/mods/better_armoury_sorting/better_armoury_sorting",
			mod_data         = "better_armoury_sorting/scripts/mods/better_armoury_sorting/better_armoury_sorting_data",
			mod_localization = "better_armoury_sorting/scripts/mods/better_armoury_sorting/better_armoury_sorting_localization",
		})
	end,
	packages = {},
}

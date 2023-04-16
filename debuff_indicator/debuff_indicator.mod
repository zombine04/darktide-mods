return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`debuff_indicator` encountered an error loading the Darktide Mod Framework.")

		new_mod("debuff_indicator", {
			mod_script       = "debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator",
			mod_data         = "debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator_data",
			mod_localization = "debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator_localization",
		})
	end,
	packages = {},
}

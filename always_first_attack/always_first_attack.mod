return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`always_first_attack` encountered an error loading the Darktide Mod Framework.")

		new_mod("always_first_attack", {
			mod_script       = "always_first_attack/scripts/mods/always_first_attack/always_first_attack",
			mod_data         = "always_first_attack/scripts/mods/always_first_attack/always_first_attack_data",
			mod_localization = "always_first_attack/scripts/mods/always_first_attack/always_first_attack_localization",
		})
	end,
	packages = {},
}

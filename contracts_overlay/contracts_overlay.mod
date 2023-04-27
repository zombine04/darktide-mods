return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`contracts_overlay` encountered an error loading the Darktide Mod Framework.")

		new_mod("contracts_overlay", {
			mod_script       = "contracts_overlay/scripts/mods/contracts_overlay/contracts_overlay",
			mod_data         = "contracts_overlay/scripts/mods/contracts_overlay/contracts_overlay_data",
			mod_localization = "contracts_overlay/scripts/mods/contracts_overlay/contracts_overlay_localization",
		})
	end,
	packages = {},
}

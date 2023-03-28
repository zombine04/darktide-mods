return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`buy_until_rating` encountered an error loading the Darktide Mod Framework.")

		new_mod("buy_until_rating", {
			mod_script       = "buy_until_rating/scripts/mods/buy_until_rating/buy_until_rating",
			mod_data         = "buy_until_rating/scripts/mods/buy_until_rating/buy_until_rating_data",
			mod_localization = "buy_until_rating/scripts/mods/buy_until_rating/buy_until_rating_localization",
		})
	end,
	packages = {},
}

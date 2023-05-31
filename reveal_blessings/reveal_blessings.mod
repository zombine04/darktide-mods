return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`reveal_blessings` encountered an error loading the Darktide Mod Framework.")

        new_mod("reveal_blessings", {
            mod_script       = "reveal_blessings/scripts/mods/reveal_blessings/reveal_blessings",
            mod_data         = "reveal_blessings/scripts/mods/reveal_blessings/reveal_blessings_data",
            mod_localization = "reveal_blessings/scripts/mods/reveal_blessings/reveal_blessings_localization",
        })
    end,
    packages = {},
}

return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`keep_dodging` encountered an error loading the Darktide Mod Framework.")

        new_mod("keep_dodging", {
            mod_script       = "keep_dodging/scripts/mods/keep_dodging/keep_dodging",
            mod_data         = "keep_dodging/scripts/mods/keep_dodging/keep_dodging_data",
            mod_localization = "keep_dodging/scripts/mods/keep_dodging/keep_dodging_localization",
        })
    end,
    packages = {},
}

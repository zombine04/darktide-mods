return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`RememberDifficulty` encountered an error loading the Darktide Mod Framework.")

        new_mod("RememberDifficulty", {
            mod_script       = "RememberDifficulty/scripts/mods/RememberDifficulty/RememberDifficulty",
            mod_data         = "RememberDifficulty/scripts/mods/RememberDifficulty/RememberDifficulty_data",
            mod_localization = "RememberDifficulty/scripts/mods/RememberDifficulty/RememberDifficulty_localization",
        })
    end,
    packages = {},
}

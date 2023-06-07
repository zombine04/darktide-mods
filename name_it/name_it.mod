return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`name_it` encountered an error loading the Darktide Mod Framework.")

        new_mod("name_it", {
            mod_script       = "name_it/scripts/mods/name_it/name_it",
            mod_data         = "name_it/scripts/mods/name_it/name_it_data",
            mod_localization = "name_it/scripts/mods/name_it/name_it_localization",
        })
    end,
    packages = {},
}

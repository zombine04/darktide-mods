return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`SpawnFeed` encountered an error loading the Darktide Mod Framework.")

        new_mod("SpawnFeed", {
            mod_script       = "SpawnFeed/scripts/mods/SpawnFeed/SpawnFeed",
            mod_data         = "SpawnFeed/scripts/mods/SpawnFeed/SpawnFeed_data",
            mod_localization = "SpawnFeed/scripts/mods/SpawnFeed/SpawnFeed_localization",
        })
    end,
    packages = {},
}

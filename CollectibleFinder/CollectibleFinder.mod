return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`CollectibleFinder` encountered an error loading the Darktide Mod Framework.")

        new_mod("CollectibleFinder", {
            mod_script       = "CollectibleFinder/scripts/mods/CollectibleFinder/CollectibleFinder",
            mod_data         = "CollectibleFinder/scripts/mods/CollectibleFinder/CollectibleFinder_data",
            mod_localization = "CollectibleFinder/scripts/mods/CollectibleFinder/CollectibleFinder_localization",
        })
    end,
    packages = {},
}

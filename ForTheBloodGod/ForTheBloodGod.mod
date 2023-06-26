return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`ForTheBloodGod` encountered an error loading the Darktide Mod Framework.")

        new_mod("ForTheBloodGod", {
            mod_script       = "ForTheBloodGod/scripts/mods/ForTheBloodGod/ForTheBloodGod",
            mod_data         = "ForTheBloodGod/scripts/mods/ForTheBloodGod/ForTheBloodGod_data",
            mod_localization = "ForTheBloodGod/scripts/mods/ForTheBloodGod/ForTheBloodGod_localization",
        })
    end,
    packages = {},
}

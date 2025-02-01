return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`DPSMeter` encountered an error loading the Darktide Mod Framework.")

        new_mod("DPSMeter", {
            mod_script       = "DPSMeter/scripts/mods/DPSMeter/DPSMeter",
            mod_data         = "DPSMeter/scripts/mods/DPSMeter/DPSMeter_data",
            mod_localization = "DPSMeter/scripts/mods/DPSMeter/DPSMeter_localization",
        })
    end,
    packages = {},
}

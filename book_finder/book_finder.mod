return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`book_finder` encountered an error loading the Darktide Mod Framework.")

        new_mod("book_finder", {
            mod_script       = "book_finder/scripts/mods/book_finder/book_finder",
            mod_data         = "book_finder/scripts/mods/book_finder/book_finder_data",
            mod_localization = "book_finder/scripts/mods/book_finder/book_finder_localization",
        })
    end,
    packages = {},
}

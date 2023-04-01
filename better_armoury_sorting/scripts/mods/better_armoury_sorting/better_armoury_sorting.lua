--[[
    title: better_armoury_sorting
    author: Zombine
    date: 02/04/2023
    version: 1.0.0
]]

local mod = get_mod("better_armoury_sorting")

mod:hook("CreditsGoodsVendorView", "_convert_offers_to_layout_entries", function(func, self, item_offers)
    local layout = func(self, item_offers)

    table.sort(layout, function (a, b)
        return b.icon < a.icon
    end)

    return layout
end)

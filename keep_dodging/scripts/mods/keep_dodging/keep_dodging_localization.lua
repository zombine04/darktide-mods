local loc = {
    mod_name = {
        en = "Keep Dodging",
    },
    mod_description = {
        en = "While the mod is active, moving left, right, or backward trigger dodging.",
    },
    key_hold = {
        en = "Hold Key",
        ja = "長押しキー",
    },
    key_toggle = {
        en = "Toggle Key",
        ja = "切り替えキー",
    },
    enable_on_start = {
        en = "Enable on Game Start",
        ja = "開始時点で有効にする",
    },
    icon_settings = {
        en = "Icon Settings",
        ja = "アイコン設定",
    },
    enable_icon = {
        en = "Enable Icon",
        ja = "アイコンを表示する",
    },
    icon_size = {
        en = "Size",
        ja = "大きさ",
    },
    color_enabled = {
        en = "Color (Enabled)",
        ja = "カラー (有効時)",
    },
    color_disabled = {
        en = "Color (Disabled)",
        ja = "カラー (無効時)",
    },
    opacity_enabled = {
        en = "Opacity (Enabled)",
        ja = "不透明度 (有効時)",
    },
    opacity_disabled = {
        en = "Opacity (Disabled)",
        ja = "不透明度 (無効時)",
    },
    position_x = {
        en = "Position: X",
        ja = "位置：X",
    },
    position_y = {
        en = "Position: Y",
        ja = "位置：Y",
    }
}

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    loc[name] = {}
    loc[name].en = text
end

return loc
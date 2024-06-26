local stationary_dodge = Localize("loc_setting_stationary_dodge")
local sd_desc = Localize("loc_setting_stationary_dodge_desc")

local loc = {
    mod_name = {
        en = "Keep Dodging",
        ["zh-cn"] = "连续闪避",
    },
    mod_description = {
        en = "While the mod is active, moving left, right, or backward trigger dodging.",
        ja = "有効状態の間、左右や後ろに移動するとドッジが発動します。",
        ["zh-cn"] = "模组启用时，向左、向右或向后移动触发闪避。",
    },
    key_hold = {
        en = "Hold Key",
        ja = "長押しキー",
        ["zh-cn"] = "按住快捷键",
    },
    key_toggle = {
        en = "Toggle Key",
        ja = "切り替えキー",
        ["zh-cn"] = "切换快捷键",
    },
    enable_on_start = {
        en = "Enable on Game Start",
        ja = "開始時点で有効にする",
        ["zh-cn"] = "游戏启动时启用",
    },
    enable_stationary_dodge = {
        en = stationary_dodge,
    },
    stationary_dodge_tooltip = {
        en = "This is synced with \"" .. stationary_dodge .. "\" option in Options -> Inputs." .. "\n\n" .. sd_desc,
        ja = "これは「オプション」の「入力」にある「" .. stationary_dodge .. "」の設定と同期しています。" .. "\n\n" .. sd_desc,
        ["zh-cn"] = "与“选项 -> 输入”中的“" .. stationary_dodge .. "”选项同步。\n\n" .. sd_desc,
    },
    disable_sd_while_active = {
        en = "Disable " .. stationary_dodge .. " while the mod is active",
        ja = "Modが有効な間は" .. stationary_dodge .. "を無効化する",
        ["zh-cn"] = "启用模组时，禁用" .. stationary_dodge,
    },
    icon_settings = {
        en = "Icon Settings",
        ja = "アイコン設定",
        ["zh-cn"] = "图标设置",
    },
    enable_icon = {
        en = "Enable Icon",
        ja = "アイコンを表示する",
        ["zh-cn"] = "启用图标",
    },
    icon_size = {
        en = "Size",
        ja = "大きさ",
        ["zh-cn"] = "大小",
    },
    color_enabled = {
        en = "Color (Enabled)",
        ja = "カラー (有効時)",
        ["zh-cn"] = "颜色（启用时）",
    },
    color_disabled = {
        en = "Color (Disabled)",
        ja = "カラー (無効時)",
        ["zh-cn"] = "颜色（禁用时）",
    },
    opacity_enabled = {
        en = "Opacity (Enabled)",
        ja = "不透明度 (有効時)",
        ["zh-cn"] = "不透明度（启用时）",
    },
    opacity_disabled = {
        en = "Opacity (Disabled)",
        ja = "不透明度 (無効時)",
        ["zh-cn"] = "不透明度（禁用时）",
    },
    position_x = {
        en = "Position: X",
        ja = "位置：X",
        ["zh-cn"] = "位置：X",
    },
    position_y = {
        en = "Position: Y",
        ja = "位置：Y",
        ["zh-cn"] = "位置：Y",
    }
}

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    loc[name] = { en = text }
end

return loc

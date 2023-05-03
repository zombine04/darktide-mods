local mod = get_mod("always_first_attack")

local loc = {
    mod_name = {
        en = "Always First Attack",
        ["zh-cn"] = "连续第一刀攻击",
    },
    mod_description = {
        en = "Before the second attack is initiated, quickly swap your weapon for breaking attack chain. ",
        ja = "2回目の攻撃直前に武器を切り替えて攻撃チェーンを中断します。",
        ["zh-cn"] = "在第二刀攻击开始之前，快速切换武器以打断攻击连招。",
    },
    enable_on_start = {
        en = "Enable on mission start",
        ja = "ミッション開始時点で有効にする",
        ["zh-cn"] = "任务开始时启用",
    },
    key_toggle = {
        en = "Toggle ON/OFF",
        ja = "キーバインド：オン/オフ",
        ["zh-cn"] = "开关快捷键",
    },
    enable_on_missed_swing = {
        en = "Trigger on missed swings",
        ja = "空振りでも発動させる",
        ["zh-cn"] = "挥空时触发",
    },
    auto_swing = {
        en = "Auto Swing",
        ja = "自動攻撃",
        ["zh-cn"] = "自动挥舞",
    },
    enable_auto_swing = {
        en = "Enable Auto Swing",
        ja = "自動攻撃を有効にする",
        ["zh-cn"] = "启用自动挥舞",
    },
    auto_swing_desc = {
        en = "If enabled, automatically spamming light attack after the first swing.\n\n" ..
             "Can be canceled by specific actions, such as heavy attack, block, combat ability etc.\n\n" ..
             "Note:\nDepending on the weapon, it may not be canceled due to attack speed or damage profile differences.\n" ..
             "Switching to another slot or using toggle keys will certainly cancel it.",
        ja = "有効な場合、最初の攻撃以降自動的に弱攻撃を連打します。\n\n" ..
             "重攻撃やブロック、戦闘アビリティなど特定の行動でキャンセルされます。\n\n" ..
             "注意：\n武器によっては、攻撃速度やダメージプロファイルの違いによりキャンセルされないことがあります。\n" ..
             "他のスロットへ切り替えたり、切り替えキーを使えば確実にキャンセルできます。",
        ["zh-cn"] = "如果启用，则首次挥舞后自动连续轻攻击。\n\n" ..
             "会被特定操作打断，例如重攻击、格挡、主动技能等。\n\n" ..
             "注意：\n根据使用武器攻击速度或伤害模式的不同，可能不会触发打断。\n" ..
             "但切换到其他武器或使用开关快捷键能保证成功打断。",
    },
    key_toggle_auto = {
        en = "Toggle Auto Swing",
        ja = "キーバインド：自動攻撃の切り替え",
        ["zh-cn"] = "开关自动挥舞快捷键",
    },
    enable_auto_start = {
        en = "Start swinging on enabled",
        ja = "有効化時に攻撃を始める",
        ["zh-cn"] = "启用时开始挥舞",
    },
    indicator = {
        en = "Indicator",
        ja = "インジケーター",
        ["zh-cn"] = "指示器",
    },
    enable_indicator = {
        en = "Enable Indicator",
        ja = "インジケーターを有効にする",
        ["zh-cn"] = "启用指示器",
    },
    indicator_desc = {
        en = "Display a small icon to indicate the mod or auto-swing is currently active.",
        ja = "Modや自動攻撃が現在有効かを示す小さなアイコンを表示します。",
        ["zh-cn"] = "显示一个小图标表示此模组或自动挥舞已激活。",
    },
	icon_size = {
		en = "Size",
		ja = "大きさ",
		["zh-cn"] = "大小",
	},
    color_auto_swing_enabled = {
        en = "Color (Auto Swing Enabled)",
        ja = "カラー (自動攻撃有効時)",
        ["zh-cn"] = "颜色（自动挥舞启用时）",
    },
    color_auto_swing_disabled = {
        en = "Color (Auto Swing Disabled)",
        ja = "カラー (自動攻撃無効時)",
        ["zh-cn"] = "颜色（自动挥舞禁用时）",
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
    },
	debug_mode = {
		en = "Debug",
		ja = "デバッグ",
		["zh-cn"] = "调试",
		ru = "Отладка",
	},
	enable_debug_mode = {
		en = "Enable Debug Mode",
		ja = "デバッグモードを有効にする",
		["zh-cn"] = "启用调试模式",
		ru = "Включить режим отладки",
	},
}

local list = Color.list

for _, name in ipairs(list) do
    local color = Color[name](255, true)

    loc[name] = {
        en = "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. name .. "{#reset()}"
    }
end

return loc

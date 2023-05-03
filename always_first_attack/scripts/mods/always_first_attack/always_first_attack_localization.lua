local mod = get_mod("always_first_attack")

local loc = {
    mod_name = {
        en = "Always First Attack",
    },
    mod_description = {
        en = "Before the second attack is initiated, quickly swa pyour weapon for breaking attack chain. ",
        ja = "2回目の攻撃直前に武器を切り替えて攻撃チェーンを中断します。",
    },
    enable_on_start = {
        en = "Enable on mission start",
        ja = "ミッション開始時点で有効にする",
    },
    key_toggle = {
        en = "Toggle ON/OFF",
        ja = "キーバインド：オン/オフ",
    },
    toggle_desc = {
        en = "Note:\nAs long as the mod isn't disabled in the toggle menu, it's always enabled at start of missions.",
        ja = "注意：\nトグルメニューからこのModを無効化しない限り、ミッション開始時には常に有効になります。",
    },
    proc_timing = {
        en = "Trigger",
        ja = "発動条件",
    },
    proc_timing_desc = {
        en = "On sweep finish:\nEffective against multiple targets. Triggered even if no hits are made.\n\n" ..
             "On hit:\nEffective against single targets. Always triggered on first hit. Not triggered if no hits are made.",
        ja = "振り終わり：\n複数の敵相手に最適です。ヒットがなくても発動します。\n\n" ..
             "ヒット時：\n単体の敵相手に最適です。常に最初のヒットで発動します。ヒットがない場合は発動しません。"
    },
    on_sweep_finish = {
        en = "On sweep finish",
        ja = "振り終わり",
    },
    on_hit = {
        en = "On hit",
        ja = "ヒット時",
    },
    enable_on_missed_swing = {
        en = "Trigger on missed swings",
        ja = "空振りでも発動させる",
    },
    breakpoint = {
        en = "Breakpoint",
        ja = "ブレイクポイント",
    },
    breakpoint_desc = {
        en = "Adjust how many times you're able to attack before swapping.",
        ja = "切り替え発動までに何回攻撃できるかを設定します。",
    },
    auto_swing = {
        en = "Auto Swing",
        ja = "自動攻撃",
    },
    enable_auto_swing = {
        en = "Enable Auto Swing",
        ja = "自動攻撃を有効にする",
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
    },
    key_toggle_auto = {
        en = "Toggle Auto Swing",
        ja = "キーバインド：自動攻撃の切り替え",
    },
    enable_auto_start = {
        en = "Start swinging on enabled",
        ja = "有効化時に攻撃を始める",
    },
    indicator = {
        en = "Indicator",
        ja = "インジケーター",
    },
    enable_indicator = {
        en = "Enable Indicator",
        ja = "インジケーターを有効にする",
    },
    indicator_desc = {
        en = "Display a small icon to indicate the mod or auto-swing is currently active.",
        ja = "Modや自動攻撃が現在有効かを示す小さなアイコンを表示します。",
    },
	icon_size = {
		en = "Size",
		ja = "大きさ",
		["zh-cn"] = "大小",
	},
    color_auto_swing_enabled = {
        en = "Color (Auto Swing Enabled)",
        ja = "カラー (自動攻撃有効時)",
    },
    color_auto_swing_disabled = {
        en = "Color (Auto Swing Disabled)",
        ja = "カラー (自動攻撃無効時)",
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
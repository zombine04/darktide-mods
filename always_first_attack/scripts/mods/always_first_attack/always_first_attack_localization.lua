return {
    mod_name = {
        en = "Always First Attack",
    },
    mod_description = {
        en = "Break attack chain after the first attack.",
        ja = "最初の攻撃後に攻撃チェーンを中断します。",
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
        en = "On Sweep Finish:\nEffective against multiple targets. Triggered even if no hits are made.\n\n" ..
             "On Hit:\nEffective against single targets. Always triggered on first hit. Not triggered if no hits are made.",
        ja = "振り終わり：\n複数の敵相手に最適です。ヒットがなくても発動します。\n\n" ..
             "ヒット時：\n単体の敵相手に最適です。常に最初のヒットで発動します。ヒットがない場合は発動しません。"
    },
    on_sweep_finish = {
        en = "On Sweep Finish",
        ja = "振り終わり",
    },
    on_hit = {
        en = "On Hit",
        ja = "ヒット時",
    },
    enable_on_missed_swing = {
        en = "Trigger on missed swings",
        ja = "空振りでも発動させる",
    },
    enable_auto_swing = {
        en = "Enable Auto Swing",
        ja = "自動攻撃を有効にする",
    },
    auto_swing_desc = {
        en = "If enabled, automatically spamming light attack after the first swing.\n\n" ..
             "Can be canceled by specific actions, such as heavy attack, block, hold interaction, etc.\n\n" ..
             "Note:\nDepending on the weapon, it may not be canceled due to attack speed or damage profile differences.\n" ..
             "Switching to another slot or using toggle keys will certainly cancel it.",
        ja = "有効な場合、最初の攻撃以降自動的に弱攻撃を連打します。\n\n" ..
             "重攻撃やブロック、長押しインタラクトなど特定の行動でキャンセルされます。\n\n" ..
             "注意：\n武器によっては、攻撃速度やダメージプロファイルの違いによりキャンセルされないことがあります。\n" ..
             "他のスロットへ切り替えたり、切り替えキーを使えば確実にキャンセルできます。",
    },
    key_toggle_auto = {
        en = "Toggle Auto Swing",
        ja = "キーバインド：自動攻撃の切り替え",
    },
	enable_debug_mode = {
		en = "Enable Debug Mode",
		ja = "デバッグモードを有効にする",
		["zh-cn"] = "启用调试模式",
		ru = "Включить режим отладки",
	},
}

local mod = get_mod("CollectibleFinder")

mod._collectibles = {
    {
        name = "grimoire",
        loc = "loc_pickup_side_mission_pocketable_01",
        hud_icon = "content/ui/materials/icons/pocketables/hud/grimoire",
        is_side_objective = true,
        is_counted_at_pickup = true,
    },
    {
        name = "tome",
        loc = "loc_pickup_side_mission_pocketable_02",
        hud_icon = "content/ui/materials/icons/pocketables/hud/scripture",
        is_side_objective = true,
        is_counted_at_pickup = true,
    },
    {
        name = "collectible_01_pickup", -- Martyr's Skull
        loc = "loc_pickup_collectible",
        hud_icon = "content/ui/materials/icons/achievements/categories/category_endeavour",
    },
    {
        name = "idol",
        loc = "loc_destructible_01",
        hud_icon = "content/ui/materials/icons/achievements/categories/category_heretics",
        is_destructible = true,
    },
    {
        name = "skulls_01_pickup", -- Tainted Skull
        loc = "loc_tainted_skull_pickup",
        hud_icon = "content/ui/materials/hud/interactions/icons/enemy",
        is_destructible = true,
        disable_by_default = true,
    },
    {
        name = "communications_hack_device",
        loc = "loc_pickup_side_mission_communications_hack_device",
        hud_icon = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
        is_side_objective = true,
        -- it doesn't proceed when picking up
    },
}

mod:add_global_localize_strings({
    loc_destructible_01 = {
        en = "Heretical Idol",
        ja = "異端の偶像",
        ["zh-cn"] = "异端雕像",
        ru = "Еретический идол",
    }
})

local loc = {
    mod_name = {
        en = "Collectible Finder",
        ["zh-cn"] = "收集物搜寻",
        ru = "Поисковик собираемых предметов",
    },
    mod_description = {
        en = "Displays a notification once you are within a certain distance from the collectibles.",
        ja = "コレクタブルから一定距離内に入った際に通知を表示します。",
        ["zh-cn"] = "进入收集物一定范围内时，显示一条通知。",
        ru = "Collectible Finder - Отображает уведомление, когда вы находитесь на определённом расстоянии от предметов, которые можно собрать.",
    },
    toggle = {
        en = "Toggle",
        ja = "切り替え",
        ["zh-cn"] = "开关",
        ru = "Переключатели",
    },
    details = {
        en = "Detailed Settings",
        ja = "詳細設定",
        ["zh-cn"] = "详细设置",
        ru = "Подробные настройки",
    },
    type_notif = {
        en = "Notification",
        ja = "通知",
        ["zh-cn"] = "通知",
        ru = "Уведомления",
    },
    type_chat = {
        en = "Chat",
        ja = "チャット",
        ["zh-cn"] = "聊天栏",
        ru = "Чат",
    },
    type_both = {
        en = "Both",
        ja = "両方",
        ["zh-cn"] = "全部",
        ru = "Всё",
    },
    collectible_sensed = {
        en = "Feel the presence of %s%s nearby...",
        ja = "%s%sの気配を近くに感じる...",
        ["zh-cn"] = "感应到附近有%s%s的存在...",
        ru = "Чувствую, что где-то рядом %s%s...",
    },
    collectible_destructed = {
        en = "%s destroyed %s.",
        ja = "%sが%sを破壊した。",
        ["zh-cn"] = "%s破坏了%s。",
        ru = "%s уничтожает %s.",
    },
    collectible_picked_up = {
        en = "%s picked up %s.",
        ja = "%sが%sを拾った。",
        ["zh-cn"] = "%s拾取了%s。",
        ru = "%s подбирает %s.",
    },
    collectible_dropped = {
        en = "%s dropped %s.",
        ja = "%sが%sを落とした。",
        ["zh-cn"] = "%s丢弃了%s。",
        ru = "%s выбрасывает %s.",
    },
    collectible_given = {
        en = "%s passed %s to %s.",
        ja = "%sが%sを%sに渡した。",
        ["zh-cn"] = "%s将%s赠送给了%s",
        ru = "%s передаёт %s %s.",
    },
    debug = {
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

local settings = {
    search_distance = {
        en = "Search Distance",
        ja = "感知範囲",
        ["zh-cn"] = "感应范围",
        ru = "Расстояние поиска",
    },
    enable_icon_indicator = {
        en = "Icon Indicator",
        ja = "アイコン表示",
        ["zh-cn"] = "图标指示器",
        ru = "Иконка индикатора",
    },
    icon_size = {
        en = "Size",
        ja = "大きさ",
        ["zh-cn"] = "大小",
        ru = "Размер",
    },
    icon_color = {
        en = "Color",
        ja = "色",
        ["zh-cn"] = "颜色",
        ru = "Цвет",
    },
    notif_type = {
        en = "Notification Type",
        ja = "通知方法",
        ["zh-cn"] = "通知方式",
        ru = "Тип уведомлений",
    },
    enable_destruct_notif = {
        en = "Destroy",
        ja = "破壊",
        ["zh-cn"] = "破坏",
        ru = "Уничтожение",
    },
    enable_pickup_notif = {
        en = "Pick Up",
        ja = "拾う",
        ["zh-cn"] = "拾取",
        ru = "Подбор",
    },
    enable_drop_notif = {
        en = "Drop / Discard",
        ja = "落とす / 破棄",
        ["zh-cn"] = "丢弃 / 摧毁",
        ru = "Выбрасывание",
    },
    enable_give_notif = {
        en = "Give",
        ja = "渡す",
        ["zh-cn"] = "赠送",
        ru = "Передача",
    },
    enable_repeat_notif = {
        en = "Repeat Notification",
        ja = "繰り返し通知",
        ["zh-cn"] = "重复通知",
        ru = "Повторение уведомления",
    },
    enable_sound_cue = {
        en = "Additional Notification Sound",
        ja = "追加の通知音",
        ["zh-cn"] = "额外通知音效",
        ru = "Дополнительный звук уведомления",
    },
    sound_cue = {
        en = "Notification Sound",
        ja = "通知音",
        ["zh-cn"] = "通知音效",
        ru = "Звук уведомления",
    },
}

for _, collectible in ipairs(mod._collectibles) do
    loc[collectible.name] = {
        en = "    " .. Localize(collectible.loc)
    }
    loc["enable_" .. collectible.name] = {
        en = Localize(collectible.loc)
    }

    for key, vals in pairs(settings) do
        loc[key .. "_" .. collectible.name] = vals
    end
end

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    loc[name] = { en = text }
end

return loc

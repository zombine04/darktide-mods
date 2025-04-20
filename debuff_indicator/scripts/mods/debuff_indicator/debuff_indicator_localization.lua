local mod = get_mod("debuff_indicator")
local Breeds = require("scripts/settings/breed/breeds")

mod.buff_names = {
    "bleed",
    "flamer_assault",
    "rending_debuff",
    "warp_fire",
    "increase_impact_received_while_staggered",
    "increase_damage_received_while_staggered",
    "psyker_protectorate_spread_chain_lightning_interval_improved",
    "psyker_protectorate_spread_charged_chain_lightning_interval_improved",
    "psyker_force_staff_quick_attack_debuff",
    "ogryn_recieve_damage_taken_increase_debuff",
    "ogryn_taunt_increased_damage_taken_buff",
    "ogryn_staggering_damage_taken_increase",
    "veteran_improved_tag_debuff",
    "power_maul_sticky_tick",
    "increase_damage_taken"
    -- "stagger",
    -- "suppression",
}

mod.keywords = {
    "electrocuted"
}

mod.merged_buffs = {
    psyker_protectorate_spread_charged_chain_lightning_interval_improved = "psyker_protectorate_spread_chain_lightning_interval_improved",
}

mod.display_style_names = {
    "both",
    "label",
    "count",
}

mod.mutators = {
    chaos_armored_infected = "chaos_newly_infected",
    chaos_hound_mutator = "chaos_hound",
    chaos_lesser_mutated_poxwalker = "chaos_poxwalker",
    chaos_mutated_poxwalker = "chaos_poxwalker",
    chaos_mutator_daemonhost = "chaos_daemonhost",
    chaos_mutator_ritualist = "cultist_ritualist",
    cultist_mutant_mutator = "cultist_mutant",
}

local loc = {
    mod_name = {
        en = "Debuff Indicator",
        ["zh-cn"] = "负面效果指示器",
        ru = "Индикатор дебаффов",
    },
    mod_description = {
        en = "Display debuffs applied to each enemy and their stacks.",
        ja = "敵に付与されたデバフとそのスタック数を表示します。",
        ["zh-cn"] = "显示敌人受到的负面效果和层数",
        ru = "Debuff Indicator - Отображает дебаффы и количество их зарядов, применённых к каждому врагу.",
    },
    display_style = {
        en = "Display style",
        ja = "表示スタイル",
        ["zh-cn"] = "显示样式",
        ru = "Стиль отображения",
    },
    display_style_options = {
        en = "\nBoth:\nShow debuff name and stack count." ..
             "\n\nLabel:\nShow debuff name only." ..
             "\n\nCount:\nShow stack count only (recommend to use with custom colors) .",
        ja = "\n両方:\nデバフ名とスタック数を表示します。" ..
             "\n\nラベル:\nデバフ名のみを表示します。" ..
             "\n\nカウント:\nスタック数のカウントのみを表示します。 (カスタムカラーとの併用を推奨) .",
        ["zh-cn"] = "\n全部:\n显示负面效果名称和层数。" ..
             "\n\n名称:\n只显示负面效果名称。" ..
             "\n\n层数:\n只显示层数（建议同时设置自定义颜色）。",
        ru = "\nВсё:\nПоказывать название дебаффа и счётчик стаков." ..
             "\n\nНазвание:\nПоказывать только название дебаффа." ..
             "\n\nСчётчик:\nПоказывать только счётчик стаков (рекомендуется использовать с пользовательскими цветами).",
    },
    display_style_both = {
        en = "Both",
        ja = "両方",
        ["zh-cn"] = "全部",
        ru = "Всё",
    },
    display_style_label = {
        en = "Label",
        ja = "ラベル",
        ["zh-cn"] = "名称",
        ru = "Название",
    },
    display_style_count = {
        en = "Count",
        ja = "カウント",
        ["zh-cn"] = "层数",
        ru = "Счётчик",
    },
    key_cycle_style = {
        en = "Keybind: Cycle styles",
        ja = "キーバインド：次のスタイル",
        ["zh-cn"] = "快捷键：下一个样式",
        ru = "Клавиша: Переключение стилей",
    },
    enable_filter = {
        en = "Display major debuffs only",
        ja = "主要なデバフのみ表示する",
        ["zh-cn"] = "仅显示主要负面效果",
        ru = "Отображать только главные дебаффы",
    },
    filter_disabled = {
        en = "Display all internal buff and debuff if disabled.",
        ja = "無効にした場合、すべての内部的なバフやデバフが表示されます。",
        ["zh-cn"] = "如果禁用，则会显示所有内部增益和减益。",
        ru = "Отображает все внутренние баффы и дебаффы, если отключено.",
    },
    distance = {
        en = "Max distance",
        ja = "最大表示距離",
        ["zh-cn"] = "最大显示距离",
        ru = "Максимальное расстояние",
    },
    display_group = {
        en = "What to display",
        ja = "表示対象",
        ["zh-cn"] = "显示对象",
        ru = "Что показывается",
    },
    debuff = {
        en = "Debuff",
        ja = "デバフ",
        ["zh-cn"] = "负面效果",
        ru = "Дебафф",
    },
    dot = {
        en = "Damage over Time",
        ja = "継続ダメージ",
        ["zh-cn"] = "持续伤害",
        ru = "Урон с течением времени",
    },
    enable_stagger = {
        en = "Stagger",
        ja = "よろめき",
        ["zh-cn"] = "踉跄",
        ru = "Ошеломление",
    },
    enable_suppression = {
        en = "Suppression",
        ja = "サプレション",
        ["zh-cn"] = "压制",
        ru = "Подавление",
    },
    font = {
        en = "Font style",
        ja = "フォントスタイル",
        ["zh-cn"] = "字体样式",
        ru = "Стиль шрифта",
    },
    font_size = {
        en = "Size",
        ja = "大きさ",
        ["zh-cn"] = "大小",
        ru = "Размер",
    },
    font_opacity = {
        en = "Opacity",
        ja = "不透明度",
        ["zh-cn"] = "不透明度",
        ru = "Прозрачность",
    },
    offset_z = {
        en = "Position (height)",
        ja = "表示位置 (高さ)",
        ["zh-cn"] = "位置（高度）",
        ru = "Положение (высота)",
    },
    toggle = {
        en = "Toggle",
        ja = "切り替え",
        ["zh-cn"] = "开关",
        ru = "Переключатели",
    },
    custom_color = {
        en = "Custom color",
        ja = "カスタムカラー",
        ["zh-cn"] = "自定义颜色",
        ru = "Пользовательские цвета",
    },
    color = {
        en = "Color",
        ja = "色",
        ["zh-cn"] = "颜色",
        ru = "цвета",
    },
    color_r = {
        en = "R",
        ["zh-cn"] = "红",
        ru = "Красный",
    },
    color_g = {
        en = "G",
        ["zh-cn"] = "绿",
        ru = "Зелёный",
    },
    color_b = {
        en = "B",
        ["zh-cn"] = "蓝",
        ru = "Синий",
    },
    breed_minion = {
        en = "Roamers",
        ja = "通常敵",
        ["zh-cn"] = "普通敌人",
        ru = "Бродяги",
    },
    breed_elite = {
        en = "Elites",
        ja = "上位者",
        ["zh-cn"] = "精英",
        ru = "Элита",
    },
    breed_specialist = {
        en = "Specialists",
        ja = "スペシャリスト",
        ["zh-cn"] = "专家",
        ru = "Специалисты",
    },
    breed_monster = {
        en = "Monstrosities",
        ja = "バケモノ",
        ["zh-cn"] = "怪物",
        ru = "Монстры",
    },
    breed_captain = {
        en = "Captains",
        ja = "キャプテン",
    },
    bleed = {
        en = "Bleeding",
        ja = "出血",
        ["zh-cn"] = "流血",
        ru = "Кровотечение",
    },
    flamer_assault = {
        en = "Burning",
        ja = "燃焼",
        ["zh-cn"] = "燃烧",
        ru = "Горение",
    },
    rending_debuff = {
        en = "Brittleness",
        ja = "脆弱",
        ["zh-cn"] = "脆弱",
        ru = "Хрупкость",
    },
    warp_fire = {
        en = "Soulblaze",
        ja = "ソウルファイア",
        ["zh-cn"] = "灵魂之火",
        ru = "Горение души",
    },
    electrocuted = {
        en = "Electrocuted",
        ja = "感電",
        ["zh-cn"] = "触电",
        ru = "Наэлектризован",
    },
    power_maul_sticky_tick = {
        en = "Shock",
        ja = "電撃",
        ["zh-cn"] = "震击",
        ru = "Шок",
    },
    increase_damage_taken = {
        en = Localize("loc_weapon_special_hook_pull")
    },
    increase_impact_received_while_staggered = {
        en = Localize("loc_trait_bespoke_staggered_targets_receive_increased_stagger_debuff")
    },
    increase_damage_received_while_staggered = {
        en = Localize("loc_trait_bespoke_staggered_targets_receive_increased_damage_debuff")
    },
    psyker_biomancer_smite_vulnerable_debuff = {
        en = Localize("loc_talent_biomancer_smite_increases_non_warp_damage")
    },
    psyker_protectorate_spread_chain_lightning_interval_improved = {
        en = Localize("loc_talent_psyker_chain_lightning_improved_target_buff")
    },
    psyker_protectorate_spread_charged_chain_lightning_interval_improved = {
        en = Localize("loc_talent_psyker_chain_lightning_improved_target_buff")
    },
    psyker_force_staff_quick_attack_debuff = {
        en = Localize("loc_talent_psyker_force_staff_quick_attack_bonus")
    },
    ogryn_recieve_damage_taken_increase_debuff = {
        en = Localize("loc_talent_ogryn_targets_recieve_damage_increase_debuff")
    },
    ogryn_taunt_increased_damage_taken_buff = {
        en = Localize("loc_talent_ogryn_taunt_damage_taken_increase")
    },
    ogryn_staggering_damage_taken_increase = {
        en = Localize("loc_talent_ogryn_big_bully_heavy_hits")
    },
    veteran_improved_tag_debuff = {
        en = Localize("loc_talent_veteran_improved_tag")
    },
    stagger = {
        en = Localize("loc_stagger")
    },
    suppression = {
        en = Localize("loc_weapon_stats_display_suppression")
    }

}

local options = table.clone(mod.buff_names)

table.append(options, mod.keywords)

for _, buff_name in ipairs(options) do
    loc["enable_" .. buff_name] = loc["toggle"]
    loc["color_" .. buff_name] = loc["color"]

    if loc[buff_name] then
        for lang, text in pairs(loc[buff_name]) do
            local key = "group_" .. buff_name

            loc[key] = loc[key] or {}
            loc[key][lang] = "    " .. text
        end
    end
end

for lang, text in pairs(loc["debuff"]) do
    loc["debuff_and_dot"] = loc["debuff_and_dot"] or {}
    loc["debuff_and_dot"][lang] = text .. " / " .. loc["dot"][lang]
end

for breed_name, breed in pairs(Breeds) do
    if breed_name ~= "human" and breed_name ~= "ogryn" and breed.display_name then
        loc[breed_name] = {
            en = Localize(breed.display_name)
        }
    end
end

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    loc[name] = {}
    loc[name].en = text
end

return loc

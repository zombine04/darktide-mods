local mod = get_mod("debuff_indicator")
local Breeds = require("scripts/settings/breed/breeds")

mod.buff_names = {
    -- DoT
    "bleed",
    "flamer_assault",
    "rending_debuff",
    "warp_fire",
	"neurotoxin_interval_buff",
	"neurotoxin_interval_buff2",
	"neurotoxin_interval_buff3",
	"exploding_toxin_interval_buff",
    -- Weapons/Blessings
    "increase_impact_received_while_staggered",
    "increase_damage_received_while_staggered",
    "power_maul_sticky_tick",
    "increase_damage_taken",
    -- Psyker
	"psyker_discharge_damage_debuff",
    "psyker_protectorate_spread_chain_lightning_interval_improved",
    "psyker_protectorate_spread_charged_chain_lightning_interval_improved",
    "psyker_force_staff_quick_attack_debuff",
    -- Ogryn
    "ogryn_recieve_damage_taken_increase_debuff",
    "ogryn_taunt_increased_damage_taken_buff",
    "ogryn_staggering_damage_taken_increase",
    -- Veteran
    "veteran_improved_tag_debuff",
	-- Zealot
	"zealot_bled_enemies_take_more_damage_effect",
    -- Arbite
    "adamant_drone_enemy_debuff",
    "adamant_drone_talent_debuff",
    "adamant_melee_weakspot_hits_count_as_stagger_debuff",
    "adamant_staggered_enemies_deal_less_damage_debuff",
    "adamant_staggering_increases_damage_taken",
	-- Broker
	"broker_punk_rage_improved_shout_debuff",
	"toxin_damage_debuff",
	"toxin_damage_debuff_monster",
    -- "stagger",
    -- "suppression",
}

mod.keywords = {
    "electrocuted"
}

mod.merged_buffs = {
    psyker_protectorate_spread_charged_chain_lightning_interval_improved = "psyker_protectorate_spread_chain_lightning_interval_improved",
	neurotoxin_interval_buff2 = "neurotoxin_interval_buff",
	neurotoxin_interval_buff3 = "neurotoxin_interval_buff",
	exploding_toxin_interval_buff = "neurotoxin_interval_buff",
	toxin_damage_debuff_monster = "toxin_damage_debuff",
}

mod.display_style_names = {
    "both",
    "label",
    "count",
}

mod.mutators = {
    chaos_hound_mutator = "chaos_hound",
    chaos_lesser_mutated_poxwalker = "chaos_poxwalker",
    chaos_mutated_poxwalker = "chaos_poxwalker",
    chaos_mutator_daemonhost = "chaos_daemonhost",
    chaos_mutator_ritualist = "cultist_ritualist",
    cultist_mutant_mutator = "cultist_mutant",
	renegade_flamer_mutator = "renegade_flamer",
}

local loc = {
    mod_name = {
        en = "Debuff Indicator",
        ["zh-cn"] = "负面效果指示器",
        ru = "Индикатор дебаффов",
        ["zh-tw"] = "Debuff效果顯示器",
    },
    mod_description = {
        en = "Display debuffs applied to each enemy and their stacks.",
        ja = "敵に付与されたデバフとそのスタック数を表示します。",
        ["zh-cn"] = "显示敌人受到的负面效果和层数",
        ru = "Debuff Indicator - Отображает дебаффы и количество их зарядов, применённых к каждому врагу.",
        ["zh-tw"] = "顯示敵人受到的負面效果和層數。",
    },
    display_style = {
        en = "Display style",
        ja = "表示スタイル",
        ["zh-cn"] = "显示样式",
        ru = "Стиль отображения",
        ["zh-tw"] = "顯示方式",
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
        ["zh-tw"] = "\n全部：\n顯示負面效果名稱和層數。" ..
             "\n\n名稱：\n只顯示負面效果名稱。" ..
             "\n\n層數：\n只顯示層數（建議同時設定自訂顏色）。",
    },
    display_style_both = {
        en = "Both",
        ja = "両方",
        ["zh-cn"] = "全部",
        ru = "Всё",
        ["zh-tw"] = "全部",
    },
    display_style_label = {
        en = "Label",
        ja = "ラベル",
        ["zh-cn"] = "名称",
        ru = "Название",
        ["zh-tw"] = "名稱",
    },
    display_style_count = {
        en = "Count",
        ja = "カウント",
        ["zh-cn"] = "层数",
        ru = "Счётчик",
        ["zh-tw"] = "層數",
    },
    key_cycle_style = {
        en = "Keybind: Cycle styles",
        ja = "キーバインド：次のスタイル",
        ["zh-cn"] = "快捷键：下一个样式",
        ru = "Клавиша: Переключение стилей",
        ["zh-tw"] = "快捷鍵：下一個樣式",
    },
    enable_filter = {
        en = "Display major debuffs only",
        ja = "主要なデバフのみ表示する",
        ["zh-cn"] = "仅显示主要负面效果",
        ru = "Отображать только главные дебаффы",
        ["zh-tw"] = "僅顯示主要負面效果",
    },
    filter_disabled = {
        en = "Display all internal buff and debuff if disabled.",
        ja = "無効にした場合、すべての内部的なバフやデバフが表示されます。",
        ["zh-cn"] = "如果禁用，则会显示所有内部增益和减益。",
        ru = "Отображает все внутренние баффы и дебаффы, если отключено.",
        ["zh-tw"] = "若停用，則會顯示所有內部增益與減益。",
    },
    distance = {
        en = "Max distance",
        ja = "最大表示距離",
        ["zh-cn"] = "最大显示距离",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最大顯示距離",
    },
    display_group = {
        en = "What to display",
        ja = "表示対象",
        ["zh-cn"] = "显示对象",
        ru = "Что показывается",
        ["zh-tw"] = "顯示對象",
    },
    debuff = {
        en = "Debuff",
        ja = "デバフ",
        ["zh-cn"] = "负面效果",
        ru = "Дебафф",
        ["zh-tw"] = "負面效果",
    },
    dot = {
        en = "Damage over Time",
        ja = "継続ダメージ",
        ["zh-cn"] = "持续伤害",
        ru = "Урон с течением времени",
        ["zh-tw"] = "持續傷害",
    },
    enable_stagger = {
        en = "Stagger",
        ja = "よろめき",
        ["zh-cn"] = "踉跄",
        ru = "Ошеломление",
        ["zh-tw"] = "踉蹌",
    },
    enable_suppression = {
        en = "Suppression",
        ja = "サプレション",
        ["zh-cn"] = "压制",
        ru = "Подавление",
        ["zh-tw"] = "壓制",
    },
    font = {
        en = "Font style",
        ja = "フォントスタイル",
        ["zh-cn"] = "字体样式",
        ru = "Стиль шрифта",
        ["zh-tw"] = "字體樣式",
    },
    font_size = {
        en = "Size",
        ja = "大きさ",
        ["zh-cn"] = "大小",
        ru = "Размер",
        ["zh-tw"] = "大小",
    },
    font_opacity = {
        en = "Opacity",
        ja = "不透明度",
        ["zh-cn"] = "不透明度",
        ru = "Прозрачность",
        ["zh-tw"] = "不透明度",
    },
    offset_z = {
        en = "Position (height)",
        ja = "表示位置 (高さ)",
        ["zh-cn"] = "位置（高度）",
        ru = "Положение (высота)",
        ["zh-tw"] = "位置（高度）",
    },
    toggle = {
        en = "Toggle",
        ja = "切り替え",
        ["zh-cn"] = "开关",
        ru = "Переключатели",
        ["zh-tw"] = "開關",
    },
    custom_color = {
        en = "Custom color",
        ja = "カスタムカラー",
        ["zh-cn"] = "自定义颜色",
        ru = "Пользовательские цвета",
        ["zh-tw"] = "自訂顏色",
    },
    color = {
        en = "Color",
        ja = "色",
        ["zh-cn"] = "颜色",
        ru = "цвета",
        ["zh-tw"] = "顏色",
    },
    color_r = {
        en = "R",
        ["zh-cn"] = "红",
        ru = "Красный",
        ["zh-tw"] = "紅",
    },
    color_g = {
        en = "G",
        ["zh-cn"] = "绿",
        ru = "Зелёный",
        ["zh-tw"] = "綠",
    },
    color_b = {
        en = "B",
        ["zh-cn"] = "蓝",
        ru = "Синий",
        ["zh-tw"] = "藍",
    },
    breed_minion = {
        en = "Roamers",
        ja = "通常敵",
        ["zh-cn"] = "普通敌人",
        ru = "Бродяги",
        ["zh-tw"] = "普通敵人",
    },
    breed_elite = {
        en = "Elites",
        ja = "上位者",
        ["zh-cn"] = "精英",
        ru = "Элита",
        ["zh-tw"] = "菁英",
    },
    breed_specialist = {
        en = "Specialists",
        ja = "スペシャリスト",
        ["zh-cn"] = "专家",
        ru = "Специалисты",
        ["zh-tw"] = "專家",
    },
    breed_monster = {
        en = "Monstrosities",
        ja = "バケモノ",
        ["zh-cn"] = "怪物",
        ru = "Монстры",
        ["zh-tw"] = "怪物",
    },
    breed_captain = {
        en = "Captains",
        ja = "キャプテン",
        ["zh-tw"] = "隊長",
        ["zh-cn"] = "连长",
    },
    breed_misc = {
        en = "Miscellaneous",
        ja = "その他",
		["zh-cn"] = "其他",
    },
    bleed = {
        en = "Bleeding",
        ja = "出血",
        ["zh-cn"] = "流血",
        ru = "Кровотечение",
        ["zh-tw"] = "流血",
    },
    flamer_assault = {
        en = "Burning",
        ja = "燃焼",
        ["zh-cn"] = "燃烧",
        ru = "Горение",
        ["zh-tw"] = "燃燒",
    },
    rending_debuff = {
        en = "Brittleness",
        ja = "脆弱",
        ["zh-cn"] = "脆弱",
        ru = "Хрупкость",
        ["zh-tw"] = "脆弱",
    },
    warp_fire = {
        en = "Soulblaze",
        ja = "ソウルファイア",
        ["zh-cn"] = "灵魂之火",
        ru = "Горение души",
        ["zh-tw"] = "靈魂之火",
    },
    electrocuted = {
        en = "Electrocuted",
        ja = "感電",
        ["zh-cn"] = "触电",
        ru = "Наэлектризован",
        ["zh-tw"] = "觸電",
    },
    neurotoxin_interval_buff = {
        en = "Chem Toxin",
		["zh-cn"] = "化学毒素",
	},
    power_maul_sticky_tick = {
        en = "Shock",
        ja = "電撃",
        ["zh-cn"] = "震击",
        ru = "Шок",
        ["zh-tw"] = "電擊",
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
	psyker_discharge_damage_debuff = {
		en = Localize("loc_talent_psyker_shout_damage_per_warp_charge")
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
    zealot_bled_enemies_take_more_damage_effect = {
        en = Localize("loc_talent_zealot_bled_enemies_take_more_damage")
    },
    adamant_drone_enemy_debuff = {
        en = Localize("loc_talent_ability_area_buff_drone")
    },
    adamant_drone_talent_debuff = {
        en = Localize("loc_talent_adamant_drone_debuff_talent")
    },
    adamant_melee_weakspot_hits_count_as_stagger_debuff = {
        en = Localize("loc_talent_adamant_melee_weakspot_hits_count_as_stagger")
    },
    adamant_staggered_enemies_deal_less_damage_debuff = {
        en = Localize("loc_talent_adamant_staggered_enemies_deal_less_damage")
    },
    adamant_staggering_increases_damage_taken = {
        en = Localize("loc_talent_adamant_staggered_enemies_take_more_damage")
    },
    toxin_damage_debuff = {
        en = Localize("loc_talent_broker_passive_reduced_damage_by_toxined")
    },
    toxin_damage_debuff_monster = {
        en = Localize("loc_talent_broker_passive_reduced_damage_by_toxined")
    },
    broker_punk_rage_improved_shout_debuff = {
        en = Localize("loc_talent_broker_ability_punk_rage_sub_3")
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


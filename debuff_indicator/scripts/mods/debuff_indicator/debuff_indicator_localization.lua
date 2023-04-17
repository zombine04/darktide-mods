local mod = get_mod("debuff_indicator")
local Breeds = require("scripts/settings/breed/breeds")

mod.buff_names = {
	"bleed",
	"flamer_assault",
	"rending_debuff",
	"warp_fire",
	"increase_impact_received_while_staggered",
	"increase_damage_received_while_staggered",
	"psyker_biomancer_smite_vulnerable_debuff",
	"stagger",
	"suppression",
}

mod.dot_names = {
	"bleed",
	"flamer_assault",
	"warp_fire",
}

local locres = {
	mod_name = {
		en = "Debuff Indicator",
		["zh-cn"] = "负面效果指示器",
	},
	mod_description = {
		en = "Display debuffs applied to each enemy and their stacks.",
		ja = "敵に付与されたデバフとそのスタック数を表示します。",
		["zh-cn"] = "显示敌人受到的负面效果和层数",
	},
	distance = {
		en = "Max distance",
		ja = "最大表示距離",
		["zh-cn"] = "最大显示距离",
	},
	enable_filter = {
		en = "Display major debuffs only",
		ja = "主要なデバフのみ表示する",
		["zh-cn"] = "仅显示主要负面效果",
	},
	disable_filter = {
		en = "Display all internal buff and debuff if disabled.",
		ja = "無効にした場合、すべての内部的なバフやデバフが表示されます。",
		["zh-cn"] = "如果禁用，则会显示所有内部增益和减益。",
	},
	toggle_display = {
		en = "What to display",
		ja = "表示対象",
		["zh-cn"] = "显示对象",
	},
	enable_debuff = {
		en = "Debuff",
		ja = "デバフ",
		["zh-cn"] = "负面效果",
	},
	enable_dot = {
		en = "Damage over Time",
		ja = "継続ダメージ",
		["zh-cn"] = "持续伤害",
	},
	enable_stagger = {
		en = "Stagger",
		ja = "よろめき",
		["zh-cn"] = "踉跄",
	},
	enable_suppression = {
		en = "Suppression",
		ja = "サプレション",
		["zh-cn"] = "压制",
	},
	font = {
		en = "Font style",
		ja = "フォントスタイル",
		["zh-cn"] = "字体样式",
	},
	font_size = {
		en = "Size",
		ja = "大きさ",
		["zh-cn"] = "大小",
	},
	font_opacity = {
		en = "Opacity",
		ja = "不透明度",
		["zh-cn"] = "不透明度",
	},
	custom_color = {
		en = "Custom color",
		ja = "カスタムカラー",
		["zh-cn"] = "自定义颜色",
	},
	color_r = {
		en = "R",
		["zh-cn"] = "红",
	},
	color_g = {
		en = "G",
		["zh-cn"] = "绿",
	},
	color_b = {
		en = "B",
		["zh-cn"] = "蓝",
	},
	breed_minion = {
		en = "Roamers",
		ja = "通常敵",
		["zh-cn"] = "普通敌人",
	},
	breed_elite = {
		en = "Elites",
		ja = "上位者",
		["zh-cn"] = "精英",
	},
	breed_specialist = {
		en = "Specialists",
		ja = "スペシャリスト",
		["zh-cn"] = "专家",
	},
	breed_monster = {
		en = "Monstrosities",
		ja = "バケモノ",
		["zh-cn"] = "怪物",
	},
	bleed = {
		en = "Bleeding",
		ja = "出血",
		["zh-cn"] = "流血",
	},
	flamer_assault = {
		en = "Burning",
		ja = "燃焼",
		["zh-cn"] = "燃烧",
	},
	rending_debuff = {
		en = "Brittleness",
		ja = "脆弱",
		["zh-cn"] = "脆弱",
	},
	warp_fire = {
		en = "Soulblaze",
		ja = "ソウルファイア",
		["zh-cn"] = "灵魂之火",
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
	stagger = {
		en = Localize("loc_stagger")
	},
	suppression = {
		en = Localize("loc_weapon_stats_display_suppression")
	}

}

for _, buff_name in ipairs(mod.buff_names) do
	for _, color in ipairs({"color_r", "color_g", "color_b"}) do
		locres[color .. "_" .. buff_name] = locres[color]
	end
end

for breed_name, breed in pairs(Breeds) do
	if breed_name ~= "human" and breed_name ~= "ogryn" and breed.display_name then
		locres[breed_name] = {
			en = Localize(breed.display_name)
		}
	end
end

return locres

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
	},
	mod_description = {
		en = "Display debuffs applied to each enemy and their stacks.",
		ja = "敵に付与されたデバフとそのスタック数を表示します。"
	},
	distance = {
		en = "Max distance",
		ja = "最大表示距離",
	},
	enable_filter = {
		en = "Display major debuffs only",
		ja = "主要なデバフのみ表示する",
	},
	disable_filter = {
		en = "Display all internal buff and debuff if disabled.",
		ja = "無効にした場合、すべての内部的なバフやデバフが表示されます。",
	},
	toggle_display = {
		en = "What to display",
		ja = "表示対象",
	},
	enable_debuff = {
		en = "Debuff",
		ja = "デバフ",
	},
	enable_dot = {
		en = "Damage over Time",
		ja = "継続ダメージ",
	},
	enable_stagger = {
		en = "Stagger",
		ja = "よろめき",
	},
	enable_suppression = {
		en = "Suppression",
		ja = "サプレション",
	},
	font = {
		en = "Font style",
		ja = "フォントスタイル",
	},
	font_size = {
		en = "Size",
		ja = "大きさ",
	},
	font_opacity = {
		en = "Opacity",
		ja = "不透明度",
	},
	custom_color = {
		en = "Custom color",
		ja = "カスタムカラー",
	},
	color_r = {
		en = "R",
	},
	color_g = {
		en = "G",
	},
	color_b = {
		en = "B",
	},
	breed_minion = {
		en = "Roamers",
		ja = "通常敵",
	},
	breed_elite = {
		en = "Elites",
		ja = "上位者",
	},
	breed_specialist = {
		en = "Specialists",
		ja = "スペシャリスト",
	},
	breed_monster = {
		en = "Monstrosities",
		ja = "バケモノ",
	},
	bleed = {
		en = "Bleeding",
		ja = "出血",
	},
	flamer_assault = {
		en = "Burning",
		ja = "燃焼",
	},
	rending_debuff = {
		en = "Brittleness",
		ja = "脆弱",
	},
	warp_fire = {
		en = "Soulblaze",
		ja = "ソウルファイア",
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
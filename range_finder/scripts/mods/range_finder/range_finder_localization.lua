local mod = get_mod("range_finder")

local locres = {
	mod_name = {
		en = "Range Finder",
	},
	mod_description = {
		en = "Display the distance to the aimed position.",
		ja = "照準した位置までの距離を表示します。",
	},
	update_delay = {
		en = "Update interval (ms)",
		ja = "アップデート間隔 (ms)",
	},
	delay_caution = {
		en = "Caution: Lowering this value will result in smoother execution, but may impact stability and performance.",
		ja = "注意：この値を下げると動作がよりなめらかになりますが、安定性やパフォーマンスに影響を与える可能性があります。",
	},
	decimals = {
		en = "Number of decimal places",
		ja = "少数点以下の桁数",
	},
	font = {
		en = "Font settings",
		ja = "フォント設定",
	},
	font_size = {
		en = "Size",
		ja = "大きさ",
	},
	font_opacity = {
		en = "Opacity",
		ja = "不透明度",
	},
	position = {
		en = "Display position",
		ja = "表示位置",
	},
	position_x = {
		en = "X",
	},
	position_y = {
		en = "Y",
	},
	distance = {
		en = "Distance to change color (m)",
		ja = "色を変える距離 (m)",
	},
	distance_mid = {
		en = "Yellow",
		ja = "黄色",
	},
	distance_close = {
		en = "Orange",
		ja = "オレンジ色",
	},
	distance_very_close = {
		en = "Red",
		ja = "赤色",
	},
}

mod.color_table = function(opacity)
	local color_table = {
		distance_mid = Color.ui_hud_overcharge_low(opacity, true),
		distance_close = Color.ui_hud_overcharge_medium(opacity, true),
		distance_very_close = Color.ui_hud_overcharge_high(opacity, true),
	}

	return color_table
end

for key, color in pairs(mod.color_table(255)) do
	if locres[key] then
		for lang, text in pairs(locres[key]) do
			locres[key][lang] = "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. text .. "{#reset()}"
		end
	end
end

return locres

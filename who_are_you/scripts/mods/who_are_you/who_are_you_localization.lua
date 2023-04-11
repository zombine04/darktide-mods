local mod = get_mod("who_are_you")

mod.modified_elements = {
	"_chat",
	"_lobby",
	"_nameplate",
	"_team_hud",
}

mod.sub_name_options = {
	"color_r",
	"color_g",
	"color_b",
	"enable_custom_color",
	"enable_custom_size",
	"enable_override",
	"sub_name_size",
}

local locres = {
	mod_name = {
		en = "Who Are You",
		ru = "Кто ты",
	},
	mod_description = {
		en = "Display players' account name next to their character name.",
		ja = "キャラクター名の横にプレイヤーのアカウントネームを表示します。",
		ru = "Who Are You - Отображет имя учётной записи игрока рядом с именем его персонажа.",
	},
	display_style = {
		en = "Display style",
		ja = "表示スタイル",
		ru = "Стиль отображения",
	},
	character_first = {
		en = "Character Name (Account Name)",
		ja = "キャラクター名 (アカウント名)",
		ru = "Имя персонажа (Учётная запись)",
	},
	account_first = {
		en = "Account Name (Character Name)",
		ja = "アカウント名 (キャラクター名)",
		ru = "Учётная запись (Имя персонажа)",
	},
	character_only = {
		en = "Character Name",
		ja = "キャラクター名",
		ru = "Имя персонажа",
	},
	account_only = {
		en = "Account Name",
		ja = "アカウント名",
		ru = "Учётная запись",
	},
	enable_display_self = {
		en = "Display your own account name",
		ja = "自身のアカウント名も表示する",
		ru = "Видимость имени вашей учётной записи",
	},
	modify_target = {
		en = "Applied to",
		ja = "変更対象",
	},
	global = {
		en = "Global",
		ja = "グローバル",
	},
	enable_team_hud = {
		en = "Team HUD",
		ja = "チームHUD",
	},
	enable_chat = {
		en = "Chat",
		ja = "チャット",
	},
	enable_lobby = {
		en = "Lobby",
		ja = "ロビー",
	},
	enable_nameplate = {
		en = "Nameplate",
		ja = "ネームプレート",
	},
	sub_name_settings = {
		en = "Sub name settings",
		ja = "サブネーム設定",
		ru = "Настройки дополнительной части имени",
	},
	tooltip_sub_name = {
		en = "This doesn't affect to chat name.",
		ja = "この設定はチャット欄には反映されません。",
	},
	enable_override = {
		en = "Override global settings",
		ja = "グローバル設定を上書きする",
	},
	enable_custom_size = {
		en = "Change sub name size",
		ja = "サブネームの大きさを変更する",
		ru = "Изменить размер доп. имени",
	},
	sub_name_size = {
		en = "Size",
		ja = "大きさ",
		ru = "Размер",
	},
	enable_custom_color = {
		en = "Change sub name color",
		ja = "サブネームの色を変更する",
		ru = "Изменить цвет доп. имени",
	},
	color_r = {
		en = "R",
		ru = "Красный",
	},
	color_g = {
		en = "G",
		ru = "Зелёный",
	},
	color_b = {
		en = "B",
		ru = "Синий",
	},
}

for _, element in ipairs(mod.modified_elements) do
	local local_name = "sub_name_settings" .. element
	locres[local_name] = {}
	for lang, text in pairs(locres.sub_name_settings) do
		if (locres["enable" .. element][lang]) then
			locres[local_name][lang] = text .. " (" .. locres["enable" .. element][lang] .. ")"
		end
	end
end
for lang, text in pairs(locres.sub_name_settings) do
	if locres.global[lang] then
		locres.sub_name_settings[lang] = text .. " (" .. locres.global[lang] .. ")"
	end
end

for _, element in ipairs(mod.modified_elements) do
	for _, option in ipairs(mod.sub_name_options) do
		locres[option .. element] = locres[option]
	end
end

return locres
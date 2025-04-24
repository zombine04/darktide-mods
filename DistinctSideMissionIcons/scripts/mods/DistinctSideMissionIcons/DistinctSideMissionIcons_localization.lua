local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")
local SideObjectives = MissionObjectiveTemplates.side_mission.objectives

local loc = {
    mod_name = {
        en = "Distinct Side Mission Icons",
    },
    mod_description = {
        en = "Change the side mission icons in the mission terminal to be more distinguishable.",
        ja = "ミッションターミナルでサイドミッションのアイコンをより見分けやすく変更します。",
    },
    color = {
        en = "Color",
        ja = "色",
        ["zh-cn"] = "颜色",
        ru = "Цвет",
    },
    icon = {
        en = "Icon",
        ja = "アイコン",
    },
    default = {
        en = "default",
        ja = "デフォルト",
        ["zh-cn"] = "默认",
        ru = "По умолчанию",
    }
}

local _add_child = function(key, suffix)
    local child_key = key .. "_" .. suffix

    for lang, text in pairs(loc[key]) do
        loc[child_key] = loc[child_key] or {}
        loc[child_key][lang] = text
    end
end

for objective_name, data in pairs(SideObjectives) do
    loc[objective_name] = { en = Localize(data.header)}

    _add_child("icon", objective_name)
    _add_child("color", objective_name)
end

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    loc[name] = { en = text }
end

return loc
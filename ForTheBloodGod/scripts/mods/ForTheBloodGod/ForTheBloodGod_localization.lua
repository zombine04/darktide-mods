local mod = get_mod("ForTheBloodGod")

local ExplosionTemplates = require("scripts/settings/damage/explosion_templates")
local GibbingSettings = require("scripts/settings/gibbing/gibbing_settings")
local HitZone = require("scripts/utilities/attack/hit_zone")
local PlayerAbilities = require("scripts/settings/ability/player_abilities/player_abilities")
local UISettings = require("scripts/settings/ui/ui_settings")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")

mod._gibbing_types = GibbingSettings.gibbing_types
mod._hit_zone_names = HitZone.hit_zone_names
mod._settings = {
    "enable_force_gibbing",
    "override_gibbing_type",
    "override_hit_zone",
    "add_extra_vfx",
    "enable_for_special_attack",
    "enable_sfx",
    "multiplier_gib_push_force",
    "multiplier_ragdoll_push_force"
}
mod._weapons = {
    melee = {},
    ranged = {},
    grenade = {},
    psyker = {}
}
mod._extra_fx = {}

local loc = {
    mod_name = {
        en = "For the Blood God",
        ["zh-cn"] = "血祭神皇",
    },
    mod_description = {
        en = "Gives you extraordinary strength and supernatural power to sucrifice the traitors.",
        ja = "異端者を血祭りにあげる類まれなるりょ力と超自然的な力をもたらします。",
        ["zh-cn"] = "赐予你超绝力量和神秘之力来献祭异端。",
    },
    enable_for_teammates = {
        en = "Trigger on Teammate Attacks",
        ja = "味方の攻撃でも発動させる",
        ["zh-cn"] = "队友攻击时触发",
    },
    global_settings = {
        en = "Global Settings",
        ja = "グローバル設定",
        ["zh-cn"] = "全局设置",
    },
    enable_force_gibbing = {
        en = "Force Gibbing",
        ja = "常に部位破壊を起こす",
        ["zh-cn"] = "强制碎块",
    },
    override_gibbing_type = {
        en = "Override Gibbing Type",
        ja = "部位破壊タイプの上書き",
        ["zh-cn"] = "替换碎块类型",
    },
    override_hit_zone = {
        en = "Override Hit Zone",
        ja = "ヒット部位の上書き",
        ["zh-cn"] = "替换命中区域",
    },
    add_extra_vfx = {
        en = "Add VFX on Death",
        ja = "死亡時のVFXを追加する",
        ["zh-cn"] = "添加死亡视觉特效",
    },
    enable_for_special_attack = {
        en = "Only for Special Attacks",
        ja = "特殊攻撃時のみ",
        ["zh-cn"] = "仅特殊攻击时有效",
    },
    enable_sfx = {
        en = "Enable SFX",
        ja = "SFXを有効にする",
        ["zh-cn"] = "启用音效",
    },
    multiplier_gib_push_force = {
        en = "Gib Push Force Multiplier",
        ja = "部位を飛ばす力の倍率",
        ["zh-cn"] = "碎块推动力倍数",
    },
    multiplier_ragdoll_push_force = {
        en = "Ragdoll Push Force Multiplier",
        ja = "ラグドールを飛ばす力の倍率",
        ["zh-cn"] = "布娃娃推动力倍数",
    },
    use_global = {
        en = "Use Global Setting",
        ja = "グローバル設定を使用する",
        ["zh-cn"] = "使用全局设置",
        ru = "Использовать глобальную настройку",
    },
    use_local = {
        en = "Use Individual Setting",
        ja = "個別設定を使用する",
        ["zh-cn"] = "使用单独设置",
    },
    toggle = {
        en = "Toggle",
        ja = "切り替え",
        ["zh-cn"] = "开关",
        ru = "Переключатели",
    },
    off = {
        en = Localize("loc_setting_checkbox_off")
    },
    grenade_ability = {
        en = Localize("loc_talents_category_tactical")
    },
    combat_ability = {
        en = Localize("loc_talents_category_combat")
    },
    -- ##### Fixes for Weapon Category Names ##### --
    loc_weapon_pattern_name_combataxe_p3 = {
        ja = "工作員のシャベル",
    },
    loc_weapon_pattern_name_combatknife_p1 = {
        ["zh-cn"] = "战斗利刃",
    },
    loc_weapon_pattern_name_combatsword_p1 = {
        en = "\"Devil's Claw\" Sword",
        ja = "「悪魔の爪」の剣",
        ["zh-cn"] = "“恶魔之爪”剑",
    },
    loc_weapon_pattern_name_combatsword_p2 = {
        ["zh-cn"] = "重剑",
    },
    loc_weapon_pattern_name_ogryn_powermaul_p1 = {
        ["zh-cn"] = "动力锤",
    },
    loc_weapon_pattern_name_powermaul_2h_p1 = {
        en = "Crusher",
        ja = "クラッシャー",
        ["zh-cn"] = "粉碎者锤",
    },
    loc_weapon_pattern_name_autogun_p2 = {
        ja = "ブレースドオートガン",
        ["zh-cn"] = "稳固自动枪",
    },
    loc_weapon_pattern_name_flamer_p1 = {
        ja = "浄化のフレイマー",
    },
    loc_weapon_pattern_name_lasgun_p1 = {
        ja = "歩兵のラスガン",
    },
    loc_weapon_pattern_name_lasgun_p3 = {
        ja = "偵察用ラスガン",
    },
    loc_weapon_pattern_name_shotgun_p1 = {
        ja = "戦闘用ショットガン",
    },
}

local local_settings  = table.append({ "toggle" }, mod._settings)

local _add_local_settings = function(suffix)
    for _, setting in ipairs(local_settings) do
        local id = setting .. "_" .. suffix

        for lang, text in pairs(loc[setting]) do
            loc[id] = loc[id] or {}
            loc[id][lang] = text
        end
    end
end

local _add_weapon_and_localization = function(source)
    for template_name, data in pairs(source) do
        local pattern = data.display_name_pattern or data.ability_type
        local template = WeaponTemplates[template_name]
        local keywords = template and template.keywords

        if keywords then
            for type, _ in pairs(mod._weapons) do
                if table.find(keywords, type) then
                    mod._weapons[type][template_name] = pattern
                end
            end
        end

        if string.match(pattern, "loc_") then
            if not loc[pattern] then
                loc[pattern] = { en = Localize(pattern) }
            elseif not loc[pattern].en then
                loc[pattern].en = Localize(pattern)
            end
        end

        _add_local_settings(pattern)
    end
end

_add_weapon_and_localization(UISettings.weapon_template_display_settings)
_add_weapon_and_localization(PlayerAbilities)

local _add_extra_vfx_and_sfx = function(source)
    local exception = {
        "corruptor_core_erupt",
        "power_maul_push_shockwave",
        "stumm_grenade",
        "smoke_grenade_initial_blast",
    }

    for template, data in pairs(source) do
        local vfx = data.vfx and data.vfx[1]
        local sfx = data.sfx and data.sfx[1]

        if vfx then
            local text = string.match(vfx, "[%w_/]+/([%w_]+)")

            if table.find(exception, text) then
                goto continue
            end

            mod._extra_fx[text] = {
                vfx = vfx,
                sfx = sfx
            }

            ::continue::
        end
    end
end

_add_extra_vfx_and_sfx(ExplosionTemplates)

local _add_raw_text = function(t)
    for text, _ in pairs(t) do
        loc[text] = { en = text }
    end
end

_add_raw_text(mod._gibbing_types)
_add_raw_text(mod._hit_zone_names)
_add_raw_text(mod._extra_fx)

return loc

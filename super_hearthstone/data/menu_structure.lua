local Config = require("config")
local MenuStructure = {
    -- 主菜单结构
    MAIN_MENU = {
        {type = Config.MENU_TYPES.FUNC, text = "传送回家", func = "GoHome", icon = 0, cost = 0, confirmation = "是否传送回|cFFF0F000家|r ?"},
        {type = Config.MENU_TYPES.FUNC, text = "记录位置", func = "SetHome", icon = 4, cost = 0, confirmation = "是否设置当前位置为|cFFF0F000家|r ?"},
        {type = Config.MENU_TYPES.FUNC, text = "在线银行", func = "OpenBank", icon = 6, cost = 0},
        {type = Config.MENU_TYPES.MENU, text = "地图传送", submenu = "TELEPORT_MAIN", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "其他功能", submenu = "FUNCTIONS_MENU", icon = 4},
        {type = Config.MENU_TYPES.MENU, text = "双重附魔", submenu = "ENCHANT_MAIN", icon = 8},
        {type = Config.MENU_TYPES.FUNC, text = "解除副本绑定", func = "UnBind", icon = 4, cost = 0, confirmation = "是否解除所有副本绑定 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "召唤随身商人", func = "SummonGNPC", icon = 6, cost = 0},
        {type = Config.MENU_TYPES.MENU, text = "职业技能训练师", submenu = "CLASS_TRAINERS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "专业技能训练师", submenu = "PROFESSION_TRAINERS", icon = 9},
        {type = Config.MENU_TYPES.FUNC, text = "副本宠物加光环", func = "AddAuraToPet", icon = 9, cost = 0},
    },
    
    -- 其他功能菜单
    FUNCTIONS_MENU = {
        {type = Config.MENU_TYPES.FUNC, text = "解除虚弱", func = "WeakOut", icon = 4, cost = 0, confirmation = "是否解除虚弱，并回复生命 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "重置天赋", func = "ResetTalents", icon = 3, cost = 0, confirmation = "确认重置天赋 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "武器熟练度满值", func = "WSkillsToMax", icon = 3, cost = 0, confirmation = "确认把武器熟练度加满 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "修理所有装备", func = "RepairAll", icon = 1, cost = 0, confirmation = "需要花费金币修理装备 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "遗忘所有法术", func = "ResetSpell", icon = 0, cost = 0, confirmation = "是否遗忘所有法术？\n|cFFFFFF00需要重新登录才能生效。|r"},
    },
    
    -- GM功能菜单
    GM_MENU = {
        {type = Config.MENU_TYPES.FUNC, text = "重置所有冷却", func = "ResetAllCD", icon = 4, cost = 0, confirmation = "确认重置所有冷却 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "保存角色", func = "SaveToDB", icon = 4, cost = 0},
        {type = Config.MENU_TYPES.FUNC, text = "返回选择角色", func = "Logout", icon = 4, cost = 0, confirmation = "返回选择角色界面 ?"},
        {type = Config.MENU_TYPES.FUNC, text = "|cFF800000不保存角色|r", func = "LogoutNosave", icon = 4, cost = 0, confirmation = "|cFFFF0000不保存角色，并返回选择角色界面 ?|r"},
    },
    
    -- 传送主菜单
    TELEPORT_MAIN = {
        {type = Config.MENU_TYPES.MENU, text = "|cFF006400[城市]|r主要城市", submenu = "CITIES", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF006400[出生]|r种族出生地", submenu = "STARTING_AREAS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF0000FF[野外]|r东部王国", submenu = "EASTERN_KINGDOMS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF0000FF[野外]|r卡利姆多", submenu = "KALIMDOR", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF0000FF[野外]|r|cFF006400外域|r", submenu = "OUTLAND", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF0000FF[野外]|r|cFF4B0082诺森德|r", submenu = "NORTHREND", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF006400【5人】经典旧世界地下城|r    ★☆☆☆☆", submenu = "CLASSIC_DUNGEONS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF0000FF【5人】燃烧的远征地下城|r    ★★☆☆☆", submenu = "TBC_DUNGEONS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFF4B0082【5人】巫妖王之怒地下城|r    ★★★☆☆", submenu = "WOTLK_DUNGEONS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "|cFFB22222【10人-40人】团队地下城|r  ★★★★★", submenu = "RAIDS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "风景传送", submenu = "SCENIC_SPOTS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "竞技场传送", submenu = "ARENAS", icon = 9},
        {type = Config.MENU_TYPES.MENU, text = "野外BOSS传送", submenu = "WORLD_BOSSES", icon = 9},
    },
    
    -- 附魔主菜单
    ENCHANT_MAIN = {
        {type = Config.MENU_TYPES.MENU, text = "头盔", submenu = "ENCHANT_HEAD", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "肩甲", submenu = "ENCHANT_SHOULDERS", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "胸甲", submenu = "ENCHANT_CHEST", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "衬衣", submenu = "ENCHANT_SHIRT", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "腰带", submenu = "ENCHANT_WAIST", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "裤子", submenu = "ENCHANT_LEGS", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "鞋子", submenu = "ENCHANT_FEET", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "护腕", submenu = "ENCHANT_WRISTS", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "手套", submenu = "ENCHANT_HANDS", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "披风", submenu = "ENCHANT_BACK", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "主手武器", submenu = "ENCHANT_MAINHAND", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "副手武器", submenu = "ENCHANT_OFFHAND", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "双手武器", submenu = "ENCHANT_TWOHAND", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "盾牌", submenu = "ENCHANT_SHIELD", icon = 8},
        {type = Config.MENU_TYPES.MENU, text = "弓弩", submenu = "ENCHANT_RANGED", icon = 8},
    }
}

-- 获取菜单定义
function MenuStructure:GetMenu(menuId)
    return self[menuId]
end

-- 检查菜单是否存在
function MenuStructure:MenuExists(menuId)
    return self[menuId] ~= nil
end

-- 获取所有菜单ID
function MenuStructure:GetAllMenuIds()
    local ids = {}
    for id, _ in pairs(self) do
        table.insert(ids, id)
    end
    return ids
end

-- 验证菜单结构
function MenuStructure:Validate()
    local errors = {}
    
    for menuId, items in pairs(self) do
        if type(items) ~= "table" then
            table.insert(errors, "菜单 " .. menuId .. " 不是有效的表格")
        else
            for i, item in ipairs(items) do
                if not item.type or not item.text then
                    table.insert(errors, string.format("菜单 %s 第 %d 项缺少必需字段", menuId, i))
                end
            end
        end
    end
    
    return #errors == 0, errors
end

return MenuStructure
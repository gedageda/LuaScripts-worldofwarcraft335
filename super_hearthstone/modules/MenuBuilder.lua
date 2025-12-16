local Config = require("config")
local ErrorHandler = require("modules.ErrorHandler")
local CacheManager = require("modules.CacheManager")
local TeleportData = require("data.teleport_data")

local MenuBuilder = {}

-- 菜单图标
MenuBuilder.ICONS = {
    CHAT = 0,
    VENDOR = 1,
    TAXI = 2,
    TRAINER = 3,
    INTERACT_1 = 4,
    INTERACT_2 = 5,
    MONEY_BAG = 6,
    TALK = 7,
    TABARD = 8,
    BATTLE = 9,
    DOT = 10
}

-- 构建主菜单
function MenuBuilder:BuildMainMenu(player)
    local menuItems = {}
    
    -- 添加常用功能
    table.insert(menuItems, {
        type = Config.MENU_TYPES.FUNC,
        text = "传送回家",
        icon = MenuBuilder.ICONS.CHAT,
        func = "GoHome",
        cost = 0,
        confirmation = "是否传送回|cFFF0F000家|r?"
    })
    
    table.insert(menuItems, {
        type = Config.MENU_TYPES.MENU,
        text = "地图传送",
        icon = MenuBuilder.ICONS.BATTLE,
        submenu = "TELEPORT_MAIN"
    })
    
    -- 添加功能菜单
    table.insert(menuItems, {
        type = Config.MENU_TYPES.MENU,
        text = "其他功能",
        icon = MenuBuilder.ICONS.INTERACT_1,
        submenu = "FUNCTIONS"
    })
    
    -- 添加专业技能
    table.insert(menuItems, {
        type = Config.MENU_TYPES.MENU,
        text = "双重附魔",
        icon = MenuBuilder.ICONS.TABARD,
        submenu = "ENCHANTING"
    })
    
    -- 检查GM权限
    if player:GetGMRank() >= 3 then
        table.insert(menuItems, {
            type = Config.MENU_TYPES.MENU,
            text = "GM功能",
            icon = MenuBuilder.ICONS.CHAT,
            submenu = "GM_FUNCTIONS"
        })
    end
    
    return menuItems
end

-- 构建传送菜单
function MenuBuilder:BuildTeleportMenu(player, category)
    local menuItems = {}
    local team = player:GetTeam()
    
    -- 根据分类构建不同的传送菜单
    if category == "CITIES" then
        local cities = TeleportData:GetLocations({
            team = team,
            minLevel = 1,
            maxLevel = player:GetLevel()
        })
        
        for _, city in ipairs(cities) do
            table.insert(menuItems, {
                type = Config.MENU_TYPES.TP,
                text = city.name,
                icon = MenuBuilder.ICONS.TAXI,
                location = city,
                cost = self:CalculateTeleportCost(player, city),
                confirmation = string.format("是否传送到|cFFFFFF00%s|r? (花费: %d铜币)", city.name, cost or 0)
            })
        end
    elseif category == "DUNGEONS" then
        -- 构建副本菜单
        local dungeons = TeleportData.Dungeons.Classic
        for _, dungeon in ipairs(dungeons) do
            if dungeon.level <= player:GetLevel() then
                table.insert(menuItems, {
                    type = Config.MENU_TYPES.TP,
                    text = dungeon.name,
                    icon = MenuBuilder.ICONS.BATTLE,
                    location = dungeon,
                    cost = self:CalculateTeleportCost(player, dungeon, true), -- 副本传送更贵
                    confirmation = string.format("是否传送到|cFFFF0000%s|r? (副本入口)", dungeon.name)
                })
            end
        end
    end
    
    return menuItems
end

-- 计算传送费用
function MenuBuilder:CalculateTeleportCost(player, location, isDungeon)
    local baseCost = 100 -- 基础费用100铜币
    local levelMultiplier = player:GetLevel() * 10
    local distanceMultiplier = 1
    
    -- 计算距离系数（简化版）
    local currentMap = player:GetMapId()
    if currentMap ~= location.map then
        distanceMultiplier = 2
    end
    
    -- 副本传送额外费用
    if isDungeon then
        distanceMultiplier = distanceMultiplier * 3
    end
    
    local totalCost = baseCost + (levelMultiplier * distanceMultiplier)
    
    -- 确保费用合理
    local playerMoney = player:GetCoinage()
    if totalCost > playerMoney then
        totalCost = math.floor(playerMoney * 0.1) -- 最多花费10%的钱
    end
    
    return math.max(100, math.min(totalCost, 10000)) -- 100铜币到1金币之间
end

-- 向玩家显示菜单
function MenuBuilder:ShowMenuToPlayer(player, item, menuItems, parentMenuId)
    -- 清除旧菜单
    player:GossipClearMenu()
    
    -- 添加菜单项
    for _, menuItem in ipairs(menuItems) do
        local success, errorMsg = ErrorHandler:SafeExecute("AddMenuItem", function()
            self:AddMenuItem(player, menuItem)
        end, player)
        
        if not success and Config.DEBUG_MODE then
            ErrorHandler:Log("WARN", string.format("Failed to add menu item: %s", errorMsg), player)
        end
    end
    
    -- 添加导航按钮
    if parentMenuId then
        player:GossipMenuAddItem(
            MenuBuilder.ICONS.CHAT,
            "上一页",
            0,
            parentMenuId
        )
    end
    
    player:GossipMenuAddItem(
        MenuBuilder.ICONS.CHAT,
        "主菜单",
        0,
        "MAIN_MENU"
    )
    
    -- 发送菜单
    player:GossipSendMenu(1, item)
    
    return true
end

-- 添加单个菜单项
function MenuBuilder:AddMenuItem(player, menuItem)
    if menuItem.type == Config.MENU_TYPES.MENU then
        player:GossipMenuAddItem(
            menuItem.icon or MenuBuilder.ICONS.CHAT,
            menuItem.text,
            0,
            menuItem.submenu
        )
        
    elseif menuItem.type == Config.MENU_TYPES.FUNC then
        player:GossipMenuAddItem(
            menuItem.icon or MenuBuilder.ICONS.CHAT,
            menuItem.text,
            menuItem.cost or 0,
            menuItem.func,
            menuItem.confirmation ~= nil,
            menuItem.confirmation or "",
            menuItem.cost or 0
        )
        
    elseif menuItem.type == Config.MENU_TYPES.TP then
        local teamPrefix = ""
        if menuItem.location.team == Config.TEAMS.ALLIANCE then
            teamPrefix = "[|cFF0070d0联盟|r]"
        elseif menuItem.location.team == Config.TEAMS.HORDE then
            teamPrefix = "[|cFFF000A0部落|r]"
        end
        
        player:GossipMenuAddItem(
            MenuBuilder.ICONS.TAXI,
            teamPrefix .. menuItem.text,
            menuItem.cost or 0,
            "TP_" .. menuItem.location.name,
            menuItem.confirmation ~= nil,
            menuItem.confirmation or "",
            menuItem.cost or 0
        )
    end
end

return MenuBuilder
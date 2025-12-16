print(">>Script: Super Hearthstone (Refactored)")

-- 加载配置和模块
local Config = require("config")
local ErrorHandler = require("modules.ErrorHandler")
local CacheManager = require("modules.CacheManager")
local MenuBuilder = require("modules.MenuBuilder")
local TeleportSystem = require("modules.TeleportSystem")
local FunctionManager = require("modules.FunctionManager")
local EnchantSystem = require("modules.EnchantSystem")
local TeleportData = require("data.teleport_data")

-- 全局状态
local SuperHearthstone = {
    initialized = false,
    modules = {},
    playerStates = {} -- 玩家状态跟踪
}

-- 初始化系统
function SuperHearthstone:Initialize()
    if self.initialized then return true end
    
    print("Initializing Super Hearthstone...")
    
    -- 初始化缓存管理器
    CacheManager:StartCleanupTimer()
    
    -- 注册事件
    self:RegisterEvents()
    
    -- 验证配置
    local configValid, configError = self:ValidateConfig()
    if not configValid then
        ErrorHandler:Log("FATAL", "Configuration validation failed: " .. configError)
        return false
    end
    
    self.initialized = true
    
    -- 加载完成
    local stats = CacheManager:GetStats()
    print(string.format(
        "Super Hearthstone initialized. Cache stats: %d entries, %d players",
        stats.totalEntries, stats.uniquePlayers
    ))
    
    return true
end

-- 验证配置
function SuperHearthstone:ValidateConfig()
    -- 检查必要配置
    if not Config.ITEM_ENTRY or Config.ITEM_ENTRY <= 0 then
        return false, "Invalid ITEM_ENTRY"
    end
    
    if not Config.SPELL_HEARTHSTONE or Config.SPELL_HEARTHSTONE <= 0 then
        return false, "Invalid SPELL_HEARTHSTONE"
    end
    
    -- 检查缓存配置
    if Config.CACHE_ENABLED then
        if Config.CACHE_TTL <= 0 then
            return false, "CACHE_TTL must be positive"
        end
        if Config.CACHE_CLEANUP_INTERVAL <= 0 then
            return false, "CACHE_CLEANUP_INTERVAL must be positive"
        end
    end
    
    return true
end

-- 注册事件
function SuperHearthstone:RegisterEvents()
    -- 物品使用事件
    RegisterItemGossipEvent(Config.ITEM_ENTRY, 1, function(event, player, item)
        return self:OnGossipShow(event, player, item)
    end)
    
    RegisterItemGossipEvent(Config.ITEM_ENTRY, 2, function(event, player, item, sender, intid, code, menu_id)
        return self:OnGossipSelect(event, player, item, sender, intid, code, menu_id)
    end)
    
    -- 玩家事件
    RegisterPlayerEvent(4, function(event, player) -- PLAYER_EVENT_ON_LOGOUT
        CacheManager:ClearPlayerCache(player)
    end)
    
    -- 服务器事件
    RegisterServerEvent(33, function(event, delay, repeats) -- SERVER_EVENT_ON_UPDATE
        self:OnUpdate(event, delay, repeats)
    end)
    
    print("Events registered successfully")
end

-- 检查使用条件
function SuperHearthstone:CanUse(player)
    if Config.DISABLE_IN_COMBAT and player:IsInCombat() then
        player:SendAreaTriggerMessage("|cFFFF0000战斗中不能使用|r")
        return false
    end
    
    if Config.DISABLE_IN_INSTANCE then
        local map = player:GetMap()
        if map and (map:IsDungeon() or map:IsRaid()) then
            player:SendAreaTriggerMessage("|cFFFF0000副本中不能使用|r")
            return false
        end
    end
    
    return true
end

-- 显示菜单事件处理
function SuperHearthstone:OnGossipShow(event, player, item)
    if not self:CanUse(player) then
        return false
    end
    
    -- 从缓存获取或构建主菜单
    local menuId = "MAIN_MENU"
    local cachedMenu = CacheManager:Get(player, menuId)
    
    if cachedMenu then
        -- 使用缓存的菜单
        MenuBuilder:ShowMenuToPlayer(player, item, cachedMenu)
    else
        -- 构建新菜单并缓存
        local menuItems = MenuBuilder:BuildMainMenu(player)
        CacheManager:Set(player, menuId, menuItems)
        MenuBuilder:ShowMenuToPlayer(player, item, menuItems)
    end
    
    return false
end

-- 菜单选择事件处理
function SuperHearthstone:OnGossipSelect(event, player, item, sender, intid, code, menu_id)
    if not self:CanUse(player) then
        player:GossipComplete()
        return false
    end
    
    local success, result = ErrorHandler:SafeExecute("ProcessMenuSelection", function()
        return self:ProcessMenuSelection(player, item, sender, intid, code, menu_id)
    end, player)
    
    if not success then
        player:GossipComplete()
        return false
    end
    
    return result
end

-- 处理菜单选择
function SuperHearthstone:ProcessMenuSelection(player, item, sender, intid, code, menu_id)
    -- 解析菜单ID
    if intid == "MAIN_MENU" or intid == 0 then
        -- 返回主菜单
        return self:OnGossipShow(nil, player, item)
        
    elseif string.sub(intid, 1, 3) == "TP_" then
        -- 传送功能
        local locationName = string.sub(intid, 4)
        local location = TeleportData:FindByName(locationName)
        
        if location then
            player:GossipComplete()
            TeleportSystem:TeleportPlayer(player, location, sender)
        else
            player:SendNotification("|cFFFF0000传送目的地不存在|r")
            self:OnGossipShow(nil, player, item)
        end
        
    elseif MenuBuilder.submenus[intid] then
        -- 子菜单
        local menuItems = MenuBuilder:BuildSubMenu(player, intid)
        CacheManager:Set(player, intid, menuItems)
        MenuBuilder:ShowMenuToPlayer(player, item, menuItems, "MAIN_MENU")
        
    else
        -- 功能执行
        player:GossipComplete()
        FunctionManager:ExecuteFunction(intid, player, code, sender)
    end
    
    return false
end

-- 服务器更新事件
function SuperHearthstone:OnUpdate(event, delay, repeats)
    -- 定期任务可以放在这里
    if repeats % 100 == 0 then -- 每100次更新执行一次
        self:PerformMaintenance()
    end
end

-- 系统维护
function SuperHearthstone:PerformMaintenance()
    if Config.DEBUG_MODE then
        local stats = CacheManager:GetStats()
        ErrorHandler:Log("DEBUG", string.format(
            "System maintenance - Cache: %d entries, Memory: %.2f KB",
            stats.totalEntries, stats.memoryUsage
        ))
    end
end

-- 重新加载配置（GM命令）
function SuperHearthstone:ReloadConfig(command, player)
    if player and player:GetGMRank() < 3 then
        return false
    end
    
    print("Reloading Super Hearthstone configuration...")
    
    -- 清除所有缓存
    CacheManager.cache = {}
    
    -- 重新加载模块
    package.loaded["config"] = nil
    package.loaded["modules.ErrorHandler"] = nil
    -- ... 重新加载其他模块
    
    -- 重新初始化
    self.initialized = false
    self:Initialize()
    
    local message = "Super Hearthstone configuration reloaded"
    if player then
        player:SendBroadcastMessage("|cFF00FF00" .. message .. "|r")
    end
    
    print(message)
    return true
end

-- 导出函数供其他脚本使用
function SuperHearthstone:TeleportPlayerToLocation(player, locationName, cost)
    local location = TeleportData:FindByName(locationName)
    if not location then
        return false, "Location not found"
    end
    
    return TeleportSystem:TeleportPlayer(player, location, cost)
end

function SuperHearthstone:GetPlayerMenuCache(player)
    local guid = player:GetGUIDLow()
    local playerCache = {}
    
    for key, entry in pairs(CacheManager.cache) do
        if string.match(key, "^" .. guid .. "_") then
            table.insert(playerCache, {
                menuId = entry.menuId,
                timestamp = entry.timestamp,
                age = os.time() - entry.timestamp
            })
        end
    end
    
    return playerCache
end

-- 启动系统
if not SuperHearthstone:Initialize() then
    ErrorHandler:Log("FATAL", "Failed to initialize Super Hearthstone")
else
    -- 注册GM命令
    RegisterServerEvent(16, function(event, command, player) -- COMMAND_EVENT
        if command == "reloadsuperhs" then
            SuperHearthstone:ReloadConfig(command, player)
            return false
        end
    end)
    
    print(">>Super Hearthstone loaded successfully")
end

return SuperHearthstone
print(">>Script: Portable Vendor NPC (Optimized)")

-- 加载模块
local VendorCache = require("vendors/vendor_cache")
local VendorData = require("vendors/vendor_data")

-- NPC配置
local NPC_CONFIG = {
    ID = 190099,
    NAME = "随身商人",
    MODEL = 16104,
    FACTION = 35,
    LEVEL = 80,
    RESPAWN_TIME = 90, -- 秒
    SAYS = {
        "我的货物不打折的哦",
        "慢慢看，我的货物在其他地方买不到。",
        "我的时间可不多，你要快点买。",
        "我这里有很多高级宝石。",
        "你不买点材料做生意吗？",
        "要来点高级宝石，给装备强化吗？",
        "你应该需要更换你的雕文。",
        "当年我可是第一盗贼，留下很多钥匙。",
    }
}

-- 菜单图标
local GOSSIP_ICON = {
    CHAT   = 0,
    VENDOR = 1,
    TRAINER = 3,
    MONEY_BAG = 6,
    TABARD = 8,
    BATTLE = 9
}

-- 菜单类型
local MENU_TYPE = {
    CATEGORY = 1,  -- 分类菜单
    ITEM_LIST = 2, -- 商品列表
    SPECIAL = 3    -- 特殊功能
}

-- 全局状态
local PortableVendor = {
    initialized = false,
    vendorItems = {}, -- NPC商品缓存 {NPC_ID -> {category -> items}}
    playerCooldowns = {}, -- 玩家冷却时间 {PLAYER_GUID -> lastUseTime}
}

-- 错误处理
local function HandleError(player, message, errorDetails)
    if player and player:IsInWorld() then
        player:SendAreaTriggerMessage("|cFFFF0000" .. message .. "|r")
    end
    print("PortableVendor Error: " .. message)
    if errorDetails then
        print("Details: " .. tostring(errorDetails))
    end
end

-- 初始化系统
function PortableVendor:Initialize()
    if self.initialized then return true end
    
    print("Initializing Portable Vendor...")
    
    -- 初始化缓存
    VendorCache:Initialize()
    
    -- 预加载商品数据
    local success, err = VendorData:LoadAll()
    if not success then
        HandleError(nil, "Failed to load vendor data: " .. err)
        return false
    end
    
    -- 注册事件
    self:RegisterEvents()
    
    self.initialized = true
    print("Portable Vendor initialized successfully")
    return true
end

-- 注册事件
function PortableVendor:RegisterEvents()
    -- NPC对话事件
    RegisterCreatureGossipEvent(NPC_CONFIG.ID, 1, function(event, player, creature)
        self:OnGossipShow(player, creature)
    end)
    
    RegisterCreatureGossipEvent(NPC_CONFIG.ID, 2, function(event, player, creature, sender, intid, code, menu_id)
        self:OnGossipSelect(player, creature, sender, intid, code, menu_id)
    end)
    
    -- NPC生成/移除事件
    RegisterCreatureEvent(NPC_CONFIG.ID, 5, function(event, creature) -- CREATURE_EVENT_ON_REMOVE_FROM_WORLD
        self:OnVendorDespawn(creature)
    end)
    
    -- 服务器定时清理
    RegisterServerEvent(33, function(event, delay, repeats) -- SERVER_EVENT_ON_UPDATE
        if repeats % 300 == 0 then -- 每5分钟清理一次
            self:CleanupOldData()
        end
    end)
end

-- 检查冷却时间
function PortableVendor:CheckCooldown(player)
    local guid = tostring(player:GetGUIDLow())
    local lastTime = self.playerCooldowns[guid]
    local currentTime = os.time()
    
    if lastTime and (currentTime - lastTime) < NPC_CONFIG.RESPAWN_TIME then
        local remaining = NPC_CONFIG.RESPAWN_TIME - (currentTime - lastTime)
        player:SendAreaTriggerMessage(string.format(
            "请等待 %d 秒后再召唤商人",
            remaining
        ))
        return false
    end
    
    return true
end

-- 更新冷却时间
function PortableVendor:UpdateCooldown(player)
    local guid = tostring(player:GetGUIDLow())
    self.playerCooldowns[guid] = os.time()
end

-- 构建主菜单
function PortableVendor:BuildMainMenu(player)
    local menuItems = {}
    
    -- 获取分类数据
    local categories = VendorData:GetCategories()
    for _, category in ipairs(categories) do
        table.insert(menuItems, {
            type = MENU_TYPE.CATEGORY,
            text = category.name,
            menuId = category.id,
            icon = category.icon or GOSSIP_ICON.VENDOR
        })
    end
    
    return menuItems
end

-- 构建分类菜单
function PortableVendor:BuildCategoryMenu(categoryId)
    local menuItems = {}
    local subcategories = VendorData:GetSubcategories(categoryId)
    
    if subcategories and #subcategories > 0 then
        for _, subcat in ipairs(subcategories) do
            table.insert(menuItems, {
                type = MENU_TYPE.CATEGORY,
                text = subcat.name,
                menuId = subcat.id,
                icon = subcat.icon or GOSSIP_ICON.VENDOR
            })
        end
    else
        -- 如果没有子分类，直接显示商品
        local items = VendorData:GetItems(categoryId)
        if items and #items > 0 then
            for i = 1, math.min(#items, 50) do -- 限制显示数量
                local item = items[i]
                table.insert(menuItems, {
                    type = MENU_TYPE.ITEM_LIST,
                    text = item.name or ("商品 #" .. item.id),
                    itemId = item.id,
                    icon = GOSSIP_ICON.MONEY_BAG
                })
            end
        end
    end
    
    return menuItems
end

-- 显示菜单给玩家
function PortableVendor:ShowMenu(player, creature, menuItems, title, parentMenuId)
    player:GossipClearMenu()
    
    -- 添加标题
    if title then
        player:GossipMenuAddItem(
            GOSSIP_ICON.CHAT,
            "|cFF00FF00" .. title .. "|r",
            0,
            0
        )
        player:GossipMenuAddItem(
            GOSSIP_ICON.CHAT,
            "|cFFAAAAAA══════════════════════|r",
            0,
            0
        )
    end
    
    -- 添加菜单项
    for _, item in ipairs(menuItems) do
        if item.type == MENU_TYPE.CATEGORY then
            player:GossipMenuAddItem(
                item.icon,
                item.text,
                0,
                item.menuId
            )
        elseif item.type == MENU_TYPE.ITEM_LIST then
            player:GossipMenuAddItem(
                item.icon,
                item.text,
                0,
                0x10000 + item.itemId -- 使用高位区分商品ID
            )
        end
    end
    
    -- 添加导航
    if parentMenuId then
        player:GossipMenuAddItem(
            GOSSIP_ICON.CHAT,
            "|cFF00CCFF◄ 返回上一页|r",
            0,
            parentMenuId
        )
    end
    
    player:GossipMenuAddItem(
        GOSSIP_ICON.CHAT,
        "|cFFFF9900✖ 关闭菜单|r",
        0,
        0xFFFF
    )
    
    player:GossipSendMenu(1, creature)
end

-- 随机商人对话
function PortableVendor:RandomVendorSay(creature)
    if not creature or not creature:IsInWorld() then return end
    
    local says = NPC_CONFIG.SAYS
    if #says > 0 then
        local randomIndex = math.random(1, #says)
        creature:SendUnitSay(says[randomIndex], 0)
    end
end

-- 为NPC添加商品
function PortableVendor:AddVendorItems(creature, itemIds)
    if not creature then return false end
    
    local entry = creature:GetEntry()
    
    -- 先清除现有商品
    VendorRemoveAllItems(entry)
    
    -- 添加新商品
    local addedCount = 0
    for _, itemId in ipairs(itemIds) do
        if type(itemId) == "number" and itemId > 0 then
            local success = pcall(function()
                AddVendorItem(entry, itemId, 0, 0, 0)
            end)
            
            if success then
                addedCount = addedCount + 1
            else
                HandleError(nil, "Failed to add item: " .. itemId)
            end
        end
    end
    
    -- 缓存商品列表
    self.vendorItems[creature:GetGUIDLow()] = itemIds
    
    return addedCount
end

-- 打开商品窗口
function PortableVendor:OpenVendorWindow(player, creature, itemIds)
    if not player or not creature then return false end
    
    -- 添加商品到NPC
    local added = self:AddVendorItems(creature, itemIds)
    if added == 0 then
        player:SendNotification("|cFFFF0000没有可用的商品|r")
        return false
    end
    
    -- 打开商品窗口
    player:SendListInventory(creature)
    
    -- 随机对话
    self:RandomVendorSay(creature)
    
    return true
end

-- 事件处理：显示对话菜单
function PortableVendor:OnGossipShow(player, creature)
    if not self:CheckCooldown(player) then
        player:GossipComplete()
        return
    end
    
    -- 从缓存获取或构建主菜单
    local cacheKey = "main_menu"
    local cachedMenu = VendorCache:Get(player, cacheKey)
    
    if cachedMenu then
        self:ShowMenu(player, creature, cachedMenu, NPC_CONFIG.NAME)
    else
        local menuItems = self:BuildMainMenu(player)
        VendorCache:Set(player, cacheKey, menuItems)
        self:ShowMenu(player, creature, menuItems, NPC_CONFIG.NAME)
    end
    
    self:UpdateCooldown(player)
end

-- 事件处理：菜单选择
function PortableVendor:OnGossipSelect(player, creature, sender, intid, code, menu_id)
    if intid == 0xFFFF then -- 关闭菜单
        player:GossipComplete()
        return
    end
    
    if intid == 0 then -- 返回主菜单
        self:OnGossipShow(player, creature)
        return
    end
    
    if intid >= 0x10000 then -- 商品选择
        local itemId = intid - 0x10000
        local items = VendorData:GetItemDetails(itemId)
        
        if items and #items > 0 then
            self:OpenVendorWindow(player, creature, items)
        else
            player:SendNotification("|cFFFF0000商品不存在|r")
            self:OnGossipShow(player, creature)
        end
        return
    end
    
    -- 分类菜单选择
    local categoryId = intid
    local categoryInfo = VendorData:GetCategoryInfo(categoryId)
    
    if not categoryInfo then
        player:SendNotification("|cFFFF0000分类不存在|r")
        self:OnGossipShow(player, creature)
        return
    end
    
    -- 检查是否有子分类
    local subcategories = VendorData:GetSubcategories(categoryId)
    local items = VendorData:GetItems(categoryId)
    
    if subcategories and #subcategories > 0 then
        -- 显示子分类菜单
        local cacheKey = "category_" .. categoryId
        local cachedMenu = VendorCache:Get(player, cacheKey)
        
        if cachedMenu then
            self:ShowMenu(player, creature, cachedMenu, categoryInfo.name, 0)
        else
            local menuItems = self:BuildCategoryMenu(categoryId)
            VendorCache:Set(player, cacheKey, menuItems)
            self:ShowMenu(player, creature, menuItems, categoryInfo.name, 0)
        end
    elseif items and #items > 0 then
        -- 直接打开商品窗口
        self:OpenVendorWindow(player, creature, items)
    else
        player:SendNotification("|cFFFF0000该分类下没有商品|r")
        self:OnGossipShow(player, creature)
    end
end

-- NPC消失时清理缓存
function PortableVendor:OnVendorDespawn(creature)
    local guid = creature:GetGUIDLow()
    if self.vendorItems[guid] then
        self.vendorItems[guid] = nil
    end
end

-- 定期清理旧数据
function PortableVendor:CleanupOldData()
    local currentTime = os.time()
    local expiredTime = currentTime - 3600 -- 1小时前的数据
    
    -- 清理玩家冷却时间
    for guid, lastTime in pairs(self.playerCooldowns) do
        if lastTime < expiredTime then
            self.playerCooldowns[guid] = nil
        end
    end
    
    -- 清理缓存
    VendorCache:CleanupExpired()
    
    -- 统计信息
    local playerCount = 0
    for _ in pairs(self.playerCooldowns) do
        playerCount = playerCount + 1
    end
    
    print(string.format(
        "[PortableVendor] Cleanup complete. Active players: %d, Cache entries: %d",
        playerCount, VendorCache:GetCount()
    ))
end

-- 获取统计信息（GM命令）
function PortableVendor:GetStats()
    return {
        players = table.getn(self.playerCooldowns),
        cachedNPCs = table.getn(self.vendorItems),
        cacheStats = VendorCache:GetStats()
    }
end

-- 初始化系统
if not PortableVendor:Initialize() then
    print(">>Error: Failed to initialize Portable Vendor")
else
    print(">>Script: Portable Vendor loaded successfully")
end

return PortableVendor
local ErrorHandler = require("modules.ErrorHandler")

local CacheManager = {
    cache = {},
    cleanupTimer = nil
}

-- 生成缓存键
function CacheManager:GenerateKey(player, menuId)
    if not player or not menuId then return nil end
    return string.format("%d_%d", player:GetGUIDLow(), menuId)
end

-- 获取缓存
function CacheManager:Get(player, menuId)
    if not Config.CACHE_ENABLED then return nil end
    
    local key = self:GenerateKey(player, menuId)
    if not key then return nil end
    
    local cacheEntry = self.cache[key]
    if cacheEntry and os.time() - cacheEntry.timestamp < Config.CACHE_TTL then
        return cacheEntry.data
    end
    
    -- 清理过期的缓存
    if cacheEntry then
        self.cache[key] = nil
    end
    
    return nil
end

-- 设置缓存
function CacheManager:Set(player, menuId, data)
    if not Config.CACHE_ENABLED then return false end
    
    local key = self:GenerateKey(player, menuId)
    if not key then return false end
    
    self.cache[key] = {
        data = data,
        timestamp = os.time(),
        playerName = player:GetName(),
        menuId = menuId
    }
    
    return true
end

-- 清理指定玩家的缓存
function CacheManager:ClearPlayerCache(player)
    local guid = player:GetGUIDLow()
    local count = 0
    
    for key, _ in pairs(self.cache) do
        if string.match(key, "^" .. guid .. "_") then
            self.cache[key] = nil
            count = count + 1
        end
    end
    
    if Config.DEBUG_MODE then
        ErrorHandler:Log("DEBUG", string.format("Cleared %d cache entries for player %s", count, player:GetName()))
    end
end

-- 定期清理过期缓存
function CacheManager:StartCleanupTimer()
    if self.cleanupTimer then return end
    
    self.cleanupTimer = CreateLuaEvent(function()
        local now = os.time()
        local removed = 0
        
        for key, entry in pairs(self.cache) do
            if now - entry.timestamp > Config.CACHE_TTL * 2 then -- 两倍TTL后强制清理
                self.cache[key] = nil
                removed = removed + 1
            end
        end
        
        if Config.DEBUG_MODE and removed > 0 then
            ErrorHandler:Log("DEBUG", string.format("Auto-cleanup removed %d expired cache entries", removed))
        end
    end, Config.CACHE_CLEANUP_INTERVAL * 1000, 0) -- 转换为毫秒
end

-- 获取缓存统计信息
function CacheManager:GetStats()
    local total = 0
    local players = {}
    
    for key, entry in pairs(self.cache) do
        total = total + 1
        players[entry.playerName] = (players[entry.playerName] or 0) + 1
    end
    
    return {
        totalEntries = total,
        uniquePlayers = table.getn(players),
        memoryUsage = collectgarbage("count") -- 粗略的内存使用估计
    }
end

return CacheManager

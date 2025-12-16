local VendorCache = {
    cache = {},
    stats = {
        hits = 0,
        misses = 0,
        sets = 0,
        evictions = 0
    }
}

-- 配置
local CACHE_CONFIG = {
    TTL = 300, -- 缓存存活时间（秒）
    MAX_ENTRIES = 1000, -- 最大缓存条目数
    CLEANUP_INTERVAL = 600, -- 清理间隔（秒）
}

-- 生成缓存键
function VendorCache:GenerateKey(player, cacheKey)
    if not player or not cacheKey then return nil end
    return string.format("%d_%s", player:GetGUIDLow(), cacheKey)
end

-- 获取缓存
function VendorCache:Get(player, cacheKey)
    local key = self:GenerateKey(player, cacheKey)
    if not key then
        self.stats.misses = self.stats.misses + 1
        return nil
    end
    
    local entry = self.cache[key]
    if entry then
        if os.time() - entry.timestamp < CACHE_CONFIG.TTL then
            self.stats.hits = self.stats.hits + 1
            return entry.data
        else
            -- 清理过期缓存
            self.cache[key] = nil
            self.stats.evictions = self.stats.evictions + 1
        end
    end
    
    self.stats.misses = self.stats.misses + 1
    return nil
end

-- 设置缓存
function VendorCache:Set(player, cacheKey, data)
    if not data then return false end
    
    local key = self:GenerateKey(player, cacheKey)
    if not key then return false end
    
    -- 检查缓存大小
    if self:GetCount() >= CACHE_CONFIG.MAX_ENTRIES then
        self:EvictOldest(10) -- 清理10个最旧的条目
    end
    
    self.cache[key] = {
        data = data,
        timestamp = os.time(),
        playerName = player:GetName(),
        key = cacheKey
    }
    
    self.stats.sets = self.stats.sets + 1
    return true
end

-- 清理指定玩家的缓存
function VendorCache:ClearPlayerCache(player)
    local guid = tostring(player:GetGUIDLow())
    local count = 0
    
    for key, _ in pairs(self.cache) do
        if key:find("^" .. guid .. "_") then
            self.cache[key] = nil
            count = count + 1
            self.stats.evictions = self.stats.evictions + 1
        end
    end
    
    return count
end

-- 清理过期缓存
function VendorCache:CleanupExpired()
    local now = os.time()
    local removed = 0
    
    for key, entry in pairs(self.cache) do
        if now - entry.timestamp > CACHE_CONFIG.TTL then
            self.cache[key] = nil
            removed = removed + 1
            self.stats.evictions = self.stats.evictions + 1
        end
    end
    
    return removed
end

-- 清理最旧的缓存条目
function VendorCache:EvictOldest(count)
    local entries = {}
    
    -- 收集所有条目
    for key, entry in pairs(self.cache) do
        table.insert(entries, {
            key = key,
            timestamp = entry.timestamp
        })
    end
    
    -- 按时间排序
    table.sort(entries, function(a, b)
        return a.timestamp < b.timestamp
    end)
    
    -- 删除最旧的条目
    local toRemove = math.min(count, #entries)
    for i = 1, toRemove do
        self.cache[entries[i].key] = nil
        self.stats.evictions = self.stats.evictions + 1
    end
    
    return toRemove
end

-- 获取缓存统计
function VendorCache:GetCount()
    local count = 0
    for _ in pairs(self.cache) do
        count = count + 1
    end
    return count
end

function VendorCache:GetStats()
    return {
        total = self:GetCount(),
        hits = self.stats.hits,
        misses = self.stats.misses,
        sets = self.stats.sets,
        evictions = self.stats.evictions,
        hitRate = self.stats.hits / math.max(1, self.stats.hits + self.stats.misses)
    }
end

-- 初始化
function VendorCache:Initialize()
    -- 启动定期清理
    CreateLuaEvent(function()
        local removed = self:CleanupExpired()
        if removed > 0 then
            print(string.format(
                "[VendorCache] Cleaned up %d expired cache entries. Total: %d",
                removed, self:GetCount()
            ))
        end
    end, CACHE_CONFIG.CLEANUP_INTERVAL * 1000, 0)
end

return VendorCache
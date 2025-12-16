local Config = {
    -- 基本设置
    ITEM_ENTRY = 6948,           -- 炉石物品ID
    SPELL_HEARTHSTONE = 8690,    -- 炉石法术ID
    
    -- 缓存设置
    CACHE_ENABLED = true,
    CACHE_TTL = 300,             -- 缓存存活时间（秒）
    CACHE_CLEANUP_INTERVAL = 600, -- 缓存清理间隔
    
    -- 使用限制（简化）
    DISABLE_IN_COMBAT = true,
    DISABLE_IN_INSTANCE = false,
    
    -- NPC召唤设置
    SUMMON_NPC = {
        MERCHANT = 190099,       -- 商人NPC
        ENCHANTER = 190098,      -- 附魔师NPC
        COOLDOWN = 90,           -- 召唤冷却时间（秒）
    },
    
    -- 传送费用设置
    TELEPORT_COST = {
        BASE_COST = 100,         -- 基础费用
        LEVEL_MULTIPLIER = 10,   -- 等级系数
        DISTANCE_MULTIPLIER = 2, -- 距离系数
        DUNGEON_MULTIPLIER = 3,  -- 副本系数
    },
    
    -- 调试设置
    DEBUG_MODE = false,
    LOG_LEVEL = "INFO",          -- DEBUG, INFO, WARN, ERROR
    
    -- 批量功能开关
    ENABLE_BATCH_ENCHANT = false, -- 批量附魔功能
}

-- 阵营常量
Config.TEAMS = {
    ALLIANCE = 0,
    HORDE = 1,
    NONE = 2
}

-- 菜单类型
Config.MENU_TYPES = {
    FUNC = 1,    -- 功能
    MENU = 2,    -- 子菜单
    TP = 3,      -- 传送
    ENC = 4      -- 附魔
}

-- 菜单图标
Config.GOSSIP_ICON = {
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

return Config
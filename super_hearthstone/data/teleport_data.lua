local Config = require("config")

local TeleportData = {
    Cities = {
        -- 联盟城市
        {name = "暴风城", map = 0, x = -8842.09, y = 626.358, z = 94.0867, o = 3.61363, team = Config.TEAMS.ALLIANCE, level = 1},
        {name = "铁炉堡", map = 0, x = -4900.47, y = -962.585, z = 501.455, o = 5.40538, team = Config.TEAMS.ALLIANCE, level = 1},
        -- 部落城市
        {name = "奥格瑞玛", map = 1, x = 1601.08, y = -4378.69, z = 9.9846, o = 2.14362, team = Config.TEAMS.HORDE, level = 1},
        {name = "雷霆崖", map = 1, x = -1274.45, y = 71.8601, z = 128.159, o = 2.80623, team = Config.TEAMS.HORDE, level = 1},
        -- 中立城市
        {name = "达拉然", map = 571, x = 5809.55, y = 503.975, z = 657.526, o = 2.38338, team = Config.TEAMS.NONE, level = 65},
        {name = "沙塔斯", map = 530, x = -1887.62, y = 5359.09, z = -12.4279, o = 4.40435, team = Config.TEAMS.NONE, level = 55},
    },
    
    Dungeons = {
        Classic = {
            {name = "死亡矿井", map = 0, x = -11209.6, y = 1666.54, z = 24.6974, o = 1.42053, team = Config.TEAMS.ALLIANCE, level = 10},
            {name = "怒焰裂谷", map = 1, x = 1811.78, y = -4410.5, z = -18.4704, o = 5.20165, team = Config.TEAMS.HORDE, level = 8},
        },
        TBC = {
            {name = "地狱火城墙", map = 530, x = -360, y = 3070, z = -15, o = 0, team = Config.TEAMS.NONE, level = 60},
            {name = "鲜血熔炉", map = 530, x = -300, y = 3160, z = 0, o = 0, team = Config.TEAMS.NONE, level = 61},
            {name = "破碎大厅", map = 530, x = -310, y = 3080, z = -20, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "奴隶围栏", map = 530, x = 720, y = 7000, z = -70, o = 0, team = Config.TEAMS.NONE, level = 62},
            {name = "蒸汽地窟", map = 530, x = 730, y = 7100, z = -70, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "幽暗沼泽", map = 530, x = 740, y = 6900, z = -70, o = 0, team = Config.TEAMS.NONE, level = 63},
            {name = "法力陵墓", map = 530, x = -3300, y = 4940, z = -100, o = 0, team = Config.TEAMS.NONE, level = 64},
            {name = "奥金尼地穴", map = 530, x = -3400, y = 5000, z = -100, o = 0, team = Config.TEAMS.NONE, level = 65},
            {name = "塞泰克大厅", map = 530, x = -3500, y = 5100, z = -100, o = 0, team = Config.TEAMS.NONE, level = 67},
            {name = "暗影迷宫", map = 530, x = -3600, y = 5200, z = -100, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "生态船", map = 530, x = 3300, y = 1550, z = 180, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "能源舰", map = 530, x = 3400, y = 1600, z = 180, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "禁魔监狱", map = 530, x = 3500, y = 1700, z = 180, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "魔导师平台", map = 530, x = 12885, y = -7317, z = 65, o = 0, team = Config.TEAMS.NONE, level = 70},
            {name = "旧希尔斯布莱德丘陵", map = 1, x = -8756, y = -4440, z = -200, o = 0, team = Config.TEAMS.NONE, level = 66},
            {name = "黑色沼泽", map = 1, x = -8756, y = -4440, z = -200, o = 0, team = Config.TEAMS.NONE, level = 70},
        },
        WotLK = {
            {name = "艾卓-尼鲁布", map = 571, x = 3707.86, y = 2150.23, z = 36.76, o = 3.22, team = Config.TEAMS.NONE, level = 72},
            {name = "安卡赫特：古代王国", map = 571, x = 3727.57, y = 2155.75, z = 36.76, o = 3.22, team = Config.TEAMS.NONE, level = 73},
            {name = "达克萨隆要塞", map = 571, x = 4765.59, y = -2038.24, z = 229.363, o = 0.887627, team = Config.TEAMS.NONE, level = 74},
            {name = "古达克", map = 571, x = 6722.44, y = -4640.67, z = 450.632, o = 3.91123, team = Config.TEAMS.NONE, level = 76},
            {name = "闪电大厅", map = 571, x = 9136.52, y = -1311.81, z = 1066.29, o = 5.19113, team = Config.TEAMS.NONE, level = 80},
            {name = "岩石大厅", map = 571, x = 8922.12, y = -1009.16, z = 1039.56, o = 1.57044, team = Config.TEAMS.NONE, level = 77},
            {name = "乌特加德城堡", map = 571, x = 1203.41, y = -4868.59, z = 41.2486, o = 0.283237, team = Config.TEAMS.NONE, level = 70},
            {name = "乌特加德之巅", map = 571, x = 1267.24, y = -4857.3, z = 215.764, o = 3.22768, team = Config.TEAMS.NONE, level = 80},
            {name = "紫罗兰监狱", map = 571, x = 5693.08, y = 502.588, z = 652.672, o = 4.0229, team = Config.TEAMS.NONE, level = 75},
            {name = "斯坦索姆的抉择", map = 1, x = -8756.39, y = -4440.68, z = -199.489, o = 4.66289, team = Config.TEAMS.NONE, level = 80},
            {name = "冠军的试炼", map = 571, x = 8515.61, y = 714.153, z = 558.248, o = 1.57753, team = Config.TEAMS.NONE, level = 80},
            {name = "冰冠城堡", map = 571, x = 5855.22, y = 2102.03, z = 635.991, o = 3.57899, team = Config.TEAMS.NONE, level = 80},
        }
    },
    
    -- 按地图分类
    ByMap = {
        [0] = {"暴风城", "铁炉堡", "暴风城监狱"},
        [1] = {"奥格瑞玛", "雷霆崖", "怒焰裂谷"},
        [530] = {"沙塔斯", "地狱火半岛"},
        [571] = {"达拉然", "北风苔原"}
    }
}

-- 获取符合条件的传送点
function TeleportData:GetLocations(filter)
    local results = {}
    
    for category, locations in pairs(self) do
        if type(locations) == "table" and category ~= "ByMap" then
            for _, loc in pairs(locations) do
                if type(loc) == "table" then
                    local match = true
                    
                    -- 应用过滤器
                    if filter then
                        if filter.team and loc.team ~= filter.team then
                            match = false
                        end
                        if filter.minLevel and loc.level and loc.level < filter.minLevel then
                            match = false
                        end
                        if filter.maxLevel and loc.level and loc.level > filter.maxLevel then
                            match = false
                        end
                        if filter.map and loc.map ~= filter.map then
                            match = false
                        end
                    end
                    
                    if match then
                        table.insert(results, loc)
                    end
                end
            end
        end
    end
    
    return results
end

-- 通过名称查找传送点
function TeleportData:FindByName(name)
    for category, locations in pairs(self) do
        if type(locations) == "table" then
            for _, loc in pairs(locations) do
                if type(loc) == "table" and loc.name == name then
                    return loc
                end
            end
        end
    end
    return nil
end

return TeleportData
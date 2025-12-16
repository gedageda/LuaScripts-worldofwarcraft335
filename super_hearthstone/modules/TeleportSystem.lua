local Config = require("config")
local ErrorHandler = require("modules.ErrorHandler")

local TeleportSystem = {}

-- 执行传送（已移除安全检查）
function TeleportSystem:TeleportPlayer(player, location, cost)
    local success, errorMsg = ErrorHandler:SafeExecute("TeleportPlayer", function()
        -- 检查玩家状态（只保留基本检查）
        if Config.DISABLE_IN_COMBAT and player:IsInCombat() then
            error("战斗中无法传送")
        end
        
        if Config.DISABLE_IN_INSTANCE then
            local map = player:GetMap()
            if map and (map:IsDungeon() or map:IsRaid()) then
                error("副本中无法传送")
            end
        end
        
        -- 检查费用
        if cost and cost > 0 then
            local playerMoney = player:GetCoinage()
            if playerMoney < cost then
                error(string.format("金币不足，需要 %d 铜币", cost))
            end
        end
        
        -- 检查等级要求
        if location.level and player:GetLevel() < location.level then
            error(string.format("需要等级 %d", location.level))
        end
        
        -- 检查阵营限制
        if location.team ~= Config.TEAMS.NONE then
            local playerTeam = player:GetTeam()
            if playerTeam ~= location.team then
                error("阵营限制无法传送")
            end
        end
        
        -- 执行传送
        local teleportSuccess = player:Teleport(
            location.map,
            location.x,
            location.y,
            location.z,
            location.o or 0
        )
        
        if not teleportSuccess then
            error("传送法术失败")
        end
        
        -- 扣费
        if cost and cost > 0 then
            player:ModifyMoney(-cost)
        end
        
        -- 发送成功消息
        player:SendBroadcastMessage(string.format(
            "|cFF00FF00已传送到 %s|r%s",
            location.name,
            cost and cost > 0 and string.format(" (花费: %d铜币)", cost) or ""
        ))
        
        -- 记录日志
        ErrorHandler:Log("INFO", string.format(
            "Teleported to %s (Map:%d, X:%.2f, Y:%.2f, Z:%.2f)",
            location.name, location.map, location.x, location.y, location.z
        ), player)
        
        return true
    end, player)
    
    if not success then
        player:SendNotification("|cFFFF0000传送失败: " .. errorMsg .. "|r")
        return false
    end
    
    return true
end

-- 查找传送点（根据名称）
function TeleportSystem:FindTeleportLocation(name, teleportData)
    for category, locations in pairs(teleportData) do
        if type(locations) == "table" then
            for _, location in ipairs(locations) do
                if location.name == name then
                    return location
                end
            end
        end
    end
    return nil
end

-- 获取玩家当前位置信息
function TeleportSystem:GetPlayerLocationInfo(player)
    return {
        mapId = player:GetMapId(),
        x = player:GetX(),
        y = player:GetY(),
        z = player:GetZ(),
        o = player:GetO(),
        areaId = player:GetAreaId(),
        zone = player:GetZone(),
        subZone = player:GetSubZone()
    }
end

-- 计算传送距离（简化版）
function TeleportSystem:CalculateDistance(player, location)
    local current = self:GetPlayerLocationInfo(player)
    
    -- 如果不在同一个地图，返回一个大距离
    if current.mapId ~= location.map then
        return 999999
    end
    
    -- 简单欧几里得距离
    local dx = current.x - location.x
    local dy = current.y - location.y
    return math.sqrt(dx * dx + dy * dy)
end

-- 获取最近的回城点（基于玩家阵营）
function TeleportSystem:GetNearestHome(player)
    local playerTeam = player:GetTeam()
    local homes = {
        [Config.TEAMS.ALLIANCE] = {
            {name = "暴风城", map = 0, x = -8842.09, y = 626.358, z = 94.0867, o = 3.61363},
            {name = "铁炉堡", map = 0, x = -4900.47, y = -962.585, z = 501.455, o = 5.40538},
        },
        [Config.TEAMS.HORDE] = {
            {name = "奥格瑞玛", map = 1, x = 1601.08, y = -4378.69, z = 9.9846, o = 2.14362},
            {name = "雷霆崖", map = 1, x = -1274.45, y = 71.8601, z = 128.159, o = 2.80623},
        }
    }
    
    local teamHomes = homes[playerTeam]
    if not teamHomes then
        return nil
    end
    
    -- 返回第一个主城
    return teamHomes[1]
end

return TeleportSystem
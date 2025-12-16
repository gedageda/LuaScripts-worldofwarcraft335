local Config = require("config")
local ErrorHandler = require("modules.ErrorHandler")
local ST = require("data.st_npc_data") -- 假设召唤NPC数据在这个文件

local FunctionManager = {
    functions = {},
    instanceBindings = require("data.instance_data") -- 副本绑定数据
}

-- 初始化功能注册
function FunctionManager:Initialize()
    self:RegisterFunctions()
end

-- 注册所有功能函数
function FunctionManager:RegisterFunctions()
    -- 炉石相关功能
    self.functions["GoHome"] = self.GoHome
    self.functions["SetHome"] = self.SetHome
    self.functions["OpenBank"] = self.OpenBank
    
    -- 状态管理
    self.functions["WeakOut"] = self.WeakOut
    self.functions["OutCombat"] = self.OutCombat
    self.functions["MaxHealth"] = self.MaxHealth
    self.functions["RepairAll"] = self.RepairAll
    
    -- 技能和天赋
    self.functions["WSkillsToMax"] = self.WSkillsToMax
    self.functions["ResetTalents"] = self.ResetTalents
    self.functions["ResetPetTalents"] = self.ResetPetTalents
    self.functions["ResetSpell"] = self.ResetSpell
    
    -- 冷却和重置
    self.functions["ResetAllCD"] = self.ResetAllCD
    self.functions["UnBind"] = self.UnBind
    
    -- 其他功能
    self.functions["SaveToDB"] = self.SaveToDB
    self.functions["Logout"] = self.Logout
    self.functions["LogoutNosave"] = self.LogoutNosave
    
    -- NPC召唤
    self.functions["SummonGNPC"] = self.SummonGNPC
    self.functions["SummonENPC"] = self.SummonENPC
    self.functions["AddAuraToPet"] = self.AddAuraToPet
    
    -- 角色定制（需要重新登录）
    self.functions["ResetName"] = self.ResetName
    self.functions["ResetFace"] = self.ResetFace
    self.functions["ResetRace"] = self.ResetRace
    self.functions["ResetFaction"] = self.ResetFaction
end

-- 执行功能
function FunctionManager:ExecuteFunction(funcName, player, ...)
    local func = self.functions[funcName]
    if not func then
        player:SendNotification("|cFFFF0000功能不存在: " .. funcName .. "|r")
        ErrorHandler:Log("ERROR", "Function not found: " .. funcName, player)
        return false
    end
    
    return ErrorHandler:SafeExecute(funcName, func, player, ...)
end

-- 功能实现
function FunctionManager:GoHome(player)
    player:CastSpell(player, Config.SPELL_HEARTHSTONE, true)
    player:ResetSpellCooldown(Config.SPELL_HEARTHSTONE, true)
    player:SendBroadcastMessage("已经回到家")
    return true
end

function FunctionManager:SetHome(player)
    local x, y, z, mapId, areaId = player:GetX(), player:GetY(), player:GetZ(), player:GetMapId(), player:GetAreaId()
    player:SetBindPoint(x, y, z, mapId, areaId)
    player:SendBroadcastMessage("已经设置当前位置为家")
    return true
end

function FunctionManager:OpenBank(player)
    player:SendShowBank(player)
    player:SendBroadcastMessage("已经打开银行")
    return true
end

function FunctionManager:WeakOut(player)
    if player:HasAura(15007) then
        player:RemoveAura(15007) -- 移除复活虚弱
        player:SetHealth(player:GetMaxHealth())
        player:SendBroadcastMessage("你的身上的复活虚弱状态已经被移除。")
    else
        player:SendBroadcastMessage("你的身上没有复活虚弱状态。")
    end
    return true
end

function FunctionManager:OutCombat(player)
    if player:IsInCombat() then
        player:ClearInCombat()
        player:SendAreaTriggerMessage("你已经脱离战斗")
        player:SendBroadcastMessage("你已经脱离战斗。")
    else
        player:SendAreaTriggerMessage("你并没有在战斗。")
        player:SendBroadcastMessage("你并没有在战斗。")
    end
    return true
end

function FunctionManager:WSkillsToMax(player)
    player:AdvanceSkillsToMax()
    player:SendBroadcastMessage("当前技能熟练度已经达到最大值")
    return true
end

function FunctionManager:MaxHealth(player)
    player:SetHealth(player:GetMaxHealth())
    player:SendBroadcastMessage("生命值已经回满。")
    return true
end

function FunctionManager:ResetTalents(player)
    player:ResetTalents(true) -- 免费重置
    player:SendBroadcastMessage("已经重置天赋")
    return true
end

function FunctionManager:ResetPetTalents(player)
    player:ResetPetTalents()
    player:SendBroadcastMessage("已经重置宠物天赋")
    return true
end

function FunctionManager:ResetAllCD(player)
    player:ResetAllCooldowns()
    player:SendBroadcastMessage("已经重置物品和技能冷却")
    return true
end

function FunctionManager:RepairAll(player)
    player:DurabilityRepairAll(true, 1, false)
    player:SendBroadcastMessage("修理完所有装备。")
    return true
end

function FunctionManager:SaveToDB(player)
    player:SaveToDB()
    player:SendAreaTriggerMessage("保存数据完成")
    return true
end

function FunctionManager:Logout(player)
    player:SendAreaTriggerMessage("正在返回选择角色菜单")
    player:LogoutPlayer(true)
    return true
end

function FunctionManager:LogoutNosave(player)
    player:SendAreaTriggerMessage("正在返回选择角色菜单")
    player:LogoutPlayer(false)
    return true
end

function FunctionManager:UnBind(player)
    local nowmap = player:GetMapId()
    local unboundCount = 0
    
    for _, instance in pairs(self.instanceBindings) do
        local mapid = instance[1]
        if mapid ~= nowmap then
            player:UnbindInstance(instance[1], instance[2])
            unboundCount = unboundCount + 1
        else
            player:SendBroadcastMessage("你所在的当前副本无法解除绑定。")
        end
    end
    
    if unboundCount > 0 then
        player:SendAreaTriggerMessage("已经解除" .. unboundCount .. "个副本的绑定")
        player:SendBroadcastMessage("已经解除" .. unboundCount .. "个副本的绑定。")
    end
    
    return true
end

function FunctionManager:SummonGNPC(player)
    return ST.SummonGNPC(player)
end

function FunctionManager:SummonENPC(player)
    return ST.SummonENPC(player)
end

function FunctionManager:AddAuraToPet(player)
    return ST.AddAuraToPet(player)
end

-- 角色定制功能
local function ResetPlayer(player, flag, text)
    player:SetAtLoginFlag(flag)
    player:SendAreaTriggerMessage("你需要重新登录角色，才能修改" .. text .. "。")
    return true
end

function FunctionManager:ResetName(player)
    local target = player:GetSelection()
    if target and (target:GetTypeId() == player:GetTypeId()) then
        ResetPlayer(target, 0x1, "名字")
    else
        player:SendAreaTriggerMessage("请选中一个玩家。")
    end
    return true
end

function FunctionManager:ResetFace(player)
    ResetPlayer(player, 0x8, "外貌")
    return true
end

function FunctionManager:ResetRace(player)
    ResetPlayer(player, 0x80, "种族")
    return true
end

function FunctionManager:ResetFaction(player)
    ResetPlayer(player, 0x40, "阵营")
    return true
end

function FunctionManager:ResetSpell(player)
    ResetPlayer(player, 0x2, "所有法术")
    return true
end

-- 获取在线时间字符串
function FunctionManager:GetTimeAsString(player)
    local inGameTime = player:GetTotalPlayedTime()
    local days = math.modf(inGameTime / (24 * 3600))
    local hours = math.modf((inGameTime - (days * 24 * 3600)) / 3600)
    local mins = math.modf((inGameTime - (days * 24 * 3600 + hours * 3600)) / 60)
    return days .. "天" .. hours .. "时" .. mins .. "分"
end

-- 初始化
FunctionManager:Initialize()

return FunctionManager
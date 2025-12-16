local Config = require("config")
local ErrorHandler = require("modules.ErrorHandler")

local EnchantSystem = {}

-- 装备位置常量（已从config中移除，移到这里）
EnchantSystem.SLOTS = {
    HEAD         = 0,  -- 头部
    NECK         = 1,  -- 颈部
    SHOULDERS    = 2,  -- 肩部
    BODY         = 3,  -- 身体
    CHEST        = 4,  -- 胸甲
    WAIST        = 5,  -- 腰部
    LEGS         = 6,  -- 腿部
    FEET         = 7,  -- 脚部
    WRISTS       = 8,  -- 手腕
    HANDS        = 9,  -- 手套
    FINGER1      = 10, -- 手指1
    FINGER2      = 11, -- 手指2
    TRINKET1     = 12, -- 饰品1
    TRINKET2     = 13, -- 饰品2
    BACK         = 14, -- 背部
    MAINHAND     = 15, -- 主手
    OFFHAND      = 16, -- 副手
    RANGED       = 17, -- 远程
    TABARD       = 18  -- 徽章
}

-- 执行附魔
function EnchantSystem:EnchantItem(player, spellId, slotId)
    local success, errorMsg = ErrorHandler:SafeExecute("EnchantItem", function()
        -- 检查玩家是否装备了对应位置的物品
        local item = player:GetEquippedItemBySlot(slotId)
        if not item then
            error(string.format("装备槽 %d 没有装备物品", slotId))
        end
        
        local itemName = item:GetItemLink()
        
        -- 清除附魔（当spellId <= 0时）
        if spellId <= 0 then
            for solt = 0, 1 do
                local espellid = item:GetEnchantmentId(solt)
                if espellid and espellid > 0 then
                    item:ClearEnchantment(solt)
                    player:SendBroadcastMessage(itemName .. " 已清除附魔(" .. espellid .. ")")
                end
            end
            return true
        end
        
        -- 检查是否已经有附魔
        local existingEnchant = item:GetEnchantmentId(0)
        if existingEnchant and existingEnchant > 0 then
            -- 如果有附魔，清除第一个槽位的附魔
            item:ClearEnchantment(0)
            
            -- 如果有第二个附魔，移到第一个槽位
            local secondEnchant = item:GetEnchantmentId(1)
            if secondEnchant and secondEnchant > 0 then
                item:ClearEnchantment(1)
                item:SetEnchantment(secondEnchant, 0)
            end
            
            player:SendBroadcastMessage(itemName .. " 已替换原有附魔")
        end
        
        -- 应用新附魔
        item:SetEnchantment(spellId, 0)
        
        -- 播放附魔效果
        player:CastSpell(player, 36937, true) -- 附魔法术视觉效果
        
        -- 恢复玩家生命值
        player:SetHealth(player:GetMaxHealth())
        
        player:SendBroadcastMessage(itemName .. " 已成功附魔！")
        
        ErrorHandler:Log("INFO", string.format(
            "Enchanted %s slot %d with spell %d",
            itemName, slotId, spellId
        ), player)
        
        return true
    end, player)
    
    if not success then
        player:SendNotification("|cFFFF0000附魔失败: " .. errorMsg .. "|r")
        return false
    end
    
    return true
end

-- 获取装备槽位的名称
function EnchantSystem:GetSlotName(slotId)
    local slotNames = {
        [0] = "头盔", [1] = "项链", [2] = "肩甲", [3] = "衬衣", 
        [4] = "胸甲", [5] = "腰带", [6] = "护腿", [7] = "靴子",
        [8] = "护腕", [9] = "手套", [10] = "戒指1", [11] = "戒指2",
        [12] = "饰品1", [13] = "饰品2", [14] = "披风", [15] = "主手",
        [16] = "副手", [17] = "远程", [18] = "战袍"
    }
    return slotNames[slotId] or "未知部位"
end

-- 验证附魔是否可用于指定装备槽
function EnchantSystem:IsEnchantValidForSlot(spellId, slotId)
    -- 这里可以添加更复杂的验证逻辑
    -- 例如：某些附魔只能用于特定类型的装备
    
    -- 基本的槽位验证
    local validSlots = {
        [15] = {15, 16, 17}, -- 武器附魔可用于主手、副手、远程
        [16] = {15, 16, 17},
        [17] = {17},
        -- 可以根据需要添加更多规则
    }
    
    -- 如果没定义特殊规则，默认所有槽位都可用（除了某些特殊槽位）
    if slotId == 1 or slotId == 10 or slotId == 11 or slotId == 12 or slotId == 13 then
        -- 项链、戒指、饰品通常不能附魔
        return false
    end
    
    return true
end

-- 批量附魔（可选功能，默认禁用）
function EnchantSystem:BatchEnchant(player, enchantments)
    if not Config.ENABLE_BATCH_ENCHANT then
        player:SendNotification("|cFFFF0000批量附魔功能已禁用|r")
        return false
    end
    
    local results = {
        success = 0,
        failed = 0,
        errors = {}
    }
    
    for _, enchant in ipairs(enchantments) do
        local success, errorMsg = self:EnchantItem(player, enchant.spellId, enchant.slotId)
        
        if success then
            results.success = results.success + 1
        else
            results.failed = results.failed + 1
            table.insert(results.errors, {
                slot = enchant.slotId,
                spell = enchant.spellId,
                error = errorMsg
            })
        end
    end
    
    return results
end

return EnchantSystem
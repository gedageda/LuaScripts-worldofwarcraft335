local ErrorHandler = {}

-- 错误级别
ErrorHandler.LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

-- 日志记录
function ErrorHandler:Log(level, message, player, details)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local playerInfo = player and string.format("[%s:%d]", player:GetName(), player:GetGUIDLow()) or "[System]"
    local logMsg = string.format("%s %s [%s] %s", timestamp, playerInfo, level, message)
    
    -- 输出到控制台
    print(logMsg)
    
    -- 记录到文件（可选）
    if details then
        print("Details: " .. (type(details) == "table" and self:TableToString(details) or tostring(details)))
    end
end

-- 安全执行函数（带错误捕获）
function ErrorHandler:SafeExecute(funcName, func, player, ...)
    local success, result = pcall(func, player, ...)
    
    if not success then
        self:Log("ERROR", string.format("Function %s failed: %s", funcName, result), player)
        
        -- 给玩家发送错误提示
        if player and player:IsInWorld() then
            player:SendNotification("|cFFFF0000功能执行出错，请稍后再试|r")
        end
        
        return false, result
    end
    
    return true, result
end

-- 验证参数
function ErrorHandler:ValidateParameters(params, required)
    for _, param in ipairs(required) do
        if params[param] == nil then
            return false, string.format("Missing required parameter: %s", param)
        end
    end
    return true
end

-- 表格转字符串（用于调试）
function ErrorHandler:TableToString(tbl, indent)
    if not indent then indent = 0 end
    local str = ""
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            str = str .. formatting .. "\n" .. self:TableToString(v, indent + 1)
        else
            str = str .. formatting .. tostring(v) .. "\n"
        end
    end
    return str
end

return ErrorHandler
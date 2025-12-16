local ErrorHandler = require("modules.ErrorHandler")

local DataLoader = {
    loadedData = {},
    dataFiles = {}
}

-- 注册数据文件
function DataLoader:RegisterDataFile(name, filePath)
    self.dataFiles[name] = filePath
end

-- 加载数据文件
function DataLoader:LoadData(name)
    if self.loadedData[name] then
        return self.loadedData[name]
    end
    
    local filePath = self.dataFiles[name]
    if not filePath then
        ErrorHandler:Log("ERROR", "Data file not registered: " .. name)
        return nil
    end
    
    local success, data = pcall(dofile, filePath)
    if not success then
        ErrorHandler:Log("ERROR", "Failed to load data file: " .. name .. " - " .. data)
        return nil
    end
    
    self.loadedData[name] = data
    ErrorHandler:Log("DEBUG", "Loaded data file: " .. name)
    
    return data
end

-- 重新加载数据文件
function DataLoader:ReloadData(name)
    self.loadedData[name] = nil
    return self:LoadData(name)
end

-- 批量加载所有数据
function DataLoader:LoadAllData()
    local results = {
        success = 0,
        failed = 0,
        errors = {}
    }
    
    for name, _ in pairs(self.dataFiles) do
        local data = self:LoadData(name)
        if data then
            results.success = results.success + 1
        else
            results.failed = results.failed + 1
            table.insert(results.errors, name)
        end
    end
    
    return results
end

-- 获取已加载数据
function DataLoader:GetData(name)
    return self.loadedData[name]
end

-- 清理数据缓存
function DataLoader:ClearCache(name)
    if name then
        self.loadedData[name] = nil
    else
        self.loadedData = {}
    end
end

-- 预加载常用数据
function DataLoader:PreloadCommonData()
    -- 注册常用数据文件
    self:RegisterDataFile("teleport", "data/teleport_data.lua")
    self:RegisterDataFile("menu", "data/menu_structure.lua")
    self:RegisterDataFile("enchant", "data/enchant_data.lua")
    self:RegisterDataFile("instances", "data/instance_data.lua")
    self:RegisterDataFile("st_npc", "data/st_npc_data.lua")
    
    -- 预加载
    self:LoadAllData()
end

-- 验证数据完整性
function DataLoader:ValidateData(name)
    local data = self:GetData(name)
    if not data then
        return false, "Data not loaded"
    end
    
    -- 基本验证（可根据数据类型扩展）
    if type(data) ~= "table" then
        return false, "Data is not a table"
    end
    
    -- 检查必需字段（根据数据类型自定义）
    if name == "teleport" then
        for _, location in pairs(data.Cities or {}) do
            if not location.name or not location.map or not location.x or not location.y or not location.z then
                return false, "Invalid teleport location data"
            end
        end
    end
    
    return true, "Data validation passed"
end

-- 获取数据统计信息
function DataLoader:GetStats()
    local stats = {
        totalFiles = 0,
        loadedFiles = 0,
        fileDetails = {}
    }
    
    for name, filePath in pairs(self.dataFiles) do
        stats.totalFiles = stats.totalFiles + 1
        local isLoaded = self.loadedData[name] ~= nil
        if isLoaded then
            stats.loadedFiles = stats.loadedFiles + 1
        end
        
        stats.fileDetails[name] = {
            path = filePath,
            loaded = isLoaded,
            type = type(self.loadedData[name])
        }
    end
    
    return stats
end

return DataLoader
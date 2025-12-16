local VendorData = {
    categories = {},
    items = {},
    loaded = false
}

-- 物品分类定义
local CATEGORY_DEFINITIONS = {
    [1] = {name = "职业雕文", icon = 3},
    [2] = {name = "钥匙", icon = 6},
    [3] = {name = "宝石", icon = 8},
    [4] = {name = "材料物品", icon = 1},
    [5] = {name = "传家宝装备", icon = 9},
}

-- 子分类定义
local SUBCATEGORY_DEFINITIONS = {
    [1] = { -- 职业雕文子分类
        {id = 0x10, name = "盗贼雕文", icon = 3},
        {id = 0x20, name = "德鲁伊雕文", icon = 3},
        {id = 0x30, name = "法师雕文", icon = 3},
        {id = 0x40, name = "猎人雕文", icon = 3},
        {id = 0x50, name = "牧师雕文", icon = 3},
        {id = 0x60, name = "骑士雕文", icon = 3},
        {id = 0x70, name = "萨满雕文", icon = 3},
        {id = 0x80, name = "术士雕文", icon = 3},
        {id = 0x90, name = "死骑雕文", icon = 3},
        {id = 0xA0, name = "战士雕文", icon = 3},
    },
    [2] = { -- 钥匙子分类
        {id = 0x10, name = "经典旧世钥匙", icon = 6},
        {id = 0x20, name = "燃烧远征钥匙", icon = 6},
        {id = 0x30, name = "巫妖王之怒钥匙", icon = 6},
    },
    [3] = { -- 宝石子分类
        {id = 0x40, name = "普通宝石", icon = 8},
        {id = 0x50, name = "高级宝石", icon = 8},
    },
    [4] = { -- 材料物品子分类
        {id = 0x60, name = "初级材料", icon = 1},
        {id = 0x70, name = "中级材料", icon = 1},
        {id = 0x80, name = "高级材料", icon = 1},
        {id = 0xA0, name = "稀有材料", icon = 1},
    },
}

-- 物品数据（部分示例，完整数据需要从原脚本迁移）
local ITEM_DATA = {
    -- 传家宝
    [0x90] = {
        42943, 42944, 42945, 42946, 42947,
        42948, 42949, 42950, 42951, 42952,
        42984, 42985, 42991, 42992, 44091,
        44092, 44093, 44094, 44095, 44096,
        44097, 44098, 44099, 44100, 44101,
        44102, 44103, 44105, 44107, 48677,
        48683, 48685, 48687, 48689, 48691,
        48716, 48718, 50255, 21537, 6265,
        23162,
    },
    
    -- 初级材料
    [0x60] = {
        22446, 23571, 22452, 21884, 23427,
        23426, 23425, 23424, 36909, 765,
        785, 961, 1274, 2447, 2449, 2450,
        2452, 2453, 2676, 2784, 3355, 3356,
        3357, 3358, 3369, 3418, 3502, 3713,
        -- ... 更多物品ID
    },
    
    -- 盗贼雕文
    [0x10] = {
        42954, 42955, 42956, 42957, 42958,
        42959, 42960, 42961, 42962, 42963,
        42964, 42965, 42966, 42967, 42968,
        42969, 42970, 42971, 42972, 42973,
        42974, 43343, 43376, 43377, 43378,
        43379, 43380, 45761, 45762, 45764,
        45766, 45767, 45768, 45769, 45908,
    },
    
    -- 普通宝石
    [0x40] = {
        774, 818, 1210, 1529, 1705,
        3864, 5498, 5500, 7909, 7910,
        7971, 11382, 12361, 12363, 12364,
        12799, 12800, 13926, 23117, 21929,
        23077, 23079, 23107, 23112, 23436,
        23437, 23438, 23439, 23440, 23441,
        24478, 24479, 25867, 25868, 23234,
        23364, 27864, 32227, 32249, 32230,
        32229, 32231,
    },
    
    -- 经典旧世钥匙
    [0x10] = {
        2629, 2719, 3467, 3499, 3704,
        3930, 4103, 4483, 4484, 4485,
        4882, 5020, 5050, 5089, 5396,
        5475, 5517, 5518, 5521, 5687,
        5689, 5690, 5691, 5851, 6077,
        6783, 6893, 7146, 7208, 7442,
        7498, 7499, 7500, 7923, 8072,
        8147, 8444, 9249, 9275, 9472,
        11000, 11078, 11106, 11140, 11197,
        11602, 11818, 12301, 12382, 12738,
        12739, 12942, 13140, 13194, 13195,
        13196, 13197, 13302, 13303, 13304,
        13305, 13306, 13307, 13704, 13873,
    },
}

-- 加载所有数据
function VendorData:LoadAll()
    if self.loaded then return true, "Already loaded" end
    
    print("Loading vendor data...")
    
    -- 构建分类结构
    self:BuildCategories()
    
    -- 验证数据
    local valid, errorMsg = self:ValidateData()
    if not valid then
        return false, "Data validation failed: " .. errorMsg
    end
    
    self.loaded = true
    print(string.format(
        "Vendor data loaded: %d categories, %d item groups",
        #self.categories, self:GetItemGroupCount()
    ))
    
    return true
end

-- 构建分类结构
function VendorData:BuildCategories()
    self.categories = {}
    
    for id, info in pairs(CATEGORY_DEFINITIONS) do
        table.insert(self.categories, {
            id = id,
            name = info.name,
            icon = info.icon,
            hasSubcategories = SUBCATEGORY_DEFINITIONS[id] ~= nil
        })
    end
    
    -- 按ID排序
    table.sort(self.categories, function(a, b)
        return a.id < b.id
    end)
end

-- 获取所有分类
function VendorData:GetCategories()
    return self.categories
end

-- 获取分类信息
function VendorData:GetCategoryInfo(categoryId)
    for _, category in ipairs(self.categories) do
        if category.id == categoryId then
            return category
        end
    end
    return nil
end

-- 获取子分类
function VendorData:GetSubcategories(categoryId)
    return SUBCATEGORY_DEFINITIONS[categoryId]
end

-- 获取物品列表
function VendorData:GetItems(categoryId)
    return ITEM_DATA[categoryId] or {}
end

-- 获取物品详情
function VendorData:GetItemDetails(itemId)
    -- 这里可以扩展为返回物品的详细信息
    -- 目前只返回物品ID数组
    return {itemId}
end

-- 获取物品组数量
function VendorData:GetItemGroupCount()
    local count = 0
    for _ in pairs(ITEM_DATA) do
        count = count + 1
    end
    return count
end

-- 验证数据
function VendorData:ValidateData()
    local errors = {}
    
    -- 验证分类数据
    for id, info in pairs(CATEGORY_DEFINITIONS) do
        if not info.name then
            table.insert(errors, "Category " .. id .. " missing name")
        end
    end
    
    -- 验证物品数据
    for categoryId, items in pairs(ITEM_DATA) do
        if not CATEGORY_DEFINITIONS[bit_and(categoryId, 0xF0)] then
            table.insert(errors, "Items for unknown category: " .. categoryId)
        end
        
        if type(items) ~= "table" then
            table.insert(errors, "Invalid items for category: " .. categoryId)
        else
            for _, itemId in ipairs(items) do
                if type(itemId) ~= "number" or itemId <= 0 then
                    table.insert(errors, "Invalid item ID in category " .. categoryId)
                end
            end
        end
    end
    
    if #errors > 0 then
        return false, table.concat(errors, ", ")
    end
    
    return true
end

-- 添加新物品组（运行时添加）
function VendorData:AddItemGroup(categoryId, items)
    if not categoryId or not items or type(items) ~= "table" then
        return false, "Invalid parameters"
    end
    
    ITEM_DATA[categoryId] = items
    return true
end

-- 移除物品组
function VendorData:RemoveItemGroup(categoryId)
    ITEM_DATA[categoryId] = nil
    return true
end

-- 搜索物品
function VendorData:SearchItems(searchTerm)
    local results = {}
    searchTerm = string.lower(searchTerm)
    
    for categoryId, items in pairs(ITEM_DATA) do
        for _, itemId in ipairs(items) do
            -- 这里可以扩展为根据物品名称搜索
            -- 目前只按ID搜索
            if tostring(itemId):find(searchTerm) then
                table.insert(results, {
                    itemId = itemId,
                    categoryId = categoryId
                })
            end
        end
    end
    
    return results
end

-- 导出数据统计
function VendorData:GetStats()
    local totalItems = 0
    for _, items in pairs(ITEM_DATA) do
        totalItems = totalItems + #items
    end
    
    return {
        categories = #self.categories,
        itemGroups = self:GetItemGroupCount(),
        totalItems = totalItems,
        loaded = self.loaded
    }
end

return VendorData
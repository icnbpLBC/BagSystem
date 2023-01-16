PlayerDataMamager = PlayerDataMamager or BaseClass(BaseManager)
-- todo 文本资源和预制体资源处理方式
-- todo 非面板类型资源异步加载
function PlayerDataMamager:__init()
    PlayerDataMamager.Instance = self
    self.itemDataJsonStr = PreLoadDataManager.Instance:GetEntity("itemdata", "ItemData")
end

function PlayerDataMamager:InitBagData()
    -- 根据Json字符串反序列化出所有物品数据【返回数组】
    self.itemData = Json.decode(self.itemDataJsonStr.text)
    -- 对应分类表
    self.equipCategory = {}
    self.gemCategory = {}
    self.itemCategory = {}
    -- 分类存储用户数据
    for i, v in pairs(self.itemData) do
        if v.type == 'equip' then
            table.insert(self.equipCategory, v)
        elseif v.type == 'gem' then
            table.insert(self.gemCategory, v)
        else
            table.insert(self.itemCategory, v)
        end
    end
end

-- 根据物品id添加新的物品
function PlayerDataMamager:InsertNewItem(tar)
    local table = Copy(self.itemData[tar])
    -- 深拷贝
    self.itemData[#self.itemData + 1] = table
    -- 根据物品类别 新物品加入相应类别的表中
    if self.itemData[tar].type == 'equip' then
        self.equipCategory[#self.equipCategory + 1] = table
    elseif self.itemData[tar].type == 'item' then
        self.itemCategory[#self.itemCategory + 1] = table
    else
        self.gemCategory[#self.gemCategory + 1] = table
    end
    -- todo 序列化相关
end

-- 删除指定的一个物品
function PlayerDataMamager:DeleteItem(realIndex)
    -- 根据位置和状态获取引用 再在集合中找到对应引用删除 引用对应的表将被垃圾回收
    local status = BagManager.Instance:GetCateStatus()
    if status == BagEnum.All then
        local tar = self.itemData[realIndex]
        table.remove(self.itemData, realIndex)
        if tar.type == 'equip' then
            self:DeleteItemInTarTable(self.equipCategory, tar)
        elseif tar.type == 'item' then
            self:DeleteItemInTarTable(self.itemCategory, tar)
        else
            self:DeleteItemInTarTable(self.gemCategory, tar)
        end
    elseif status == BagEnum.Equip then
        local tar = self.equipCategory[realIndex]
        table.remove(self.equipCategory, realIndex)
        self:DeleteItemInTarTable(self.itemData, tar)
    elseif status == BagEnum.Item then
        local tar = self.itemCategory[realIndex]
        table.remove(self.itemCategory, realIndex)
        self:DeleteItemInTarTable(self.itemData, tar)
    else
        local tar = self.gemCategory[realIndex]
        table.remove(self.gemCategory, realIndex)
        self:DeleteItemInTarTable(self.itemData, tar)
    end
end

-- 删除指定表中的元素
function PlayerDataMamager:DeleteItemInTarTable(tarTable, tar)
    local index = FindKey(tarTable, tar)
    if index ~= nil then
        table.remove(tarTable, index)
    end
end
PlayerDataMamager = PlayerDataMamager or BaseClass(BaseManager)
-- todo 文本资源和预制体资源处理方式

function PlayerDataMamager:__init()
    PlayerDataMamager.Instance = self
    self.itemDataJsonStr = nil
    local cb = function(asset)
        self.itemDataJsonStr = asset
        -- 增加引用计数
        CS.ABMgr.Instance:AddReferenceCount("itemdata", "ItemData")
    end
    CS.ABMgr.Instance:LoadRes("itemdata", "ItemData", typeof(CS.UnityEngine.TextAsset), cb, 1)

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
    -- 仅仅只是浅拷贝
    self.itemData[#self.itemData + 1] = self.itemData[tar]
    -- 根据物品类别 新物品加入相应类别的表中
    if self.itemData[tar].type == 'equip' then
        self.equipCategory[#self.equipCategory + 1] = self.itemData[tar]
    elseif self.itemData[tar].type == 'item' then
        self.itemCategory[#self.itemCategory + 1] = self.itemData[tar]
    else
        self.gemCategory[#self.gemCategory + 1] = self.itemData[tar]
    end
    -- todo 序列化相关
end

function PlayerDataMamager:DeleteLastItem(realIndex)
    local status = BagManager.Instance:GetCateStatus()
    if status == 0 then
        table.remove(self.itemData, realIndex)
    elseif status == 1 then
        table.remove(self.equipCategory, realIndex)
    elseif status == 2 then
        table.remove(self.itemCategory, realIndex)
    else
        table.remove(self.gemCategory, realIndex)
    end
end

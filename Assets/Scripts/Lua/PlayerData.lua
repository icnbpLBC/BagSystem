PlayerData = Object:subClass("PlayerData")
-- todo 文本资源和预制体资源处理方式
ItemDataJsonStr = nil
local cb = function (asset)
    ItemDataJsonStr = asset
    -- 增加引用计数
    CS.ABMgr.Instance:AddReferenceCount("itemdata", "ItemData")
end
CS.ABMgr.Instance:LoadRes("itemdata", "ItemData", typeof(CS.UnityEngine.TextAsset), cb, 0)

PlayerData.itemData = nil


function PlayerData:Init()
    -- 根据Json字符串反序列化出物品数据【返回数组】
    PlayerData.itemData = Json.decode(ItemDataJsonStr.text)
end
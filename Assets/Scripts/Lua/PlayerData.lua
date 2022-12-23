ItemDataJsonStr = CS.ABMgr.Instance:LoadRes("itemdata", "ItemData", typeof(CS.UnityEngine.TextAsset))
PlayerData = Object:subClass("PlayerData")
PlayerData.itemData = nil

function PlayerData:Init()
    -- 根据Json字符串反序列化出物品数据【返回数组】
    PlayerData.itemData = Json.decode(ItemDataJsonStr.text)
end
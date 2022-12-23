-- 物品类
ItemContent = Object:subClass("ItemContent")

-- 物品类属性 主要保存对应C#实例对象和相关UI组件
ItemContent.itemObj = nil
ItemContent.itemImg = nil
ItemContent.itemTxt = nil

-- 根据物品信息 更新UI
function ItemContent:Init(info)
    -- 调用AB包管理器加载对应包内对应资源
    self.itemObj = CS.ABMgr.Instance:LoadRes("prefabs", "ItemContent", typeof(CS.UnityEngine.GameObject), BagPanel.itemPanelObjTrans)
    self.itemImg = self.itemObj.transform:Find("Bg/ItemImg"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    self.itemTxt = self.itemObj.transform:Find("Bg/ItemTxt"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    self.itemImg.sprite = BagPanel.spriteAtlasObj:GetSprite(CS.ProjectConstantData.ItemsNameArray[info.id])
    self.itemTxt.text = info.num
end
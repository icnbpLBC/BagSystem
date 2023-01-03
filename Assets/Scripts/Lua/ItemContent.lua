-- 物品类
ItemContent = Object:subClass("ItemContent")

-- 物品类属性 主要保存对应C#实例对象和相关UI组件
ItemContent.itemObj = nil
ItemContent.itemImg = nil
ItemContent.itemTxt = nil
ItemContent.itemBtn = nil
ItemContent.itemSelectObj = nil
ItemContent.isSelected = false
ItemContent.itemId = nil
-- 物品相对content的位置
ItemContent.posi = nil


ItemContent.row = nil
ItemContent.column = nil


-- 根据物品信息 更新UI
function ItemContent:Init(info)
    -- 调用AB包管理器加载对应包内对应资源
    self.itemObj = CS.ABMgr.Instance:LoadRes("prefabs", "ItemContent", typeof(CS.UnityEngine.GameObject), BagPanel.scrollContentTrans)
    self.itemImg = self.itemObj.transform:Find("Bg/ItemImg"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    self.itemTxt = self.itemObj.transform:Find("Bg/ItemTxt"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    self.itemBtn = self.itemObj.transform:Find("Bg"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.itemSelectObj = self.itemObj.transform:Find("Bg/ItemSelect").gameObject
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).pivot = CS.UnityEngine.Vector2(0, 1)
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchorMin = CS.UnityEngine.Vector2(0,1)
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchorMax = CS.UnityEngine.Vector2(0,1)
    self.row = info.row
    self.column = info.column
    self:Show()
end

-- 设置物品锚点和中心点 以及相对锚点位置
function ItemContent:InitPos(position) 
    self.posi = position
    -- todo 设置相对锚点位置
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchoredPosition = CS.UnityEngine.Vector2(self.posi.x, self.posi.y)
    self:ChangeActive(true)
end


-- 更改相对锚点的x位置
function ItemContent:ChangeX(x)
    self.posi.x = x
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchoredPosition = CS.UnityEngine.Vector2(self.posi.x, self.posi.y)
    
end
function ItemContent:ChangeActive(status)
    self.itemObj:SetActive(status)
end

-- 更新GO组件
function ItemContent:Update(info)
    -- 更新时一定未被选中
    self.itemSelectObj:SetActive(false)
    if info.id ~= nil then
        self.itemId = info.id 
        self.itemImg.sprite = BagPanel.spriteAtlasObj:GetSprite(CS.ProjectConstantData.ItemsNameArray[self.itemId])
        self.itemTxt.text = info.num
    else
        self.itemId = nil 
        self.itemImg.sprite = nil
        self.itemTxt.text = ""
    end
    
end
function ItemContent:Show()
    self:AddEvent()
end

function ItemContent:AddEvent()
    self.itemBtn.onClick:AddListener(function ()
        self:OnItemSelectedClick()
    end)
end

function ItemContent:ChangeSelectedState()
    self.itemSelectObj:SetActive(not self.itemSelectObj.activeSelf)
end

-- 物品选中框 如果已被选中 则框消失  如果未被选中 则被选中的框消失 自己的框出现
function ItemContent:OnItemSelectedClick()
    if self.itemSelectObj.activeSelf then
        BagManager:SetSelectedRowAndColumn(nil, nil)
    end
    self:ChangeSelectedState()
    if self.itemSelectObj.activeSelf then
        if BagManager:GetSelectedRowAndColumn().row ~= nil then
            
            BagManager:ChangeSelectedStatus()
        end
        BagManager:SetSelectedRowAndColumn(self.row, self.column)
    end
    
end
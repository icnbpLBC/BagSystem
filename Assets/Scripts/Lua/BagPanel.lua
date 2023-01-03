-- 继承于Object
BagPanel = Object:subClass("BagPanel")

-- 背包面板类特有属性
BagPanel.isInit = false
BagPanel.panelObj = nil
BagPanel.cloBtn = nil
-- 物品面板位置 便于后续物品实例化时设置父对象
BagPanel.scrollContentTrans = nil

-- 图集对象
BagPanel.spriteAtlasObj = nil

-- 各按钮组件
BagPanel.allItemBtn = nil
BagPanel.equipCateBtn = nil
BagPanel.itemCateBtn = nil
BagPanel.gemCateBtn = nil

-- 初始化过程
function BagPanel:Init()
    if (self.isInit == false) then
        self.panelObj = CS.ABMgr.Instance:LoadRes("prefabs", "BagPanel", typeof(CS.UnityEngine.GameObject), Canvas)
        self.cloBtn = self.panelObj.transform:Find("Bg/CloBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.allItemBtn = self.panelObj.transform:Find("Bg/AllItemBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.equipCateBtn = self.panelObj.transform:Find("Bg/EquipCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.itemCateBtn = self.panelObj.transform:Find("Bg/ItemCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.gemCateBtn = self.panelObj.transform:Find("Bg/GemCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.spriteAtlasObj = CS.ABMgr.Instance:LoadRes("imgs", "Items", typeof(CS.UnityEngine.U2D.SpriteAtlas))
        self.scrollContentTrans = self.panelObj.transform:Find("Bg/ItemPanel/ScrollView/Viewport/Content")


        self.isInit = true
        BagManager:LoadItemContents()
        self:InitBag()
        self:OnAllItemBtnClick()
    end
    self:Show()

end

function BagPanel:InitBag()
    self.scrollContentTrans.anchorMin = CS.UnityEngine.Vector2(0, 0)
    self.scrollContentTrans.anchorMax = CS.UnityEngine.Vector2(0, 1)
    self.scrollContentTrans:GetComponent(typeof(CS.UnityEngine.RectTransform)).sizeDelta = CS.UnityEngine.Vector2(BagManager:GetContentsSize(), 0)

end

function BagPanel:Show()
    self.panelObj:SetActive(true)
    self:AddEvent()
end

function BagPanel:Hide()
    self:DelEvent()
    self.panelObj:SetActive(false)
end

function BagPanel:AddEvent()
    self.panelObj.transform:Find("Bg/ItemPanel/ScrollView"):GetComponent(typeof(CS.UnityEngine.UI.ScrollRect)).onValueChanged
        :AddListener(function(vec2)
            self:OnScrollMoveWidth(vec2)
        end)
    self.cloBtn.onClick:AddListener(function()
        self:OnCloBtnClick()
    end)
    self.allItemBtn.onClick:AddListener(function()
        self:OnAllItemBtnClick()
    end)
    self.equipCateBtn.onClick:AddListener(function()
        self:OnEquipCateBtnClick()
    end)
    self.itemCateBtn.onClick:AddListener(function()
        self:OnItemCateBtnClick()
    end)
    self.gemCateBtn.onClick:AddListener(function()
        self:OnGemCateBtnClick()
    end)
end

function BagPanel:DelEvent()
    self.cloBtn.onClick:RemoveAllListeners()
    self.allItemBtn.onClick:RemoveAllListeners()
    self.equipCateBtn.onClick:RemoveAllListeners()
    self.itemCateBtn.onClick:RemoveAllListeners()
    self.gemCateBtn.onClick:RemoveAllListeners()
end

function BagPanel:ClearCateClick()
    self.panelObj.transform:Find("Bg/AllItemBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.panelObj.transform:Find("Bg/EquipCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.panelObj.transform:Find("Bg/ItemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.panelObj.transform:Find("Bg/GemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
end

function BagPanel:OnScrollMoveWidth(vec2)
    BagManager:ScrollMove(self.scrollContentTrans.anchoredPosition.x)
end

function BagPanel:OnAllItemBtnClick()
    -- 清空选中颜色
    self:ClearCateClick()
    -- 修改状态
    -- self.categoryStatus = 0
    BagManager:UpdateCateStatus(0)
    -- 更改颜色为选中
    self.panelObj.transform:Find("Bg/AllItemBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- 显示物品
    -- self:ShowCateData()
    -- 还原content位置
    BagManager:ShowCateData()
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
end

function BagPanel:OnEquipCateBtnClick()
    self:ClearCateClick()
    -- self.categoryStatus = 1
    BagManager:UpdateCateStatus(1)
    self.panelObj.transform:Find("Bg/EquipCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    --self:ShowCateData()
    -- 还原content位置
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
    BagManager:ShowCateData()
end

function BagPanel:OnItemCateBtnClick()
    self:ClearCateClick()
    -- self.categoryStatus = 2
    BagManager:UpdateCateStatus(2)
    self.panelObj.transform:Find("Bg/ItemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- self:ShowCateData()
    -- 还原content位置
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
    BagManager:ShowCateData()
end

-- todo content大小与对应分类大小匹配
function BagPanel:OnGemCateBtnClick()
    self:ClearCateClick()
    -- self.categoryStatus = 3
    BagManager:UpdateCateStatus(3)
    self.panelObj.transform:Find("Bg/GemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- self:ShowCateData()
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
    BagManager:ShowCateData()
end


-- 关闭按钮点击事件
function BagPanel:OnCloBtnClick()
    self:Hide()
end

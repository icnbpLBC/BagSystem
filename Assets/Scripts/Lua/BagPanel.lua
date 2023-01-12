-- 继承于Object
-- BagPanel = Object:subClass("BagPanel")
BagPanel = BagPanel or BaseClass(BasePanel)
function BagPanel:__init()
    -- todo 资源管理器封装事件对象

    self.assetList = 
    {{abName = "prefabs", assetName = "BagPanel", type = typeof(CS.UnityEngine.GameObject)},
    {abName = "imgs", assetName = "Items", type = typeof(CS.UnityEngine.U2D.SpriteAtlas)}}
    
end

-- 背包面板初始化
function BagPanel:InitView()
    -- GO实例化
    self.gameObject = self:GetEntity("prefabs", "BagPanel", Canvas)
    self.spriteAtlasObj = self:GetEntity("imgs", "Items")
    -- 确保加载完
    self.cloBtn = self.gameObject.transform:Find("Bg/CloBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.allItemBtn = self.gameObject.transform:Find("Bg/AllItemBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.equipCateBtn = self.gameObject.transform:Find("Bg/EquipCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.itemCateBtn = self.gameObject.transform:Find("Bg/ItemCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.gemCateBtn = self.gameObject.transform:Find("Bg/GemCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.scrollContentTrans = self.gameObject.transform:Find("Bg/ItemPanel/ScrollView/Viewport/Content")
    self.AddBtn = self.gameObject.transform:Find("Bg/AddBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.DeleteBtn = self.gameObject.transform:Find("Bg/DeleteBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    BagManager.Instance:LoadItemContents()
    self:InitBag()
    self:Show() 
    self:OnAllItemBtnClick()
end

-- 面板GO依据资源实例化
function BagPanel:Instantiate(asset, parent)
    self.gameObject = CS.UnityEngine.GameObject.Instantiate(asset, parent)
    -- 增加引用计数
    CS.ABMgr.Instance:AddReferenceCount("prefabs", "BagPanel")
end

function BagPanel:InitBag()
    self.scrollContentTrans.anchorMin = CS.UnityEngine.Vector2(0, 0)
    self.scrollContentTrans.anchorMax = CS.UnityEngine.Vector2(0, 1)
    self.scrollContentTrans:GetComponent(typeof(CS.UnityEngine.RectTransform)).sizeDelta = CS.UnityEngine.Vector2(BagManager.Instance:GetContentsSize(), 0)

end

function BagPanel:Show()

    self.gameObject:SetActive(true)
    self:AddEvent()

end

function BagPanel:Hide()
    self:DelEvent()
    self.gameObject:SetActive(false)
end

function BagPanel:AddEvent()
    self.gameObject.transform:Find("Bg/ItemPanel/ScrollView"):GetComponent(typeof(CS.UnityEngine.UI.ScrollRect)).onValueChanged
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

    self.AddBtn.onClick:AddListener(function ()
        BagManager.Instance:AddItem()
    end)
    self.DeleteBtn.onClick:AddListener(function ()
        BagManager.Instance:DeleteItem()
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
    self.gameObject.transform:Find("Bg/AllItemBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.gameObject.transform:Find("Bg/EquipCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.gameObject.transform:Find("Bg/ItemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.gameObject.transform:Find("Bg/GemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
end

function BagPanel:OnScrollMoveWidth(vec2)
    BagManager.Instance:ScrollMove(self.scrollContentTrans.anchoredPosition.x)
end

function BagPanel:OnAllItemBtnClick()
    -- 清空选中颜色
    self:ClearCateClick()
    -- 修改状态
    -- self.categoryStatus = 0
    BagManager.Instance:UpdateCateStatus(0)
    -- 更改颜色为选中
    self.gameObject.transform:Find("Bg/AllItemBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- 显示物品
    -- 还原content位置
    BagManager.Instance:ShowCateData()
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
end

function BagPanel:OnEquipCateBtnClick()
    self:ClearCateClick()
    -- self.categoryStatus = 1
    BagManager.Instance:UpdateCateStatus(1)
    self.gameObject.transform:Find("Bg/EquipCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    --self:ShowCateData()
    -- 还原content位置
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
    BagManager.Instance:ShowCateData()
end

function BagPanel:OnItemCateBtnClick()
    self:ClearCateClick()
    -- self.categoryStatus = 2
    BagManager.Instance:UpdateCateStatus(2)
    self.gameObject.transform:Find("Bg/ItemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- self:ShowCateData()
    -- 还原content位置
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
    BagManager.Instance:ShowCateData()
end

-- todo content大小与对应分类大小匹配
function BagPanel:OnGemCateBtnClick()
    self:ClearCateClick()
    -- self.categoryStatus = 3
    BagManager.Instance:UpdateCateStatus(3)
    self.gameObject.transform:Find("Bg/GemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- self:ShowCateData()
    self.scrollContentTrans.anchoredPosition = CS.UnityEngine.Vector2(0,0)
    BagManager.Instance:ShowCateData()
end


-- 关闭按钮点击事件
function BagPanel:OnCloBtnClick()
    self:Hide()
end

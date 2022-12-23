-- 继承于Object
BagPanel = Object:subClass("BagPanel")

-- 背包面板类特有属性
BagPanel.isInit = false
BagPanel.panelObj = nil
BagPanel.cloBtn = nil
-- 物品面板位置 便于后续物品实例化时设置父对象
BagPanel.itemPanelObjTrans = nil
BagPanel.itemContents = {}
-- 图集对象
BagPanel.spriteAtlasObj = nil
BagPanel.itemDatas = {}

-- 初始化过程
function BagPanel:Init()
    if (self.isInit == false) then
        self.panelObj = CS.ABMgr.Instance:LoadRes("prefabs", "BagPanel", typeof(CS.UnityEngine.GameObject), Canvas)
        self.cloBtn = self.panelObj.transform:Find("Bg/CloBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.spriteAtlasObj = CS.ABMgr.Instance:LoadRes("imgs", "Items", typeof(CS.UnityEngine.U2D.SpriteAtlas))
        self.itemPanelObjTrans = self.panelObj.transform:Find("Bg/ItemPanel")
        self.isInit = true
        self:LoadItemContents()
    end
    self:Show()
    
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
    self.cloBtn.onClick:AddListener(function()
        self:OnCloBtnClick()
    end)
end

function BagPanel:DelEvent()
    self.cloBtn.onClick:RemoveAllListeners()
end

-- 关闭按钮点击事件
function BagPanel:OnCloBtnClick()
    self:Hide()
end


-- 加载物品内容
function BagPanel:LoadItemContents()
    -- 获取用户数据
    -- 实例化物品预设 更新预设对应组件属性
    PlayerData:Init()
    for i, v in pairs(PlayerData.itemData) do
        obj = ItemContent:new()
        obj:Init(v)
        table.insert(self.itemDatas, obj)
    end
end

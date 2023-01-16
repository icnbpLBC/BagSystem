-- MainPanel = Object:subClass("MainPanel")
MainPanel = MainPanel or BaseClass(BasePanel)
-- 主面板封装的属性
-- MainPanel.panelObj = nil
-- MainPanel.charaBtn = nil
-- MainPanel.isInit = false


-- 对外接口
function MainPanel:__init()
    self.assetList = 
    {{abName = "prefabs", assetName = "MainPanel", type = typeof(CS.UnityEngine.GameObject)}}
end


-- function MainPanel:Instantiate(asset, parent)
--     self.panelObj = CS.UnityEngine.GameObject.Instantiate(asset, parent)
--     -- 增加引用计数
--     CS.ABMgr.Instance:AddReferenceCount("prefabs", "MainPanel")
    
-- end

function MainPanel:InitView()
    self.gameObject = self:GetEntity("prefabs", "MainPanel", Canvas)
    self.charaBtn = self.gameObject.transform:Find("CharaBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    PlayerDataMamager:New()
    ItemContentManager:New()
    BagManager.New()
    self:Show()
end
function MainPanel:Show()
    self:AddEvent()
end

function MainPanel:Hide()
    self:DelEvent()
end

function MainPanel:AddEvent()
    -- 闭包
    self.charaBtn.onClick:AddListener(function ()
        self:OnCharaBtnClick()
    end)
end

function MainPanel:DelEvent()
    self.charaBtn.onClick:RemoveAllListeners()
end

function MainPanel:OnCharaBtnClick()
    BagManager.Instance.model:InitBagPanel()
end
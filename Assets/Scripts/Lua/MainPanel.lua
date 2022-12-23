MainPanel = Object:subClass("MainPanel")

-- 主面板封装的属性
MainPanel.panelObj = nil
MainPanel.charaBtn = nil
MainPanel.isInit = false


-- 对外接口
function MainPanel:Init()
    if MainPanel.isInit == false then
        self.panelObj = CS.ABMgr.Instance:LoadRes("prefabs", "MainPanel", typeof(CS.UnityEngine.GameObject), Canvas);
        self.charaBtn = self.panelObj.transform:Find("CharaBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.isInit = false
    end
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
    BagPanel:Init()
end
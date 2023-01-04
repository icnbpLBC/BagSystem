-- MainPanel = Object:subClass("MainPanel")
MainPanel = MainPanel or BaseClass(BasePanel)
-- 主面板封装的属性
-- MainPanel.panelObj = nil
-- MainPanel.charaBtn = nil
-- MainPanel.isInit = false


-- 对外接口
function MainPanel:__init()
    local cb = function (asset)
        self:Instantiate(asset, Canvas)
        -- 确保资源加载完成才进行下部动作
        self.charaBtn = self.panelObj.transform:Find("CharaBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        BagManager.New()
        self:Show()
    end
    CS.ABMgr.Instance:LoadRes("prefabs", "MainPanel", typeof(CS.UnityEngine.GameObject), cb, 1);
end


function MainPanel:Instantiate(asset, parent)
    self.panelObj = CS.UnityEngine.GameObject.Instantiate(asset, parent)
    -- 增加引用计数
    CS.ABMgr.Instance:AddReferenceCount("prefabs", "MainPanel")
    
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
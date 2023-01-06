BasePanel = BasePanel or BaseClass()
function BasePanel:__init()
    self.loadFinish = false
end

-- 资源加载事件完成后进行初始化
function BasePanel:OnResLoadCompleted()
    -- 初始化面板
    self:InitPanel()
    self.loadFinish = true
end

function BasePanel:LoadAsset()
    if(self.assetLoader == nil) then
        self.assetLoader = AssetLoader:New()
    end
    local cb = function ()
        self:OnResLoadCompleted()
    end
    self.assetLoader:AddListener(cb)
    self.assetLoader:LoadAllAssets(self.assetList)
end
-- 子类实现
function BasePanel:InitPanel()
    
end

function BasePanel:Open()
    if(self.loadFinish == true) then
        self.panelObj:SetActive(true)
    end
end
function BasePanel:__delete()
    
end

function BasePanel:GetEntity(abName, assetName, parent)
    return self.assetLoader:GetEntity(abName, assetName, parent)
end
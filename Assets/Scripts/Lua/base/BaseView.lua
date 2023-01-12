BaseView = BaseView or BaseClass()

function BaseView:__init()
    self.loadFinish = false
end

-- 资源加载事件完成后进行初始化
function BaseView:OnResLoadCompleted()
    -- 初始化视图
    self:InitView()
    self.loadFinish = true
end

function BaseView:LoadAsset()
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
function BaseView:InitView()
    
end

function BaseView:GetEntity(abName, assetName, parent)
    return self.assetLoader:GetEntity(abName, assetName, parent)
end
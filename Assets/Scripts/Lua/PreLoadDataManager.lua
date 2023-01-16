PreLoadDataManager = PreLoadDataManager or BaseClass(BagManager)

function PreLoadDataManager:__init()
    self.assetList = { { abName = "prefabs", assetName = "ItemContent", type = typeof(CS.UnityEngine.GameObject) }
        , { abName = "itemdata", assetName = "ItemData", type = typeof(CS.UnityEngine.TextAsset) } }
    self.assetLoader = AssetLoader.New()
    PreLoadDataManager.Instance = self
    self:PreLoadData()
end

function PreLoadDataManager:PreLoadData()
    -- todo 添加提前加载的监听
--    self.assetLoader:AddListener() 
    self.assetLoader:SetLoadMethod(LoaderEnum.loaderMethod.Sync)
   self.assetLoader:LoadAllAssets(self.assetList)
end

function PreLoadDataManager:GetEntity(abName, assetName, parent)
    return self.assetLoader:GetEntity(abName, assetName, parent)
end
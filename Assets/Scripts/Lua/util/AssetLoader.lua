 
AssetLoader = AssetLoader or BaseClass()

function AssetLoader:__init()
  -- {abName, assetName, type, asset}
  self.assetList = nil
  self.event = nil
end


-- 添加资源加载监听
function AssetLoader:AddListener(cb)
  if(self.event == nil) then
    self.event = EventLib.New()
  end
  self.event:Add(cb)
end

-- 加载所有资源并进行统一的回调
function AssetLoader:LoadAllAssets(assetList)
  self.assetList = assetList
  for key, data in pairs(self.assetList) do
    local cb = function (asset)
      self:SetDataAsset(asset, data)
      -- 所有资源都加载完毕 才算加载事件完成
      local complete = true
      for i, data in pairs(self.assetList) do
        if(data.asset == nil) then
          complete = false
        end
      end
      if complete then
        self.event:Happen()
      end
      
    end
    -- 默认异步方式加载
    CS.ABMgr.Instance:LoadRes(data.abName, data.assetName, data.type, cb, 0)
  end
end

function AssetLoader:SetDataAsset(asset, data)
  data.asset = asset
  --增加资源引用
  CS.ABMgr.Instance:AddReferenceCount(data.abName, data.assetName)
end

function AssetLoader:GetEntity(abName, assetName, parent)
  for i, data in pairs(self.assetList) do
    if(data.abName == abName and data.assetName == assetName) then
      -- 减少引用次数
      CS.ABMgr.Instance:DecreaseReferenceCount(data.abName, data.assetName)
      if(data.type == typeof(CS.UnityEngine.GameObject)) then
        -- 局部变量销毁 返回拷贝后就销毁 -- todo 浅拷贝
        local obj = CS.UnityEngine.GameObject.Instantiate(data.asset, parent)
        -- 增加引用
        CS.ABMgr.Instance:AddReferenceCount(data.abName, data.assetName)
        return obj
      else
        local asset = data.asset
        CS.ABMgr.Instance:AddReferenceCount(data.abName, data.assetName)
        return asset
      end
    end
  end
end
-- 引用字符串分割和Json工具
require("SplitTools")

Json = require("JsonUtility")


-- todo require 封装
-- 基类
require("base/Object");
require("base/BaseView");
require("base/BasePanel");
require("base/BaseModel");
require("base/BaseManager");
require("util/AssetLoader")
require("util/EventManager")
require("util/LoaderEnum")
require("BagEnum")
require("PreLoadDataManager")
require("ItemContentModel")
require("BagModel")
require("BagManager")
-- 画布 便于后续挂载
Canvas = CS.UnityEngine.GameObject.Find("Canvas").transform

require("MainPanel")
require("BagPanel")
require("ItemContentManager")
require("PlayerDataManager")
PreLoadDataManager.New()
-- 启动主面板
Start = MainPanel.New()
Start:LoadAsset()

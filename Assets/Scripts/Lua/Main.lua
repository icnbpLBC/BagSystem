-- 引用字符串分割和Json工具
require("SplitTools")

Json = require("JsonUtility")

-- 基类
require("base/Object");
require("base/BasePanel");
require("base/BaseModel");
require("base/BaseManager");
require("BagModel")
require("BagManager")
-- 画布 便于后续挂载
Canvas = CS.UnityEngine.GameObject.Find("Canvas").transform

require("MainPanel")
require("BagPanel")
require("ItemContent")
require("PlayerData")

-- 启动主面板
MainPanel.New()

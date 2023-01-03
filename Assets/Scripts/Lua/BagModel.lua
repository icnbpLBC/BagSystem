-- 继承于Object
BagModel = Object:subClass("BagModel")

-- 封装对应的视图对象
BagModel.panel = nil

-- 显示的二维GO数组
BagModel.itemDatas = {}
-- 对应物体分类集合
BagModel.equipCategory = {}
BagModel.gemCategory = {}
BagModel.itemCategory = {}

BagModel.categoryStatus = nil -- 分类状态 0-全部 1-装备 2-物品 3-宝石
-- 通过物品行数和列数 得出面板大小
BagModel.itemRows = 5
BagModel.itemColumns = nil

-- 实际显示的物品GO行列数
BagModel.showRows = 5
BagModel.showColumns = 6

-- 对应抽象的二维物品数组索引  根据其二维坐标映射成一维坐标在实际的物品集合中寻找
BagModel.leftIndex = 1
BagModel.rightIndex = 6

-- x轴和y轴上间距
BagModel.padX = 12
BagModel.padY = 12
BagModel.perfabW = 125
BagModel.perfabH = 125

-- 已选中的GO 在数组的位置
BagModel.selectedRow = nil
BagModel.selectedColumn = nil

function BagModel:Init()
    -- self.model = BagPanel
    -- 获取用户数据
    PlayerData:Init()
    -- 向上取整 + 1
    self.itemColumns = math.ceil(#(PlayerData.itemData) / self.itemRows)
end

function BagModel:InitBagPanel()
    BagPanel:Init()
    self.panel = BagPanel
end
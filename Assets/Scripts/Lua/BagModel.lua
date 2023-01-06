-- 继承于Object
-- BagModel = Object:subClass("BagModel")
BagModel = BagModel or BaseClass(BaseModel)

-- function BagModel:Init()
--     -- self.model = BagPanel
--     -- 获取用户数据
--     PlayerData:Init()
--     -- 向上取整 + 1
--     self.itemColumns = math.ceil(#(PlayerData.itemData) / self.itemRows)
-- end

function BagModel:__init()
    -- 封装对应的视图对象
    self.panel = nil

    -- 显示的二维GO数组
    self.itemDatas = {}
    -- 对应物体分类集合
    self.equipCategory = {}
    self.gemCategory = {}
    self.itemCategory = {}

    self.categoryStatus = nil -- 分类状态 0-全部 1-装备 2-物品 3-宝石
    -- 通过物品行数和列数 得出面板大小
    self.itemRows = 5
    self.itemColumns = nil

    -- 实际显示的物品GO行列数
    self.showRows = 5
    self.showColumns = 6

    -- 对应抽象的二维物品数组索引  根据其二维坐标映射成一维坐标在实际的物品集合中寻找
    self.leftIndex = 1
    self.rightIndex = 6

    -- x轴和y轴上间距
    self.padX = 12
    self.padY = 12
    self.perfabW = 125
    self.perfabH = 125

    -- 已选中的GO 在数组的位置
    self.selectedRow = nil
    self.selectedColumn = nil
    -- 获取用户数据
    PlayerData:Init()
    -- 向上取整 + 1
    self.itemColumns = math.ceil(#(PlayerData.itemData) / self.itemRows)
end

function BagModel:InitBagPanel()
    if(self.panel == nil) then
        self.panel = BagPanel.New()
        self.panel:LoadAsset()
    end
    self.panel:Open()
end
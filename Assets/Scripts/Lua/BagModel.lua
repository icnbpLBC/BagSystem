-- 继承于Object
-- BagModel = Object:subClass("BagModel")
BagModel = BagModel or BaseClass(BaseModel)


function BagModel:__init()
    -- 封装对应的视图对象
    self.panel = nil
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
    self.selectedLogicRow = nil
    self.selectedLogicColumn = nil
    self:LoadPlayerData()
end


-- 加载用户数据
function BagModel:LoadPlayerData()
     -- 获取用户数据
     PlayerDataMamager.Instance:InitBagData()
     self:InitColumns()
end
function BagModel:InitColumns()
    -- 向上取整 + 1
    self.itemColumns = math.ceil(#(PlayerDataMamager.Instance.itemData) / self.itemRows)
    if(#(PlayerDataMamager.Instance.itemData) % self.itemRows == 0) then
       self.itemColumns = self.itemColumns + 1
    end
end
function BagModel:InitBagPanel()
    if(self.panel == nil) then
        self.panel = BagPanel.New()
        self.panel:LoadAsset()
    end
    self.panel:Open()
end
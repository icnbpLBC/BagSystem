-- 物品类 todo 基于重写的OOP和MVC实现
ItemContentManager = ItemContentManager or BaseClass(BaseManager)


function ItemContentManager:__init()
    ItemContentManager.Instance = self
    self.itemDatas = {}
end

function ItemContentManager:LoadAllItemContents(rows, columns)
    for i = 1, rows do
        self.itemDatas[i] = {}
        for j = 1, columns do
            -- i, j 为实际行列
            local obj = ItemContentModel:New()
            obj:LoadModel({ ["row"] = i, ["column"] = j })
            self.itemDatas[i][j] = obj
        end
    end
end

-- 所有物品列增
function ItemContentManager:AllItemsColumnAddOne()
    for key1, table in pairs(self.itemDatas) do
        
        for key2, value in pairs(table) do
            value:ColumnAdd()
        end
        
    end
end

-- 所有物品列减
function ItemContentManager:AllItemsColumnDecreaseOne()
    for key1, table in pairs(self.itemDatas) do
        
        for key2, value in pairs(table) do
            value:ColumnDecrease()
        end
        
    end
end

-- 指定物品后面的物品前移
function ItemContentManager:BehindTarItemsMoveForward(tar)
    -- 实际行列后面的往前填
    local moveNum = (BagManager.Instance:GetShowRows() * BagManager.Instance:GetShowColumns()) - (BagManager.Instance:GetShowRows() * (tar.logicColumn - 1) + tar.logicRow)
    local i = 0
    local row = tar.realRow
    local column = tar.realColumn
    while i < moveNum do
        local nextRow = (row % BagManager.Instance:GetShowRows()) + 1
        local nextColumn = column
        -- 换列情况
        if nextRow == 1 then
            nextColumn = (column % BagManager.Instance:GetShowColumns()) + 1
        end
        -- 进行更新
        ItemContentManager.Instance.itemDatas[row][column]:UpdateByAnotherItem(ItemContentManager.Instance.itemDatas[nextRow][nextColumn])
        row = nextRow
        column = nextColumn
        i = i + 1
    end
end
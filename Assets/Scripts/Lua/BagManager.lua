-- 继承于Object
BagManager = Object:subClass("BagManager")
BagManager.model = nil


function BagManager:Init()
    BagModel:Init()
    self.model = BagModel
end

-- 左滑需比较位置
function BagManager:GetLeftCompareValue()
    return (self.model.leftIndex) * (self.model.perfabW + self.model.padX)
end

-- 右滑需比较位置
function BagManager:GetRightCompareValue()
    return ((self.model.leftIndex - 1)) * (self.model.perfabW + self.model.padX)
end

-- 获取内容面板大小
function BagManager:GetContentsSize()
    return (self.model.perfabW + self.model.padX) * self.model.itemColumns
end

-- 根据标签为背包物品做初始加载
function BagManager:ShowCateData()
    -- todo 清除数据
    for i = 1, self.model.showRows do
        for j = 1, self.model.showColumns do
            self.model.itemDatas[i][j]:ChangeActive(false)
        end
    end
    -- 初始化变量
    self.model.leftIndex = 1
    self.model.rightIndex = 6

    -- todo 根据类别更新显示数据
    -- 左右滑动 故外循环为列 内循环为行
    if self.model.categoryStatus == 0 then
        for j = 1, self.model.showColumns do
            for i = 1, self.model.showRows do

                
                self.model.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.model.perfabW + (j) * self.model.padX,
                    ['y'] = -(i - 1) * self.model.perfabH - (i) * self.model.padY })


                -- 二维索引映射一维
                if ((i + (j - 1) * self.model.showRows) <= #(PlayerData.itemData)) then
                    self.model.itemDatas[i][j]:Update(PlayerData.itemData[i + (j - 1) * self.model.showRows])
                end
            end
        end
    elseif self.model.categoryStatus == 1 then
        for i = 1, self.model.showRows do
            for j = 1, self.model.showColumns do

                self.model.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.model.perfabW + (j) * self.model.padX,
                    ['y'] = -(i - 1) * self.model.perfabH - (i) * self.model.padY })


                if ((i + (j - 1) * self.model.showRows) <= #(self.model.equipCategory)) then
                    self.model.itemDatas[i][j]:Update(self.model.equipCategory[i + (j - 1) * self.model.showRows])
                end

            end
        end

    elseif self.model.categoryStatus == 2 then
        for i = 1, self.model.showRows do
            for j = 1, self.model.showColumns do

                self.model.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.model.perfabW + (j) * self.model.padX,
                    ['y'] = -(i - 1) * self.model.perfabH - (i) * self.model.padY })
                -- 二维索引映射一维
                if ((i + (j - 1) * self.model.showRows) <= #(self.model.itemCategory)) then
                    self.model.itemDatas[i][j]:Update(self.model.itemCategory[i + (j - 1) * self.model.showRows])
                end
            end
        end


    else
        for i = 1, self.model.showRows do
            for j = 1, self.model.showColumns do

                self.model.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.model.perfabW + (j) * self.model.padX,
                    ['y'] = -(i - 1) * self.model.perfabH - (i) * self.model.padY })
                -- 二维索引映射一维
                if ((i + (j - 1) * self.model.showRows) <= #(self.model.gemCategory)) then
                    self.model.itemDatas[i][j]:Update(self.model.gemCategory[i + (j - 1) * self.model.showRows])
                end
            end
        end
    end
end

-- 加载物品内容
function BagManager:LoadItemContents()
    print(#PlayerData.itemData)
    -- 分类存储用户数据
    for i, v in pairs(PlayerData.itemData) do
        if v.type == 'equip' then
            table.insert(self.model.equipCategory, v)
        elseif v.type == 'gem' then
            table.insert(self.model.gemCategory, v)
        else
            table.insert(self.model.itemCategory, v)
        end
    end

    -- 加载预制体
    for i = 1, self.model.showRows do
        self.model.itemDatas[i] = {}
        for j = 1, self.model.showColumns do
            obj = ItemContent:new()
            obj:Init({["row"] = i, ["column"] = j})
            self.model.itemDatas[i][j] = obj
        end
    end

end

-- 根据状态和装填对应标签物品的集合的大小比较 判断是否需要对复用的格子加载资源
function BagManager:TryNewLoad(info)

    if self.model.categoryStatus == 0 then
        if info.index <= #PlayerData.itemData then
            self.model.itemDatas[info.showRow][info.showColumn]:Update(PlayerData.itemData[info.index])
        else
            -- todo 无需装填时
            self.model.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    elseif self.model.categoryStatus == 1 then
        if info.index <= #self.model.equipCategory then
            self.model.itemDatas[info.showRow][info.showColumn]:Update(self.model.equipCategory[info.index])
        else
            -- todo 无需装填时
            self.model.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    elseif self.model.categoryStatus == 2 then
        if info.index <= #self.model.itemCategory then
            self.model.itemDatas[info.showRow][info.showColumn]:Update(self.model.itemCategory[info.index])
        else
            -- todo 无需装填时
            self.model.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    else
        if info.index <= #self.model.gemCategory then
            self.model.itemDatas[info.showRow][info.showColumn]:Update(self.model.gemCategory[info.index])
        else
            -- todo 无需装填时
            self.model.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    end
end

-- 更改背包分类状态
function BagManager:UpdateCateStatus(status)
    self.model.categoryStatus = status
end

-- 左滑操作 更新对应索引
function BagManager:LeftScrollUpdate()
    -- 对应GO的列索引
    local realLeftIndex = nil
    if (self.model.leftIndex % (self.model.showColumns)) == 0 then
        realLeftIndex = self.model.showColumns
    else
        realLeftIndex = (self.model.leftIndex % (self.model.showColumns))
    end

    -- 更改移出GO的x位置【补充到右索引处】
    for i = 1, self.model.showRows do
        self.model.itemDatas[i][realLeftIndex]:ChangeX((self.model.rightIndex) * (self.model.perfabW + self.model.padX) + self.model.padX)
        -- 判断后面是否有未加载的物品 如果有则补充加载
        -- index表示映射到一维物品数组中的索引
        self:TryNewLoad({ ["index"] = (i + (self.model.rightIndex) * self.model.showRows), ["showRow"] = i,
            ["showColumn"] = (realLeftIndex) })

    end

    self.model.leftIndex = (self.model.leftIndex + 1)
    self.model.rightIndex = (self.model.rightIndex + 1)
end

-- 右滑操作 更新对应索引
function BagManager:RightScrollUpdate()
    -- 实际物品的列索引
    local realRightIndex = nil
    if (self.model.rightIndex % (self.model.showColumns)) == 0 then
        realRightIndex = self.model.showColumns
    else
        realRightIndex = (self.model.rightIndex % (self.model.showColumns))
    end


    for i = 1, self.model.showRows do
        self.model.itemDatas[i][realRightIndex]:ChangeX((self.model.leftIndex - 2) * (self.model.perfabW + self.model.padX) + self.model.padX)
        -- 判断后面是否有未加载的物品 如果有则补充加载
        -- index表示映射到一维物品数组中的索引
        self:TryNewLoad({ ["index"] = (i + (self.model.leftIndex - 2) * self.model.showRows), ["showRow"] = i,
            ["showColumn"] = (realRightIndex) })
    end
    self.model.leftIndex = (self.model.leftIndex - 1)
    self.model.rightIndex = (self.model.rightIndex - 1)
end

-- 滚动操作
function BagManager:ScrollMove(x)
    if(math.abs(x) > self:GetLeftCompareValue()) then
        self:LeftScrollUpdate()
    end
    if(math.abs(x) < self:GetRightCompareValue()) then
        self:RightScrollUpdate()
    end
    
end

-- 获取选中行列
function BagManager:GetSelectedRowAndColumn()
    return {row = self.model.selectedRow, column = self.model.selectedColumn}
end

-- 设置选中行列
function BagManager:SetSelectedRowAndColumn(row, column)
    self.model.selectedRow = row
    self.model.selectedColumn = column
end

-- 改变被选中物体的状态
function BagManager:ChangeSelectedStatus()
    self.model.itemDatas[self.model.selectedRow][self.model.selectedColumn]:ChangeSelectedState()
end
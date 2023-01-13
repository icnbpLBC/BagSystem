-- 继承于Object
-- BagManager = Object:subClass("BagManager")
BagManager = BagManager or BaseClass(BaseManager)


-- function BagManager:Init()
--     BagModel:Init()
--     self.model = BagModel
-- end

function BagManager:__init()
    self.model = BagModel.New()
    BagManager.Instance = self
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

-- 获取实际的列
function BagManager:GetRealColumn(logicColumn)
    local realColumn = nil
    if (logicColumn % (self.model.showColumns)) == 0 then
        realColumn = self.model.showColumns
    else
        realColumn = (logicColumn % (self.model.showColumns))
    end
    return realColumn
end

-- 更新最后一个物品
function BagManager:UpdateLastItem(itemList, isAdd)
    -- 先获取最后一个GO的逻辑索引
    local realRow = (#itemList) % self.model.showRows
    local logicColumn = math.ceil((#itemList) / self.model.showRows)

    -- 根据目前显示索引位置判断是否需要更新显示
    if logicColumn > self.model.rightIndex then
        return nil
    end

    -- 整除情况特殊考虑
    if realRow == 0 then
        realRow = self.model.showRows
    end

    local realColumn = self:GetRealColumn(logicColumn)

    -- 增加操作
    if isAdd then
        ItemContentManager.Instance.itemDatas[realRow][realColumn]:Update(itemList[
            #itemList])
    else
    end
end


-- 调整背包面板大小
function BagManager:UpdateBagSize()
    -- 调整背包面板大小
    self.model:InitColumns()
    self.model.panel:InitBag()
end

-- 初始化背包物品数据
function BagManager:InitBagItemDataByCateList(tarCateList)
    for j = 1, self.model.showColumns do
        for i = 1, self.model.showRows do

            ItemContentManager.Instance.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.model.perfabW +
                (j) * self.model.padX,
                ['y'] = -(i - 1) * self.model.perfabH - (i) * self.model.padY},{row = i, column = j})


            -- 二维索引映射一维
            if ((i + (j - 1) * self.model.showRows) <= #(tarCateList)) then
                ItemContentManager.Instance.itemDatas[i][j]:Update(tarCateList[
                    i + (j - 1) * self.model.showRows])
            end
        end
    end
end

-- 根据标签为背包物品做初始加载
function BagManager:ShowCateData()
    -- 清除数据
    ItemContentManager.Instance.selectedItem = nil
    for i = 1, self.model.showRows do
        for j = 1, self.model.showColumns do
            ItemContentManager.Instance.itemDatas[i][j]:ChangeActive(false)
        end
    end
    -- 从头开始显示
    self.model.leftIndex = 1
    self.model.rightIndex = 6

    -- 根据类别更新显示数据
    -- 左右滑动 故外循环为列 内循环为行
    if self.model.categoryStatus == 0 then
        self:InitBagItemDataByCateList(PlayerDataMamager.Instance.itemData)
    elseif self.model.categoryStatus == 1 then
        self:InitBagItemDataByCateList(PlayerDataMamager.Instance.equipCategory)
    elseif self.model.categoryStatus == 2 then
        self:InitBagItemDataByCateList(PlayerDataMamager.Instance.itemCategory)
    else
        self:InitBagItemDataByCateList(PlayerDataMamager.Instance.gemCategory)
    end
end

-- 加载物品内容
function BagManager:LoadItemContents()
    -- 分类装入

    -- 加载预制体
    ItemContentManager.Instance:LoadAllItemContents(self.model.showRows, self.model.showColumns)
end

-- 根据状态和装填对应标签物品的集合的大小比较 判断是否需要对复用的格子加载资源
function BagManager:TryNewLoad(info)

    if self.model.categoryStatus == 0 then
        if info.index <= #PlayerDataMamager.Instance.itemData then
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update(PlayerDataMamager.Instance.itemData
                [info.index])
        else
            -- todo 无需装填时
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update({ ["id"] = nil })
        end
    elseif self.model.categoryStatus == 1 then
        if info.index <= #PlayerDataMamager.Instance.equipCategory then
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update(PlayerDataMamager.Instance.equipCategory
                [info.index])
        else
            -- todo 无需装填时
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update({ ["id"] = nil })
        end
    elseif self.model.categoryStatus == 2 then
        if info.index <= #PlayerDataMamager.Instance.itemCategory then
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update(PlayerDataMamager.Instance.itemCategory
                [info.index])
        else
            -- todo 无需装填时
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update({ ["id"] = nil })
        end
    else
        if info.index <= #PlayerDataMamager.Instance.gemCategory then
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update(PlayerDataMamager.Instance.gemCategory
                [info.index])
        else
            -- todo 无需装填时
            ItemContentManager.Instance.itemDatas[info.showRow][info.showColumn]:Update({ ["id"] = nil })
        end
    end
end

-- 获取实际显示列个数
function BagManager:GetShowColumns()
    return self.model.showColumns
end

-- 获取实际显示行个数
function BagManager:GetShowRows()
    return self.model.showRows
end

function BagManager:GetCateStatus()
    return self.model.categoryStatus
end

-- 更改背包分类状态
function BagManager:UpdateCateStatus(status)
    self.model.categoryStatus = status
end

-- 左滑操作 更新对应索引
function BagManager:LeftScrollUpdate()
    ItemContentManager.Instance:AllItemsColumnDecreaseOne()
    -- 对应GO的列索引
    local realLeftIndex = self:GetRealColumn(self.model.leftIndex)

    -- 更改移出GO的x位置【补充到右索引处】
    for i = 1, self.model.showRows do
        ItemContentManager.Instance.itemDatas[i][realLeftIndex]:ChangeX((self.model.rightIndex) *
            (self.model.perfabW + self.model.padX) +
            self.model.padX)
        -- 判断后面是否有未加载的物品 如果有则补充加载
        -- index表示映射到一维物品数组中的索引
        self:TryNewLoad({ ["index"] = (i + (self.model.rightIndex) * self.model.showRows), ["showRow"] = i,
            ["showColumn"] = (realLeftIndex) })

    end

    self.model.leftIndex = (self.model.leftIndex + 1)
    self.model.rightIndex = (self.model.rightIndex + 1)
end

-- 随机生成新物品
function BagManager:RandomBuildItemToTable(ranStart, ranEnd, tarCateList)
    local tar = math.random(ranStart, ranEnd)
    PlayerDataMamager.Instance:InsertNewItem(tar)
    self:UpdateBagSize()
    -- 更新最后一个物品
    self:UpdateLastItem(tarCateList, true)
end

-- 增加物品
function BagManager:AddItem()
    -- 增加随机数种子
    math.randomseed(os.time())
    -- 基于分类来增加
    -- 随机选择当前分类中的某个id
    -- 1-6 装备 7 - 13 宝石  14 - 17 物品
    if self.model.categoryStatus == 0 then
        self:RandomBuildItemToTable(1, 17, PlayerDataMamager.Instance.itemData)
    elseif self.model.categoryStatus == 1 then
        self:RandomBuildItemToTable(1, 6, PlayerDataMamager.Instance.equipCategory)
    elseif self.model.categoryStatus == 2 then
        self:RandomBuildItemToTable(14, 17, PlayerDataMamager.Instance.itemCategory)
    elseif self.model.categoryStatus == 3 then
        self:RandomBuildItemToTable(7, 13, PlayerDataMamager.Instance.gemCategory)
    end
end

-- 删除物品
function BagManager:DeleteItem()
    -- 判断是否选中
    if ItemContentManager.Instance.selectedItem == nil then
        return nil
    end
    -- 图片清除
    ItemContentManager.Instance.selectedItem:Update({ ["id"] = nil })

    local tar = ItemContentManager.Instance.selectedItem

    -- 选中为取消
    ItemContentManager.Instance.selectedItem:OnItemSelectedClick()
    
    -- 根据选中的实际行列来找出实际的一维位置
    -- 需要由抽象二维映射到实际一维
    local realIndex = (self.model.leftIndex + tar.logicColumn - 2) * self.model.showRows + tar.logicRow
    -- 减少对应集合中的引用
    PlayerDataMamager.Instance:DeleteItem(realIndex)

    -- 删除后自动往前补齐
    ItemContentManager.Instance:BehindTarItemsMoveForward(tar)

end

-- 右滑操作 更新对应索引
function BagManager:RightScrollUpdate()
    -- GO列位置改变
    ItemContentManager.Instance:AllItemsColumnAddOne()
    -- 实际物品的列索引
    local realRightIndex = self:GetRealColumn(self.model.rightIndex)


    for i = 1, self.model.showRows do
        ItemContentManager.Instance.itemDatas[i][realRightIndex]:ChangeX((self.model.leftIndex - 2) *
            (self.model.perfabW + self.model.padX) + self.model.padX)
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
    if (math.abs(x) > self:GetLeftCompareValue()) then
        self:LeftScrollUpdate()
    end
    if (math.abs(x) < self:GetRightCompareValue()) then
        self:RightScrollUpdate()
    end

end

-- 获取选中行列
function BagManager:GetSelectedRowAndColumn()
    return { row = self.model.selectedLogicRow, column = self.model.selectedLogicColumn }
end

-- 设置选中行列
function BagManager:SetSelectedRowAndColumn(row, column)
    self.model.selectedRow = row
    self.model.selectedColumn = column
end

-- 改变被选中物体的状态
function BagManager:ChangeSelectedStatus()
    ItemContentManager.Instance.selectedItem:ChangeSelectedState()
end

-- 获取content的transform
function BagManager:GetScrollContentTrans()
    return self.model.panel.scrollContentTrans
end

-- 获取图集中的图像
function BagManager:GetBagSpriteByName(name)
    return self.model.panel.spriteAtlasObj:GetSprite(name)
end


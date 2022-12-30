-- 继承于Object
BagPanel = Object:subClass("BagPanel")

-- 背包面板类特有属性
BagPanel.isInit = false
BagPanel.panelObj = nil
BagPanel.cloBtn = nil
-- 物品面板位置 便于后续物品实例化时设置父对象
BagPanel.scrollContentTrans = nil
BagPanel.itemContents = {}
-- 图集对象
BagPanel.spriteAtlasObj = nil

-- 显示的二维GO数组
BagPanel.itemDatas = {}
BagPanel.equipCategory = {}
BagPanel.gemCategory = {}
BagPanel.itemCategory = {}

BagPanel.itemSelectedId = nil
BagPanel.categoryStatus = nil -- 分类状态 0-全部 1-装备 2-物品 3-宝石
BagPanel.allItemBtn = nil
BagPanel.equipCateBtn = nil
BagPanel.itemCateBtn = nil
BagPanel.gemCateBtn = nil

-- 通过物品行数和列数 得出面板大小
BagPanel.itemRows = 5
BagPanel.itemColumns = nil

-- 实际显示的物品GO行列数
BagPanel.showRows = 5
BagPanel.showColumns = 6

-- 对应抽象的二维物品数组索引  根据其二维坐标映射成一维坐标在实际的物品集合中寻找
BagPanel.leftIndex = 1
BagPanel.rightIndex = 6

-- x轴和y轴上间距
BagPanel.padX = 12
BagPanel.padY = 12
BagPanel.perfabW = 125
BagPanel.perfabH = 125

-- 已选中的GO 在数组的位置
BagPanel.selectedRow = nil
BagPanel.selectedColumn = nil

-- 初始化过程
function BagPanel:Init()
    if (self.isInit == false) then
        self.panelObj = CS.ABMgr.Instance:LoadRes("prefabs", "BagPanel", typeof(CS.UnityEngine.GameObject), Canvas)
        self.cloBtn = self.panelObj.transform:Find("Bg/CloBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.allItemBtn = self.panelObj.transform:Find("Bg/AllItemBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.equipCateBtn = self.panelObj.transform:Find("Bg/EquipCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.itemCateBtn = self.panelObj.transform:Find("Bg/ItemCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.gemCateBtn = self.panelObj.transform:Find("Bg/GemCateBtn"):GetComponent(typeof(CS.UnityEngine.UI.Button))
        self.spriteAtlasObj = CS.ABMgr.Instance:LoadRes("imgs", "Items", typeof(CS.UnityEngine.U2D.SpriteAtlas))
        self.scrollContentTrans = self.panelObj.transform:Find("Bg/ItemPanel/ScrollView/Viewport/Content")


        self.isInit = true

        self:LoadItemContents()
        -- todo 3、点击标签分类
        -- 向上取整 + 1
        self.itemColumns = math.ceil(#(PlayerData.itemData) / self.itemRows)
        -- 初始状态为全部物品
        self:InitBag()
        self:OnAllItemBtnClick()
    end
    self:Show()

end

function BagPanel:InitBag()
    self.scrollContentTrans.anchorMin = CS.UnityEngine.Vector2(0, 0)
    self.scrollContentTrans.anchorMax = CS.UnityEngine.Vector2(0, 1)
    self.scrollContentTrans:GetComponent(typeof(CS.UnityEngine.RectTransform)).sizeDelta = CS.UnityEngine.Vector2((
        self.perfabW + self.padX) * self.itemColumns, 0)

end

function BagPanel:Show()
    self.panelObj:SetActive(true)
    self:AddEvent()
end

function BagPanel:Hide()
    self:DelEvent()
    self.panelObj:SetActive(false)
end

function BagPanel:AddEvent()
    self.panelObj.transform:Find("Bg/ItemPanel/ScrollView"):GetComponent(typeof(CS.UnityEngine.UI.ScrollRect)).onValueChanged
        :AddListener(function(vec2)
            self:OnScrollMoveWidth(vec2)
        end)
    self.cloBtn.onClick:AddListener(function()
        self:OnCloBtnClick()
    end)
    self.allItemBtn.onClick:AddListener(function()
        self:OnAllItemBtnClick()
    end)
    self.equipCateBtn.onClick:AddListener(function()
        self:OnEquipCateBtnClick()
    end)
    self.itemCateBtn.onClick:AddListener(function()
        self:OnItemCateBtnClick()
    end)
    self.gemCateBtn.onClick:AddListener(function()
        self:OnGemCateBtnClick()
    end)
end

function BagPanel:DelEvent()
    self.cloBtn.onClick:RemoveAllListeners()
    self.allItemBtn.onClick:RemoveAllListeners()
    self.equipCateBtn.onClick:RemoveAllListeners()
    self.itemCateBtn.onClick:RemoveAllListeners()
    self.gemCateBtn.onClick:RemoveAllListeners()
end

function BagPanel:ClearCateClick()
    self.panelObj.transform:Find("Bg/AllItemBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.panelObj.transform:Find("Bg/EquipCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.panelObj.transform:Find("Bg/ItemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
    self.panelObj.transform:Find("Bg/GemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.white
end

function BagPanel:OnScrollMoveWidth(vec2)
    -- 根据指针和父物体位置的距离关系
    -- 左滑
    -- 通过content距离viewport的距离 和 左右索引的关系来判断变化
    if (math.abs(self.scrollContentTrans.anchoredPosition.x)) > ((self.leftIndex) * (self.perfabW + self.padX)) then
        print("left:" ..
            self.leftIndex ..
            " scrollTrans:" ..
            (math.abs(self.scrollContentTrans.anchoredPosition.x)) ..
            "firstX:" .. ((self.leftIndex) * self.perfabW + self.padX))

        -- 对应GO的列索引
        local realLeftIndex = nil
        if (self.leftIndex % (self.showColumns)) == 0 then
            realLeftIndex = self.showColumns
        else
            realLeftIndex = (self.leftIndex % (self.showColumns))
        end

        -- 更改移出GO的x位置【补充到右索引处】
        for i = 1, self.showRows do
            self.itemDatas[i][realLeftIndex]:ChangeX((self.rightIndex) * (self.perfabW + self.padX) + self.padX)
            -- 判断后面是否有未加载的物品 如果有则补充加载
            -- index表示映射到一维物品数组中的索引
            self:TryNewLoad({ ["index"] = (i + (self.rightIndex) * self.showRows), ["showRow"] = i,
                ["showColumn"] = (realLeftIndex) })

        end

        self.leftIndex = (self.leftIndex + 1)
        self.rightIndex = (self.rightIndex + 1)
    end

    -- 右滑
    if (
        (math.abs(self.scrollContentTrans.anchoredPosition.x)) < (((self.leftIndex - 1)) * (self.perfabW + self.padX))
            and (self.leftIndex > 1)) then
        print("right:" ..
            self.rightIndex ..
            " scrollTrans:" ..
            (math.abs(self.scrollContentTrans.anchoredPosition.x)) ..
            "firstX:" .. ((self.leftIndex) * self.perfabW + self.padX))


        -- 实际物品的列索引
        local realRightIndex = nil
        if (self.rightIndex % (self.showColumns)) == 0 then
            realRightIndex = self.showColumns
        else
            realRightIndex = (self.rightIndex % (self.showColumns))
        end


        for i = 1, self.showRows do
            self.itemDatas[i][realRightIndex]:ChangeX((self.leftIndex - 2) * (self.perfabW + self.padX) + self.padX)
            -- 判断后面是否有未加载的物品 如果有则补充加载
            -- index表示映射到一维物品数组中的索引
            self:TryNewLoad({ ["index"] = (i + (self.leftIndex - 2) * self.showRows), ["showRow"] = i,
                ["showColumn"] = (realRightIndex) })
        end
        self.leftIndex = (self.leftIndex - 1)
        self.rightIndex = (self.rightIndex - 1)
    end
end

function BagPanel:OnAllItemBtnClick()
    -- 清空选中颜色
    self:ClearCateClick()
    -- 修改状态
    self.categoryStatus = 0
    -- 更改颜色为选中
    self.panelObj.transform:Find("Bg/AllItemBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    -- 显示物品
    self:ShowCateData()
end

function BagPanel:OnEquipCateBtnClick()
    self:ClearCateClick()
    self.categoryStatus = 1
    self.panelObj.transform:Find("Bg/EquipCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    self:ShowCateData()
end

function BagPanel:OnItemCateBtnClick()
    self:ClearCateClick()
    self.categoryStatus = 2
    self.panelObj.transform:Find("Bg/ItemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    self:ShowCateData()
end

function BagPanel:OnGemCateBtnClick()
    self:ClearCateClick()
    self.categoryStatus = 3
    self.panelObj.transform:Find("Bg/GemCateBtn/Image"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = CS.UnityEngine
        .Color.red
    self:ShowCateData()
end

-- 根据状态和装填对应标签物品的集合的大小比较 判断是否需要对复用的格子加载资源
function BagPanel:TryNewLoad(info)

    if self.categoryStatus == 0 then
        if info.index <= #PlayerData.itemData then
            self.itemDatas[info.showRow][info.showColumn]:Update(PlayerData.itemData[info.index])
        else
            -- todo 无需装填时
            self.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    elseif self.categoryStatus == 1 then
        if info.index <= #self.equipCategory then
            self.itemDatas[info.showRow][info.showColumn]:Update(self.equipCategory[info.index])
        else
            -- todo 无需装填时
            self.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    elseif self.categoryStatus == 2 then
        if info.index <= #self.itemCategory then
            self.itemDatas[info.showRow][info.showColumn]:Update(self.itemCategory[info.index])
        else
            -- todo 无需装填时
            self.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    else
        if info.index <= #self.gemCategory then
            self.itemDatas[info.showRow][info.showColumn]:Update(self.gemCategory[info.index])
        else
            -- todo 无需装填时
            self.itemDatas[info.showRow][info.showColumn]:Update({["id"] = nil})
        end
    end
end

-- 关闭按钮点击事件
function BagPanel:OnCloBtnClick()
    self:Hide()
end

-- 根据标签为背包物品做初始加载
function BagPanel:ShowCateData()
    -- todo 清除数据
    for i = 1, self.showRows do
        for j = 1, self.showColumns do
            self.itemDatas[i][j]:ChangeActive(false)
        end
    end
    -- 还原content位置
    self.scrollContentTrans:GetComponent(typeof(CS.UnityEngine.RectTransform)).sizeDelta = CS.UnityEngine.Vector2((
        self.perfabW + self.padX) * self.itemColumns, 0)
    -- 初始化变量
    self.leftIndex = 1
    self.rightIndex = 6

    -- todo 根据类别更新显示数据
    -- 左右滑动 故外循环为列 内循环为行
    if self.categoryStatus == 0 then
        for j = 1, self.showColumns do
            for i = 1, self.showRows do

                
                self.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.perfabW + (j) * self.padX,
                    ['y'] = -(i - 1) * self.perfabH - (i) * self.padY })


                -- 二维索引映射一维
                if ((i + (j - 1) * self.showRows) <= #(PlayerData.itemData)) then
                    self.itemDatas[i][j]:Update(PlayerData.itemData[i + (j - 1) * self.showRows])
                end
            end
        end
    elseif self.categoryStatus == 1 then
        for i = 1, self.showRows do
            for j = 1, self.showColumns do

                self.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.perfabW + (j) * self.padX,
                    ['y'] = -(i - 1) * self.perfabH - (i) * self.padY })


                if ((i + (j - 1) * self.showRows) <= #(self.equipCategory)) then
                    self.itemDatas[i][j]:Update(self.equipCategory[i + (j - 1) * self.showRows])
                end

            end
        end

    elseif self.categoryStatus == 2 then
        for i = 1, self.showRows do
            for j = 1, self.showColumns do

                self.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.perfabW + (j) * self.padX,
                    ['y'] = -(i - 1) * self.perfabH - (i) * self.padY })
                -- 二维索引映射一维
                if ((i + (j - 1) * self.showRows) <= #(self.itemCategory)) then
                    self.itemDatas[i][j]:Update(self.itemCategory[i + (j - 1) * self.showRows])
                end
            end
        end


    else
        for i = 1, self.showRows do
            for j = 1, self.showColumns do

                self.itemDatas[i][j]:InitPos({ ['x'] = (j - 1) * self.perfabW + (j) * self.padX,
                    ['y'] = -(i - 1) * self.perfabH - (i) * self.padY })
                -- 二维索引映射一维
                if ((i + (j - 1) * self.showRows) <= #(self.gemCategory)) then
                    self.itemDatas[i][j]:Update(self.gemCategory[i + (j - 1) * self.showRows])
                end
            end
        end
    end
end

-- 加载物品内容
function BagPanel:LoadItemContents()
    -- 获取用户数据
    PlayerData:Init()
    print(#PlayerData.itemData)
    -- 分类存储用户数据
    for i, v in pairs(PlayerData.itemData) do
        if v.type == 'equip' then
            table.insert(self.equipCategory, v)
        elseif v.type == 'gem' then
            table.insert(self.gemCategory, v)
        else
            table.insert(self.itemCategory, v)
        end
    end

    -- 加载预制体
    for i = 1, self.showRows do
        self.itemDatas[i] = {}
        for j = 1, self.showColumns do
            obj = ItemContent:new()
            obj:Init({["row"] = i, ["column"] = j})
            self.itemDatas[i][j] = obj
        end
    end

end

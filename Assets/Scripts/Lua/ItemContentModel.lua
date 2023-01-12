ItemContentModel = ItemContentModel or BaseClass(BaseModel)

function ItemContentModel:__init()
    -- -- 物品类属性 主要保存对应C#实例对象和相关UI组件
    -- self.itemObj = nil
    -- self.itemImg = nil
    -- self.itemTxt = nil
    -- self.itemBtn = nil
    -- self.itemSelectObj = nil


    -- -- 业务相关属性
    -- self.isSelected = false
    -- self.itemId = nil
    -- -- 物品相对content的位置
    -- self.posi = nil
    -- self.row = nil
    -- self.column = nil
end

function ItemContentModel:LoadModel(info)
    local cb = function(asset)
        self:InitModel(asset, BagManager.Instance:GetScrollContentTrans(), info)
    end
    -- 调用AB包管理器加载对应包内对应资源
    CS.ABMgr.Instance:LoadRes("prefabs", "ItemContent", typeof(CS.UnityEngine.GameObject), cb, 1)
end

-- 屬性初始化
function ItemContentModel:InitModel(asset, parent, info)
    self.itemObj = CS.UnityEngine.GameObject.Instantiate(asset, parent)
    -- 增加引用计数
    CS.ABMgr.Instance:AddReferenceCount("prefabs", "ItemContent")
    -- todo 异步加载完成判定后续处理
    self.itemImg = self.itemObj.transform:Find("Bg/ItemImg"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    self.itemTxt = self.itemObj.transform:Find("Bg/ItemTxt"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    self.itemBtn = self.itemObj.transform:Find("Bg"):GetComponent(typeof(CS.UnityEngine.UI.Button))
    self.itemSelectObj = self.itemObj.transform:Find("Bg/ItemSelect").gameObject
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).pivot = CS.UnityEngine.Vector2(0, 1)
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchorMin = CS.UnityEngine.Vector2(0, 1)
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchorMax = CS.UnityEngine.Vector2(0, 1)
    -- 实际行列
    self.row = info.row
    self.column = info.column
    self:Show()
end


-- 设置物品锚点和中心点 以及相对锚点位置
function ItemContentModel:InitPos(position) 
    self.posi = position
    -- todo 设置相对锚点位置
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchoredPosition = CS.UnityEngine.Vector2(self.posi.x, self.posi.y)
    self:ChangeActive(true)
end

function ItemContentModel:ChangeX(x)
    self.posi.x = x
    self.itemObj:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchoredPosition = CS.UnityEngine.Vector2(self.posi.x, self.posi.y)
end


function ItemContentModel:ChangeActive(status)
    self.itemObj:SetActive(status)
end

-- 更新物品GO的UI
function ItemContentModel:Update(info)
    -- 更新时一定未被选中
    self.itemSelectObj:SetActive(false)
    if info.id ~= nil then
        self.itemId = info.id 
        self.itemImg.sprite = BagManager.Instance:GetBagSpriteByName(CS.ProjectConstantData.ItemsNameArray[self.itemId])
        self.itemTxt.text = info.num
    else
        self.itemId = nil 
        self.itemImg.sprite = nil
        self.itemTxt.text = ""
    end
    
end

function ItemContentModel:Show()
    self:AddEvent()
end

function ItemContentModel:AddEvent()
    self.itemBtn.onClick:AddListener(function ()
        self:OnItemSelectedClick()
    end)
end

function ItemContentModel:ChangeSelectedState()
    self.itemSelectObj:SetActive(not self.itemSelectObj.activeSelf)
end

-- 物品选中框 如果已被选中 则框消失  如果未被选中 则被选中的框消失 自己的框出现
function ItemContentModel:OnItemSelectedClick()
    if self.itemSelectObj.activeSelf then
        BagManager.Instance:SetSelectedRowAndColumn(nil, nil)
    end
    self:ChangeSelectedState()
    if self.itemSelectObj.activeSelf then
        if BagManager.Instance:GetSelectedRowAndColumn().row ~= nil then
            
            BagManager.Instance:ChangeSelectedStatus()
        end
        BagManager.Instance:SetSelectedRowAndColumn(self.row, self.column)
    end
    
end
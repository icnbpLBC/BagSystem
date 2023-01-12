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
            local obj = ItemContentModel:New()
            obj:LoadModel({ ["row"] = i, ["column"] = j })
            self.itemDatas[i][j] = obj
        end
    end
end


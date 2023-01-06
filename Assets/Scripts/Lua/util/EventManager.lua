-- 封装了事件功能 订阅事件即为事件添加方法引用，事件发生时执行封装的方法引用
EventLib = EventLib or BaseClass()

function EventLib:__init()
    self.funcList = nil
    self.errfunction = function (errinfo)
        print("event happend error info:" .. errinfo)
    end
end

-- 添加方法
function EventLib:Add(func)
    if(self.funcList == nil) then
        self.funcList = {}
    end
    table.insert(self.funcList, func)
end



-- 事件发生
function EventLib:Happen()
    -- 顺序执行方法引用
    for k,func in pairs(self.funcList) do
        -- 事件完成 执行回调
        xpcall(func, self.errfunction)
        -- 取消订阅
        -- self.funcList[k] = nil
    end
end
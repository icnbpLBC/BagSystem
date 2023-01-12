local _class = {}
function BaseClass(super)
    local class_type = {}
    class_type.__init = false
    class_type.super = super
    class_type.New = function (...)
        local obj = {}
        obj.type = class_type
        -- 实例化 读路径 实例化对象 -> 模板对象 -> 父类模板
        -- 写路径 实例化对象
        setmetatable(obj, {__index = _class[class_type]})
        -- 执行初始化
        do
            local create
            create = function (c, ...)
                if c.super then
                    create(c.super, ...)
                end
                if c.__init then
                    c.__init(obj, ...)
                end
            end
            create(class_type, ...)
        end
        return obj
    end

    local vtbl = {}
    _class[class_type] = vtbl
    -- 模板的写都是在虚表中
    setmetatable(class_type, {__newindex =function (t, k, v)
        vtbl[k] = v
    end, __index = vtbl})

    if super then
        setmetatable(vtbl, {__index = function (t, k)
            return _class[super][k]
        end})
    end
    return class_type
end
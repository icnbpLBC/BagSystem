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

-- 深拷贝函数
function Copy(tar)
    function _copy(obj)
        if type(obj) ~= 'table' then
            return obj
        end
        local new_table = {}
        for k, v in pairs(obj) do
            -- 递归进行
            new_table[_copy(k)] = _copy(v)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(tar)
end

-- 查找表中元素对应的键
function FindKey(table, tar)
    if type(table) ~= 'table' then
        return nil
    end
    for key, value in pairs(table) do
        if value == tar then
            return key
        end
    end
    return nil
end
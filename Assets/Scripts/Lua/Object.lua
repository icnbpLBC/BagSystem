Object = {}
function Object:new()
    obj = {}
    self.__index = self;
    setmetatable(obj, self);
    return obj
end

function Object:subClass(className)
    obj = {}
    obj.base = self;
    self.__index = self;
    _G[className] = obj;
    setmetatable(obj, self)
    return obj
end
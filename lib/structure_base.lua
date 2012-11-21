structure_base = {}

function structure_base:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o;
end

function structure_base:map(f)
    local i = self;
    f(i);
    return self
end

return structure_base;


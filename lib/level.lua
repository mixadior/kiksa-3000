level = {}
setmetatable(level, structure_base)

function level:new(game)
    local o = getmetatable(self):new()
    setmetatable(o, self)
    self.__index = self
    return o
end

function level:update(...)

end

return level
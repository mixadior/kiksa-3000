bullets = {}

function bullets:init(bullets)
    local o = {}
    o.bullets = bullets
    setmetatable(o, self)
    self.__index = self
    return o
end

function bullets:call_for_all(f)
    for i=1, #self.bullets,1 do
        f(self.bullets[i])
    end
    return self
end

return bullets;
bullet_cold = {}
setmetatable(bullet_cold, bullet)

function bullet_cold:new(...)
    local o = getmetatable(self):new(...)
    o.type = 'cold'
    o.time = 5
    setmetatable(o, self)
    self.__index = self
    return o;
end

function bullet_cold:update(dt, ...)
    local parent = getmetatable(self.__index)
    if (self.state == 'freezing') then

    else
        parent.update(self, dt, ...)
    end
end

function bullet_cold:on_bot_collision(bot)
    if (self.state ~= 'dead') then
        bot.timings.frozen = 0
        bot.affectedBy = self
        self.state = 'freezing'
    end
end

return bullet_cold;


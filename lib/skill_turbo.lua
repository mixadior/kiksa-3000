skill_turbo = {

}
setmetatable(skill_turbo, skill)

function skill_turbo:new(amount)
    local o = getmetatable(self):new()
    o.amount = amount
    o.speedUp = 1
    o.turbos = {1,2,8}
    o.speedUpK = 1
    o.name = 'turbo'
    setmetatable(o ,self)
    self.__index = self;
    return o;
end

function skill_turbo:update(data)
    if (self.speedUpK > 1) then
        self.amount =  self.amount - data.step
    end
    if (self.amount < 0) then
        self.amount = 0
    end
end

function skill_turbo:toggle()
    if (self.amount > 0) then
        self.speedUpK = next(self.turbos, self.speedUpK) or 1
    else
        self.speedUpK = 1
    end
end

function skill_turbo:on()
    self.speedUpK = 2
end

function skill_turbo:off()
    self.speedUpK = 1
end

function skill_turbo:get_speed_up()
    if (self.amount > 0) then
        return  self.turbos[self.speedUpK]
    else
        return  1
    end
end

function skill_turbo:get_amount()
    return math.floor(self.amount)
end

return skill_turbo;


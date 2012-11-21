skill_axe = {

}

function skill_axe:new()
    setmetatable(self, {__index = skill:new()})
    local o = {
        amount = 0
    }
    setmetatable(o ,self)
    self.__index = self;
    return o;
end

function skill_axe:update(data)

end

return skill_axe;


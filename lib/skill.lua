skill = {}

function skill:new()
    local o = {
        name = 'skill' ,
        is_active = false,
        shit = {
            fuck = 'you'
        }
    }
    setmetatable(o, self)
    self.__index = self
    return o;
end

function skill:get_name()
    return self.name;
end

function skill:give(a)
    self.amount = self.amount + a
end

return skill


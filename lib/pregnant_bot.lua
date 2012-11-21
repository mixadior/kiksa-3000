pregnant_bot = {}
setmetatable(pregnant_bot, bot)

function pregnant_bot:new(...)
    local o = getmetatable(self):new(...)
    o.children = {}
    o.type = "pregnant"
    o.pregnant = true
    o.color = {255,0,255}
    o.default_color = {255,0,255}

    setmetatable(o, self)
    self.__index = self

    return o
end

function pregnant_bot:produce_child(amount)
    if (self.dead) then return false end
    if (not self.pregnant) then return false end
    local amount = amount or 1
    --print_r(self)
    local b = bot:new(self.nullNullReal:clone(),  15, 15, 15)
    b.id = self.id.."_child"
    b.color = self.color
    table.insert(self.children, b)
    hrumalka.go.gamestats.alive = hrumalka.go.gamestats.alive + amount
    return b
end

function pregnant_bot:kill(kill_type)
    self.dead = true
    self.killed = kill_type or 1
    hrumalka.go.gamestats.alive = hrumalka.go.gamestats.alive - 1
    hrumalka.go.gamestats.frags = hrumalka.go.gamestats.frags + 1

    for i=1,#self.children,1 do
        if (not self.children[i].dead) then
            self.children[i]:kill(2);
        end
    end

end

return pregnant_bot
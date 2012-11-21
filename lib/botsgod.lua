botsgod = {}

function botsgod:new(bots)
    local botsgod = {}
    botsgod.bots = bots

    setmetatable(botsgod, self)
    self.__index = self
    return botsgod;
end

function botsgod:update(dt, map)

    self:call_for_all('update', dt, map)

end

function botsgod:inside(poly)
    local bots = {}
    for i = 1, #self.bots, 1 do
        if (self.bots[i] and self.bots[i]:is_inside(poly)) then
            table.insert(bots, self.bots[i])
        end
    end
    return botsgod:new(bots)
end

function botsgod:produce_child(amount)
    local pregnant = 0
    local stop = false;
    local f = function(i, bot)

        if (not stop and bot.type == "pregnant" and not bot.dead) then

            local b = bot:produce_child(amount)

            table.insert(self.bots, b)
            stop = true
        end
    end
    self:call_for_all(f)
end

function botsgod:collided(hero)
    local bots = {}
    for i=1,#self.bots,1 do
        if (self.bots[i] and self.bots[i]:check_collision(hero)) then
            table.insert(bots, self.bots[i])
        end
    end
    return botsgod:new(bots)
end

function botsgod:call_for_all(f, ...)
    for i=1,#self.bots,1 do
        self:call(f,i,...)
    end
end

function botsgod:call(f,i, ...)
    local bot = self:get_bot(i)

    if (bot) then

        if (type(f) == "function") then
            return f(i, bot, ...)
        else

            return bot[f](bot, ...)
        end
    end
end


function botsgod:get_bot(i)
    return self.bots[i]
end

return botsgod



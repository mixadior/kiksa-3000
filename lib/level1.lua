level1 = {}
setmetatable(level1, level)

function level1:new(game, ...)
    local o = getmetatable(self):new(...)
    local bots = {
        pregnant_bot:new(vertex:new(400, 100), 80, 40, 5, polygon:new({
            vertex:new(0,0),
            vertex:new(50,0),
            vertex:new(50,50),
            vertex:new(100,50),
            vertex:new(100, 100),
            vertex:new(50, 100),
            vertex:new(50,150),
            vertex:new(0, 150),
            vertex:new(0, 100),
            vertex:new(-50, 100),
            vertex:new(-50, 50)
        }), 120),

        --[[pregnant_bot:new(vertex:new(400, 100), 80, 40, 5, polygon:new({
            vertex:new(0,0),
            vertex:new(50,0),
            vertex:new(50,50),
            vertex:new(100,50),
            vertex:new(100, 100),
            vertex:new(50, 100),
            vertex:new(50,150),
            vertex:new(0, 150),
            vertex:new(0, 100),
            vertex:new(-50, 100),
            vertex:new(-50, 50)
        }), 200)--]]
    }
    game.go.bots = botsgod:new(bots)
    game.go.gamestats.alive = game.go.gamestats.alive + #bots

    --game:give_skill(skill_turbo:new(1000))
    o.bots = bots
    o.name = 1
    o.full_name = 'Начало истории'
    o.osd = osd:init()
    o.once_t = false
    setmetatable(o, self)
    self.__index = self
    return o
end

function level1:update(...)
    if (self.completed == 3) then
       return 'completed'
    elseif (self.completed == 2) then
        return false
    end

    local dt, g = ...
    local all_dead = true
    g.go.bots:call_for_all(function(i, b)
        if (not b.dead) then
            all_dead = false
        end
    end)

    if (g.go.youare.total_moved > 50 and not self.once_t) then
        self.once_t = true
        osdd:add({text = 'Вы обнаружили способность к турбо режиму. В зависимости от режима акселлерации ( 2x/8x ), вы сможете менять скорость передвижения. Вы получаете 1000 едениц ускорения, как только они закончаться скорость вернется к стандартной. \n Для активации турбо режима используйте кнопку S. \n\n [ Нажмите Esc для закрытия сообщения ]', header = 'Новое умение', before = function(self, v)  end, close = function(self, v) print('shit'..v.state) end})
        g:give_skill(skill_turbo:new(1000))
    end


    if (all_dead) then
        g.restore.youare = deepcopy(g.go.youare)
        g.restore.frags = g.go.gamestats.frags

        local l = self
        osdd:close_all();
        osdd:add({text = 'Вы прошли первый уровень. Перед переходом на следующий уровень - несколько подсказок: \n 1. Иногда чтобы выиграть, нужно проиграть \n 2. Чтобы идти только по контуру нужно зажать [Пробел].  ', header = 'Поздравляю', close = function(self, osd) self.level.completed = 3 end, level = l})
        l.completed = 2
        return false
    else
        return false
    end

end

return level1


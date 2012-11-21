level2 = {}
setmetatable(level2, level)

function level2:new(game, ...)
    local o = getmetatable(self):new(...)


    local n = 50
    local vtxs = {
        vertex:new(0,0),
        vertex:new(1*n,1*n),
        vertex:new(1*n,0),
        vertex:new(2*n,1*n),
        vertex:new(2*n, 0),
        vertex:new(3*n, 1*n),
        vertex:new(3*n, 0),
        vertex:new(4*n, 1*n),
        vertex:new(4*n, 0),
        vertex:new(5*n, 1*n),
        vertex:new(5*n, 0),
        vertex:new(6*n, 1*n),
        vertex:new(6*n, 0),
        vertex:new(7*n, 1*n),
        vertex:new(7*n, 0),
        vertex:new(8*n, 1*n),
        vertex:new(8*n, 0),
        vertex:new(9*n, 1*n),
        vertex:new(9*n, 0),
        vertex:new(10*n, 1*n),
        vertex:new(10*n, 0),
        vertex:new(11*n, 1*n),
        vertex:new(11*n, 0),
        vertex:new(12*n, 1*n),
        vertex:new(12*n, 0),
        vertex:new(13*n, 1*n),
        vertex:new(11*n, 3*n),
        vertex:new(11*n, 2*n),
        vertex:new(10*n, 3*n),
        vertex:new(10*n, 2*n),
        vertex:new(9*n, 3*n),
        vertex:new(9*n, 2*n),
        vertex:new(8*n, 2*n),
        vertex:new(7*n, 3*n),
        vertex:new(7*n, 2*n),
        vertex:new(6*n, 3*n),
        vertex:new(6*n, 2*n),
        vertex:new(5*n, 3*n),
        vertex:new(5*n, 2*n),
        vertex:new(4*n, 3*n),
        vertex:new(4*n, 2*n),
        vertex:new(3*n, 3*n),
        vertex:new(3*n, 2*n),
        vertex:new(2*n, 2*n),
        vertex:new(2*n, 6*n),
        vertex:new(4*n, 6*n),
        vertex:new(4*n, 4*n),
        vertex:new(6*n, 4*n),
        vertex:new(6*n, 6*n),
        vertex:new(8*n, 4*n),
        vertex:new(8*n, 6*n),
        vertex:new(9*n, 6*n),
        vertex:new(9*n, 4*n),
        vertex:new(11*n, 6*n),
        vertex:new(11*n, 7*n),
        vertex:new(6*n, 7*n),
        vertex:new(6*n, 8*n),
        vertex:new(4*n, 7*n),
        vertex:new(2*n, 8*n),
        vertex:new(0, 6*n)

    }

    local bb = replicator_bot:new({ {1,2,60}, {2,3,4} , {4,5,6} , {6,7,8}, {8,9,10}, {10,11,12}, {12,13,14}, {14,15,16}, {16,17,18}, {18,19,20}, {20,21,22}, {22,23,24}, {24,25,26} , {26,27,28}, {28,29,30}, {30,31,32}, {33, 34,35}, {35,36,37}, {37,38,39} , {39,40,41}, {41,42,43}, {2, 24, 28, 44}}, vertex:new(500, 200), 80, 40, 5, polygon:new(vtxs), 10)

    --bb.distance_to_change_direction = 20
    local bots = {
        bb

    }

    game.go.bots = botsgod:new(bots)
    game.go.gamestats.alive = game.go.gamestats.alive + #bots

    o.bots = bots
    o.name = 2
    o.full_name = 'Репликатор'
    o.watch_for_bot = bb
    o.rewarded = {}

    setmetatable(o, self)
    self.__index = self
    return o
end

function level2:update(...)
    if (self.completed == 3) then
           return 'completed'
    end
    local dt, g = ...
    if (self.watch_for_bot.dead and not self.rewarded.freezer) then
        g.go.youare.skills.weapon = true
        g.go.youare.skills.freezer = true
        self.rewarded.freezer = true
        g:give_skill(skill_turbo:new(5000))
        osdd:add({text = 'За смелое решение вы награждаетесь 5000 еденицами ускорения и новым умением - Заморозка. Стрельбы заморозкой - кнопка X (икс). Пуля парализует врага на 5 секунд. \n\n [ Нажмите Esc для закрытия сообщения ]', header = 'За смелость', before = function(self, v)  end, close = function(self, v) print('shit'..v.state) end})

    end

    local dt, g = ...
    local all_dead = true
    g.go.bots:call_for_all(function(i, b)
        if (not b.dead) then
            all_dead = false
        end
    end)

    if (all_dead) then

        g.restore.youare = deepcopy(g.go.youare)
        g.restore.frags = g.go.gamestats.frags

        local l = self
        l.completed = 3

        return false
    else
        return false
    end
    return false
end

return level1


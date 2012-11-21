game = {}

function game:new()
    local o = {}
    o.go = {}
    o.inited = false
    o.level = false
    o.restore = {

    }
    o.status = 'wait_init'

    setmetatable(o, self)
    self.__index = self
    return o
end

function game:init()
    self.go.gameBullets = bullets:init({});
    --self.go.youare =  hero:new(vertex:new(790, 50))

    self.go.caches = {mapxy = nil, capturings = {}}
    self.go.gameMap = map:new({
        vertex:new(10,10),
        vertex:new(1010,10),
        vertex:new(1010,610),
        vertex:new(10,610)
    })
    self.go.youare =  hero:new(self.go.gameMap.vertices[1])
    self.go.youare.lifes = 25

    self.go.youare.skills = {}
    self.go.gamestats = {
        frags = 0,
        alive = 0,
        capturings = 0
    }
    local max_min = self.go.gameMap:get_max_min()
    self.go.caches.game_area = {max_min.min.x-5, max_min.min.y-5 , (max_min.max.x - max_min.min.x)+10 , (max_min.max.y - max_min.min.y)+10, polygon:new(deepcopy(self.go.gameMap.vertices))}
    self.inited = true
end

function game:start_level(level)
    self.status = 'level_screen'
    self:init()
    if (self.restore.youare) then
        self.go.youare = self.restore.youare
        self.go.youare.position = self.go.gameMap.vertices[1]
        self.go.gamestats.frags = self.restore.frags
    end
    local level = level or 1
    self.level = _G['level'..level]:new(self)
end

function game:update(dt)
    local r = self.level:update(dt, self)
    if (r == 'completed') then
        if (self.level.name >= 1 and self.level.name < 3) then
            self:start_level(self.level.name + 1)
        end
    end
end

function game:give_skill(skill)
    local skl = self.go.youare.skills[skill:get_name()]
    if (skl) then
        skl:give(skill.amount)
    else
        self.go.youare.skills[skill:get_name()] = skill
    end
end



return game


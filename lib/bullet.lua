bullet = {}


function bullet:new(traectory, maxsteps, speed)
    local o = {}
    o.traectory = traectory
    o.maxsteps = maxsteps
    o.nextPoint = false
    o.speed = speed or 100
    o.stepsLeft = maxsteps
    o.state = 'start'
    setmetatable(o, self)
    self.__index = self
    return o;
end

function bullet:update(dt, gameMap)
    if (self.state == 'dead') then return false end

    local move = dt*self.speed
    self.stepsLeft = self.stepsLeft - move
    if (self.stepsLeft < 0) then
        self.state = 'dead'
        self.stepsLeft = 0
        return false
    end
    local n = self.traectory:next_point(self.maxsteps - self.stepsLeft, false)
    if (n) then
        self.nextPoint = n
        self.state = 'active'
    end
    if (not gameMap:is_inside(self.nextPoint)) then
        self.state = 'dead'
    end
end

function bullet:die()
end

function bullet:draw()
    if (self.nextPoint and self.state == 'active') then
        love.graphics.point(self.nextPoint:xy());
    end
end

function bullet:get_position()
    return self.nextPoint
end

function bullet:die()
    self.state = 'dead'
end

return bullet

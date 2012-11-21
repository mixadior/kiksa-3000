map_captured_block = {}

-- map should be always cw oriented polygon. You understand me stupid bitch?

function map_captured_block:new(polygon, expansion)
    setmetatable(self, {__index = polygon})
    local o = {}
    o.expire = calc_map_captured_block_expire(polygon)
    o.fixed = false
    o.expired = false
    o.expire_vertices = expansion

    for i=1, #expansion, 1 do
        polygon:remove_equal_vertex(expansion[i])
    end
    o.rollback_vertices = polygon.vertices
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function map_captured_block:fix_vertex(vertex)
    for i=1, #self.expire_vertex,1 do
    end
end

function calc_map_captured_block_expire(map_captured_block)
    local level = gameHero.level or 1
    return map_captured_block:len() * (1e-3 / level)
end

function map_captured_block:fix()
    self.fixed = true
end

function map_captured_block:update(dt)
    self.expired = self.expired - dt
    if (self.expired < 0) then
        self.expired = true
    end
end

return map_captured_block

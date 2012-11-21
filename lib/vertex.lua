vertex = {}
setmetatable(vertex, structure_base)

function vertex:new(x,y)
    local o = getmetatable(self):new();
    o.x = x
    o.y = y
    setmetatable(o, self);
    self.__index = self;
    return o
end

function vertex:move(dx,dy)
    self.x = self.x + dx
    self.y = self.y + dy
    return self
end

function vertex:rotate(angle, rotationVertex)
    local x,y = self:apply_coords_center(rotationVertex):xy()
    self.x = x * math.cos(math.rad(angle)) - y * math.sin(math.rad(angle))
    self.y = x * math.sin(math.rad(angle))  + y * math.cos(math.rad(angle))
    self:move(rotationVertex.x, rotationVertex.y);
    return self
end

function vertex:rotate_and_move(angle, rotationVertex, movingToVertex)
    self:rotate(angle, rotationVertex)
    self:move(movingToVertex.x, movingToVertex.y)
    return self
end

function vertex:get_invert()
    return self.x * -1, self.y * -1
end

function vertex:nearest(vertices)
    local min = false
    for i = 1, #vertices do
        local vec = vector:new(self:clone(), vertices[i]);
        local len = vec:len();
        if ((not min or len < min.len) and (not self:equal(vertices[i]))) then
            min = {vtx = vertices[i], len = len}   --{ x = point[i].x, y = point[i].y, len = len }
        end
    end
    if (not min) then return vertices[1] end
    return min.vtx;
end

function vertex:equal(vertex)
    return (utils.rounder(vertex.x) == utils.rounder(self.x)) and (utils.rounder(vertex.y) == utils.rounder(self.y))
end

function vertex:apply_coords_center(center)
    self:move(center:get_invert());
    return self
end

function vertex:xy()
    return self.x, self.y
end

function vertex:invert_y()
    self.y = self.y * -1
    return self;
end

function vertex:clone()
    return vertex:new(self.x, self.y);
end

return vertex;
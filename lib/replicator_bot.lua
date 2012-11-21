replicator_bot = {}
setmetatable(replicator_bot, bot)

function replicator_bot:new(replication_program, ...)

    local o =  getmetatable(self):new(...)
    o.children = {}
    o.type = "replicator"
    o.pregnant = true
    o.color = {0,255,0}
    o.default_color = {0,255,0}


    o.replication_program = replication_program
    o.replication = {}

    setmetatable(o, self)
    self.__index = self

    if (o.replication_program) then
        for i=1, #o.replication_program,1 do
            local vtxs = {}
            for j=1, #o.replication_program[i], 1 do
                -- i know this is shit code, but it means that every program is list of vertices indexes
                table.insert(vtxs, o.borderVertex.vertices[o.replication_program[i][j]]:clone());
            end
            local p = polygon:new(vtxs)
            table.insert(o.replication, p)
        end
    end

    return o
end

function replicator_bot:replicate(hero, bots)
    if (self.dead) then return false end
    if (#self.borderVertex.vertices == 3) then
        return false
    end
    local a, rv, nn = self.angle, self.rotationVertex, self.nullNullReal
    if (hero.state == "capture") then

        if (#self.replication > 0) then
            for i=1, #self.replication,1 do
                local p = self.replication[i]
                local b = bot:new(p:centroid():rotate_and_move(a, rv, nn), 0,0, 10, p)
                b.color = self.color
                b.default_color = self.color
                b.angle = a
                table.insert(bots.bots, b)
            end
            hrumalka.go.gamestats.alive = hrumalka.go.gamestats.alive + #self.replication - 1
        else

            local triangles = self.botPolygon:triangulate()

            for i=1, #triangles, 1 do
                local sv = triangles[i]:centroid()
                local botPoly = triangles[i]:clone():map_to_vertex(
                    function(v)
                        v:rotate_and_move(-a, vertex:new(rv:get_invert()), vertex:new(nn:get_invert()))
                    end);
                local b  = bot:new(sv, 0,0, 10, botPoly);
                b.color = self.default_color
                b.default_color = self.default_color
                b.angle = a
                table.insert(bots.bots, b)
            end
            hrumalka.go.gamestats.alive = hrumalka.go.gamestats.alive + #triangles - 1
        end
        ssfx:play('holyshit')
        self:kill(3)
    end
    hero:to_safe_place()
end

function replicator_bot:draw()
    if (self.dead and self.killed ~= 1) then return true end
    if (self.botPolygon) then

        if (self.killed == 1) then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 100);
        else
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 50);
        end
        love.graphics.polygon('line', self.mmp:xy());
        love.graphics.polygon('line', self.botPolygon:xy());

        if (not self.dead) then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 255);
        end
        if (#self.replication > 0) then
            for i=1, #self.replication_program,1 do
                local vtxs = {}
                for j=1, #self.replication_program[i], 1 do
                    -- i know this is shit code, but it means that every program is list of vertices indexes
                    table.insert(vtxs, self.botPolygon.vertices[self.replication_program[i][j]]:clone());
                end
                local p = polygon:new(vtxs)
                love.graphics.polygon('line', p:xy());
            end
        else
            local tr = self.botPolygon:triangulate()
            for i=1, #tr, 1 do
                love.graphics.polygon('line', tr[i]:xy());
            end
        end
        if (self.affectedBy and not self.dead) then
            if (self.affectedBy.type == 'cold') then
                love.graphics.setColor(255,255,255);
                local textPos = self.botPolygon:centroid()
                love.graphics.print(math.max(0, math.ceil(self.affectedBy.time - self.timings.frozen)), textPos.x, textPos.y, 0, 2,2, 5,10)
            end
        end
    end
end

return replicator_bot


bot = {}

function bot:new(startVertex, xlen, ylen, rays, poly , speed)

    local conv =  vertex:new(xlen/2, ylen/2)
    local b = {

        vtx1 = {},
        vtx2 = {}
    }

    if (poly) then
        b.borderVertex = poly
        b.borderMM = poly:get_border()
        b.borderMM:apply_coords_center(b.borderVertex:centroid())
        b.borderVertex:apply_coords_center(b.borderVertex:centroid())
    else
        b.borderVertex =  polygon:new({
            vertex:new(0, 0),
            vertex:new(xlen, 0),
            vertex:new(xlen, ylen),
            vertex:new(0, ylen)
        })
        b.borderVertex:apply_coords_center(b.borderVertex:centroid())
        b.borderMM = b.borderVertex
    end

    b.cachedByAngle = {}


    if (rays and rays > 0) then
        b.raysAmount = rays
    else
        b.raysAmount = 30
    end
    b.color = {255, 255, math.random(0,255) }
    b.default_color = {255, 255, math.random(0,255) }
    b.dead = false
    b.hidden = false
    b.killed = 0
    b.id = os.time()..math.random()
    b.convertVertex = startVertex
    b.centroid =  vertex:new(0, 0)
    b.rotationVertex = b.centroid:clone()
    b.nullNull = b.centroid:clone()
    -- this point is real position of b center, we convert all points to coordination system by this point, we move it to move all points of b
    b.nullNullReal = startVertex
    b.state = "change";
    b.angle = 0;
    b.mimeOne = 1;
    b.distance = 0;
    b.distance_to_change_direction = 1000
    b.speed = speed or 50
    b.cnt3 = 0
    b.timings = {
        rotate = 0
    }
    b.affectedBy = false
    b.botPolygon = false;
    setmetatable(b, self);
    self.__index = self;
    return b;
end

function bot:update(dt, map)

    if (self.dead) then
        return false
    end

    if (self.affectedBy) then

        if (self.affectedBy.type == 'cold') then
            if (self.timings.frozen >= self.affectedBy.time) then
                self.affectedBy:die()
                self.affectedBy = false
                self.timings.frozen = nil
                self.color = self.default_color
            else
                self.color = {0,0,255}
                self:increment_timings(dt)
                return false
            end
        end
    end

    local shaker,waypoints, wayPointCross, botNextStep
    local step = utils.rounder(dt * self.speed)

    local angle_ch = false
    local angle_diff = 0

    local rotate_timing = 0.05
    if (activated_speed_pc) then
        rotate_timing = 0.8
    end
    if (self.timings.rotate > rotate_timing or self.timings.rotate == 0) then
        angle_ch = true
        angle_diff = utils.rounder(dt * 10 * (self.mimeOne), 3);
        local angle = self.angle + angle_diff
        if (math.abs(angle) > 360) then
            angle = angle - (360 * self.mimeOne)
        end
        self.angleBackup = self.angle
        self.angle = angle;

        self.timings.rotate = 0
    end

    if (math.random(1, 10000) < 20) then
        self.mimeOne = self.mimeOne * -1
    end

    if (self.state == "rebuild") then
        if (self.state == "rebuild") then
            self.state = "flying"
        end
    end

    local centroid = vertex:new(self.centroid.x, self.centroid.y)
    centroid:rotate_and_move(self.angle, self.rotationVertex, self.nullNullReal);

    if (self.distance > self.distance_to_change_direction or self.distance == 0 or self.state == "change") then
        self.distance = 0
        if (not map:pnpoly(centroid)) then
            self.waypoint = map:get_random_inside()
            self.wayPointCross = self.waypoint
        else
            waypoints = self:generate_waypoints(map)
            shaker = { 1, 2, 3, 4 }
            if (self.excludeShakerChoice ~= nil) then
                table.remove(shaker, self.excludeShakerChoice)
                self.excludeShakerChoice = nil

            end
            self.shakerChoice = math.random(1, #shaker)
            self.waypoint = waypoints[shaker[self.shakerChoice]]
            self.wayPointCross = map:nearest_crossing(vector:new(centroid, self.waypoint), centroid)
        end
        self.state = "flying"
    end

    --fucking debug
    if (self.wayPointCross == nil) then
        debug_log('centroid:'..centroid.x..' '..centroid.y)
        debug_log('wp:'..self.waypoint.x..' '..self.waypoint.y)
        debug_flush();
    end

    local traectoryVector = vector:new(centroid, self.wayPointCross)
    local traectoryNextPoint = traectoryVector:next_point(step, true)

    if (not traectoryNextPoint or (not map:pnpoly(traectoryNextPoint, true) and not map:pnpoly(self.waypoint))) then
        self.state = "change"
    else
        self.vectorsDraw = {}
        local diffX = traectoryNextPoint.x - centroid.x
        local diffY = traectoryNextPoint.y  - centroid.y

        local nullNullReal = self.nullNullReal:clone()
        nullNullReal.x = nullNullReal.x + diffX
        nullNullReal.y = nullNullReal.y + diffY
        self.distance = self.distance + step
        -- move and rotate rays too

        local angle, rv, nn = self.angle, self.rotationVertex, nullNullReal

        if (self.cachedByAngle.bp == nil or angle_diff > 0) then
            self.cachedByAngle.bp =  self.borderVertex:clone():map_to_vertex(function(v)
                v:rotate(angle, rv)
            end)
        end

        local botPolygon = self.cachedByAngle.bp:clone():map_to_vertex(
            function (v)
                v:move(nn.x, nn.y)
            end
        );
        if (activated_speed_pc) then
            if (self.cachedByAngle.mmp == nil or angle_diff > 0) then
                        self.cachedByAngle.mmp =  self.borderMM:clone():map_to_vertex(function(v)
                            v:rotate(angle, rv)
                        end)
            end
            local mmP = self.cachedByAngle.mmp:clone():map_to_vertex(
                        function (v)
                            v:move(nn.x, nn.y)
                        end
                    );

            self.mmp = mmP
            --print_r(mmP.vertices)
            local outOfMap = false
            local allowRotate = false
            if (self.cnt3 > 15) then
                allowRotate = true
            end

                for i=1,#mmP.vertices,1 do

                    if (not map:is_inside(mmP.vertices[i])) then
                        if (not allowRotate) then
                            self.state = "change"
                            self.excludeShakerChoice = self.shakerChoice
                        end
                        outOfMap = true

                        self.cnt3 = self.cnt3 + 1
                        break;


                    end
                end

            if (not outOfMap) then

                self.nullNullReal = nullNullReal
                self.botPolygon = botPolygon
                self.cnt3 = 0
            else
                 if (not allowRotate) then

                    self.angle = self.angleBackup
                 else
                     self.botPolygon = botPolygon
                 end
            end
        else
            --self.angle = self.angleBackup
            self.nullNullReal = nullNullReal
            self.botPolygon = botPolygon
        end
    end
    self:increment_timings(dt);
end

function bot:generate_points(amount)
    for i = 1, amount do
        table.insert(self.vtx1, vertex:new(math.random(self.borderVertex[1].x, self.centroid.x), math.random(self.borderVertex[1].y, self.centroid.y)));
        table.insert(self.vtx2, vertex:new(math.random(self.centroid.x, self.borderVertex[3].x), math.random(self.centroid.y, self.borderVertex[3].y)));
    end
end

function bot:increment_timings(dt)
    for k,v in pairs(self.timings) do
        self.timings[k] = self.timings[k] + dt;
    end
end

function bot:generate_waypoints(map)
    local out_map_ranges = map:get_out_of_map_ranges()
    return {
        vertex:new(math.random(out_map_ranges[1].x[1], out_map_ranges[1].x[2]), math.random(out_map_ranges[1].y[1], out_map_ranges[1].y[2])),
        vertex:new(math.random(out_map_ranges[2].x[1], out_map_ranges[2].x[2]), math.random(out_map_ranges[2].y[1], out_map_ranges[2].y[2])),
        vertex:new(math.random(out_map_ranges[3].x[1], out_map_ranges[3].x[2]), math.random(out_map_ranges[3].y[1], out_map_ranges[3].y[2])),
        vertex:new(math.random(out_map_ranges[4].x[1], out_map_ranges[4].x[2]), math.random(out_map_ranges[4].y[1], out_map_ranges[4].y[2]))
    }
end

function bot:check_collision(hero)
    if (self.dead) then return false end
    if (not self.botPolygon) then return false end
    if (hero.state == "capture") then
        if (self.botPolygon:pnpoly(hero.position)) then
            return true;
        end

        for i=1, #hero.expansion,1 do
            local np
            local ni = next(hero.expansion, i)
            if (not ni) then
                np = hero.position
            else
                np = hero.expansion[ni]
            end

            local crossings = self.botPolygon:crossings(vector:new(hero.expansion[i], np))
            if (#crossings > 0) then
                return true
            end
        end
    end
    return false
end

function bot:draw()
    if (self.dead and self.killed ~= 1) then return true end
    if (self.botPolygon) then
        local color = self.color

        if (self.killed == 1) then
            love.graphics.setColor(color[1], color[2], color[3], 100);
        else
            love.graphics.setColor(color[1], color[2], color[3]);
        end
        --love.graphics.polygon('line', self.mmp:xy());
        love.graphics.polygon('line', self.botPolygon:xy());
        if (self.affectedBy and not self.dead) then
            if (self.affectedBy.type == 'cold') then
                love.graphics.setColor(255,255,255);
                local textPos = self.botPolygon:centroid()
                love.graphics.print(math.max(0, math.ceil(self.affectedBy.time - self.timings.frozen)), textPos.x, textPos.y, 0, 2,2, 5,10)
            end
        end
    end
end

function bot:is_inside(poly)
    local centroid = vertex:new(self.centroid.x, self.centroid.y)
    centroid:rotate_and_move(self.angle, self.rotationVertex, self.nullNullReal);
    return poly:pnpoly(centroid);
end

function bot:kill(kill_type)
    if (not self.dead) then
        self.dead = true
        self.killed = kill_type or 1
        if (kill_type ~= 3) then
            hrumalka.go.gamestats.alive = hrumalka.go.gamestats.alive - 1
            hrumalka.go.gamestats.frags = hrumalka.go.gamestats.frags + 1
        end
    end
end

function bot:scale(coef)
    self.borderVertex = self.borderVertex:scale(coef);
    self.state = "rebuild"
end

function bot:is_catched_bullet(bullet)
    if (not self.dead and self.botPolygon) then
        if (self.botPolygon:pnpoly(bullet:get_position(), true)) then
            return true
        end
    end
    return false
end



return bot;

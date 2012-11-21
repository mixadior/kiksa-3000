local vertex = require('.vertex');
local vector = require('.vector');

bot2 = {}

function bot2:new(startVertex, xlen, ylen, rays)

    local conv = vertex:new(xlen/2, ylen/2)
    local bot = {
        borderVertex = {
            vertex:new(0, 0):apply_coords_center(conv),
            vertex:new(xlen, 0):apply_coords_center(conv),
            vertex:new(xlen, ylen):apply_coords_center(conv),
            vertex:new(0, ylen):apply_coords_center(conv)
        },
        vtx1 = {},
        vtx2 = {}
    }
    bot.raysAmount = 50
    bot.convertVertex = startVertex
    bot.centroid =  vertex:new(0, 0)
    bot.rotationVertex = bot.centroid:clone()
    bot.nullNull = bot.centroid:clone()
    -- this point is real position of bot center, we convert all points to coordination system by this point, we move it to move all points of bot
    bot.nullNullReal = startVertex
    bot.state = "change";
    bot.angle = 0;
    bot.mimeOne = 1;
    bot.distance = 0;
    bot.timings = {
        regenerateRays = 0
    }

    setmetatable(bot, self);
    self.__index = self;
    return bot;
end

function bot2:update(dt, map)
    local shaker,waypoints, wayPointCross, botNextStep
    local step = dt * 100
    local angle = self.angle + dt * 100 * (self.mimeOne)
    if (angle > 360) then
        angle = angle - 360
    end
    self.angle = angle;

    if (math.random(1, 10000) < 20) then
        self.mimeOne = self.mimeOne * -1
    end

    if (self.timings.regenerateRays > 0.05 or self.timings.regenerateRays == 0) then
        self.timings.regenerateRays = 0
        self.vtx1 = {}
        self.vtx2 = {}
        self.vtx3 = {}
        self.vtx4 = {}
        self:generate_points(self.raysAmount)

    end

    local centroid = vertex:new(self.centroid.x, self.centroid.y)
    centroid:rotate_and_move(angle, self.rotationVertex, self.nullNullReal);
    if (self.distance > 1000 or self.distance == 0 or self.state == "change") then
        self.distance = 0
        waypoints = self:generate_waypoints(map)
        shaker = { 1, 2, 3, 4 }
        self.waypoint = waypoints[shaker[math.random(1, 4)]]
        self.wayPointCross = map:nearest_crossing(vector:new(centroid, self.waypoint), centroid)
        self.state = "flying"
    end

    local traectoryVector = vector:new(centroid, self.wayPointCross)
    local traectoryNextPoint = traectoryVector:next_point(step, true)

    if (not traectoryNextPoint or not map:is_inside(traectoryNextPoint) or traectoryVector:len() < 20) then
        print('change');
        self.state = "change"
    else
        self.vectorsDraw = {}
        local diffX = traectoryNextPoint.x - centroid.x
        local diffY = traectoryNextPoint.y  - centroid.y
        self.nullNullReal.x = self.nullNullReal.x + diffX
        self.nullNullReal.y = self.nullNullReal.y + diffY
        self.distance = self.distance + step
        -- move and rotate rays too
        for i = 1, #self.vtx1 do

            local vtx1 = self.vtx1[i]:clone():rotate_and_move(angle, self.rotationVertex, self.nullNullReal)
            local vtx2 = self.vtx2[i]:clone():rotate_and_move(angle, self.rotationVertex, self.nullNullReal)
            local vtx3 = self.vtx3[i]:clone():rotate_and_move(angle, self.rotationVertex, self.nullNullReal)
            local vtx4 = self.vtx4[i]:clone():rotate_and_move(angle, self.rotationVertex, self.nullNullReal)

            local vector1 = vector:new(centroid, vtx1)
            local vector2 = vector:new(centroid, vtx2)

            local vector3 = vector:new(centroid, vtx3)
            local vector4 = vector:new(centroid, vtx4)

            local vec1c = map:nearest_crossing(vector1, centroid)
            local vec2c = map:nearest_crossing(vector2, centroid)
            local vec3c = map:nearest_crossing(vector3, centroid)
            local vec4c = map:nearest_crossing(vector4, centroid)

            if (vec1c) then
                vector1[2] = vec1c
            end

            if (vec2c) then
                vector2[2] = vec2c
            end

            if (vec3c) then
                vector3[2] = vec3c
            end

            if (vec4c) then
                vector4[2] = vec4c
            end

            table.insert(self.vectorsDraw, vector1)
            table.insert(self.vectorsDraw, vector2)
            table.insert(self.vectorsDraw, vector3)
            table.insert(self.vectorsDraw, vector4)
        end
    end

    self:increment_timings(dt);
end

function bot2:generate_points(amount)
    for i = 1, amount do
        table.insert(self.vtx1, vertex:new(math.random(self.borderVertex[1].x, self.centroid.x), math.random(self.borderVertex[1].y, self.centroid.y)));
        table.insert(self.vtx2, vertex:new(math.random(self.centroid.x, self.borderVertex[3].x), math.random(self.centroid.y, self.borderVertex[3].y)));

        table.insert(self.vtx3, vertex:new(math.random(self.borderVertex[1].x, self.centroid.x), math.random(self.centroid.y, self.borderVertex[3].y )));
        table.insert(self.vtx4, vertex:new(math.random(self.centroid.x, self.borderVertex[2].x), math.random(self.borderVertex[2].y, self.centroid.y)));

    end
end

function bot2:increment_timings(dt)
    for k,v in pairs(self.timings) do
        self.timings[k] = self.timings[k] + dt;
    end
end

function bot2:generate_waypoints(map)
    local out_map_ranges = map:get_out_of_map_ranges()
    return {
        vertex:new(math.random(out_map_ranges[1].x[1], out_map_ranges[1].x[2]), math.random(out_map_ranges[1].y[1], out_map_ranges[1].y[2])),
        vertex:new(math.random(out_map_ranges[2].x[1], out_map_ranges[2].x[2]), math.random(out_map_ranges[2].y[1], out_map_ranges[2].y[2])),
        vertex:new(math.random(out_map_ranges[3].x[1], out_map_ranges[3].x[2]), math.random(out_map_ranges[3].y[1], out_map_ranges[3].y[2])),
        vertex:new(math.random(out_map_ranges[4].x[1], out_map_ranges[4].x[2]), math.random(out_map_ranges[4].y[1], out_map_ranges[4].y[2]))
    }
end

function bot2:draw()
    love.graphics.setColor(255,128-math.random(1,128),0)
    for i = 1, #self.vectorsDraw do

        love.graphics.line(self.vectorsDraw[i]:xy())
    end
end

return bot2;

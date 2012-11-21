hero = {}

function hero:new(position)
    local hero = {}
    hero.state = "start"
    hero.speed = 100
    hero.dead_count = 0
    hero.path = {}
    hero.direction = false
    hero.position = position or vertex:new(10, 50)
    hero.expansion = {}
    hero.mode = 'walk'
    hero.weapon_basis = false
    hero.gun_length = 5
    setmetatable(hero, self)
    self.__index = self
    self.moved = 0
    self.total_moved = 0
    return hero;
end

function hero:move(direction, steps, map)

    local function weaponBasis(v1,v2, pos, map)
        local poss= {}
        if (utils.eq(v1.x, v2.x)) then
            table.insert(poss, {vertex:new(pos.x + 1, pos.y), 'x', 1})
            table.insert(poss, {vertex:new(pos.x - 1, pos.y), 'x', -1})
        elseif (utils.eq(v1.y, v2.y)) then
            table.insert(poss, {vertex:new(pos.x, pos.y + 1), 'y', 1})
            table.insert(poss, {vertex:new(pos.x, pos.y - 1), 'y', -1})
        end
        if (#poss > 0) then
            for i=1, #poss, 1 do
                if (map:is_inside(poss[i][1])) then
                    return poss[i]
                end
            end
        end
        return false;
    end

    self.moved = 0
    local direction_ch = false
    if (self.direction ~= direction) then
        direction_ch = true
    end


    if (self.state == "capture" and is_backward(direction, self.direction)) then
        direction_ch = false
        --self.direction = false
        return false
    end

    self.direction = direction

    local new_position = self.position:clone()
    self:move_by_direction(new_position, direction, steps)
    -- check that new hero position is not outside map
    local on_map_edge, on_map_edge2 = map:on_edge(new_position)
    self.weapon_basis = false
    if (map:is_inside(new_position)) then
        if (self.mode == 'draw') then

            if (#self.expansion > 1) then
                for i = 1, #self.expansion-1,1 do
                    local ni = next(self.expansion, i)
                    if (vector:new(self.expansion[i], self.expansion[ni]):crossing(vector:new(self.position, new_position))) then
                        --new_position = self.position
                        self:move_by_direction(new_position, direction, 15, -1)
                        break;
                    end
                end

            end
            --if hero move out of map edge and start to move trying to catch pepyaka
            if (direction_ch) then
                table.insert(self.expansion, self.position)
                -- this case when hero started move without change of direction e.g. when moving from one of map edges vertex
            else
                local vtx1, vtx2 = map:on_edge(self.position)
                if (vtx1 and vtx2) then
                    local nearest = new_position:nearest({map:get_vertex(vtx1), map:get_vertex(vtx2)})
                    table.insert(self.expansion, nearest:clone())
                end
            end
            self.state = 'capture'
        else
            --print(new_position:xy())
            if (not direction_ch) then
                local vtx1, vtx2 = map:on_edge(self.position)
                if (vtx1 and vtx2) then
                    local nearest = new_position:nearest({map:get_vertex(vtx1), map:get_vertex(vtx2)})
                    new_position = nearest
                end
            else
                new_position = self.position
            end
            self.direction = false
        end

    elseif (on_map_edge) then

        if (self.state == "capture") then
            self.state = "save"
        else

            if (self.skills.freezer) then
                local weapon_basis = weaponBasis(map.vertices[on_map_edge], map.vertices[on_map_edge2], new_position, map)

                if (weapon_basis) then
                    local gunl = self.gun_length
                    local gun = vector:new(new_position, weapon_basis[1]:clone():map(function (s) s[weapon_basis[2]] = s[weapon_basis[2]] + weapon_basis[3] * gunl end))
                    if (#map:crossings(gun) < 2) then
                        self.weapon_basis = weapon_basis
                    end
                end
            end
        end
    else

        local nearest_edge_crossing = map:nearest_crossing(vector:new(self.position, new_position), self.position)
        new_position = nearest_edge_crossing
        if (self.state == "capture") then
            self.state = "save"
        end
    end

    if (self.state == "save") then
        if (direction_ch) then
            table.insert(self.expansion, self.position)
        end

        table.insert(self.expansion, new_position)

    end

    if (not new_position) then
        print(new_position)
        print_r(map)
    end

    if (self.position.x == new_position.x and self.position.y == new_position.y) then
        self.moved = 0
    end


    self.position = new_position
    if (self.skills.turbo) then
        self.skills.turbo:update({step = self.moved})
    end


end



function hero:to_safe_place()
    if (self.state == 'capture') then
        local expansion_start = self.expansion[1]
        self.position = expansion_start
        self.expansion = {}
        self.state = "start"
        self.direction = false
        --print_r(expansion_start)
    end
end

function hero:toggle_draw_mode()
    if (self.mode == 'walk') then
        self.mode = 'draw'
    else
        if (self.state == 'capture') then
            return false
        else
            self.mode = 'walk'
        end
    end
end

function hero:turn_mode(mode)
    if (self.state == 'capture') then
        return false
    end
    self.mode = mode
end

function hero:fire()
    if (self.weapon_basis) then
        local weapon_basis, gunl = self.weapon_basis, self.gun_length
        local shoot_vector_p1,  shoot_vector_p2 = weapon_basis[1]:clone():map(function (s) s[weapon_basis[2]] = s[weapon_basis[2]] + weapon_basis[3] * gunl end), weapon_basis[1]:clone():map(function (s) s[weapon_basis[2]] = s[weapon_basis[2]] + weapon_basis[3] * (gunl+1) end)
        local bullet = bullet_cold:new(vector:new(shoot_vector_p1, shoot_vector_p2), 500, 500);
        table.insert(hrumalka.go.gameBullets.bullets, bullet)
    end
end


function hero:move_by_direction(vertex, direction, step, koef)

    local koefs = {up = -1, down = 1, left = -1, right = 1 }
    local koef = koef or 1

    self.moved = self.moved + step * koef
    self.total_moved = self.total_moved + math.abs(self.moved)
    if (direction == "up" or direction == "down") then
        vertex.y = vertex.y + step * koef * koefs[direction]
    else
        vertex.x =
        vertex.x +
                step *
                koef *
                koefs[direction]
    end
    return vertex
end

function is_backward(direction1, direction2)
    local d = {up = "down", down = "up", left = "right", right = "left" }
    if (d[direction1] == direction2) then
        return true
    end
    return false
end


return hero;


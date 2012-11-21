map = {}
setmetatable(map, polygon)

-- map should be always cw oriented polygon. You understand me stupid bitch?

function map:new(vertices)
    local o = getmetatable(self):new(vertices)
    o.expansions = {}
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function map:nearest_crossing(vector, to_vertex)
    local crossings = self:crossings(vector)
    local nearest_crossing
    if (not crossings) then
        return false
    else
        if (#crossings > 1) then
            nearest_crossing = to_vertex:nearest(crossings)
        else
            nearest_crossing = crossings[1]
        end
        return nearest_crossing
    end
end

function map:get_out_of_map_ranges()
    local maxmin = self:get_max_min();
    local ranges = {
        {x = {maxmin.min.x - 10, maxmin.min.x - 1}, y = {maxmin.min.y - 10, maxmin.max.y + 10}},
        {x = {maxmin.min.x, maxmin.max.x}, y = {maxmin.min.y - 10, maxmin.min.y - 1}},
        {x = {maxmin.max.x + 1, maxmin.max.x + 10}, y = {maxmin.min.y - 10, maxmin.max.y + 10}},
        {x = {maxmin.min.x, maxmin.max.x}, y = {maxmin.max.y + 1, maxmin.max.y + 10}}
    }
    return ranges
end

function map:is_inside(vertex)
    return self:pnpoly(vertex, false)
end

function map:get_random_inside()
    local triangles = self:triangulate()
    local rand = math.random(1, #triangles)
    return triangles[rand]:centroid();
end


function map:merge_with_line(expansion)

    local on_same_edge = false
    local on_same_edge_cw = false
    local expansion_vtx_first = expansion[1]
    local expansion_vtx_last = expansion[#expansion]

    local edge_first_1,edge_first_2 = self:on_edge(expansion_vtx_first)
    local edge_last_1, edge_last_2 = self:on_edge(expansion_vtx_last)

    if (edge_first_1 == edge_last_1 and edge_first_2 == edge_last_2) then

        on_same_edge = true
    end

    if (on_same_edge) then
        if (vector:new(expansion_vtx_last, self:get_vertex(edge_last_2)):len() < vector:new(expansion_vtx_first, self:get_vertex(edge_last_2)):len()) then
            on_same_edge_cw = true
        end
    end

    local poly_cw, poly_ccw = false, false
    if (on_same_edge) then
        if (on_same_edge_cw) then
            poly_cw = expansion
        else
            poly_ccw = expansion
        end
    end

    if (not poly_cw) then
        poly_cw = {}
        table.insert(poly_cw, expansion_vtx_first:clone())
        local i = edge_first_1
        while (true) do
            i = next(self.vertices, i) or 1;

            local merging_vertex = self.vertices[i]:clone()
            if (merging_vertex:equal(self.vertices[edge_last_1])) then
                table.insert(poly_cw, merging_vertex)

                if (not(merging_vertex:equal(expansion_vtx_last))) then
                    table.insert(poly_cw, expansion_vtx_last:clone());
                end

                for j = (#expansion)-1, 2, -1 do
                    table.insert(poly_cw, expansion[j]:clone())
                end
                break;
            else
                if (not(expansion_vtx_first:equal(self.vertices[i]))) then
                    table.insert(poly_cw, self.vertices[i]:clone())
                end
            end
        end
    end

    local edge_first_1,edge_first_2 = self:on_edge(expansion_vtx_first, 'ccw')
    local edge_last_1, edge_last_2 = self:on_edge(expansion_vtx_last, 'ccw')

    if (not(poly_ccw)) then
        poly_ccw = {}
        table.insert(poly_ccw, expansion_vtx_first:clone())
        local i = edge_first_1
        while (true) do
            i = i - 1;
            if (i == 0) then
                i = #self.vertices
            end

            local merging_vertex = self.vertices[i]:clone()
            if (merging_vertex:equal(self.vertices[edge_last_1])) then

                table.insert(poly_ccw, merging_vertex)

                if (not(merging_vertex:equal(expansion_vtx_last))) then
                    table.insert(poly_ccw, expansion_vtx_last:clone());
                end

                for j = (#expansion)-1, 2, -1 do
                    table.insert(poly_ccw, expansion[j]:clone())
                end
                break;
            else
                if (not(expansion_vtx_first:equal(self.vertices[i]))) then
                    table.insert(poly_ccw, self.vertices[i]:clone())
                end
            end
        end
    end

    poly_cw = polygon:new(poly_cw)
    poly_ccw = polygon:new(poly_ccw)

    if (poly_cw:orient() ~= 'cw') then
        poly_cw:verte_orientation()
    end

    if (poly_ccw:orient() ~= 'cw') then
        poly_ccw:verte_orientation()
    end

    local result = {}
    if (poly_cw:len() > poly_ccw:len()) then
        result.captured = poly_ccw
        result.left = poly_cw
    else
        result.captured = poly_cw
        result.left = poly_ccw

    end

    return result

end

function map:add_expansion(expansion)
    local merge_result = self:merge_with_line(expansion)
    local expansion = map_captured_block:new(merge_result.captured:clone(), expansion)
end

return map;


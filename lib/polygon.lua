polygon = {}

function polygon:new(vertices)
    local poly = {}
    poly.vertices = vertices;
    setmetatable(poly, self)
    self.__index = self;
    return poly;
end

function polygon:pnpoly(vertex, on_borders)
    local on_borders = on_borders or false
    local x,y = vertex:xy()
    local cnt = false
    local vertexMap = self.vertices
    for i=1,#vertexMap,1 do
        local j = next(vertexMap,i) or 1;
        local borders = vector:new(vertexMap[i], vertexMap[j]):contains(vertex)
        if (on_borders and borders) then
            return true;
        elseif (not(on_borders) and borders) then
            return false;
        elseif ((((vertexMap[i].y <= y) and (y < vertexMap[j].y)) or ((vertexMap[j].y <= y) and (y < vertexMap[i].y))) and  (x < (vertexMap[j].x - vertexMap[i].x) * (y - vertexMap[i].y) / (vertexMap[j].y - vertexMap[i].y) + vertexMap[i].x)) then
            cnt = not cnt
        end
    end

    return cnt
end

function polygon:get_max_min()

    local minx = self.vertices[1].x
    local miny = self.vertices[1].y
    local maxx = self.vertices[1].x
    local maxy = self.vertices[1].y
    for i=1,#self.vertices do
        if (self.vertices[i].x < minx) then minx = self.vertices[i].x end
        if (self.vertices[i].x > maxx) then maxx = self.vertices[i].x end
        if (self.vertices[i].y < miny) then miny = self.vertices[i].y end
        if (self.vertices[i].y > maxy) then maxy = self.vertices[i].y end
    end
    return {min = vertex:new(minx, miny), max = vertex:new(maxx, maxy)}
end

function polygon:crossings(vector)
    local crossings, vertexMap = {}, self.vertices
    for i = 1, #vertexMap do
        if i == #vertexMap then
            nextI = 1
        else
            nextI = i + 1
        end
        local vertexMapVector = vector:new(vertexMap[i], vertexMap[nextI])
        local crossing = vector:crossing(vertexMapVector)
        if (crossing ~= false) then
            table.insert(crossings, crossing)
        end
    end
    return crossings;
end

function polygon:on_edge(vertex , orient)
    local walk_step, start, stop, nextI;
    if (not orient) then orient = "cw" end

    if (orient == self:orient()) then
        walk_step = 1
        start = 1
        stop = #self.vertices
    else
        walk_step = -1
        start = #self.vertices
        stop = 1
    end

    for i=start,stop,walk_step do
        if (walk_step == 1) then
            nextI = next(self.vertices, i) or 1;
        elseif (walk_step < 0) then
            nextI = i + walk_step
            if (nextI == 0) then
                nextI = #self.vertices
            end
        end
        if (vector:new(self.vertices[i], self.vertices[nextI]):contains(vertex)) then
            return i,nextI
        end
    end
    return false
end

function polygon:len()
    local len = 0
    for i = 1, #self.vertices, 1 do
        local ni = next(self.vertices, i) or 1
        len = len + vector:new(self.vertices[i], self.vertices[ni]):len()
    end
    return len;
end

function polygon:orient()
    local next_idx, res
    local min_idx = 1
    local xmin = self.vertices[1].x
    local ymin = self.vertices[1].y * -1
    -- i don't know why when y is inverted it is incorrect, but in games y is always inverted
    for i=2,#self.vertices,1 do
        if (self.vertices[i].y * -1 > ymin) then
        else
            if (self.vertices[i].y * -1 == ymin and self.vertices[i].x < xmin) then
            else
                min_idx = i
                xmin = self.vertices[i].x
                ymin = self.vertices[i].y * -1
            end
        end
    end

    local p,q,r
    if (min_idx == 1) then
        p = self.vertices[#self.vertices-1]:clone():invert_y()
        q = self.vertices[1]:clone():invert_y()
        r = self.vertices[2]:clone():invert_y()
    else
        if (min_idx == #self.vertices) then next_idx = 1 else next_idx = min_idx + 1 end
        p = self.vertices[min_idx-1]:clone():invert_y()
        q = self.vertices[min_idx]:clone():invert_y()
        r = self.vertices[next_idx]:clone():invert_y()

    end

    res =  classify_point(p,q,r)

    if (res >= 0) then
        return 'ccw';
    else
        return 'cw'
    end
end

function classify_point(p,q,r)
    return vector:new(vertex:new(q.x - p.x, q.y - p.y), vertex:new(r.x - p.x, r.y - p.y)):det()
end

function polygon:is_convex()
    local res, resN
    -- i'm lazy bitch
    local function det(p, q, r)
        return vector:new(vertex:new(q.x - p.x, q.y - p.y), vertex:new(r.x - p.x, r.y - p.y)):det()
    end

    local v = self.vertices
    res = det(v[#v], v[1], v[2]) >= 0;
    for i = 2, #v - 1, 1 do
        resN = det(v[i - 1], v[i], v[i + 1]) >= 0
        if (res ~= resN) then
            return false
        end
    end
    resN = det(v[#v - 1], v[#v], v[1]) >= 0
    if resN ~= res then
        return false
    end
    return true
end

function polygon:xy()
    local xy = {}
    for i = 1, #self.vertices, 1 do
        table.insert(xy, self.vertices[i].x)
        table.insert(xy, self.vertices[i].y)
    end
    return xy
end

function polygon:verte_orientation()
    local vertices = {}
    --vertices[1] = self.vertices[1]
    for i=#self.vertices, 1, -1 do
        table.insert(vertices, self.vertices[i])
    end
    self.vertices = vertices
    return self;
end

function polygon:get_vertex(index)
    return self.vertices[index]
end

function polygon:add_vertex(vertex)
    table.insert(self.vertices, vertex)
    return self
end

function polygon:remove_equal_vertex(vertex)
    for i=1,#self.vertices,1 do
        if (self.vertices[i]:equal(vertex)) then
            table.remove(self.vertices, i)
        end
    end
end

function polygon:clone()
    local vertices = {}
    for i=1,#self.vertices,1 do
        table.insert(vertices, self.vertices[i]:clone())
    end
    return polygon:new(vertices)
end

function polygon:scale(scale, apply_point)
    local apply_point = apply_point
    if (apply_point) then
        self:apply_coords_center(apply_point)
    end
    local scale_f = function (v) v.x,v.y = v.x * scale, v.y * scale; return v; end
    self:map_to_vertex(scale_f, true)
    if (apply_point) then
        self:apply_coords_center(vertex:new(apply_point:get_invert()))
    end
    return self
end

-- this function i take from HardonCollider (big big thx to Matthias Richter http://vrld.org) go to http://github.com/vrld/HardonCollider
function polygon:triangulate()
    local function ccw(p1, p2, p3)
        return classify_point(p1, p2, p3) >= 0;
    end
    if #self.vertices == 3 then return {self:clone()} end
    local triangles = {} -- list of triangles to be returned
    local concave = {}   -- list of concave edges
    local adj = {}       -- vertex adjacencies
    local vertices = self.vertices

    -- retrieve adjacencies as the rest will be easier to implement
    for i,p in ipairs(vertices) do
        local l = (i == 1) and vertices[#vertices] or vertices[i-1]
        local r = (i == #vertices) and vertices[1] or vertices[i+1]
        adj[p] = {p = p, l = l, r = r} -- point, left and right neighbor

        -- test if vertex is a concave edge
        if not ccw(l,p,r) then concave[p] = p end
    end


    -- and ear is an edge of the polygon that contains no other
    -- vertex of the polygon
    local function isEar(p1,p2,p3)
        if not ccw(p1,p2,p3) then return false end
        for q,_ in pairs(concave) do
            if q ~= p1 and q ~= p2 and q ~= p3 and pointInTriangle(q, p1,p2,p3) then
                return false
            end
        end
        return true
    end

    -- main loop
    local nPoints, skipped = #vertices, 0
    local p = adj[ vertices[2] ]
    while nPoints > 3 do
        if not concave[p.p] and isEar(p.l, p.p, p.r) then
            -- polygon may be a 'collinear triangle', i.e.
            -- all three points are on a line. In that case
            -- the polygon constructor throws an error.
            if not areCollinear(p.l, p.p, p.r) then
                triangles[#triangles+1] = polygon:new({p.l:clone(), p.p:clone(), p.r:clone()})
                skipped = 0
            end

            if concave[p.l] and ccw(adj[p.l].l, p.l, p.r) then
                concave[p.l] = nil
            end
            if concave[p.r] and ccw(p.l, p.r, adj[p.r].r) then
                concave[p.r] = nil
            end

            -- remove point from list
            adj[p.p] = nil
            adj[p.l].r = p.r
            adj[p.r].l = p.l
            nPoints = nPoints - 1
            skipped = 0
            p = adj[p.l]
        else
            p = adj[p.r]
            skipped = skipped + 1
            assert(skipped <= nPoints, "Cannot triangulate polygon (is the polygon intersecting itself?)")
        end
    end

    if not areCollinear(p.l, p.p, p.r) then
        triangles[#triangles+1] = polygon:new({p.l:clone(), p.p:clone(), p.r:clone()})
    end

    return triangles
end

function polygon:apply_coords_center(center)
    local c = center
    local convert_center  = function(vertex) vertex:apply_coords_center(c) end
    self:map_to_vertex(convert_center, false)
end

function polygon:map_to_vertex(f, do_clone)
    for i=1, #self.vertices,1 do
        if (do_clone) then
            self.vertices[i] = f(self.vertices[i]:clone())
        else
            f(self.vertices[i])
        end
    end
    return self
end

function polygon:centroid()
    local x,y = 0,0
    for i=1, #self.vertices, 1 do
        x = x + self.vertices[i].x
        y = y + self.vertices[i].y
    end
    x = x / #self.vertices
    y = y / #self.vertices
    return vertex:new(x, y)
end

function polygon:get_border()
    local mm = self:get_max_min()
    return polygon:new({
        vertex:new(mm.min.x, mm.min.y),
        vertex:new(mm.max.x, mm.min.y),
        vertex:new(mm.max.x, mm.max.y),
        vertex:new(mm.min.x, mm.max.y)
    })
end

function onSameSide(a,b, c,d)
    local px, py = d.x-c.x, d.y-c.y
    local l = vector:new(vertex:new(px, py), vertex:new(a.x-c.x, a.y-c.y)):det()
    local m = vector:new(vertex:new(px, py), vertex:new(b.x-c.x, b.y-c.y)):det()
    return l*m >= 0
end

function pointInTriangle(p, a,b,c)
    return onSameSide(p,a, b,c) and onSameSide(p,b, a,c) and onSameSide(p,c, a,b)
end

function areCollinear(p, q, r, eps)
    return math.abs(vector:new(vertex:new(q.x-p.x, q.y-p.y), vertex:new(r.x-p.x,r.y-p.y)):det()) <= (eps or 1e-32)
end

return polygon

local vertex = require('.vertex');
local vector = require('.vector');
local polygon = require('.polygon');
local map = require('.map');
local util = require('.utils')
local util = require('.skill')
local util = require('.skill_axe')


function print_r (t, indent, done)
    done = done or {}
    indent = indent or ''
    local nextIndent -- Storage for next indentation value
    for key, value in pairs (t) do
        if type (value) == "table" and not done [value] then
            nextIndent = nextIndent or
                    (indent .. string.rep(' ',string.len(tostring (key))+2))
            -- Shortcut conditional allocation
            done [value] = true
            print (indent .. "[" .. tostring (key) .. "] => Table {");
            print  (nextIndent .. "{");
            print_r (value, nextIndent .. string.rep(' ',2), done)
            print  (nextIndent .. "}");
        else
            print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
        end
    end
end

gameMap = map:new({
    vertex:new(0,0),
    vertex:new(50, 0),
    vertex:new(75,75),
    vertex:new(100,0),
    vertex:new(100,100),
    vertex:new(0,100)
});

test_poly = polygon:new({
 vertex:new(0,0),
 vertex:new(50,50),
 vertex:new(100,0),
 vertex:new(300,300),
 vertex:new(400,0),
 vertex:new(500, 10),
 vertex:new(600, 600)
})


test_vertex = {
    vertex:new(50, 50),
    vertex:new(100,100),
    vertex:new(50,21),
    vertex:new(32, 50),
    vertex:new(600, 500),
    vertex:new(90,10),
    vertex:new(55,1)
}

--print_r(gameMap:get_out_of_map_ranges());

vector1 = vector:new(vertex:new(548, 503), vertex:new(381, 133));
vector2 = vector:new(vertex:new(700, 500), vertex:new(10, 500));

--print('is r:', vector2:contains(vertex:new(720, 500)));

--print_r(vector1:crossing(vector2));

--print_r(vertex:new(100,100):rotate_and_move(30, vertex:new(10, 10), vertex:new(500,500)))

--local centroid = vertex:new(0, 0)
--print(centroid:rotate_and_move(50, vertex:new(0,0), vertex:new(500,500)):xy());

--print(gameMap:verte_orientation():orient2());

--print(gameMap:is_convex());

--print(test_poly:verte_orientation():orient2(), test_poly:is_convex());

--print(vector:new(vertex:new(50.1, 10.76), vertex:new(50.1, 9.96)):len())

--print(vector:new(vertex:new(10, 10), vertex:new(500, 10)):contains(vertex:new(50.1, 10)))

--[[test_scale_poly = polygon:new({
    Vertex(0,0),
    Vertex(50,0),
    Vertex(50,50),
    Vertex(100,0),
    Vertex(100,50),
    Vertex(80,50),
    Vertex(100,100),
    Vertex(0,100)
})

inv = function(v) v:invert_y() end
vtxes = test_scale_poly.vertices

triangles = Triangulate(vtxes);

for i=1,#triangles,1 do
    print('triangle')
    print('1 x,y', triangles[i].v0.x, triangles[i].v0.y)
    print('2 x,y', triangles[i].v1.x, triangles[i].v1.y)
    print('3 x,y', triangles[i].v2.x, triangles[i].v2.y)
    print('------------')
end ]]--

--[[poly = polygon:new({
    vertex:new(0,0),
    vertex:new(50,0),
    vertex:new(50,50),
    vertex:new(100,50),
    vertex:new(100,0),
    vertex:new(150, 0),
    vertex:new(150, 150),
    vertex:new(0, 150),
})

print_r(poly:triangulate());]]--
p = {
    vertex:new(161.93555486443, 141.7676202432),
    vertex:new(367.6603931668, 424.92356827443),
    vertex:new( 84.504445135567,  630.6484065768),
    vertex:new(-121.2203931668, 347.49245854557)
}

print(polygon:new(p):pnpoly(vertex:new(87, 328)));


vec1 = vector:new(vertex:new(100,100), vertex:new(7,159))
vec2 = vector:new(vertex:new(10,500), vertex:new(10,10))


print(vec1:contains(vertex:new(10,157.0967742)));







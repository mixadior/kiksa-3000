print('DEEP COPY TEST')

t = require('.bootstrap')

polygon = t.polygon:new({
    t.vertex:new(0,0),
    t.vertex:new(100,0),
    t.vertex:new(100,100),
    t.vertex:new(0,100)
})

polygon2 = deepcopy(polygon)

polygon2:map_to_vertex(
    function (v)
        v.y = v.y + 1
    end
    );

print('P2y:'..polygon2.vertices[4].y)
print('P1y:'..polygon.vertices[4].y);

status = 'failed'

if ((polygon2.vertices[4].y - polygon.vertices[4].y) == 1) then
    status = 'passed'
end

print('DEEP COPY TEST ['..status..']')






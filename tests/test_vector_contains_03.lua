--[[ This test case describes problem when incorrect rounding of k,b coefs of vector line causes error in calculation of intersection point]]--
print('Vector contains')

t = require('.bootstrap')

vt3 = t.vector:new(vertex:new(848.75, 609.95), vertex:new(555, 615))

r = (vector:new(vertex:new(1010,610), vertex:new(10,610)):crossing(vt3))

if (r and r.x > 0) then
    print('Vector contains test: [OK]')
else
    print('Vector contains test: [Fail]')
end
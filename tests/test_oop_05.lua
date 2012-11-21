t = require('.bootstrap')

o1 = {}

function o1:new()
    local o = {}
    o.o1= 'zika'
    setmetatable(o, self);
    self.__index = self
    return o;
end

function o1:test1()
    print (self.o1)
end

o2 = {}
setmetatable(o2, o1)

function o2:new()
    local o = getmetatable(self):new();
    o.bc = deepcopy(o)
    o.o2 = 'zika2'
    o.o1 = 123;
    setmetatable(o, self)
    self.__index = self
    return o
end

function o2:test1()

    print (self.o2)
end

function o2:update()
    self.o2 = 4
end

o3 = {}
setmetatable(o3, o2)

function o3:new()
    local o = o2:new()
    o.o3 = 'zika3'
    setmetatable(o, self)
    self.__index = self
    return o
end

function o3:test1()
    print(self.o1)
end




o = o3:new();
ox = o3:new();

o:update();

o:test1()
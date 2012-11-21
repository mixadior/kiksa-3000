sfx = {}

function sfx:init()
    local o = {}
    o.firstblood = love.audio.newSource("resources/sounds/ut/firstblood.wav", "static")
    o.doublekill = love.audio.newSource("resources/sounds/ut/doublekill.wav", "static")
    o.monsterkill= love.audio.newSource("resources/sounds/ut/monsterkill.wav", "static")
    o.holyshit = love.audio.newSource("resources/sounds/ut/holyshit.wav", "static")
    o.headshot = love.audio.newSource("resources/sounds/ut/headshot.wav", "static")
    o.sfx_enabled = true
    setmetatable(o, self)
    self.__index = self

    return o
end

function sfx:play(sound)
    if (not self.sfx_enabled) then return false end
    love.audio.stop()
    love.audio.play(self[sound])
end

function sfx:toggle()
    self.sfx_enabled = not self.sfx_enabled
end

return sfx;

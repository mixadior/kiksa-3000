fonter = {}

setmetatable(fonter, structure_base)

function fonter:new()
    local o = getmetatable(self):new();
    setmetatable(o, self);
    o.fonts = {
        aliases = {
            frr = 'Furore.otf',
            hs = 'homespun/homespun.ttf',
            just = 'just_square_cyr_reg.otf',
            bic = 'Bicubik.OTF'
        }
    }
    self.__index = self;
    return o
end

function fonter:get(font, size)
    local font = self.fonts.aliases[font] or font
    local font_key = font..size
    if (self.fonts[font_key]) then
        return self.fonts[font_key]
    else
        local font = love.graphics.newFont('resources/fonts/'..font, size)
        self.fonts[font_key] = font
        return font;
    end
end

function fonter:set(font, size)
    local f = self:get(font, size)
    love.graphics.setFont(f);
end

return fonter


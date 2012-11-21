osd = {}

function osd:init(...)

    local o = {}
    o.q = {

    }
    o.box_color = ...
    if (not o.box_color) then
        o.box_color = {255,255,0, 100}
    end
    o.state = 'free'
    setmetatable(o, self)
    self.__index = self;
    return o;
end

function osd:add(t)
    table.insert(self.q, t);
    self.state = 'wait'
end

function osd:close()
    if (self.state == 'wait') then
        local m = self:get()
        if (m.close) then
            m:close(self)
        end
        table.remove(self.q , 1)
        self.state = 'free'
    end
end

function osd:close_all()
    for i = 1, #self.q, 1 do
        local m = self.q[1]
        if (m.close) then
            m:close(self)
        end
        table.remove(self.q, 1)
    end
    self.state = 'free'
end

function osd:get()
    if (self.q and #self.q > 0) then
        return self.q[1]
    end
    return false;
end

function osd:update(dt)
    --self.timer.expire = self.timer.expire + dt
    local m = self:get()
    if (m and m.update) then
        m:update(dt, self)
    end
end

function osd:draw()
    local m = self:get()
    if (m) then
        if (m.before) then
            m:before(self)
        end

        local w = 500
        local header, text = m.header, m.text
        local _, l = hs:getWrap(text, w)
        local header_h, text_h = hs_big:getHeight(), l * hs:getHeight()
        local total_h = header_h + 10 + text_h
        local map_c = hrumalka.go.caches.game_area[5]:centroid()
        local osd_x, osd_y = (map_c.x - w / 2), (map_c.y - total_h / 2)
        love.graphics.setColor( self.box_color[1], self.box_color[2], self.box_color[3], self.box_color[4] )
        love.graphics.rectangle("fill", osd_x - 10 , osd_y - 10, w + 10, total_h + 30)

        love.graphics.setColor( 0,0,0 )

        love.graphics.setFont(hs_big)
        love.graphics.printf( header, osd_x, osd_y, w, "center")

        love.graphics.setFont(hs)
        love.graphics.printf( text, osd_x, osd_y + 10 + header_h, w, "left")



        if (m.after) then
            m:after(self)
        end

        self.state = 'wait'
    end
end

return osd;

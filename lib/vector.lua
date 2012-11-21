vector = {}

function vector:new(p1, p2)
    local vec = {p1, p2}
    setmetatable(vec, self);
    self.__index = self;
    return vec
end

function vector:crossing(vector)
    local crossingX, crossingY,k1,k2,b1,b2, crossing;
    local vector1, vector2 = self, vector;
    if (utils.eq(vector1[1].x, vector1[2].x) and utils.eq(vector2[1].x, vector2[2].x) or utils.eq(vector1[1].y, vector1[2].y) and utils.eq(vector2[1].y, vector2[2].y)) then
        return false;
    elseif (utils.eq(vector1[1].x, vector1[2].x) or utils.eq(vector2[1].x, vector2[2].x)) then
        local vector;
        if (utils.eq(vector1[1].x , vector1[2].x)) then
            crossingX = vector1[1].x
            vector = vector2
        else
            crossingX = vector2[1].x
            vector = vector1
        end
        crossingY = ( vector[2].x*vector[1].y - vector[1].x*vector[2].y + (vector[2].y - vector[1].y) * crossingX ) / (vector[2].x - vector[1].x)
    else
        k1,b1 = vector1:coef();
        k2,b2 = vector2:coef();
        crossingX = (b2 - b1) / (k1 - k2)
        crossingY = k1*(b2-b1)/(k1-k2)+b1
    end
    crossingX = utils.rounder(crossingX)
    crossingY = utils.rounder(crossingY)
    crossing = vertex:new(crossingX, crossingY)
    if (vector1:contains_90(crossing) and vector2:contains_90(crossing)) then

        return crossing
    else

        return false;
    end
end

function vector:coef()
    local vector1 = self
    local k1 = (vector1[2].y - vector1[1].y) / (vector1[2].x - vector1[1].x)
    local b1 = (vector1[2].x*vector1[1].y - vector1[1].x*vector1[2].y) / (vector1[2].x - vector1[1].x)
    return k1, b1
end

function vector:det()

    return self[1].x * self[2].y - self[1].y * self[2].x
end

function vector:contains_90(vertex)
    local mnx, mxx = math.min(self[1].x, self[2].x), math.max(self[1].x, self[2].x)
    local mny, mxy = math.min(self[1].y, self[2].y), math.max(self[1].y, self[2].y)
    return (((vertex.x > mnx or utils.eq(vertex.x, mnx))
            and (vertex.x < mxx or utils.eq(vertex.x, mxx))
            and ((vertex.y > mny or utils.eq(vertex.y, mny)))
            and (vertex.y < mxy or utils.eq(vertex.y, mxy))))
end

function vector:contains(vertex)
    if (utils.eq(self[1].x, self[2].x) or utils.eq(self[1].y, self[2].y)) then
        return self:contains_90(vertex)
    else
        local k,b = self:coef()
        local x,y = vertex:xy();

        if (utils.eq(math.abs(y - (k*x + b)), 0)) then
            return self:contains_90(vertex);
        end
    end
    return false;
end

function vector:next_point(x_step, ...)
    local direction, x, y, coef;
    local check_range = ...
    if (self[1].x > self[2].x) then
        direction = -1
    else
        direction = 1
    end
    x = self[1].x + x_step * direction
    if (math.abs(self[1].y - self[2].y) <= utils.eps) then
        y = self[1].y
    elseif (math.abs(self[1].x - self[2].x) <= utils.eps) then
        if (self[1].y > self[2].y) then
            direction = -1
        else
            direction = 1
        end
        y = self[1].y + x_step * direction
        x = self[1].x
    else
        local k,b = self:coef()
        y = k * x + b
    end
    local next_step_vertex = vertex:new(utils.rounder(x),utils.rounder(y))
    if (check_range) then
        if (self:contains(next_step_vertex)) then
            return next_step_vertex
        else

            return false
        end
    else
        return next_step_vertex
    end
end

function vector:xy()
    return self[1].x, self[1].y, self[2].x, self[2].y
end

function vector:len()
    return math.pow((self[1].x-self[2].x), 2) + math.pow((self[1].y - self[2].y), 2);
end

return vector;







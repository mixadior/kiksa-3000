utils = {

}

function utils.rounder(v, signs_after_dot)
    local p = 8
    if (signs_after_dot and signs_after_dot > 0) then p = signs_after_dot end
    local v,c = math.modf(v);
    local ax = math.pow(10, p)
    local cax = math.floor(c * ax);
    local ccax = cax % 10
    if (ccax > 5) then cax = cax + 10 - ccax end;
    return v + cax / ax;
end

function utils.zerozify(num, zeros)
    local z = zeros or 5
    local len = string.len(num)
    local zeros_app = z - len
    if (zeros_app > 0) then
        return string.rep('0', zeros_app)..num
    end
    return num
end

function utils.eq(n1,n2)
    return math.abs(n2-n1) <= utils.eps
end

utils.eps = 1e-5

return utils;


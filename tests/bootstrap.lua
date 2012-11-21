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

function deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end


package.path = package.path..';../?.lua'

testable = {
    structure_base = require('bot2oop/structure_base'),
    vertex = require('bot2oop/vertex'),
    vector = require('bot2oop/vector'),
    polygon = require('bot2oop/polygon'),
    map = require('bot2oop/map'),
    util = require('bot2oop/utils'),
    bot = require('bot2oop/bot'),
    hero = require('.hero'),
    botsgod = require('bot2oop/botsgod'),
    pregnant_bot = require('bot2oop/pregnant_bot'),
    replicator_bot = require('bot2oop/replicator_bot'),
    skill = require('bot2oop/skill'),
    skill_turbo = require('bot2oop/skill_turbo'),
    --local bot2 = require('../bot2oop/bot2')
    bullets = require('bot2oop/bullets'),
    bullet = require('bot2oop/bullet'),
    bullet_cold = require('bot2oop/bullet_cold')
}

return testable




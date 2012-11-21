local vertex = require('.vertex');
local vector = require('.vector');
local polygon = require('.polygon');
local map = require('.map');
local util = require('.utils')
local bot = require('.bot')
local bot2 = require('.bot2')

require('.dumper');

function dd(v)
    print(DataDumper(v));
end

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


function love.load()
    gameMap = map:new({
        vertex:new(10,10),
        vertex:new(700, 10),
        vertex:new(700, 500),
        vertex:new(10, 500)
    })
    gameBot1 = bot:new(vertex:new(11,11), 200, 200, 20)
    gameBot2 = bot:new(vertex:new(100,100), 50, 50, 10)
    gameBot3 = bot:new(vertex:new(200,200), 20, 20, 10)
    gameBot4 = bot:new(vertex:new(150,150), 10, 10, 10)
    gameBot5 = bot:new(vertex:new(400,400), 80, 30, 5)

    gameBot6 = bot2:new(vertex:new(200,200), 300, 250, 5)
end

function love.update(dt)
    gameBot1:update(dt, gameMap)
    gameBot2:update(dt, gameMap)
    gameBot3:update(dt, gameMap)
    gameBot4:update(dt, gameMap)
    gameBot5:update(dt, gameMap)

    gameBot6:update(dt, gameMap)
end

function love.draw()
    gameBot1:draw();
    gameBot2:draw();
    gameBot3:draw();
    gameBot4:draw();
    gameBot5:draw();
    gameBot6:draw()
end



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

function debug_write(data)
    love.filesystem.write('crash_report_'..crash, data, string.len(data))
end

debugLog = '';

function debug_log(data)
    debugLog = debugLog..'\n'..data;
end

function debug_flush()
    debug_write(debugLog)
end

local structure_base = require('lib/structure_base')
local vertex = require('lib/vertex');
local vector = require('lib/vector');
local polygon = require('lib/polygon');
local map = require('lib/map');
local util = require('lib/utils')
local bot = require('lib/bot')
local hero = require('lib/hero')
local botsgod = require('lib/botsgod')
local pregnant_bot = require('lib/pregnant_bot')
local replicator_bot = require('lib/replicator_bot')
local skill = require('lib/skill')
local skill_turbo = require('lib/skill_turbo')
--local bot2 = require('lib/bot2')
local sfx = require('lib/sfx')
local bullets = require('lib/bullets')
local bullet = require('lib/bullet')
local bullet_cold = require('lib/bullet_cold')
local game = require('lib/game')
local level = require('lib/level')
local level1 = require('lib/level1')
local level2 = require('lib/level2')
local osd = require('lib/osd')
local fonter = require('lib/fonter')


function love.load()
  ssfx = sfx:init()
  osdd = osd:init({255,255,0,150})
  font_master = fonter:new()
  osd_settings = osd:init({0,255,0,100})

  crash = love.timer.getTime()
  love.filesystem.setIdentity("vertex3000")
  hrumalka = game:new()
  hrumalka:init()
  hrumalka:start_level(1)

  once = true
  axe = true;
  debugger = false;

  --hs = love.graphics.newFont('resources/fonts/homespun/homespun.ttf', 20)
  hs = font_master:get('just', 18) --love.graphics.newFont('resources/fonts/Furore.otf', 14)
  love.graphics.setFont(hs)
  --hs_big = love.graphics.newFont('resources/fonts/homespun/homespun.ttf', 50)
  hs_big = font_master:get('frr', 40)

  text_styles = {
    normal = love.graphics.newFont('resources/fonts/homespun/homespun.ttf', 20),
    big50 = love.graphics.newFont('resources/fonts/homespun/homespun.ttf', 50),
    red = {255,0,0},
    magenta = {128,64,255},
    white = {255,255,255}
  }


end

function love.keypressed(key)

    if (hrumalka.status == 'level_screen') then
        hrumalka.status = 'gaming'
        love.graphics.setFont(hs)
    end
    -- HERE STARTS GAMING KEYS PART
    if (hrumalka.status ~= 'gaming') then
        return false
    end

    if (key == 'f') then
        hrumalka.go.bots:produce_child(1)
    end

    if (key == 'd') then
        debugger = not debugger
    end
    if (key == 'x') then
        hrumalka.go.youare:fire()
    end
    if (key == 'r') then
        hrumalka:start_level(1)
    end
    if (key == 'o') then
        ssfx:toggle()
        local status = 'Off'
        if (ssfx.sfx_enabled) then
            status = 'On'
        end
        osd_settings:add({text = '', header = 'Sound: '..status, update = function(self, dt, osd)  self.timer = (self.timer or 0) + dt * 10 if(self.timer > 5) then osd:close() end  end})
    end
    if (key == 'escape') then
        osdd:close()
    end
end
 
function love.update(dt)

 -- HERE STARTS GAMING UPDATE PART
 if (hrumalka.status ~= 'gaming') then
     return false
 end

 local direction = false
 local steps = 0


 local fragsBefore = hrumalka.go.gamestats.frags

 hrumalka:update(dt)
 --print(#hrumalka.go.bots.bots)
 hrumalka.go.bots:call_for_all(function (i,b)
    if (not b.dead and not b.affectedBy) then
        for i=1, #hrumalka.go.gameBullets.bullets, 1 do
            local bullet = hrumalka.go.gameBullets.bullets[i]
            if (bullet.state == 'active') then
                if (b:is_catched_bullet(bullet)) then
                    ssfx:play('headshot')
                    bullet:on_bot_collision(b)
                end
            end
        end
    end
 end)

 if (hrumalka.go.youare.state == "save") then


     local mergeMap = hrumalka.go.gameMap:merge_with_line(hrumalka.go.youare.expansion)
     hrumalka.go.gameMap = map:new(mergeMap.left.vertices)

     table.insert(hrumalka.go.caches.capturings, mergeMap.captured:xy())
     --print_r(mergeMap.left:xy())

     hrumalka.go.youare.expansion = {}
     hrumalka.go.youare.state = "start"
     local inside = hrumalka.go.bots:inside(mergeMap.captured)
     if (#inside.bots) then
          inside:call_for_all('kill');
     end
     hrumalka.go.gamestats.capturings =  hrumalka.go.gamestats.capturings + 1
     if (hrumalka.go.gamestats.capturings%3 == 0) then
         for i=1,5,1 do
             hrumalka.go.bots:produce_child(1)
         end
     end
     hrumalka.go.caches.mapxy = nil
     hrumalka.go.caches.stcl = false
 end

 if love.keyboard.isDown(" ")  then
     hrumalka.go.youare:turn_mode('walk')
 else
     hrumalka.go.youare:turn_mode('draw')
 end

 if (hrumalka.go.youare.skills.turbo ~= nil) then
     if love.keyboard.isDown("s")  then
         hrumalka.go.youare.skills.turbo:on()
     else
         hrumalka.go.youare.skills.turbo:off()
     end

 end


 if love.keyboard.isDown("left")  then
   direction = "left"
 elseif love.keyboard.isDown("right") then
   direction = "right"
 elseif love.keyboard.isDown("up") then      
   direction = "up"
 elseif love.keyboard.isDown("down") then
   direction = "down"
 end 
 if (direction) then
     local speed_up = 1
     if (hrumalka.go.youare.skills.turbo) then
        speed_up = hrumalka.go.youare.skills.turbo:get_speed_up();
     end
     steps = utils.rounder(hrumalka.go.youare.speed*dt*speed_up)
 end
 if (steps > 0) then
     hrumalka.go.youare:move(direction, steps, hrumalka.go.gameMap)
 end

 hrumalka.go.bots:update(dt, hrumalka.go.gameMap)

 --hrumalka.go.bots:call_for_all(function(i,b) b.color = b.default_color end)

 local collided = hrumalka.go.bots:collided(hrumalka.go.youare)

 if (#collided.bots > 0) then
     local die = false
     collided:call_for_all(function(i, b) if (b.type == "replicator") then b:replicate(hrumalka.go.youare, hrumalka.go.bots)  else die = true end end);
     if (die) then
         hrumalka.go.youare:to_safe_place()
         hrumalka.go.youare.state = 'dead'
         hrumalka.go.youare.lifes = hrumalka.go.youare.lifes - 1
     end
 end

 hrumalka.go.gameBullets:call_for_all(function(b) b:update(dt, hrumalka.go.gameMap) end);

 if (fragsBefore == 0 and hrumalka.go.gamestats.frags > 0) then
     ssfx:play('firstblood')
 elseif (fragsBefore > 0) then
     local fgDiff = (hrumalka.go.gamestats.frags - fragsBefore)
     if (fgDiff == 2) then
        ssfx:play('doublekill')
     elseif (fgDiff > 2) then
        ssfx:play('monsterkill')
     end

 end
 osd_settings:update(dt)
end
 
function love.draw()

  if (hrumalka.status == 'level_screen') then
      love.graphics.setFont(hs_big)
      love.graphics.setColor(255,255,255)
      love.graphics.rectangle("line", hrumalka.go.caches.game_area[1], hrumalka.go.caches.game_area[2], hrumalka.go.caches.game_area[3], hrumalka.go.caches.game_area[4])
      love.graphics.printf('Уровень '..hrumalka.level.name, hrumalka.go.caches.game_area[3] / 2 - 125, hrumalka.go.caches.game_area[4] / 2 - 50, 250, "center");
      love.graphics.setFont(hs)
      love.graphics.printf(hrumalka.level.full_name, hrumalka.go.caches.game_area[3] / 2 - 125, hrumalka.go.caches.game_area[4] / 2, 250, "center");
  end
    -- HERE STARTS GAMING GRAPICS PART
 if (hrumalka.status ~= 'gaming') then
    return false
 end
 --love.graphics.setColor(255, 255, 255, 90)
 --love.graphics.rectangle("line", hrumalka.go.caches.game_area[1], hrumalka.go.caches.game_area[2], hrumalka.go.caches.game_area[3], hrumalka.go.caches.game_area[4]);

 love.graphics.setScissor(hrumalka.go.caches.game_area[1], hrumalka.go.caches.game_area[2], hrumalka.go.caches.game_area[3], hrumalka.go.caches.game_area[4])

 love.graphics.setLineWidth(2);

 love.graphics.setColor(189,193,191,64)
 for i=1, #hrumalka.go.caches.capturings, 1 do
     love.graphics.polygon("line", hrumalka.go.caches.capturings[i])
 end

 love.graphics.setColor(255, 255, 0)

 if (hrumalka.go.caches.mapxy == nil) then
    hrumalka.go.caches.mapxy = hrumalka.go.gameMap:xy()
    hrumalka.go.caches.map_triangulated = hrumalka.go.gameMap:triangulate()
 end

 if (not hrumalka.go.caches.stcl) then
     local map_stencil_func = function()
        for i=1,#hrumalka.go.caches.map_triangulated,1 do
            local xy = hrumalka.go.caches.map_triangulated[i]:xy()
            love.graphics.triangle("fill", xy[1], xy[2], xy[3], xy[4], xy[5], xy[6]);
        end
     end
     hrumalka.go.caches.stcl = love.graphics.newStencil(map_stencil_func)
 end

 love.graphics.polygon("line", hrumalka.go.caches.mapxy);
 local stcl = hrumalka.go.caches.stcl

 love.graphics.setStencil(stcl)

     hrumalka.go.bots:call_for_all(function (i,b)
         if (not b.dead) then
             b:draw();
         end
     end)

 love.graphics.setStencil()


 love.graphics.setInvertedStencil(stcl)

     hrumalka.go.bots:call_for_all(function (i,b)
         if (b.dead) then
             b:draw();
         end
     end)

 love.graphics.setStencil()

 love.graphics.setPointSize(6);
 love.graphics.setColor(255, 0, 0)
 love.graphics.point(hrumalka.go.youare.position:xy());

 hrumalka.go.gameBullets:call_for_all(function(b) b:draw() end);

 if (hrumalka.go.youare.weapon_basis) then

     local basis = hrumalka.go.youare.weapon_basis
     local x1,y1 = hrumalka.go.youare.position:xy();

     local x2,y2 = hrumalka.go.youare.weapon_basis[1]:clone():map(function(s)
        s[basis[2]] = s[basis[2]] + basis[3] * 5;
     end):xy();
     love.graphics.line(x1,y1, x2,y2);
 end

 if (hrumalka.go.youare.state == "capture") then
     for i = 1, #hrumalka.go.youare.expansion, 1 do
         local next_p
         local next_i = next(hrumalka.go.youare.expansion, i)
         if (not next_i) then
             next_p = hrumalka.go.youare.position
         else
            next_p = hrumalka.go.youare.expansion[next_i]
         end
         love.graphics.line(hrumalka.go.youare.expansion[i].x, hrumalka.go.youare.expansion[i].y, next_p.x, next_p.y)
     end
 end

 love.graphics.setScissor()

 local info_y = hrumalka.go.caches.game_area[2] + hrumalka.go.caches.game_area[4]

 love.graphics.setColor(255,0,0);
 love.graphics.print(utils.zerozify(hrumalka.go.youare.lifes, 3)..' UP`s ', 10,  info_y)


 love.graphics.setColor(128,64,255);
 love.graphics.print(utils.zerozify(hrumalka.go.gamestats.frags, 2)..' Captured', 100, info_y)
 --love.graphics.print(utils.zerozify(hrumalka.go.gamestats.alive, 2)..' ', 190, info_y)

 love.graphics.setColor(255,255,255, 100);
 local fps = love.timer.getFPS();
 love.graphics.print('FPS:'..fps, 400, info_y)

 love.graphics.setColor(255,255,255);

 if (hrumalka.go.youare.skills.weapon and hrumalka.go.youare.skills.freezer) then
     love.graphics.print('[x] Freezer [Unlim]: 5s', 625, info_y + 20)
 end

 if (hrumalka.go.youare.skills.turbo) then
     if (hrumalka.go.youare.skills.turbo:get_speed_up() > 1) then
        love.graphics.print('[s] Turbo ['..utils.zerozify(hrumalka.go.youare.skills.turbo:get_amount(), 5)..']: '..hrumalka.go.youare.skills.turbo:get_speed_up()..'x', 625, info_y)
     else
        love.graphics.print('[s] Turbo ['..utils.zerozify(hrumalka.go.youare.skills.turbo:get_amount(), 5)..']: Off', 625, info_y)
     end
 end

 love.graphics.setColor(0,0,255);
 love.graphics.print('mode: '..hrumalka.go.youare.mode..' [space]', 835, info_y)
 osdd:draw()
 osd_settings:draw()
end

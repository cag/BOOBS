--[[

Copyright (c) 2010 Alan Lu

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.

--]]

-- this is just a simple testbed for boobs functionality

local boobs = require "boobs"

-- framethrottled variation
function love.run()
	if love.load then love.load(arg) end
	
	local throttle = 1/60
	local dt = throttle
	
	-- Main loop time.
	while true do
		if love.timer then
			love.timer.step()
			dt = dt + love.timer.getDelta()
		end
		
		while dt > 0 do
			love.update(throttle)
			dt = dt - throttle
		end
		
		if love.graphics then
			love.graphics.clear()
			if love.draw then love.draw() end
		end
		-- Process events. Fuck this shit I'm not touching this with a ten foot pole
		if love.event then
			for e,a,b,c in love.event.poll() do
				if e == "q" then
					if love.audio then
						love.audio.stop()
					end
					return
				end
				love.handlers[e](a,b,c)
			end
		end
		if love.timer then love.timer.sleep(1) end
		if love.graphics then love.graphics.present() end
	end
end

function love.load()
	print "disabling key repeat"
	love.keyboard.setKeyRepeat(0, 0)
	
	mv1 = boobs.movelist:new("fighter")
	mv1:register_sequence("d rd r p", function(pdx) print("player " .. tostring(pdx) .. " throws a fireball") end)
	mv1:register_sequence("d rd r d rd r p", function(pdx) print("player " .. tostring(pdx) .. " throws a super fireball") end)
	mv1:register_sequence("d ld l k", function(pdx) print("player " .. tostring(pdx) .. " whirlwind kicks") end)
	
	player1 = boobs.player:new()
	player1:bind_dir{ type = "axes", joy = 0, pair = 0 }
	player1:bind_input("p", { type = "button", joy = 0, button = 0 })
	player1:bind_input("k", { type = "button", joy = 0, button = 1 })
	player1:set_movelist(mv1)
end

function love.update(dt)
	player1:update()
end

function love.draw()
end

function love.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
end

function love.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
end

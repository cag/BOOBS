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
local Q = require "queues"

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
	print "setting write folder to `impulse'"
	love.filesystem.setIdentity("impulse")
	
	print "disabling key repeat"
	love.keyboard.setKeyRepeat(0, 0)
	
	print "initializing B��BS with two players"
	boobs.init(2)
end

function love.update(dt)
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

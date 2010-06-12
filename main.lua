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

function love.load()
	print "disabling key repeat"
	love.keyboard.setKeyRepeat(0, 0)
	
	mv1 = boobs.movelist:new("fighter")
	mv1:register_sequence("d rd r p", function(pdx) print("player " .. tostring(pdx) .. " throws a fireball") end)
	mv1:register_sequence("l ld d rd r p", function(pdx) print("player " .. tostring(pdx) .. " throws a fiery fireball") end)
	mv1:register_sequence("r d rd p", function(pdx) print("player " .. tostring(pdx) .. " dragon punches") end)
	mv1:register_sequence("d ld l k", function(pdx) print("player " .. tostring(pdx) .. " hurricane-kicks") end)
	mv1:register_sequence("d rd r d rd r p", function(pdx) print("player " .. tostring(pdx) .. " throws a super fireball") end)
	mv1:register_sequence("d ld l d ld l k", function(pdx) print("player " .. tostring(pdx) .. " hurricane-kicks really fucking hard") end)
	mv1:register_sequence("p p r k p", function(pdx) print("player " .. tostring(pdx) .. " RAEPS LAWL") end)
	
	player1 = boobs.player:new()
	player1:bind_dir{ type = "axes", joy = 0, pair = 0 }
	--player1:bind_dir{ type = "hat", joy = 0, hat = 0 }
	player1:bind_input("p", { type = "button", joy = 0, button = 0 })
	player1:bind_input("k", { type = "button", joy = 0, button = 1 })
	player1:set_movelist(mv1)
	
	player2 = boobs.player:new()
	player2:bind_dir{ type = "keys", l = "left", r = "right", u = "up", d = "down" }
	player2:bind_input("p", { type = "key", key = "z" })
	player2:bind_input("k", { type = "key", key = "x" })
	player2:set_movelist(mv1)
	
	player2.hflip = true
end

function love.update(dt)
	boobs.update()
end
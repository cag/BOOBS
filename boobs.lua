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

local J = love.joystick
local Q = require "queues"
local T = love.timer
local print = print
local tostring = tostring

-- B÷÷BS
-- this is a module for some juicy input mangling on top of L÷VE
-- specifically, it is useful for processing timed priority queue sequences in input
-- good for fighting games and beat-em ups and similar stuff
-- it is also designed to handle lube ;)
-- being framethrottled = easier time implementing network support

module "boobs"

-- the input update count, don't try to mess with it
local uc = 0
-- time delta
local td = 0

-- for those of you willing to dig and tune...
-- here are some internal parameters for the initialization of this module

-- reserved strings for stuff: . / ; u lu l dl d rd r ru c
-- updates per second
local s = 30
-- deadzone for joystick input
local deadzone = .1 -- 10%
-- threshold for directional symbol registration
local dsthreshold = .5 -- 50%
-- input life length (in updates)
local life_length = 2 * s -- conversion factor
-- default input linkage time
local default_il = .1 * s

---------------------------------------
-- directional string maekers given yus

local function c2s(xc, yc)
	if xc < -dsthreshold then
		if yc < -dsthreshold then return "lu" end
		if yc > dsthreshold then return "ld" end
		return "l"
	elseif xc > dsthreshold then
		if yc < -dsthreshold then return "ru" end
		if yc > dsthreshold then return "rd" end
		return "r"
	end
	if yc < -dsthreshold then return "u" end
	if yc > dsthreshold then return "d" end
	return "c"
end

-- first up, the rather straightforward axes!
function axesmaek(joy, pair)
	-- joy in set {0,...,numjoys-1}
	-- pair in set {1,...}
	local a = { J.getAxes(joy) }
	local xc = a[pair * 2 - 1]
	local yc = a[pair * 2]
	return c2s(xc, yc)
end

-- then we have the infamous hat
local hatmaek = J.getHat

-- lol bawlz
local function ballmaek(joy, ball)
	return c2s(J.getBall(joy, ball))
end

---------------------------------------
-- utility functions


---------------------------------------
-- vars
local input_wtfbbqs = {} -- wtfbbqs queueueueueues!
local hov = false -- horizontal orientation value

local maps = {
	-- direction -> symbol map
	ds = {};
	-- button -> symbol map
	bs = {};
	-- key -> direction map
	kd = {};
	-- joy -> button map
	jb = {};
	-- key -> button map
	kb = {};
}

-- delicious handlers

-- for pressing
local phandlers = {
	kds = function(k)
		local d = maps.kd[k]
		if d then
			local s = maps.ds[d]
			if hov then
				if s == "l" then s = "r"
				elseif s == "r" then s = "l"
				end
			end
			if s then Q.enq(input_wtfbbqs, {s, T.getTime()}) end
		end
	end,
	
	kbs = function(k)
		local k = maps.kb[k]
		if b then
			local s = maps.bs[b]
			if s then Q.enq(input_wtfbbqs, {s, T.getTime()}) end
		end
	end,
	
	jds = function(joystick, j)
		
	end,
	
	jbs = function(joystick, j)
		
	end
}

-- and releasing


-------------------------------------------------------------------------------
-- the actual part you use to do stuff

-- init(players)
-- initializes the input system given # of players
function init(players)
	-- love auto-opens our hardware! :)
	-- setup input queues for players
	for i = 1, players do
		input_wtfbbqs[i] = Q.new()
	end
end

-------------------------------------------------------------------------------
-- some helpful stuff
-- before we get ahead of ourselves:


-------------------------------------------------------------------------------

-- update(dt)
-- updates boobs' internal state to reflect input stuff
-- and resolves pattern-matched callbacks
function update(dt)
	-- I AM A CODE MONKEY
	
end

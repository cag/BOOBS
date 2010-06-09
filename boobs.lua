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
local K = love.keyboard
local T = love.timer
local print = print
local tostring = tostring

-- BÖÖBS
-- this is a module for some juicy input mangling on top of LÖVE
-- specifically, it is useful for processing timed priority queue sequences in input
-- good for fighting games and beat-em ups and similar stuff

module "boobs"

-------------------------------------------------------------------------------
-- module parameters (feel free to tune)

-- where the joystick decides to register a direction
local dir_reg_threshold = .5

-------------------------------------------------------------------------------
-- utility functions for making directional strings

function axes2string(joy, axespair, hflip)
	local x = J.getAxis(joy, axespair * 2)
	local y = J.getAxis(joy, axespair * 2 + 1)
	local drt = dir_reg_threshold
	
	local l, r
	
	if hflip then
		l = x > drt
		r = x < -drt
	else
		l = x < -drt
		r = x > drt
	end
	
	if l then
		if y < -drt then return "lu"
		elseif y > drt then return "ld"
		end
		return "l"
	elseif r then
		if y < -drt then return "ru"
		elseif y > drt then return "rd"
		end
		return "r"
	end
	
	if y < -drt then return "u"
	elseif y > drt then return "d"
	end
	return "c"
end

function hat2string(joy, hat, hflip)
	local res = J.getHat(joy, hat)
	--EPICSTRINGHAX
	return hflip and res:gsub("([lr])", function(d) return d == "l" and "r" or "l" end) or res
end

function keys2string(left, right, up, down, hflip)
	local u = K.isDown(up)
	local d = K.isDown(down)
	local l, r
	
	if hflip then
		l = K.isDown(right)
		r = K.isDown(left)
	else
		l = K.isDown(left)
		r = K.isDown(right)
	end
	
	if l and not r then
		if u and not d then return "lu"
		elseif d and not u then return "ld"
		end
		return "l"
	elseif r and not l then
		if u and not d then return "ru"
		elseif d and not u then return "rd"
		end
		return "r"
	end
	if u and not d then return "u"
	elseif d and not u then return "d"
	end
	return "c"
end

-------------------------------------------------------------------------------
-- symbol registration


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
local time = love.timer.getTime
local ipairs = ipairs
local pairs = pairs
local print = print
local setmetatable = setmetatable
local tostring = tostring

-- BÖÖBS
-- this is a module for some juicy input mangling on top of LÖVE
-- specifically, it is useful for processing sequences in input
-- good for fighting games and beat-em ups and similar stuff

module "boobs"

-------------------------------------------------------------------------------
-- module parameters (feel free to tune)

-- where the joystick decides to register a direction
local dir_reg_threshold = .5
-- time between inputs for them to link up
local input_link_time = .2

-------------------------------------------------------------------------------
-- utility functions for making directional strings
-- has extra parameter hflip to determine whether x axis should be checked backwards

local function axes2dir(joy, axespair, hflip)
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

local function hat2dir(joy, hat, hflip)
	local res = J.getHat(joy, hat)
	--EPICSTRINGHAX
	return hflip and res:gsub("([lr])", function(d) return d == "l" and "r" or "l" end) or res
end

local function keys2dir(left, right, up, down, hflip)
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
-- input-symbol binding stuff
local players = {}

-- prototype
player = {}

--constructor
function player:new()
	local idx = #players + 1
	local o = {
		index = idx,
		inputmap = {},
		inwasdown = {},
		lastdir = "c",
		hflip = false,
		lpts = time(),
		crawlposet = {},
	}
	
	setmetatable(o, self)
	self.__index = self
	
	players[idx] = o
	return o
end

--methods
function player:bind_dir(a)
	local t = a.type
	if t == "axes" then
		local j = a.joy
		local p = a.pair
		print("BOOBS: player " .. tostring(self.index)
			.. ": binding directions to joystick " .. tostring(j) .. " axes pair " .. tostring(p))
		
		self.dir = function() return axes2dir(j, p, self.hflip) end
	elseif t == "hat" then
		local j = a.joy
		local h = a.hat
		print("BOOBS: player " .. tostring(self.index)
			.. ": binding directions to joystick " .. tostring(j) .. " hat " .. tostring(h))
		
		self.dir = function() return hat2dir(j, h, self.hflip) end
	elseif t == "keys" then
		local l, r, u, d = a.l, a.r, a.u, a.d
		print("BOOBS: player " .. tostring(self.index)
			.. ": binding directions to keys (l,r,u,d):",l,r,u,d)
		
		self.dir = function() return keys2dir(l, r, u, d, self.hflip) end
	else
		print("BOOBS: player " .. tostring(self.index)
			.. ": ignoring direction bind attempt with invalid type `" .. t .. "'")
	end
end

function player:bind_input(s, i)
	local t = i.type
	if t == "key" then
		local k = i.key
		print("BOOBS: player " .. tostring(self.index)
			.. ": binding input symbol `" .. s .. "' to key " .. k)
		self.inputmap[s] = function() return K.isDown(k) end
	elseif t == "button" then
		local j = i.joy
		local b = i.button
		print("BOOBS: player " .. tostring(self.index)
			.. ": binding input symbol `" .. s .. "' to joystick " .. tostring(j) .. " button " .. tostring(b))
		self.inputmap[s] = function() return J.isDown(j, b) end
	else
		print("BOOBS: player " .. tostring(self.index)
			.. ": ignoring input bind attempt with invalid type `" .. t .. "'")
	end
end

function player:set_movelist(movelist)
	self.movelist = movelist
	print("BOOBS: player " .. tostring(self.index)
		.. ": setting movelist to `" .. movelist.name .. "'")
	self:reset_crawl()
end

function player:reset_crawl()
	self.crawlposet = { [self.movelist.root] = time() }
end

function player:crawl(sym)
	self.movelist:crawl(sym, self.crawlposet, self.index)
end

function player:update()
	-- first do direction
	local ldir = self.lastdir
	local cdir = self.dir()
	if ldir ~= cdir then
		self:crawl(cdir)
		--print(cdir)
		self.lastdir = cdir
	end
	-- then do input
	local iwd = self.inwasdown
	
	for s,f in pairs(self.inputmap) do
		local bp = f()
		if iwd[s] then
			if not bp then
				self:crawl(s.."^")
				--print(s.."^")
				iwd[s] = false
			end
		else
			if bp then
				self:crawl(s)
				--print(s)
				iwd[s] = true
			end
		end
	end
end

-------------------------------------------------------------------------------
-- movelists and callbacks
local movelists = {}

-- prototype
movelist = {}

-- constructor
function movelist:new(n)
	local o = o or { index = idx, name = n }
	o.root = { name = "root" }
	
	setmetatable(o, self)
	self.__index = self
	
	movelists[n] = o
	return o
end

-- methods
function movelist:register_sequence(seq, callback)
	print("BOOBS: " .. self.name .. ": registering sequence `" .. seq .. "'")
	-- iterate through words
	local pos = self.root
	-- maek tree
	for w in seq:gmatch("%a+") do
		if not pos[w] then
			print("BOOBS: " .. self.name .. ":   making node " .. w .. " from node " .. pos.name)
			pos[w] = {}
		end
		pos = pos[w]
		pos.name = w
	end
	print("BOOBS: " .. self.name .. ":   registering callback " .. tostring(callback) .. " at node " .. pos.name)
	pos.cb = callback
end

function movelist:traverse(dt, sym, pos, pidx)
	if dt > input_link_time then return nil end
	local pos = pos or self.root
	local npos = pos[sym]
	if npos then
		local cb = npos.cb
		if cb then cb(pidx) end
		return npos
	end
	return pos
end

function movelist:crawl(sym, poset, pidx)
	local destroy = {}
	local append = {}
	local ct = time()
	poset[self.root] = ct
	
	for pos,lt in pairs(poset) do 
		if lt then
			local npos = self:traverse(ct - lt, sym, pos, pidx)
			if not npos then
				destroy[#destroy + 1] = pos
			elseif npos ~= pos then
				append[#append + 1] = npos
			end
		end
	end
	-- set to false instead of nil for recycling purposes
	for _,n in ipairs(destroy) do poset[n] = false end
	for _,n in ipairs(append) do poset[n] = ct end
end

-- fuck this file
-- this is standard
-- do whatever you want with it

module "queues"

function new()
	return { first = 0, last = -1 }
end

function enq(q, v)
	local last = q.last + 1
	q.last = last
	q[last] = v
end

function deq(q)
	local first = q.first
	if first > q.last then error("queue is empty") end
	local v = q[first]
	q[first] = nil
	q.first = first + 1
	return v
end

function it(q)
	local i = q.first - 1
	local last = q.last
	return function ()
		i = i + 1
		if i <= last then return q[i] end
	end
end
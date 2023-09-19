local utils = {}

utils.nfc = function(num)
    return tostring(num):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

utils.formatTime = function(timeInSeconds)
    if timeInSeconds < 0.000001 then
        return ">1μs"
    elseif timeInSeconds < 0.002 then
        local microseconds = math.floor(timeInSeconds * 1000000)
        return microseconds .. "μs"
    elseif timeInSeconds < 2 then
        local milliseconds = math.floor(timeInSeconds * 1000)
        return milliseconds .. "ms"
    else
        return timeInSeconds .. "s"
    end
end

utils.createVector = function(x, y)
	local vector_metatable = {
		__add = function(vec1, vec2)
			return { x = vec1.x + vec2.x, y = vec1.y + vec2.y }
		end,
		__sub = function(vec1, vec2)
			return { x = vec1.x - vec2.x, y = vec1.y - vec2.y }
		end,
		__mul = function(vec, scalar)
			return { x = vec.x * scalar, y = vec.y * scalar }
		end,
		__div = function(vec, scalar)
			return { x = vec.x / scalar, y = vec.y / scalar }
		end,
		__unm = function(vec)
			return { x = -vec.x, y = -vec.y }
		end,
		__eq = function(vec1, vec2)
			return vec1.x == vec2.x and vec1.y == vec2.y
		end,
		__len = function(vec)
			return math.sqrt(vec.x ^ 2 + vec.y ^ 2)
		end,
		__index = {
			dot = function(vec1, vec2)
				  return vec1.x * vec2.x + vec1.y * vec2.y
			end,
			cross = function(vec1, vec2)
				  return vec1.x * vec2.y - vec1.y * vec2.x
			end
		}
	}

    local vec = { x = x, y = y }
    setmetatable(vec, vector_metatable)
    return vec
end

utils.createBounds = function(x, y, width, height, scale)
	local bounds = {
		x = x,
		y = y,
		width = width,
		height = height,
		scale = scale or 1
	}
  
	function bounds:getWidth()
	  	return self.width * self.scale
	end
  
	function bounds:getHeight()
	  	return self.height * self.scale
	end

    function bounds:includes(x, y)
        return x > self.x and x < self.x + self:getWidth() and y > self.y and y < self.y + self:getHeight()
    end
  
	return bounds
end

--[[ 
	function love.load()
  		myTimer = createTimer(1, function() print("Hello, world!") end)
	end

	function love.update(dt)
		myTimer(dt)
	end
]]
utils.createTimer = function(interval, func)
	local t = 0
	
	return function(dt)
		t = t + dt		
		if t >= interval then
			func()
			t = t - interval
		end
	end
end

utils.rgb = function(r, g, b)
    return r / 255, g / 255, b / 255
end

return utils
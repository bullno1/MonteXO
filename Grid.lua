local m = {}

function m.new(width, height)
	return {
		width = width,
		height = height,
	}
end

function m.getSize(grid)
	return grid.width, grid.height
end

function m.clone(grid)
	local clone = {}

	for k, v in pairs(grid) do
		clone[k] = v
	end

	return clone
end

function m.isValid(grid, x, y)
	return true
		and x >= 1 and y >= 1
		and x <= grid.width and y <= grid.height
end

function m.put(grid, x, y, val)
	grid[x + (y - 1) * grid.height] = val
end

function m.putIndex(grid, index, val)
	grid[index] = val
end

function m.get(grid, x, y)
	return grid[x + (y - 1) * grid.height]
end

function m.toIndex(grid, x, y)
	return x + (y - 1) * grid.height
end

return m

local m = {}

local TILE_WIDTH = 20
local TILE_HEIGHT = 20
local GAP = 3

function m.new(width, height, winRequirement)
	return {
		width = width,
		height = height,
		winRequirement = winRequirement or 3
	}
end

function m.clone(state)
	local clone = {}

	for k, v in pairs(state) do
		clone[k] = v
	end

	return clone
end

function m.draw(state)
	for x = 0, state.width - 1 do
		for y = 0, state.height - 1 do
			love.graphics.rectangle(
				'line', x * TILE_WIDTH, y * TILE_HEIGHT,
				TILE_WIDTH, TILE_HEIGHT
			)

			local piece = m.get(state, x, y)
			if piece == 'x' then
				local left = x * TILE_WIDTH + GAP
				local right = left + TILE_WIDTH - GAP * 2
				local top = y * TILE_HEIGHT + GAP
				local bottom = top + TILE_HEIGHT - GAP * 2

				love.graphics.line(left, top, right, bottom)
				love.graphics.line(right, top, left, bottom)
			elseif piece == 'o' then
				love.graphics.circle(
					'line',
					x * TILE_WIDTH + TILE_WIDTH / 2,
					y * TILE_HEIGHT + TILE_HEIGHT / 2,
					TILE_WIDTH / 2 - GAP
				)
			end
		end
	end

	love.graphics.print(m.checkState(state), 0, state.height * TILE_HEIGHT + GAP)
end

function m.isValid(state, x, y)
	if x < 0 or y < 0 then return false end
	if x >= state.width or y >= state.height then return false end
	if m.get(state, x, y) then return false end

	return true
end

local function checkWinDir(state, piece, x, y, vx, vy)
	for i = 1, state.winRequirement - 1 do
		local adjacentPiece = m.get(state, x + vx * i, y + vy * i)
		if adjacentPiece ~= piece then return false end
	end

	return true
end

local function checkWin(state, piece, x, y)
	return false
		or checkWinDir(state, piece, x, y, 1, 0)
		or checkWinDir(state, piece, x, y, 0, 1)
		or checkWinDir(state, piece, x, y, 1, 1)
end

function m.checkState(state)
	local hasEmpty = false

	for x = 0, state.width - 1 do
		for y = 0, state.height - 1 do
			local piece = m.get(state, x, y)

			if piece then
				if checkWin(state, piece, x, y) then return piece end
			else
				hasEmpty = true
			end
		end
	end

	if not hasEmpty then
		return 'draw'
	else
		return 'undecided'
	end
end

function m.put(state, x, y, val)
	state[x * state.width + y] = val
end

function m.get(state, x, y)
	return state[x * state.width + y]
end

function m.mouseToCoord(x, y)
	return math.floor(x / TILE_WIDTH), math.floor(y /TILE_HEIGHT)
end

return m

local Grid = require('Grid')

local m = {}

function m.newGame(width, height, winRequirement)
	return {
		board = Grid.new(width, height),
		winRequirement = winRequirement,
		nextPlayer = 'x',
	}
end

function m.clone(state)
	local clone = {
		board = Grid.clone(state.board),
		winRequirement = state.winRequirement,
		nextPlayer = state.nextPlayer,
	}
end

local function checkWinDir(state, piece, x, y, vx, vy)
	local board = state.board
	for i = 1, state.winRequirement - 1 do
		local adjacentPiece = Grid.get(board, x + vx * i, y + vy * i)
		if adjacentPiece ~= piece then return false end
	end

	return true
end

local function checkWin(state, piece, x, y)
	return false
		or checkWinDir(state, piece, x, y, 1, 0)
		or checkWinDir(state, piece, x, y, 0, 1)
		or checkWinDir(state, piece, x, y, 1, 1)
		or checkWinDir(state, piece, x, y, 1, -1)
end

function m.checkState(state)
	local board = state.board
	local width, height = Grid.getSize(board)

	local hasEmpty = false
	for x = 1, width do
		for y = 1, height do
			local piece = Grid.get(board, x, y)

			if piece then
				if checkWin(state, piece, x, y) then return piece end
			else
				hasEmpty = true
			end
		end
	end

	if hasEmpty then
		return 'undecided'
	else
		return 'draw'
	end
end

function m.isResultTerminal(result)
	return result == 'x' or result == 'o' or result == 'draw'
end

function m.getValidMoves(state)
end

function m.isValid(state, x, y)
	if not Grid.isValid(state.board, x, y) then return false end
	if Grid.get(state.board, x, y) then return false end

	return true
end

function m.play(state, x, y)
	Grid.put(state.board, x, y, state.nextPlayer)

	if state.nextPlayer == 'x' then
		state.nextPlayer = 'o'
	else
		state.nextPlayer = 'x'
	end
end

return m

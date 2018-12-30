local Grid = require('Grid')

local m = {}

local function cloneTable(table)
	local clone = {}
	for k, v in pairs(table) do
		clone[k] = v
	end
	return clone
end

function m.newGame(width, height, winRequirement)
	local validMoves = {}

	for i = 1, width * height do
		validMoves[i] = true
	end

	return {
		board = Grid.new(width, height),
		winRequirement = winRequirement,
		nextPlayer = 'x',
		numEmptyCells = width * height,
		validMoves = validMoves,
	}
end

function m.clone(state)
	return {
		board = Grid.clone(state.board),
		winRequirement = state.winRequirement,
		nextPlayer = state.nextPlayer,
		numEmptyCells = state.numEmptyCells,
		validMoves = cloneTable(state.validMoves),
	}
end

local function checkWinDir(board, winRequirement, x, y, vx, vy)
	local maxX = x + vx * (winRequirement - 1)
	local maxY = y + vy * (winRequirement - 1)
	if not Grid.isValid(board, maxX, maxY) then return false end

	local piece = Grid.get(board, x, y)
	for i = 1, winRequirement - 1 do
		local checkX = x + vx * i
		local checkY = y + vy * i
		local checkPiece = Grid.get(board, checkX, checkY)

		if checkPiece ~= piece then return false end
	end

	return true
end

local function checkWin(board, winRequirement, x, y)
	return false
		or checkWinDir(board, winRequirement, x, y, -1, -1)
		or checkWinDir(board, winRequirement, x, y, -1, 0)
		or checkWinDir(board, winRequirement, x, y, -1, 1)
		or checkWinDir(board, winRequirement, x, y, 0, -1)
		or checkWinDir(board, winRequirement, x, y, 0, 1)
		or checkWinDir(board, winRequirement, x, y, 1, -1)
		or checkWinDir(board, winRequirement, x, y, 1, 0)
		or checkWinDir(board, winRequirement, x, y, 1, 1)
end

local function getOpponent(piece)
	if piece == 'x' then
		return 'o'
	else
		return 'x'
	end
end

function m.checkState(state)
	if state.numEmptyCells == 0 then return 'draw' end

	local lastX, lastY = state.lastX, state.lastY
	if state.lastX == nil then return 'undecided' end

	local board = state.board
	local winRequirement = state.winRequirement

	if not checkWin(board, winRequirement, lastX, lastY) then
		return 'undecided'
	else
		return Grid.get(board, lastX, lastY)
	end
end

function m.isResultTerminal(result)
	return result == 'x' or result == 'o' or result == 'draw'
end

function m.getValidMoves(state)
	local moves = {}
	local numMoves = 0

	for move in pairs(state.validMoves) do
		numMoves = numMoves + 1
		moves[numMoves] = move
	end

	return moves, numMoves
end

function m.isValid(state, x, y)
	if not Grid.isValid(state.board, x, y) then return false end
	if Grid.get(state.board, x, y) then return false end

	return true
end

function m.play(state, x, y)
	local index
	if y == nil then
		index = x
		x, y = Grid.fromIndex(state.board, x)
	else
		index = Grid.toIndex(state.board, x, y)
	end

	Grid.putIndex(state.board, index, state.nextPlayer)
	state.lastX, state.lastY = x, y

	state.nextPlayer = getOpponent(state.nextPlayer)
	state.numEmptyCells = state.numEmptyCells - 1
	state.validMoves[index] = nil
end

function m.getReward(state, result)
	if result == 'draw' then
		return 0.5
	elseif result ~= state.nextPlayer then
		return 1
	else
		return 0
	end
end

return m

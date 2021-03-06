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
	return {
		board = Grid.new(width, height),
		winRequirement = winRequirement,
		nextPlayer = 'x',
		numEmptyCells = width * height,
	}
end

function m.clone(state)
	return {
		board = Grid.clone(state.board),
		winRequirement = state.winRequirement,
		nextPlayer = state.nextPlayer,
		numEmptyCells = state.numEmptyCells,
	}
end

local function countPieces(board, piece, x, y, vx, vy)
	local count = 0

	while true do
		x = x + vx
		y = y + vy

		if not Grid.isValid(board, x, y) then return count end
		if Grid.get(board, x, y) ~= piece then return count end

		count = count + 1
	end
end

local function checkWinDir(board, winRequirement, x, y, vx, vy)
	local piece = Grid.get(board, x, y)

	local forwardStride = countPieces(board, piece, x, y, vx, vy)
	local backwardStride = countPieces(board, piece, x, y, -vx, -vy)

	return forwardStride + backwardStride + 1 >= winRequirement
end

local function checkWin(board, winRequirement, x, y)
	return false
		or checkWinDir(board, winRequirement, x, y, 1, 0)
		or checkWinDir(board, winRequirement, x, y, 0, 1)
		or checkWinDir(board, winRequirement, x, y, 1, 1)
		or checkWinDir(board, winRequirement, x, y, 1, -1)
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

local function calculateMoveDistance(board, index, x, y)
	local indexX, indexY = Grid.fromIndex(board, index)
	local diffX = x - indexX
	local diffY = y - indexY
	return diffX * diffX + diffY * diffY
end

local function findValidMoves(state)
	local moves = {}
	local numMoves = 0

	local width, height = Grid.getSize(state.board)
	for x = 1, width do
		for y = 1, height do
			if m.isValid(state, x, y) then
				numMoves = numMoves + 1
				moves[numMoves] = Grid.toIndex(state.board, x, y)
			end
		end
	end

	return moves, numMoves
end

local function getValidMovesForSimulation(state)
	local moves, numMoves

	if state.validMoves ~= nil then
		moves = {}
		numMoves = 0

		for move in pairs(state.validMoves) do
			numMoves = numMoves + 1
			moves[numMoves] = move
		end
	else
		moves, numMoves = findValidMoves(state)

		local validMoves = {}
		for i = 1, numMoves do
			validMoves[moves[i]] = true
		end
		state.validMoves = validMoves
	end

	return moves, numMoves
end

local function getValidMovesForExpansion(state)
	local moves, numMoves = findValidMoves(state)

	local lastX, lastY = state.lastX, state.lastY
	if lastX ~= nil then
		table.sort(moves, function(lhs, rhs)
			local lhsDistanceSquared = calculateMoveDistance(state.board, lhs, lastX, lastY)
			local rhsDistanceSquared = calculateMoveDistance(state.board, rhs, lastX, lastY)
			return lhsDistanceSquared < rhsDistanceSquared
		end)
	end

	return moves, numMoves
end

function m.getValidMoves(state, purpose)
	if purpose == 'simulation' then
		return getValidMovesForSimulation(state)
	elseif purpose == 'expansion' then
		return getValidMovesForExpansion(state)
	else
		return findValidMoves(state)
	end
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

	if state.validMoves ~= nil then
		state.validMoves[index] = nil
	end
end

function m.compactState(state)
	return { nextPlayer = state.nextPlayer }
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

local Grid = require('Grid')

local m = {}

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

local function checkWinDir(state, piece, x, y, vx, vy)
	local board = state.board
	for i = 1, state.winRequirement - 1 do
		local adjacentX = x + vx * i
		local adjacentY = y + vy * i
		if not Grid.isValid(board, adjacentX, adjacentY) then return false end

		local adjacentPiece = Grid.get(board, adjacentX, adjacentY)
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

local function getOpponent(piece)
	if piece == 'x' then
		return 'o'
	else
		return 'x'
	end
end

function m.checkState(state)
	if state.numEmptyCells == 0 then return 'draw' end

	local lastX, lastY= state.lastX, state.lastY
	if state.lastX == nil then return 'undecided' end

	local board = state.board
	local winRequirement = state.winRequirement

	local width, height = Grid.getSize(state.board)

	for x = math.max(1, lastX - winRequirement + 1), math.min(width, lastX + winRequirement - 1) do
		for y = math.max(1, lastY - winRequirement + 1), math.min(width, lastY + winRequirement - 1) do
			local piece = Grid.get(board, x, y)

			if piece and checkWin(state, piece, x, y) then
				return piece
			end
		end
	end

	return 'undecided'
end

function m.isResultTerminal(result)
	return result == 'x' or result == 'o' or result == 'draw'
end

function m.getValidMoves(state)
	local board = state.board
	local boardWidth, boardHeight = Grid.getSize(board)
	local moves = {}
	local numMoves = 0

	for x = 1, boardWidth do
		for y = 1, boardHeight do
			if m.isValid(state, x, y) then
				numMoves = numMoves + 1
				moves[numMoves] = Grid.toIndex(board, x, y)
			end
		end
	end

	return moves, numMoves
end

function m.isValid(state, x, y)
	if not Grid.isValid(state.board, x, y) then return false end
	if Grid.get(state.board, x, y) then return false end

	return true
end

function m.play(state, x, y)
	if y == nil then
		Grid.putIndex(state.board, x, state.nextPlayer)
		state.lastX, state.lastY = Grid.fromIndex(state.board, x)
	else
		Grid.put(state.board, x, y, state.nextPlayer)
		state.lastX = x
		state.lastY = y
	end

	state.nextPlayer = getOpponent(state.nextPlayer)
	state.numEmptyCells = state.numEmptyCells - 1
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

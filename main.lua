local Rule = require('Rule')
local Grid = require('Grid')
local AI = require('AI')
local ThreadPool = require('ThreadPool')

local TILE_WIDTH = 30
local TILE_HEIGHT = 30
local GAP = 5

local game, humanPlayer, ai

function love.load()
	threadPool = ThreadPool.new()
	game = Rule.newGame(10, 10, 5)
	ai = AI.new {
		mcts = {
			exploreParam = 0.6,
			numIterations = 40000,
			thinkTime = 6.0,
			limit = 'iteration',
		},
		game = game,
		threadPool = threadPool,
	}
	humanPlayer = 'x'
end

function love.update(dt)
	ThreadPool.update(threadPool)
	AI.update(ai)
end

local function getSymbolOwner(symbol)
	if symbol == humanPlayer then
		return 'Human'
	else
		return 'AI'
	end
end

function love.draw()
	local board = game.board
	local boardWidth, boardHeight = Grid.getSize(board)
	for x = 1, boardWidth do
		for y = 1, boardHeight do
			local piece = Grid.get(board, x, y)
			if x == game.lastX and y == game.lastY then
				love.graphics.setColor(1, 0, 0, 1)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end

			if piece == 'x' then
				local left = (x - 1) * TILE_WIDTH + GAP
				local right = left + TILE_WIDTH - GAP * 2
				local top = (y - 1) * TILE_HEIGHT + GAP
				local bottom = top + TILE_HEIGHT - GAP * 2

				love.graphics.line(left, top, right, bottom)
				love.graphics.line(right, top, left, bottom)
			elseif piece == 'o' then
				love.graphics.circle(
					'line',
					(x - 1) * TILE_WIDTH + TILE_WIDTH / 2,
					(y - 1) * TILE_HEIGHT + TILE_HEIGHT / 2,
					TILE_WIDTH / 2 - GAP
				)
			end

			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle(
				'line', (x - 1) * TILE_WIDTH, (y - 1) * TILE_HEIGHT,
				TILE_WIDTH, TILE_HEIGHT
			)
		end
	end

	local gameState = Rule.checkState(game)
	if gameState == 'x' or gameState == 'o' then
		gameState = getSymbolOwner(gameState) .. ' won'
	end

	love.graphics.print('Status: '..gameState, 0, boardHeight * TILE_HEIGHT + GAP)
	love.graphics.print('Current turn: '..getSymbolOwner(game.nextPlayer), 0, boardHeight * TILE_HEIGHT + GAP * 4)

	if ai.endTime and ai.endTime > ai.startTime then
		love.graphics.print('Think time: '..(ai.endTime - ai.startTime), 0, boardHeight * TILE_HEIGHT + GAP * 8)
	end
end

function love.keypressed(key, scancode, isRepeat)
	if key == 'r' and love.keyboard.isDown('lctrl') then
		love.event.quit('restart')
	end
end

local function isGameFinished(rule, game)
	return rule.isResultTerminal(rule.checkState(game))
end

function love.mousereleased(x, y, button)
	if isGameFinished(Rule, game) then return end

	if game.nextPlayer == humanPlayer then
		local boardX = math.floor(x / TILE_WIDTH) + 1
		local boardY = math.floor(y / TILE_HEIGHT) + 1

		if Rule.isValid(game, boardX, boardY) then
			Rule.play(game, boardX, boardY)

			if not isGameFinished(Rule, game) then AI.think(ai) end
		end
	end
end

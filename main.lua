local Rule = require('Rule')
local Grid = require('Grid')
local Mcts = require('Mcts')

local TILE_WIDTH = 20
local TILE_HEIGHT = 20
local GAP = 3

local game, mctsCfg

function love.load()
	game = Rule.newGame(8, 8, 5)
	mctsCfg = {
		rule = Rule,
		exploreParam = 1.5,
		numIterations = 50000,
	}

	--local move = Mcts.think(mctsCfg, game)
	--Rule.play(game, move)
end

function love.update(dt)
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

	love.graphics.print(Rule.checkState(game), 0, boardHeight * TILE_HEIGHT + GAP)
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

	local boardX = math.floor(x / TILE_WIDTH) + 1
	local boardY = math.floor(y / TILE_HEIGHT) + 1

	if Rule.isValid(game, boardX, boardY) then
		Rule.play(game, boardX, boardY)

		if not isGameFinished(Rule, game) then
			local startTime = love.timer.getTime()
			local move = Mcts.think(mctsCfg, game)
			local endTime = love.timer.getTime( )
			print("Think time:", endTime - startTime)

			Rule.play(game, move)
		end
	end
end

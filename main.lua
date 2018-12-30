local Rule = require('Rule')
local Grid = require('Grid')
local Mcts = require('Mcts')

local TILE_WIDTH = 20
local TILE_HEIGHT = 20
local GAP = 3

local game, mctsCfg

function love.load()
	game = Rule.newGame(10, 10, 5)
	mctsCfg = {
		rule = Rule,
		exploreParam = 1.5,
		role = 'o',
		numIterations = 1000,
	}
end

function love.update(dt)
end

function love.draw()
	local board = game.board
	local boardWidth, boardHeight = Grid.getSize(board)
	for x = 1, boardWidth do
		for y = 1, boardHeight do
			love.graphics.rectangle(
				'line', (x - 1) * TILE_WIDTH, (y - 1) * TILE_HEIGHT,
				TILE_WIDTH, TILE_HEIGHT
			)

			local piece = Grid.get(board, x, y)
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
		end
	end

	love.graphics.print(Rule.checkState(game), 0, boardHeight * TILE_HEIGHT + GAP)
end

function love.keypressed(key, scancode, isRepeat)
	if key == 'r' and love.keyboard.isDown('lctrl') then
		love.event.quit('restart')
	end
end

function love.mousereleased(x, y, button)
	local boardX = math.floor(x / TILE_WIDTH) + 1
	local boardY = math.floor(y / TILE_HEIGHT) + 1

	if Rule.isValid(game, boardX, boardY) then
		Rule.play(game, boardX, boardY)
	end
end
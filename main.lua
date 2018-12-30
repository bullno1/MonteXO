local Game = require('Game')
local Gfx = love.graphics

local game

function love.load()
	game = Game.new(4, 4)
end

function love.update(dt)
end

function love.draw()
	Game.draw(game)
end

function love.keypressed(key, scancode, isRepeat)
	if key == 'r' and love.keyboard.isDown('lctrl') then
		love.event.quit('restart')
	end
end

function love.mousereleased(x, y, button)
	local boardX, boardY = Game.mouseToCoord(x, y)

	if Game.isValid(game, boardX, boardY) then
		Game.put(game, boardX, boardY, 'x')
	end
end

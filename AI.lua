local Mcts = require('Mcts')
local Rule = require('Rule')
local ThreadPool = require('ThreadPool')
love.timer = require('love.timer')

local m = {}

local function checkNumIterations(cfg)
	cfg.numIterations = mctsCfg.numIterations - 1
	return cfg.numIterations > 0
end

local function checkThinkTime(cfg)
	return love.timer.getTime() - cfg.startTime < cfg.thinkTime
end

function m.new(cfg)
	return cfg
end

function m.update(ai)
	if ai.reqId == nil then return end

	local finished, success, resultOrError = ThreadPool.collectResult(ai.threadPool, ai.reqId)
	if not finished then return end
	if not success then return error(resultOrError, 0) end

	ai.reqId = nil
	Rule.play(ai.game, resultOrError)
end

function m.think(ai)
	ai.reqId = ThreadPool.execute(ai.threadPool, 'AI', '_think', ai.mcts, ai.game)
end

function m._think(cfg, game)
	cfg.startTime = love.timer.getTime()
	cfg.rule = Rule

	if cfg.limit == 'time' then
		cfg.canKeepThinking = checkThinkTime
	else
		cfg.canKeepThinking = checkNumIterations
	end

	return Mcts.think(cfg, game)
end

return m

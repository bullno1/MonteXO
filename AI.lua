local Mcts = require('Mcts')
local Rule = require('Rule')
local ThreadPool = require('ThreadPool')
local ParallelMap = require('ThreadPool.ParallelMap')
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
	if ai.reqHandle == nil then return end

	local finished, success, resultOrErrors = ParallelMap.collect(ai.threadPool, ai.reqHandle)
	if not finished then return end

	for i, v in ipairs(success) do
		if not v then return error(resultOrErrors[i], 0) end
	end

	table.sort(resultOrErrors, function(lhs, rhs)
		return lhs[3] > rhs[3]
	end)

	ai.reqHandle = nil
	Rule.play(ai.game, resultOrErrors[1][1])
end

function m.think(ai)
	local args = {}
	for i = 1, love.system.getProcessorCount() do
		args[i] = { ai.mcts, ai.game, math.random() }
	end

	ai.reqHandle = ParallelMap.execute(ai.threadPool, 'AI', '_think', args)
end

function m._think(args)
	local cfg, game, seed = unpack(args)
	math.randomseed(seed)

	cfg.startTime = love.timer.getTime()
	cfg.rule = Rule

	if cfg.limit == 'time' then
		cfg.canKeepThinking = checkThinkTime
	else
		cfg.canKeepThinking = checkNumIterations
	end

	return { Mcts.think(cfg, game) }
end

return m

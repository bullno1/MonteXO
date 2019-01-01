local Mcts = require('Mcts')
local Tree = require('Mcts.Tree')
local Rule = require('Rule')
local ThreadPool = require('ThreadPool')
local ParallelMap = require('ThreadPool.ParallelMap')
love.timer = require('love.timer')

local m = {}

local function checkNumIterations(cfg)
	cfg.numIterations = cfg.numIterations - 1
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

	local totalScores = {}

	for i, moves in ipairs(resultOrErrors) do
		for move, numVisits in pairs(moves) do
			local currentNumVisits = totalScores[move] or 0
			totalScores[move] = currentNumVisits + numVisits
		end
	end

	local bestMove, bestScore
	for move, score in pairs(totalScores) do
		if bestScore == nil or score > bestScore then
			bestMove = move
			bestScore = score
		end
	end

	ai.reqHandle = nil
	Rule.play(ai.game, bestMove)
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

	local tree = Mcts.buildTree(cfg, game)

	local moves = {}
	Tree.forEachChild(tree, Tree.getRoot(tree), function(child)
		local numWins, numVisits = Tree.getStats(tree, child)
		local move = Tree.getMove(tree, child)
		moves[move] = numVisits
	end)
	return moves
end

return m

local Tree = require('Mcts.Tree')

local m = {}

local getState = Tree.getState
local getStats = Tree.getStats
local getParent = Tree.getParent
local expandNode = Tree.expandNode
local backpropagate = Tree.backpropagate
local isFullyExpanded = Tree.isFullyExpanded
local getFirstChild = Tree.getFirstChild
local getNextSibling = Tree.getNextSibling
local getNumChildren = Tree.getNumChildren
local log = math.log
local sqrt = math.sqrt

local function uct(tree, node, exploreParam)
	local parent = getParent(tree, node)
	local reward, numVisits = getStats(tree, node)
	local parentReward, numParentVisits = getStats(tree, parent)

	return (reward / numVisits) + exploreParam * sqrt(log(numParentVisits) / numVisits)
end

local function findBestChild(tree, node, evaluationFn)
	local bestChild = getFirstChild(tree, node)
	local bestScore = evaluationFn(tree, bestChild)

	local currentChild = bestChild
	for i = 2, getNumChildren(tree, node) do
		currentChild = getNextSibling(tree, currentChild)
		local currentScore = evaluationFn(tree, currentChild)
		if currentScore > bestScore then
			bestChild = currentChild
			bestScore = currentScore
		end
	end

	--print('best child', node, bestChild, bestScore)
	return bestChild
end

local function selectNode(tree, root, evaluationFn)
	local currentNode = root

	while isFullyExpanded(tree, currentNode) do
		currentNode = findBestChild(tree, currentNode, evaluationFn)
	end

	--print('select', currentNode)
	return currentNode
end

local function simulate(rule, state)
	local state = rule.clone(state)

	local checkState = rule.checkState
	local isResultTerminal = rule.isResultTerminal
	local getValidMoves = rule.getValidMoves
	local play = rule.play
	local random = math.random

	while true do
		local result = checkState(state)
		if isResultTerminal(result) then
			return result
		end

		local moves, numMoves = getValidMoves(state, 'simulation')
		local chosenMove = moves[random(numMoves)]
		play(state, chosenMove)
	end
end

local function getVisitCount(tree, node)
	local reward, numVisits = getStats(tree, node)
	return numVisits
end

function m.think(cfg, state)
	local rule = cfg.rule
	local exploreParam = cfg.exploreParam
	local canKeepThinking = cfg.canKeepThinking

	local tree = Tree.new(rule.clone(state))
	local root = Tree.getRoot(tree)

	local function calculateSelectScore(tree, node)
		return uct(tree, node, exploreParam)
	end

	local checkState = rule.checkState
	local isResultTerminal = rule.isResultTerminal

	while canKeepThinking(cfg) do
		local node = selectNode(tree, root, calculateSelectScore)
		local result = checkState(getState(tree, node))

		if not isResultTerminal(result) then
			local oldNode = node
			node = expandNode(tree, node, rule)
			local state = getState(tree, node)
			result = simulate(rule, state)
		end

		backpropagate(tree, node, rule, result)
	end

	local bestChild = findBestChild(tree, root, getVisitCount)
	--print('chose move', bestChild, Tree.getMove(tree, bestChild))
	return Tree.getMove(tree, bestChild)
end

return m

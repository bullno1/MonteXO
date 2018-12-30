local Tree = require('Tree')

local m = {}

local function uct(tree, node, exploreParam)
	local parent = Tree.getParent(tree, node)
	local reward, numVisits = Tree.getStats(tree, node)
	local parentReward, numParentVisits = Tree.getStats(tree, parent)

	return (reward / numVisits) + exploreParam * math.sqrt(math.log(numParentVisits) / numVisits)
end

local function findBestChild(tree, node, evaluationFn)
	local bestChild = Tree.getFirstChild(tree, node)
	local bestScore = evaluationFn(tree, bestChild)

	local currentChild = bestChild
	for i = 2, Tree.getNumChildren(tree, node) do
		currentChild = Tree.getNextSibling(tree, currentChild)
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

	while Tree.isFullyExpanded(tree, currentNode) do
		currentNode = findBestChild(tree, currentNode, evaluationFn)
	end

	--print('select', currentNode)
	return currentNode
end

local function simulate(rule, state)
	local state = rule.clone(state)

	while true do
		local result = rule.checkState(state)
		if rule.isResultTerminal(result) then
			return result
		end

		local moves, numMoves = rule.getValidMoves(state)
		local chosenMove = moves[math.random(numMoves)]
		rule.play(state, chosenMove)
	end
end

local function getVisitCount(tree, node)
	local reward, numVisits = Tree.getStats(tree, node)
	return numVisits
end

function m.think(cfg, state)
	local rule = cfg.rule
	local exploreParam = cfg.exploreParam

	local tree = Tree.new(rule.clone(state))
	local root = Tree.getRoot(tree)

	local function calculateSelectScore(tree, node)
		return uct(tree, node, exploreParam)
	end

	for i = 1, cfg.numIterations do
		local node = selectNode(tree, root, calculateSelectScore)
		local result = rule.checkState(Tree.getState(tree, node))

		if not rule.isResultTerminal(result) then
			local oldNode = node
			node = Tree.expandNode(tree, node, rule)
			--print('expand', oldNode, node, Tree.getMove(tree, node))
			local state = Tree.getState(tree, node)
			result = simulate(rule, state)
			--print('simulate', node, result)
		end

		Tree.backpropagate(tree, node, rule, result)
	end

	local bestChild = findBestChild(tree, root, getVisitCount)
	--print('chose move', bestChild, Tree.getMove(tree, bestChild))
	return Tree.getMove(tree, bestChild)
end

return m

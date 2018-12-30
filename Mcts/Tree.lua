--- A game tree optimized for low GC pressure and fixed memory usage

local m = {}

function m.new(state)
	return {
		numNodes = 1,
		nodeParent = {},
		nodeMove = {},
		nodeState = { state },
		nodeNumChildren = {},
		nodeFirstChild = {},
		nodeExpansionProgress = {},
		nodeReward = { 0 },
		nodeVisitCount = { 0 },
	}
end

function m.getRoot(tree)
	return 1 -- first node is always root
end

function m.getState(tree, node)
	return tree.nodeState[node]
end

function m.getMove(tree, node)
	return tree.nodeMove[node]
end

function m.getParent(tree, node)
	return tree.nodeParent[node]
end

function m.getStats(tree, node)
	return tree.nodeReward[node], tree.nodeVisitCount[node]
end

function m.getFirstChild(tree, node)
	return tree.nodeFirstChild[node]
end

function m.getNumChildren(tree, node)
	return tree.nodeNumChildren[node]
end

function m.getNextSibling(tree, node)
	local parent = m.getParent(tree, node)
	local numSiblings = m.getNumChildren(tree, parent)
	local firstSibling = m.getFirstChild(tree, parent)
	local lastSibling = firstSibling + numSiblings - 1
	local nextSibling = node + 1

	if nextSibling <= lastSibling then
		return nextSibling
	end
end

function m.isFullyExpanded(tree, node)
	local progress = tree.nodeExpansionProgress[node]
	return progress ~= nil and progress >= m.getNumChildren(tree, node)
end

local function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

function m.expandNode(tree, node, rule)
	local progress = tree.nodeExpansionProgress[node]
	local state = m.getState(tree, node)

	if progress == nil then -- not yet started
		local moves, numMoves = rule.getValidMoves(state, true)

		local newNode = tree.numNodes
		for i, move in ipairs(moves) do
			newNode = newNode + 1
			tree.nodeParent[newNode] = node
			tree.nodeMove[newNode] = move
			tree.nodeReward[newNode] = 0
			tree.nodeVisitCount[newNode] = 0
		end

		tree.nodeFirstChild[node] = tree.numNodes + 1
		tree.nodeNumChildren[node] = numMoves
		tree.nodeExpansionProgress[node] = 0
		tree.numNodes = newNode
		progress = 0
	end

	local firstChild = m.getFirstChild(tree, node)
	local nodeToExpand = firstChild + progress

	local newNodeState = rule.clone(state)
	rule.play(newNodeState, m.getMove(tree, nodeToExpand))
	tree.nodeState[nodeToExpand] = newNodeState

	tree.nodeExpansionProgress[node] = progress + 1

	-- Game state is no longer needed
	if m.isFullyExpanded(tree, node) then
		tree.nodeState[node] = rule.compactState(tree.nodeState[node])
	end

	return nodeToExpand
end

function m.backpropagate(tree, node, rule, result)
	local nodeVisitCount = tree.nodeVisitCount
	repeat
		nodeVisitCount[node] = nodeVisitCount[node] + 1

		local state = m.getState(tree, node)
		local reward = rule.getReward(state, result)
		--print('reward', node, reward)
		tree.nodeReward[node] = tree.nodeReward[node] + reward

		node = m.getParent(tree, node)
	until node == nil
end

return m

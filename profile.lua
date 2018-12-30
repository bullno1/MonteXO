local Rule = require('Rule')
local Mcts = require('Mcts')
local ProFi = require('ProFi')

local game = Rule.newGame(10, 10, 5)
local mctsCfg = {
	rule = Rule,
	exploreParam = 1.3,
	thinkTime = 5.0,
}

function mctsCfg.canKeepThinking()
	mctsCfg.numIterations = mctsCfg.numIterations - 1
	return mctsCfg.numIterations > 0
end

ProFi:start()
mctsCfg.numIterations = 200
Mcts.think(mctsCfg, game)
ProFi:stop()
ProFi:writeReport('mcts.txt')

local m = {}

function m.new(numWorkers)
	numWorkers = numWorkers or love.system.getProcessorCount()
	local reqChannel = love.thread.newChannel()
	local repChannel = love.thread.newChannel()

	local workers = {}
	local workerModulePath = package.searchpath('ThreadPool.Worker', package.path)
	for i = 1, numWorkers do
		local thread = love.thread.newThread(workerModulePath:sub(2))
		workers[i] = thread
		thread:start(reqChannel, repChannel)
	end

	return {
		workers = workers,
		numWorkers = numWorkers,
		reqChannel = reqChannel,
		repChannel = repChannel,
		freeIds = {},
		finishedReqs = {},
		requestStates = {},
		results = {},
		nextId = 1,
	}
end

local function newReqId(threadPool)
	if #threadPool.freeIds > 0 then
		return table.remove(threadPool.freeIds)
	else
		local newId = threadPool.nextId
		threadPool.nextId = newId + 1
		return newId
	end
end

function m.execute(threadPool, moduleName, functionName, ...)
	local reqId = newReqId(threadPool)

	threadPool.reqChannel:push({reqId, moduleName, functionName, {...}})
	threadPool.finishedReqs[reqId] = false

	return reqId
end

function m.update(threadPool)
	while true do
		local msg = threadPool.repChannel:pop()

		if msg == nil then return end

		local reqId, success, resultOrError = unpack(msg)
		threadPool.finishedReqs[reqId] = true
		threadPool.requestStates[reqId] = success
		threadPool.results[reqId] = resultOrError
	end
end

function m.isRequestFinished(threadPool, reqId)
	return threadPool.finishedReqs[reqId]
end

function m.collectResult(threadPool, reqId)
	if not m.isRequestFinished(threadPool, reqId) then return false end

	table.insert(threadPool.freeIds, reqId)

	return true, threadPool.requestStates[reqId], threadPool.results[reqId]
end

return m

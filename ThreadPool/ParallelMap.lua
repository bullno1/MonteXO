local ThreadPool = require('ThreadPool')

local m = {}

function m.execute(threadPool, moduleName, functionName, array)
	local handle = {}

	for i, value in ipairs(array) do
		local reqId = ThreadPool.execute(threadPool, moduleName, functionName, value)
		handle[i] = reqId
	end

	return handle
end

function m.collect(threadPool, handle, resultOrErrors)
	for i, reqId in ipairs(handle) do
		if not ThreadPool.isRequestFinished(threadPool, reqId) then
			return false
		end
	end

	if resultOrErrors == nil then resultOrErrors = {} end

	for i, reqId in ipairs(handle) do
		local finished, success, resultOrError = ThreadPool.collectResult(threadPool, reqId)
		handle[i] = success
		resultOrErrors[i] = resultOrError
	end

	return true, handle, resultOrErrors
end

return m

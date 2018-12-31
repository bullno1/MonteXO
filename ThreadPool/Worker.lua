local reqChannel, repChannel = ...

local function doWork(moduleName, functionName, args)
	local module = require(moduleName)
	return module[functionName](unpack(args))
end

while true do
	local reqId, moduleName, functionName, args = unpack(reqChannel:demand())
	local success, resultOrError = pcall(doWork, moduleName, functionName, args)
	repChannel:push({reqId, success, resultOrError})
end

local logger = {
    logList = {};
}

function logger:log(input)
    logger.logList[#logger.logList+1] = input
end

function logger:verboseLog(input)
    if not table.contains(arg, "--verbose") then return end
    logger.logList[#logger.logList+1] = input
end

function logger:clear()
    logger.logList = {}
end

return logger
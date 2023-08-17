local logger = {
    logList = {};
}

function logger:log(input)
    logger.logList[#logger.logList+1] = input
end

function logger:clear()
    logger.logList = {}
end

return logger
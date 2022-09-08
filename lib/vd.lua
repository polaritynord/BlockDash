local vd = {
    logs = {};
}

function vd.log(text)
    vd.logs[#vd.logs+1] = text
end

function vd.draw()
    -- Erase the log if it passes the limit
    local length = 10
    if #vd.logs > length then
        table.remove(vd.logs, 1)
    end
    if not Settings.showLogs then return end
    -- Draw log
    local x = 0; local y = 0;
    love.graphics.setNewFont("fonts/JetBrainsMono-Regular.ttf", 12)
    for _, v in ipairs(vd.logs) do
        love.graphics.print(v, x, y)
        y = y + 16
    end
end

return vd

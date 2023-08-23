
function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end


function love.conf(t)
	t.version = "11.4"
	t.title = "Block Dash"
	SC_WIDTH = 960 ; SC_HEIGHT = 540
	t.window.width = SC_WIDTH ; t.window.height = SC_HEIGHT
	t.window.resizable = true
	t.window.icon = "images/icon.png"
	-- Vsync
	t.window.vsync = 1
	t.window.fullscreen = false
	if table.contains(arg, "--no-vsync") then t.window.vsync = 0 end
	Version = "1.3a"
end

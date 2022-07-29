# love-just-ui
An immediate mode graphic user interface (IMGUI) library for love2d.  
The library is in the early stages of development and is not yet ready for production use.  
Check `main.lua` for simple demo.

## Usage

Require the library in your project:
```lua
local just = require("just")
```

Call mouse callbacks `mousepressed`, `mousereleased`, `mousemoved`, `wheelmoved`:
```lua
function love.mousepressed(...)
	if just.mousepressed(...) then return end
	-- your code here
end
```

In the end of your love.draw function, call `just._end`:
```lua
function love.draw()
	-- your code here
    just._end()
end
```

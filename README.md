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

The library has only one column layout. Each widget draws in the column next to the previous one.
But you can use `just.sameline()` to draw next widget in the same row.

### The library provides the following functions:

#### changed = just.button(text)
Draws a button.

#### changed = just.checkbox(id, out)
Draws a checkbox. `out` is the "pointer" to the boolean variable. Example:
```lua
local game_config = {vsync = true}  -- is not in love.draw
just.checkbox("vsync", {vsync = game_config})
```

#### changed = just.slider(id, out, min, max, vertical)
Draws a slider. `out` is the "pointer" to the boolean variable. `min` and `max` are the minimum and maximum values of the slider. `vertical` is a boolean value that determines whether the slider is vertical or horizontal. Example:
```lua
local game_config = {volume = 50}  -- is not in love.draw
just.slider("Hello7", {volume = game_config}, 0, 100)
```

#### just.text(id)
Draws a text.

#### dx, dy = just.begin_window(id, w, h)
#### just.end_window()
Creates a window. Example:
```lua
local x, y = 100, 100
function love.draw()
	love.graphics.translate(x, y)
	local dx, dy = just.begin_window("Window1", 300, 200)
	x, y = x + dx, y + dy
	-- your code here
	just.end_window()
	just._end()
end
```

#### just.wheelscroll(out, speed)
Handles wheel scroll. `out` is the "pointer" to the integer variable. `speed` is the speed of the wheel.
Call it after `just.begin_window`.

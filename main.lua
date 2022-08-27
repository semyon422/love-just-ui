local just = require("just")
local ui = require("just.ui")

local event_message = ""

function love.mousepressed(x, y, button)
	if just.callbacks.mousepressed(x, y, button) then
		return
	end
	event_message = ("%s: %d, %d, %d"):format("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
	if just.callbacks.mousereleased(x, y, button) then
		return
	end
	event_message = ("%s: %d, %d, %d"):format("mousereleased", x, y, button)
end

function love.mousemoved(x, y)
	if just.callbacks.mousemoved(x, y) then
		return
	end
	event_message = ("%s: %d, %d"):format("mousemoved", x, y)
end

function love.wheelmoved(x, y)
	if just.callbacks.wheelmoved(x, y) then
		return
	end
	event_message = ("%s: %d, %d"):format("wheelmoved", x, y)
end

function love.keypressed(key, scancode, isrepeat)
	if just.callbacks.keypressed(key, scancode, isrepeat) then
		return
	end
	event_message = ("%s: %s, %s, %s"):format("keypressed", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
	if just.callbacks.keyreleased(key, scancode, isrepeat) then
		return
	end
	event_message = ("%s: %s, %s, %s"):format("keyreleased", key, scancode, isrepeat)
end

function love.textinput(text)
	if just.callbacks.textinput(text) then
		return
	end
	event_message = ("%s: %s"):format("textinput", text)
end

local config = {
	test = true,
	byte = 60,
}

local function label(text)
	love.graphics.translate(0, 13)
	just.indent(13)
	just.text(text)
	love.graphics.translate(0, -13)
	just.sameline()
	just.next(0, 40)
end

local function window1()
	love.graphics.setColor(1, 1, 1, 1)
	just.text("Hello") just.sameline() just.text("World")
	just.emptyline(13)
	just.indent(13)
	just.text("Hello") just.sameline() just.text("World")
	if ui.button("Hello") then print("Hello") end
	just.sameline()
	label("Label 1")
	just.sameline()
	label("Label 2")
	if ui.button("Hello1") then print("Hello1") end
	just.sameline()
	if ui.checkbox("Hello2", {test = config}) then print("Hello2") end
	just.sameline()
	label("Checkbox")
	label("Label 3")

	if config.test then
		love.graphics.translate(80, 80)
		love.graphics.rotate(-math.pi / 4)
		love.graphics.scale(1.5, 1)
	end
	if ui.button("Hello5") then print("Hello5") end
	just.sameline()
	if ui.slider("Hello7", {byte = config}, 0, 255) then print("Hello7") end
	if ui.button("Hello6") then print("Hello6") end
	ui.set_id("Hello66") if ui.button("Hello6" .. math.random(10,99)) then print("Hello66") end
	if ui.button("Hello8") then print("Hello8") end
	if ui.button("Hello6") then print("Hello6") end
	if ui.button("Hello6") then print("Hello6") end
	if ui.button("Hello6") then print("Hello6") end

	if just.keyboard_over() then
		if just.keypressed("q") then
			print("q")
		end
	end
end

local function window2()
	if ui.button("Hello123") then print("Hello123") end
	just.sameline()
	love.graphics.translate(-40, 20)
	if ui.button("Hello1234") then print("Hello1234") end
	if ui.button("Hello12345") then print("Hello12345") end
	love.graphics.translate(40, -20)

	love.graphics.translate(20, 0)
	ui.begin_window("Window3", 80, 80)
	love.graphics.translate(20, 0)
	if ui.button("Hello1122") then print("Hello1122") end
	ui.end_window()

	if just.keyboard_over() then
		if just.keypressed("w") then
			print("w")
		end
	end
end

local x1, y1 = 200, 300
local rotate = {a = 0}

local enter_exit_log = {}
local prev_exit, prev_enter

local mx, my = 0, 0
local text, index = "", 1
function love.draw()
	if just.keyboard_over() then
		if just.keypressed("e") then
			print("e")
		end
	end
	love.graphics.printf(event_message, 0, 0, love.graphics.getWidth(), "center")
	love.graphics.printf(table.concat(enter_exit_log, "\n"), 0, 0, love.graphics.getWidth(), "right")

	just.row(true)
	ui.button("Button 1")
	ui.button("Button 2")
	ui.button("Button 3")
	just.row(true)
	ui.button("Button 1")
	ui.button("Button 2")
	ui.button("Button 3")
	just.row(false)
	ui.button("Button 1")
	ui.button("Button 2")
	ui.button("Button 3")

	if ui.begin_dropdown("Dropdown (0, 0)", "dd (0, 0)", 100, false, false) then
		ui.button("dButton 1")
		ui.button("dButton 2")
		ui.end_dropdown()
	end
	love.graphics.translate(100, -40)
	if ui.begin_dropdown("Dropdown (1, 0)", "dd (1, 0)", 100, true, false) then
		ui.button("dButton 1")
		ui.button("dButton 2")
		ui.end_dropdown()
	end
	love.graphics.translate(100, -40)
	if ui.begin_dropdown("Dropdown (0, 1)", "dd (0, 1)", 100, false, true) then
		ui.button("dButton 1")
		ui.button("dButton 2")
		ui.end_dropdown()
	end
	love.graphics.translate(100, -40)
	if ui.begin_dropdown("Dropdown (1, 1)", "dd (1, 1)", 100, true, true) then
		ui.button("dButton 1")
		ui.button("dButton 2")
		ui.end_dropdown()
	end

	love.graphics.origin()

	local _mx, _my = love.mouse.getPosition()
	local dmx, dmy = _mx - mx, _my - my

	local w, h = 300, 200
	love.graphics.translate(x1, y1)
	ui.slider("Window1 rotate", {a = rotate}, 0, 2 * math.pi)
	love.graphics.rotate(rotate.a)
	if ui.begin_window("Window1", w, h) then
		x1, y1 = x1 + dmx, y1 + dmy
	end
	window1()
	ui.end_window()

	love.graphics.origin()
	love.graphics.translate(600, 400)
	ui.begin_window("Window2", 200, 200)
	window2()
	ui.end_window()

	if prev_enter ~= just.entered_id then
		table.insert(enter_exit_log, ("%s: %s"):format("entered", just.entered_id))
		prev_enter = just.entered_id
	end
	if prev_exit ~= just.exited_id then
		table.insert(enter_exit_log, ("%s: %s"):format("exited", just.exited_id))
		prev_exit = just.exited_id
	end
	while #enter_exit_log > 10 do table.remove(enter_exit_log, 1) end

	-- if just.key("q") then
	-- 	print("q")
	-- end
	-- if just.key("w") then
	-- 	print("w")
	-- end
	-- if just.key("a") then
	-- 	print("a")
	-- end
	-- if just.key("s") then
	-- 	print("s")
	-- end

	-- text, index = just.textinput(text, index)
	-- print(text, index)

	mx, my = _mx, _my
	just._end()
end

SetProfilerEnabled(false)
--physics.SetFrameRate(120)
--physics.SetAccuracy(4)

runProcess(function()
	while true do
		update()
		if
			input.Press(string.byte("Q"))
			and (input.Press(KEYBOARD_BUTTON_LCONTROL) or input.Press(KEYBOARD_BUTTON_RCONTROL))
		then
			application.Exit()
		end
	end
end)

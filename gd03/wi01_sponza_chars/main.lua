function SetupGfx(rp)
    rp.SetResolutionScale(0.88)
end


runProcess(function()
	local scene = GetScene()
    local cam = GetCamera()
	cam.SetFOV(44 * (math.pi / 180)) -- deg2rad

    LoadModel(script_dir() .. "/art/Sponza/Sponza.wiscene")
    local emitter = scene.Entity_FindByName('editorEmitter')
    if emitter ~= INVALID_ENTITY then
		scene.Entity_Remove(emitter)
	end

	-- create a point light to be able to see the cube:
	local light_entity = CreateEntity()
	local light = scene.Component_CreateLight(light_entity)
	light.SetType(POINT)
	light.SetIntensity(10)
	local light_transform = scene.Component_CreateTransform(light_entity)
	light_transform.Translate(Vector(2,2,-2))

	-- set up a 3D render path, so if you load a model it will be displayed
    local renderpath = RenderPath3D()
	SetupGfx(renderpath)
	application.SetActivePath(renderpath, 1.0, 0, 0, 0, FadeType.CrossFade) -- 1 sec cross fade

	-- put camera back a bit so we can see the cube in the origin (note that the camera is updated with this transform every frame when TransformCamera() is called):
    local cam_transform = TransformComponent()
	local pos_pointer = {}

	-- run an endless update loop, it will run until killProcesses() is called or the application exits
	while true do
		update() -- blocks this process until next update() is signaled from Wicked Engine

		local dt = getDeltaTime() -- get delta time (elapsed time since last update())

		local diff = input.GetAnalog(GAMEPAD_ANALOG_THUMBSTICK_R)
		diff = vector.Multiply(diff, dt * 4)
		-- Mouse look camera:
        if input.Down(MOUSE_BUTTON_RIGHT) then
            input.HidePointer(true)
            local mouseDiff = input.GetPointerDelta()
            mouseDiff = mouseDiff:Multiply(0.01)
            diff = vector.Add(diff, mouseDiff)
            input.SetPointer(pos_pointer)
        else
            pos_pointer = input.GetPointer()
            input.HidePointer(false)
        end
		cam_transform.Rotate(Vector(diff.GetY(),diff.GetX())) -- roll-pitch-yaw rotation

		-- WASD camera movement:
		local camspeed = 4.321 * dt
		local camera_movement = Vector()
		if input.Down(string.byte('W')) then
			camera_movement = vector.Add(camera_movement, Vector(0,0,camspeed))
		end
		if input.Down(string.byte('S')) then
			camera_movement = vector.Add(camera_movement, Vector(0,0,-camspeed))
		end
		if input.Down(string.byte('A')) then
			camera_movement = vector.Add(camera_movement, Vector(-camspeed,0,0))
		end
		if input.Down(string.byte('D')) then
			camera_movement = vector.Add(camera_movement, Vector(camspeed,0,0))
		end
		if input.Down(string.byte('Q')) then
			camera_movement = vector.Add(camera_movement, Vector(0,-camspeed,0))
		end
		if input.Down(string.byte('E')) then
			camera_movement = vector.Add(camera_movement, Vector(0,camspeed,0))
		end
		camera_movement = vector.Rotate(camera_movement, cam_transform.Rotation_local) -- rotate the camera movement with camera orientation, so it's relative
		cam_transform.Translate(camera_movement)

		cam_transform.UpdateTransform() -- because cam_transform is not part of the scene system, but we created it just in the script, update it manually with UpdateTransform()
		cam.TransformCamera(cam_transform)
		cam.UpdateCamera()

		-- Add some editor testing functionality to return to editor when ESC is pressed. This can help development, and only works if script is running from the Editor:
		if IsThisEditor() and input.Press(KEYBOARD_BUTTON_ESCAPE) then
			ReturnToEditor()
			input.ResetCursor(CURSOR_DEFAULT)
			return
		end

	end

end)

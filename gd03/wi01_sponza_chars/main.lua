local sponza_path = script_dir() .. "/art/Sponza/Sponza.wiscene"

runProcess(function()
	local scene = GetScene()
	local cam = GetCamera()
	cam.SetFOV(44 * (math.pi / 180)) -- deg2rad

	LoadModel(sponza_path)
	local emitter = scene.Entity_FindByName("editorEmitter")
	if emitter ~= INVALID_ENTITY then
		scene.Entity_Remove(emitter)
	end

	local cam_transform = TransformComponent()
	cam_transform.Translate(Vector(0, 2, 0))

	while true do
		update()

		local dt = getDeltaTime()

		local diff = input.GetAnalog(GAMEPAD_ANALOG_THUMBSTICK_R)
		diff = vector.Multiply(diff, dt * 4)
		local mouseDiff = input.GetPointerDelta()
		mouseDiff = mouseDiff:Multiply(0.01)
		diff = vector.Add(diff, mouseDiff)
		cam_transform.Rotate(Vector(diff.GetY(), diff.GetX()))

		local camspeed = 4.321 * dt
		local camera_movement = Vector()
		if input.Down(string.byte("W")) then
			camera_movement = vector.Add(camera_movement, Vector(0, 0, camspeed))
		end
		if input.Down(string.byte("S")) then
			camera_movement = vector.Add(camera_movement, Vector(0, 0, -camspeed))
		end
		if input.Down(string.byte("A")) then
			camera_movement = vector.Add(camera_movement, Vector(-camspeed, 0, 0))
		end
		if input.Down(string.byte("D")) then
			camera_movement = vector.Add(camera_movement, Vector(camspeed, 0, 0))
		end
		if input.Down(string.byte("Q")) then
			camera_movement = vector.Add(camera_movement, Vector(0, -camspeed, 0))
		end
		if input.Down(string.byte("E")) then
			camera_movement = vector.Add(camera_movement, Vector(0, camspeed, 0))
		end
		camera_movement = vector.Rotate(camera_movement, cam_transform.Rotation_local) -- rotate the camera movement with camera orientation, so it's relative
		cam_transform.Translate(camera_movement)

		cam_transform.UpdateTransform() -- because cam_transform is not part of the scene system, but we created it just in the script, update it manually with UpdateTransform()
		cam.TransformCamera(cam_transform)
		cam.UpdateCamera()

		if IsThisEditor() and input.Press(KEYBOARD_BUTTON_ESCAPE) then
			ReturnToEditor()
			return
		end
	end
end)

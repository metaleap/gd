local sponza_path = script_dir() .. "/art/Sponza/Sponza.wiscene"

function SetupGfx(rp)
	rp.SetResolutionScale(0.88)
	rp.SetAO(AO_MSAO)
	rp.SetAOPower(0.77)
	rp.SetSSREnabled(true)
	rp.SetSSGIEnabled(true)
	rp.SetShadowsEnabled(true)
	rp.SetReflectionsEnabled(true)
	rp.SetFXAAEnabled(true)
	-- rp.SetBloomEnabled(true)
	rp.SetBloomThreshold(3.21)
	-- rp.SetVolumeLightsEnabled(true)
	rp.SetLightShaftsEnabled(true)
	rp.SetLightShaftsStrength(0.321)
	rp.SetMotionBlurEnabled(true)
	rp.SetMotionBlurStrength(44)
	rp.SetDitherEnabled(true)
	rp.SetMSAASampleCount(8)
	rp.SetSharpenFilterEnabled(true)
	rp.SetSharpenFilterAmount(0.88)
	rp.SetEyeAdaptionEnabled(true)
	rp.SetTonemap(ACES)
	rp.SetChromaticAberrationEnabled(true)
	rp.SetChromaticAberrationAmount(3.21)
	rp.SetEyeAdaptionRate(4)
	rp.SetEyeAdaptionKey(0.123)
	rp.SetContrast(1.11)
	rp.SetSaturation(0.6)
	rp.SetLightShaftsFadeSpeed(4)
	rp.SetMeshBlendEnabled(true)
	rp.SetOcclusionCullingEnabled(true)
	rp.SetSSGIDepthRejection(1.23)
end

runProcess(function()
	local scene = GetScene()
	local cam = GetCamera()
	cam.SetFOV(44 * (math.pi / 180)) -- deg2rad

	LoadModel(sponza_path)
	local emitter = scene.Entity_FindByName("editorEmitter")
	if emitter ~= INVALID_ENTITY then
		scene.Entity_Remove(emitter)
	end

	-- set up a 3D render path, so if you load a model it will be displayed
	local renderpath = RenderPath3D()
	SetupGfx(renderpath)
	application.SetActivePath(renderpath, 1.0, 0, 0, 0, FadeType.CrossFade) -- 1 sec cross fade

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
		cam_transform.Rotate(Vector(diff.GetY(), diff.GetX()))

		-- WASD camera movement:
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

		-- Add some editor testing functionality to return to editor when ESC is pressed. This can help development, and only works if script is running from the Editor:
		if IsThisEditor() and input.Press(KEYBOARD_BUTTON_ESCAPE) then
			ReturnToEditor()
			input.ResetCursor(CURSOR_DEFAULT)
			return
		end
	end
end)

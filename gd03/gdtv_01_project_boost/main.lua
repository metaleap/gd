-- by running the script as a process, we can use engine events like update() in it to halt the script while the event doesn't arrive
runProcess(function()

	-- retrieve the global scene and camera objects that will be used for 3D rendering
	local scene = GetScene()
	local camera = GetCamera()

	-- load a sample model simply into the current global scene from an asset file:
	local cube_root_entity = LoadModel(script_dir() .. "/cube.wiscene")

	-- create a point light to be able to see the cube:
	local light_entity = CreateEntity()
	local light = scene.Component_CreateLight(light_entity)
	light.SetType(POINT)
	light.SetIntensity(10)
	local light_transform = scene.Component_CreateTransform(light_entity)
	light_transform.Translate(Vector(2,2,-2))

	-- put camera back a bit so we can see the cube in the origin (note that the camera is updated with this transform every frame when TransformCamera() is called):
	local cam_transform = TransformComponent()
	cam_transform.Translate(Vector(0, 2, -8))

	-- set up a 3D render path, so if you load a model it will be displayed
	local renderpath = RenderPath3D()
	application.SetActivePath(renderpath, 1.0, 0, 0, 0, FadeType.CrossFade) -- 1 sec cross fade

	-- set up a simple 2D text that will dynamically change every frame
	local counter = 0
	local font = SpriteFont()
	renderpath.AddFont(font)

	-- run an endless update loop, it will run until killProcesses() is called or the application exits
	while true do
		update() -- blocks this process until next update() is signaled from Wicked Engine

		local dt = getDeltaTime() -- get delta time (elapsed time since last update())

		-- every frame the text is positioned to the upper center of the screen and display the value of the frame counter
		font.SetText("Hello World! Current frame counter = " .. counter .. "\nCamera look: right mouse button\nMove camera: WASD\nMove object: arrows\nIf you run this script from Wicked Editor, ESCAPE will return to the editor.")
		font.SetSize(11) -- the true render size of the font (larger can increase memory usage, but improves appearance)
		font.SetScale(2) -- upscaling the font without increasing the true font resolution
		font.SetPos(Vector(GetScreenWidth() * 0.5, GetScreenHeight() * 0.25)) -- put to upper center of the screen
		font.SetAlign(WIFALIGN_CENTER, WIFALIGN_CENTER) -- horizontal and vertical text align

		-- Mouse look camera:
		if input.Down(MOUSE_BUTTON_RIGHT) then
			local mouse_movement = input.GetPointerDelta()
			mouse_movement = vector.Multiply(mouse_movement, dt * 0.1)
			cam_transform.Rotate(Vector(mouse_movement.GetY(), mouse_movement.GetX())) -- roll-pitch-yaw rotation
		end

		-- WASD camera movement:
		local camspeed = 10 * dt
		local camera_movement = Vector()
		if input.Down(string.byte('W')) then
			camera_movement = vector.Add(camera_movement, Vector(0,0,camspeed))
		end
		if input.Down(string.byte('S')) then
			camera_movement = vector.Add(camera_movement, Vector(0,0,-camspeed))
		end
		if input.Down(string.byte('A')) then
			camera_movement = vector.Add(camera_movement, Vector(-camspeed,0))
		end
		if input.Down(string.byte('D')) then
			camera_movement = vector.Add(camera_movement, Vector(camspeed,0))
		end
		camera_movement = vector.Rotate(camera_movement, cam_transform.Rotation_local) -- rotate the camera movement with camera orientation, so it's relative
		cam_transform.Translate(camera_movement)

		cam_transform.UpdateTransform() -- because cam_transform is not part of the scene system, but we created it just in the script, update it manually with UpdateTransform()
		camera.TransformCamera(cam_transform)
		camera.UpdateCamera()

		-- rotate the cube every frame by a bit with the amount of delta time since last frame:
		local cube_transform = scene.Component_GetTransform(cube_root_entity)
		cube_transform.Rotate(Vector(0, dt * math.pi, 0))

		-- arrows object movement:
		local movspeed = 10 * dt
		local object_movement = Vector()
		if input.Down(KEYBOARD_BUTTON_UP) then
			object_movement = vector.Add(object_movement, Vector(0,movspeed))
		end
		if input.Down(KEYBOARD_BUTTON_DOWN) then
			object_movement = vector.Add(object_movement, Vector(0,-movspeed))
		end
		if input.Down(KEYBOARD_BUTTON_LEFT) then
			object_movement = vector.Add(object_movement, Vector(-movspeed,0))
		end
		if input.Down(KEYBOARD_BUTTON_RIGHT) then
			object_movement = vector.Add(object_movement, Vector(movspeed,0))
		end
		object_movement = vector.Rotate(object_movement, cam_transform.Rotation_local) -- rotate the object movement with camera orientation, so it's relative
		cube_transform.Translate(object_movement)

		-- Add some editor testing functionality to return to editor when ESC is pressed. This can help development, and only works if script is running from the Editor:
		if IsThisEditor() and input.Press(KEYBOARD_BUTTON_ESCAPE) then
			ReturnToEditor()
			input.ResetCursor(CURSOR_DEFAULT)
			return
		end

		counter = counter + 1

	end

end)

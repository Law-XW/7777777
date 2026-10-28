local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Icons
pcall(function()
	Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function resolveIcon(name)
	if type(name) == "number" then return "rbxassetid://" .. name end
	if type(name) == "string" then
		if string.match(name, "^rbxassetid://") then return name end
		if string.match(name, "^%d+$") then return "rbxassetid://" .. name end
		local key = string.lower(name)
		if type(Icons) == "function" then
			local ok, data = pcall(Icons, key)
			if ok and type(data) == "table" then
				local id = data.id or data.Id or data[1]
				local size = data.imageRectSize or data.ImageRectSize or data[2]
				local offset = data.imageRectOffset or data.imageRectPosition or data.ImageRectOffset or data[3]
				if id then return "rbxassetid://" .. tostring(id), offset, size end
			end
		elseif type(Icons) == "table" then
			for _, set in { Icons["48px"], Icons["256px"], Icons } do
				if type(set) == "table" then
					local data = set[key]
					if type(data) == "table" and data[1] then
						return "rbxassetid://" .. tostring(data[1]), data[3], data[2]
					end
				end
			end
		end
	end
	return "rbxassetid://0"
end

local function toVector2(value)
	if typeof(value) == "Vector2" then return value end
	if type(value) == "table" then return Vector2.new(value[1] or value.X or 0, value[2] or value.Y or 0) end
	return Vector2.new(0, 0)
end

local function applyIcon(object, name)
	if not name then return end
	local image, offset, size = resolveIcon(name)
	object.Image = image
	if offset then object.ImageRectOffset = toVector2(offset) end
	if size then object.ImageRectSize = toVector2(size) end
end

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"
Library.Font = Enum.Font.Gotham
Library.FontMedium = Enum.Font.GothamMedium
Library.FontBold = Enum.Font.GothamBold
Library.Logo = ""

Library.Theme = {
	Background = Color3.fromRGB(8, 8, 10),
	Section = Color3.fromRGB(15, 15, 18),
	Element = Color3.fromRGB(24, 24, 28),
	ElementHover = Color3.fromRGB(33, 33, 38),
	Track = Color3.fromRGB(42, 42, 48),
	Accent = Color3.fromRGB(52, 168, 222),
	Text = Color3.fromRGB(232, 232, 236),
	SubText = Color3.fromRGB(128, 128, 138),
	Stroke = Color3.fromRGB(36, 36, 42),
	Danger = Color3.fromRGB(214, 80, 92),
}

local Theme = Library.Theme

local Defaults = {}
for key, value in pairs(Theme) do
	Defaults[key] = value
end

local function preset(overrides)
	local out = {}
	for key, value in pairs(Defaults) do
		out[key] = overrides[key] or value
	end
	return out
end

Library.ThemeOrder = { "Ocean", "Rose", "Emerald", "Amethyst", "Mono" }
Library.Themes = {
	Ocean = preset({}),
	Rose = preset({
		Accent = Color3.fromRGB(226, 92, 140),
		Background = Color3.fromRGB(12, 8, 10),
		Section = Color3.fromRGB(20, 14, 17),
		Element = Color3.fromRGB(30, 22, 26),
		ElementHover = Color3.fromRGB(40, 30, 35),
		Track = Color3.fromRGB(52, 40, 46),
		Stroke = Color3.fromRGB(44, 32, 38),
	}),
	Emerald = preset({
		Accent = Color3.fromRGB(60, 190, 130),
		Background = Color3.fromRGB(7, 10, 9),
		Section = Color3.fromRGB(13, 17, 15),
		Element = Color3.fromRGB(21, 27, 24),
		ElementHover = Color3.fromRGB(30, 38, 34),
		Track = Color3.fromRGB(38, 48, 43),
		Stroke = Color3.fromRGB(32, 42, 37),
	}),
	Amethyst = preset({
		Accent = Color3.fromRGB(150, 110, 235),
		Background = Color3.fromRGB(9, 8, 12),
		Section = Color3.fromRGB(16, 14, 21),
		Element = Color3.fromRGB(25, 22, 32),
		ElementHover = Color3.fromRGB(35, 31, 44),
		Track = Color3.fromRGB(46, 42, 58),
		Stroke = Color3.fromRGB(38, 34, 48),
	}),
	Mono = preset({
		Accent = Color3.fromRGB(220, 220, 225),
		Background = Color3.fromRGB(10, 10, 10),
		Section = Color3.fromRGB(17, 17, 17),
		Element = Color3.fromRGB(26, 26, 26),
		ElementHover = Color3.fromRGB(36, 36, 36),
		Track = Color3.fromRGB(48, 48, 48),
		Stroke = Color3.fromRGB(38, 38, 38),
	}),
}

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Registry = {}
local Themed = {
	BackgroundColor3 = true,
	TextColor3 = true,
	ImageColor3 = true,
	Color = true,
	ScrollBarImageColor3 = true,
	PlaceholderColor3 = true,
}

local Quint = Enum.EasingStyle.Quint
local Back = Enum.EasingStyle.Back

local function themeName(value)
	for key, color in pairs(Theme) do
		if color == value then
			return key
		end
	end
	return nil
end

local function make(class, props, children)
	local object = Instance.new(class)
	local parent = nil
	local themed = true
	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		elseif key == "NoTheme" then
			themed = not value
		else
			object[key] = value
		end
	end
	if themed then
		for key, value in pairs(props or {}) do
			if Themed[key] and typeof(value) == "Color3" then
				local name = themeName(value)
				if name then
					table.insert(Registry, { object, key, name })
				end
			end
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = object
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function animate(object, props, time, style, direction)
	local info = TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(object, info, props)
	tween:Play()
	return tween
end

local function findStroke(object)
	return object:FindFirstChildOfClass("UIStroke")
end

local function round(radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function outline(color, thickness)
	return make("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function inset(left, top, right, bottom)
	return make("UIPadding", {
		PaddingLeft = UDim.new(0, left),
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
	})
end

local function text(props)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.Font = props.Font or Library.FontMedium
	props.TextSize = props.TextSize or 12
	props.TextColor3 = props.TextColor3 or Theme.Text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return make("TextLabel", props)
end

local function glyph(parent, name, size, color)
	local image = make("ImageLabel", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageColor3 = color or Theme.SubText,
		Parent = parent,
	})
	applyIcon(image, name)
	return image
end

local function emblem(parent, size)
	local source = Library.Logo
	if source == nil or source == "" then
		return glyph(parent, "zap", size, Theme.Accent)
	end
	local image = make("ImageLabel", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Fit,
		Parent = parent,
	})
	local loaded = false
	if type(source) == "string" and getcustomasset and isfile then
		pcall(function()
			if isfile(source) then
				image.Image = getcustomasset(source)
				loaded = true
			end
		end)
	end
	if not loaded then
		applyIcon(image, source)
	end
	return image
end

local function fire(callback, ...)
	if type(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function nextOrder(container)
	local value = (container:GetAttribute("order") or 0) + 1
	container:SetAttribute("order", value)
	return value
end

local function guiParent()
	if gethui then
		local ok, hidden = pcall(gethui)
		if ok and hidden then
			return hidden
		end
	end
	local ok, core = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and core then
		return core
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function encode(value)
	if typeof(value) == "Color3" then
		return { __color = value:ToHex() }
	end
	return value
end

local function decode(value)
	if type(value) == "table" and value.__color then
		return Color3.fromHex(value.__color)
	end
	return value
end

function Window:Bind(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function Window:Dragger(frame, onmove)
	frame.InputBegan:Connect(function(input)
		if isPointer(input) then
			self.Drag = onmove
			onmove(input.Position)
		end
	end)
end

local function buildElements(window, container, tab, popup)
	local api = {}

	local function newRow(height, name, clip)
		local row = make("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = clip == true,
			LayoutOrder = nextOrder(container),
			Parent = container,
		})
		if name and not popup then
			table.insert(window.Searchable, { Row = row, Name = tostring(name), Tab = tab })
		end
		return row
	end

	local function register(opts, object)
		if opts.Flag then
			window.Flags[opts.Flag] = object
		end
		return object
	end

	local function hitbox(row)
		return make("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 2,
			Parent = row,
		})
	end

	local function field(parent, y, height)
		return make("Frame", {
			Size = UDim2.new(1, -2, 0, height),
			Position = UDim2.fromOffset(1, y),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Parent = parent,
		}, { round(5), outline(Theme.Stroke, 1) })
	end

	local function swatch(row, default, callback)
		local color = default or Color3.new(1, 1, 1)
		local button = make("TextButton", {
			Size = UDim2.fromOffset(30, 14),
			Position = UDim2.new(1, -31, 0.5, -7),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
			NoTheme = true,
			Parent = row,
		}, { round(4), outline(Theme.Track, 1) })
		local ring = findStroke(button)
		local object = {}
		function object:Get()
			return color
		end
		function object:Set(value, silent)
			color = value
			button.BackgroundColor3 = value
			if not silent then
				fire(callback, value)
			end
		end
		button.MouseEnter:Connect(function()
			animate(ring, { Color = Theme.Accent }, 0.12)
		end)
		button.MouseLeave:Connect(function()
			animate(ring, { Color = Theme.Track }, 0.12)
		end)
		button.MouseButton1Click:Connect(function()
			window:OpenPicker(button, color, function(value)
				object:Set(value)
			end)
		end)
		return object
	end

	function api:AddLabel(content)
		local label = text({
			Text = content or "",
			TextColor3 = Theme.SubText,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = nextOrder(container),
			Parent = container,
		})
		local object = {}
		function object:Set(value)
			label.Text = tostring(value)
		end
		return object
	end

	function api:AddDivider()
		local row = newRow(1)
		make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Stroke,
			BorderSizePixel = 0,
			Parent = row,
		})
	end

	function api:AddButton(opts)
		opts = opts or {}
		local row = newRow(28, opts.Name or "Button")
		local button = make("TextButton", {
			Size = UDim2.new(1, -2, 1, 0),
			Position = UDim2.fromOffset(1, 0),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Text = opts.Name or "Button",
			Font = Library.FontMedium,
			TextSize = 12,
			TextColor3 = Theme.Text,
			AutoButtonColor = false,
			Parent = row,
		}, { round(5), outline(Theme.Stroke, 1) })
		local ring = findStroke(button)
		button.MouseEnter:Connect(function()
			animate(button, { BackgroundColor3 = Theme.ElementHover }, 0.12)
			animate(ring, { Color = Theme.Track }, 0.12)
		end)
		button.MouseLeave:Connect(function()
			animate(button, { BackgroundColor3 = Theme.Element }, 0.15)
			animate(ring, { Color = Theme.Stroke }, 0.15)
		end)
		button.MouseButton1Click:Connect(function()
			button.BackgroundColor3 = Theme.Accent
			animate(button, { BackgroundColor3 = Theme.Element }, 0.4, Quint)
			fire(opts.Callback)
		end)
		local object = {}
		function object:SetText(value)
			button.Text = tostring(value)
		end
		return object
	end

	function api:AddToggle(opts)
		opts = opts or {}
		local state = opts.Default == true
		local row = newRow(24, opts.Name or "Toggle")
		local hit = hitbox(row)
		local box = make("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0, 1, 0.5, -8),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Parent = row,
		}, { round(4), outline(Theme.Track, 1) })
		local boxStroke = findStroke(box)
		local check = glyph(box, "check", 10, Theme.Background)
		check.AnchorPoint = Vector2.new(0.5, 0.5)
		check.Position = UDim2.fromScale(0.5, 0.5)
		check.Size = UDim2.fromOffset(4, 4)
		check.ImageTransparency = 1
		local label = text({
			Text = opts.Name or "Toggle",
			Size = UDim2.new(1, -28, 1, 0),
			Position = UDim2.fromOffset(26, 0),
			Parent = row,
		})

		local picker
		if opts.Color then
			picker = swatch(row, opts.Color, opts.ColorCallback)
			label.Size = UDim2.new(1, -66, 1, 0)
			if opts.ColorFlag then
				window.Flags[opts.ColorFlag] = picker
			end
		end

		local function render(withTween)
			local boxColor = state and Theme.Accent or Theme.Element
			local strokeColor = state and Theme.Accent or Theme.Track
			local textColor = state and Theme.Text or Theme.SubText
			local alpha = state and 0 or 1
			local px = state and 10 or 4
			if withTween then
				animate(box, { BackgroundColor3 = boxColor }, 0.15)
				animate(boxStroke, { Color = strokeColor }, 0.15)
				animate(check, { ImageTransparency = alpha }, 0.12)
				animate(check, { Size = UDim2.fromOffset(px, px) }, 0.22, Back)
				animate(label, { TextColor3 = textColor }, 0.15)
			else
				box.BackgroundColor3 = boxColor
				boxStroke.Color = strokeColor
				check.ImageTransparency = alpha
				check.Size = UDim2.fromOffset(px, px)
				label.TextColor3 = textColor
			end
		end

		local object = {}
		local settings
		function object:Set(value, silent)
			state = value and true or false
			render(true)
			if not silent then
				fire(opts.Callback, state)
			end
		end
		function object:Get()
			return state
		end
		function object:GetColor()
			return picker and picker:Get()
		end
		function object:SetColor(value, silent)
			if picker then
				picker:Set(value, silent)
			end
		end
		function object:AddSettings(sopts)
			sopts = sopts or {}
			if settings then
				return settings.Api
			end
			local gear = make("TextButton", {
				Size = UDim2.fromOffset(18, 18),
				Position = UDim2.new(1, picker and -53 or -20, 0.5, -9),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 3,
				Parent = row,
			})
			local gearIcon = glyph(gear, "settings", 14, Theme.SubText)
			gearIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			gearIcon.Position = UDim2.fromScale(0.5, 0.5)
			label.Size = UDim2.new(1, picker and -84 or -50, 1, 0)
			settings = window:CreatePopup(sopts.Width or 220, sopts.Title or ((opts.Name or "Toggle") .. " Settings"))
			settings.Api = buildElements(window, settings.Panel, nil, true)
			settings.OnState = function(open)
				animate(gearIcon, { Rotation = open and 90 or 0, ImageColor3 = open and Theme.Accent or Theme.SubText }, 0.25, Quint)
			end
			gear.MouseEnter:Connect(function()
				if not settings.IsOpen then
					animate(gearIcon, { ImageColor3 = Theme.Text, Rotation = 45 }, 0.2, Quint)
				end
			end)
			gear.MouseLeave:Connect(function()
				if not settings.IsOpen then
					animate(gearIcon, { ImageColor3 = Theme.SubText, Rotation = 0 }, 0.2, Quint)
				end
			end)
			gear.MouseButton1Click:Connect(function()
				if settings.IsOpen then
					settings.Close()
				else
					settings.Open(gear)
				end
			end)
			return settings.Api
		end
		hit.MouseButton1Click:Connect(function()
			object:Set(not state)
		end)
		table.insert(window.Refreshers, function()
			render(false)
		end)
		render(false)
		return register(opts, object)
	end

	function api:AddColorPicker(opts)
		opts = opts or {}
		local row = newRow(24, opts.Name or "Color")
		text({
			Text = opts.Name or "Color",
			TextColor3 = Theme.SubText,
			Size = UDim2.new(1, -40, 1, 0),
			Parent = row,
		})
		local object = swatch(row, opts.Default, opts.Callback)
		return register(opts, object)
	end

	function api:AddSlider(opts)
		opts = opts or {}
		local min = opts.Min or 0
		local max = opts.Max or 100
		local step = opts.Increment or 1
		local suffix = opts.Suffix or ""
		local value = math.clamp(opts.Default or min, min, max)
		local row = newRow(36, opts.Name or "Slider")
		text({
			Text = opts.Name or "Slider",
			TextColor3 = Theme.SubText,
			Size = UDim2.new(1, -70, 0, 16),
			Parent = row,
		})
		local readout = text({
			Size = UDim2.new(0, 70, 0, 16),
			Position = UDim2.new(1, -70, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})
		local track = make("Frame", {
			Size = UDim2.new(1, -2, 0, 6),
			Position = UDim2.fromOffset(1, 24),
			BackgroundColor3 = Theme.Track,
			BorderSizePixel = 0,
			Parent = row,
		}, { round(3) })
		local fill = make("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Parent = track,
		}, { round(3) })
		local hit = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.fromOffset(0, 14),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 2,
			Parent = row,
		})
		local function render()
			local alpha = max == min and 0 or (value - min) / (max - min)
			fill.Size = UDim2.fromScale(alpha, 1)
			readout.Text = tostring(value) .. suffix
		end
		local object = {}
		function object:Get()
			return value
		end
		function object:Set(v, silent)
			v = math.clamp(math.floor(((tonumber(v) or min) - min) / step + 0.5) * step + min, min, max)
			value = tonumber(string.format("%.4f", v))
			render()
			if not silent then
				fire(opts.Callback, value)
			end
		end
		window:Dragger(hit, function(pos)
			local alpha = math.clamp((pos.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			object:Set(min + (max - min) * alpha)
		end)
		render()
		return register(opts, object)
	end

	function api:AddDropdown(opts)
		opts = opts or {}
		local items = opts.Options or {}
		local multi = opts.Multi == true
		local selected = {}
		local value
		local buttons = {}
		local open = false
		if multi then
			for _, item in ipairs(opts.Default or {}) do
				selected[item] = true
			end
		else
			value = opts.Default
		end
		local row = newRow(26, opts.Name or "Dropdown", true)
		local head = make("TextButton", {
			Size = UDim2.new(1, -2, 0, 26),
			Position = UDim2.fromOffset(1, 0),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 2,
			Parent = row,
		}, { round(5), outline(Theme.Stroke, 1) })
		local title = text({
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.fromOffset(8, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = head,
		})
		local arrow = glyph(head, "chevron-down", 14, Theme.SubText)
		arrow.AnchorPoint = Vector2.new(0.5, 0.5)
		arrow.Position = UDim2.new(1, -14, 0.5, 0)
		local list = make("ScrollingFrame", {
			Position = UDim2.fromOffset(1, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Track,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = row,
		}, { make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }) })

		local function listHeight()
			return math.min(#items, 6) * 24
		end

		local function current()
			if multi then
				local out = {}
				for _, item in ipairs(items) do
					if selected[item] then
						table.insert(out, item)
					end
				end
				return out
			end
			return value
		end

		local function render()
			if multi then
				local chosen = current()
				title.Text = (opts.Name and (opts.Name .. ": ") or "") .. (#chosen > 0 and table.concat(chosen, ", ") or "None")
			else
				title.Text = (opts.Name and (opts.Name .. ": ") or "") .. (value ~= nil and tostring(value) or "None")
			end
			for item, button in pairs(buttons) do
				local on = multi and selected[item] or (not multi and value == item)
				animate(button, { TextColor3 = on and Theme.Accent or Theme.SubText }, 0.12)
			end
		end

		local function setOpen(state)
			open = state
			list.Size = UDim2.new(1, -2, 0, listHeight())
			animate(row, { Size = UDim2.new(1, 0, 0, state and (30 + listHeight()) or 26) }, 0.2, Quint)
			animate(arrow, { Rotation = state and 180 or 0 }, 0.2, Quint)
		end

		local object = {}
		local function build()
			for _, button in pairs(buttons) do
				button:Destroy()
			end
			buttons = {}
			for index, item in ipairs(items) do
				local button = make("TextButton", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					Text = tostring(item),
					Font = Library.FontMedium,
					TextSize = 12,
					TextColor3 = Theme.SubText,
					AutoButtonColor = false,
					LayoutOrder = index,
					Parent = list,
				}, { round(4) })
				buttons[item] = button
				button.MouseButton1Click:Connect(function()
					if multi then
						selected[item] = not selected[item] or nil
					else
						value = item
						setOpen(false)
					end
					render()
					fire(opts.Callback, current())
				end)
			end
			render()
			if open then
				setOpen(true)
			end
		end

		function object:Get()
			return current()
		end
		function object:Set(v, silent)
			if multi then
				selected = {}
				for _, item in ipairs(type(v) == "table" and v or {}) do
					selected[item] = true
				end
			else
				value = v
			end
			render()
			if not silent then
				fire(opts.Callback, current())
			end
		end
		function object:Refresh(newItems)
			items = newItems or {}
			build()
		end
		head.MouseButton1Click:Connect(function()
			setOpen(not open)
		end)
		list.Size = UDim2.new(1, -2, 0, listHeight())
		build()
		return register(opts, object)
	end

	function api:AddTextbox(opts)
		opts = opts or {}
		local row = newRow(26, opts.Name or "Textbox")
		local frame = field(row, 0, 26)
		local box = make("TextBox", {
			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.fromOffset(6, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or opts.Name or "",
			PlaceholderColor3 = Theme.SubText,
			TextColor3 = Theme.Text,
			Font = Library.FontMedium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = frame,
		})
		box.FocusLost:Connect(function()
			fire(opts.Callback, box.Text)
		end)
		local object = {}
		function object:Get()
			return box.Text
		end
		function object:Set(value, silent)
			box.Text = tostring(value)
			if not silent then
				fire(opts.Callback, box.Text)
			end
		end
		return register(opts, object)
	end

	return api
end

function Window:CreatePopup(width, title)
	local popup = { IsOpen = false }
	local frame = make("Frame", {
		Size = UDim2.fromOffset(width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 50,
		Parent = self.Gui,
	}, {
		round(6),
		outline(Theme.Track, 1),
		inset(10, 8, 10, 10),
		make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
	})
	text({
		Text = title or "",
		Font = Library.FontBold,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 0,
		Parent = frame,
	})
	popup.Panel = frame
	popup.Frame = frame
	function popup.Open(anchor)
		for _, other in ipairs(self.Popups) do
			if other ~= popup and other.IsOpen then
				other.Close()
			end
		end
		local origin = anchor.AbsolutePosition - self.Gui.AbsolutePosition
		local viewport = self.Gui.AbsoluteSize
		local x = math.clamp(origin.X + anchor.AbsoluteSize.X - width, 6, math.max(6, viewport.X - width - 6))
		local y = math.min(origin.Y + anchor.AbsoluteSize.Y + 6, math.max(6, viewport.Y - 160))
		frame.Position = UDim2.fromOffset(x, y)
		frame.Visible = true
		popup.IsOpen = true
		if popup.OnState then
			popup.OnState(true)
		end
	end
	function popup.Close()
		frame.Visible = false
		popup.IsOpen = false
		if popup.OnState then
			popup.OnState(false)
		end
	end
	table.insert(self.Popups, popup)
	return popup
end

function Window:ClosePopups()
	for _, popup in ipairs(self.Popups) do
		if popup.IsOpen then
			popup.Close()
		end
	end
end

function Window:OpenPicker(anchor, color, callback)
	local picker = self.Picker
	if not picker then
		picker = { h = 0, s = 0, v = 1 }
		picker.Pop = self:CreatePopup(190, "Color")
		local panel = picker.Pop.Panel
		local area = make("Frame", {
			Size = UDim2.new(1, 0, 0, 110),
			BackgroundColor3 = Color3.new(1, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = 1,
			NoTheme = true,
			Parent = panel,
		}, { round(4) })
		make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			NoTheme = true,
			Parent = area,
		}, { round(4), make("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
		make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			NoTheme = true,
			Parent = area,
		}, { round(4), make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
		local cursor = make("Frame", {
			Size = UDim2.fromOffset(10, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 3,
			NoTheme = true,
			Parent = area,
		}, { round(5), make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })
		local areaHit = make("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 4,
			Parent = area,
		})
		local stops = {}
		for i = 0, 6 do
			table.insert(stops, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
		end
		local hue = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 2,
			NoTheme = true,
			Parent = panel,
		}, { round(4), make("UIGradient", { Color = ColorSequence.new(stops) }) })
		local hueCursor = make("Frame", {
			Size = UDim2.fromOffset(4, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			NoTheme = true,
			Parent = hue,
		}, { round(2), make("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }) })
		function picker.Update(notify)
			area.BackgroundColor3 = Color3.fromHSV(picker.h, 1, 1)
			cursor.Position = UDim2.fromScale(picker.s, 1 - picker.v)
			hueCursor.Position = UDim2.fromScale(picker.h, 0.5)
			if notify and picker.Callback then
				picker.Callback(Color3.fromHSV(picker.h, picker.s, picker.v))
			end
		end
		self:Dragger(areaHit, function(pos)
			picker.s = math.clamp((pos.X - area.AbsolutePosition.X) / math.max(area.AbsoluteSize.X, 1), 0, 1)
			picker.v = 1 - math.clamp((pos.Y - area.AbsolutePosition.Y) / math.max(area.AbsoluteSize.Y, 1), 0, 1)
			picker.Update(true)
		end)
		self:Dragger(hue, function(pos)
			picker.h = math.clamp((pos.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 0.999)
			picker.Update(true)
		end)
		self.Picker = picker
	end
	if picker.Pop.IsOpen and picker.Anchor == anchor then
		picker.Pop.Close()
		return
	end
	picker.Anchor = anchor
	picker.Callback = callback
	picker.h, picker.s, picker.v = color:ToHSV()
	picker.Update(false)
	picker.Pop.Open(anchor)
end

function Tab:Render()
	local active = self.Window.Current == self
	self.Page.Visible = active
	animate(self.Button, { BackgroundTransparency = active and 0 or 1 }, 0.15)
	animate(self.Label, { TextColor3 = active and Theme.Text or Theme.SubText }, 0.15)
	animate(self.Icon, { ImageColor3 = active and Theme.Accent or Theme.SubText }, 0.15)
end

function Tab:AddSection(name)
	local holder = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self.Page),
		Parent = self.Page,
	}, {
		round(6),
		outline(Theme.Stroke, 1),
		inset(10, 8, 10, 10),
		make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
	})
	text({
		Text = string.upper(name or ""),
		TextColor3 = Theme.SubText,
		Font = Library.FontBold,
		TextSize = 10,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 0,
		Parent = holder,
	})
	return buildElements(self.Window, holder, self, false)
end

function Window:SelectTab(tab)
	self:ClosePopups()
	self.Current = tab
	for _, other in ipairs(self.Tabs) do
		other:Render()
	end
end

function Window:AddTab(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local tab = setmetatable({ Name = opts.Name or "Tab", Window = self }, Tab)
	tab.Button = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabList,
	}, { round(5) })
	tab.Icon = glyph(tab.Button, opts.Icon or "circle", 14, Theme.SubText)
	tab.Icon.Position = UDim2.fromOffset(8, 7)
	tab.Label = text({
		Text = tab.Name,
		TextColor3 = Theme.SubText,
		Size = UDim2.new(1, -32, 1, 0),
		Position = UDim2.fromOffset(28, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = tab.Button,
	})
	tab.Page = make("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Track,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.Content,
	}, {
		make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
		inset(12, 12, 12, 12),
	})
	local api = buildElements(self, tab.Page, tab, false)
	for key, fn in pairs(api) do
		tab[key] = fn
	end
	tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)
	table.insert(self.Tabs, tab)
	table.insert(self.Refreshers, function()
		tab:Render()
	end)
	if not self.Current then
		self:SelectTab(tab)
	else
		tab:Render()
	end
	return tab
end

function Window:Toggle(value)
	if value == nil then
		value = not self.Main.Visible
	end
	self.Main.Visible = value
	if not value then
		self:ClosePopups()
	end
end

function Window:Notify(opts)
	if type(opts) == "string" then
		opts = { Content = opts }
	end
	opts = opts or {}
	local card = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Parent = self.Notes,
	}, {
		round(6),
		outline(Theme.Accent, 1),
		inset(10, 8, 10, 8),
		make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
	})
	text({
		Text = opts.Title or "Library",
		Font = Library.FontBold,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})
	text({
		Text = opts.Content or "",
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = card,
	})
	task.delay(opts.Duration or 4, function()
		if card.Parent then
			card:Destroy()
		end
	end)
end

function Window:SetTheme(name)
	local set = Library.Themes[name]
	if not set then
		return
	end
	for key, value in pairs(set) do
		Theme[key] = value
	end
	for _, entry in ipairs(Registry) do
		pcall(function()
			entry[1][entry[2]] = Theme[entry[3]]
		end)
	end
	for _, refresh in ipairs(self.Refreshers) do
		pcall(refresh)
	end
end

function Window:ExportConfig()
	local data = {}
	for name, object in pairs(self.Flags) do
		local ok, value = pcall(object.Get, object)
		if ok then
			data[name] = encode(value)
		end
	end
	return HttpService:JSONEncode(data)
end

function Window:ImportConfig(json)
	local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
	if not ok or type(data) ~= "table" then
		return false
	end
	for name, value in pairs(data) do
		local object = self.Flags[name]
		if object then
			pcall(object.Set, object, decode(value))
		end
	end
	return true
end

function Window:SaveConfig(name)
	if writefile then
		pcall(writefile, (name or "LibraryConfig") .. ".json", self:ExportConfig())
	end
end

function Window:LoadConfig(name)
	local file = (name or "LibraryConfig") .. ".json"
	if readfile and isfile and isfile(file) then
		return self:ImportConfig(readfile(file))
	end
	return false
end

function Window:Destroy()
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	self.Gui:Destroy()
end

function Library:CreateWindow(opts)
	opts = opts or {}
	local self = setmetatable({
		Connections = {},
		Searchable = {},
		Refreshers = {},
		Flags = {},
		Tabs = {},
		Popups = {},
	}, Window)

	local size = typeof(opts.Size) == "Vector2" and opts.Size or Vector2.new(580, 380)

	local gui = make("ScreenGui", {
		Name = "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Parent = guiParent(),
	})
	self.Gui = gui

	local main = make("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(size.X, size.Y),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	}, { round(8), outline(Theme.Stroke, 1) })
	self.Main = main

	local scale = make("UIScale", { Parent = main })
	local function fit()
		local viewport = gui.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then
			return
		end
		scale.Scale = math.clamp(math.min((viewport.X - 20) / size.X, (viewport.Y - 20) / size.Y), 0.5, 1)
	end
	fit()
	self:Bind(gui:GetPropertyChangedSignal("AbsoluteSize"), fit)

	local top = make("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Parent = main,
	})
	local mark = emblem(top, 16)
	mark.Position = UDim2.fromOffset(12, 10)
	text({
		Text = opts.Title or "Library",
		Font = Library.FontBold,
		TextSize = 13,
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.fromOffset(34, 0),
		Parent = top,
	})
	text({
		Text = tostring(opts.Version or Library.Version),
		TextColor3 = Theme.SubText,
		TextSize = 10,
		Size = UDim2.new(0, 60, 1, 0),
		Position = UDim2.new(1, -100, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = top,
	})
	local close = make("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -32, 0, 4),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = top,
	})
	local closeIcon = glyph(close, "x", 14, Theme.SubText)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Position = UDim2.fromScale(0.5, 0.5)
	close.MouseEnter:Connect(function()
		animate(closeIcon, { ImageColor3 = Theme.Danger }, 0.12)
	end)
	close.MouseLeave:Connect(function()
		animate(closeIcon, { ImageColor3 = Theme.SubText }, 0.12)
	end)
	close.MouseButton1Click:Connect(function()
		self:Toggle(false)
	end)
	make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = top,
	})

	top.InputBegan:Connect(function(input)
		if isPointer(input) then
			local start, origin = input.Position, main.Position
			self.Drag = function(pos)
				local delta = pos - start
				main.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
			end
		end
	end)

	local sidebar = make("Frame", {
		Size = UDim2.new(0, 150, 1, -36),
		Position = UDim2.fromOffset(0, 36),
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Parent = main,
	})
	local searchFrame = make("Frame", {
		Size = UDim2.new(1, -16, 0, 26),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { round(5), outline(Theme.Stroke, 1) })
	local searchIcon = glyph(searchFrame, "search", 12, Theme.SubText)
	searchIcon.Position = UDim2.fromOffset(7, 7)
	local searchBox = make("TextBox", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.fromOffset(24, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.SubText,
		TextColor3 = Theme.Text,
		Font = Library.FontMedium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchFrame,
	})
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchBox.Text)
		for _, entry in ipairs(self.Searchable) do
			entry.Row.Visible = query == "" or string.find(string.lower(entry.Name), query, 1, true) ~= nil
		end
	end)
	self.TabList = make("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -42),
		Position = UDim2.fromOffset(0, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, {
		make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
		inset(8, 0, 8, 8),
	})
	make("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	self.Content = make("Frame", {
		Size = UDim2.new(1, -150, 1, -36),
		Position = UDim2.fromOffset(150, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = main,
	})

	self.Notes = make("Frame", {
		Size = UDim2.fromOffset(240, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		BackgroundTransparency = 1,
		ZIndex = 100,
		Parent = gui,
	}, { make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }) })

	local floating = make("TextButton", {
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromOffset(10, 70),
		BackgroundColor3 = Theme.Section,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 60,
		Parent = gui,
	}, { round(8), outline(Theme.Stroke, 1) })
	local floatMark = emblem(floating, 18)
	floatMark.AnchorPoint = Vector2.new(0.5, 0.5)
	floatMark.Position = UDim2.fromScale(0.5, 0.5)
	floating.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	self:Bind(UserInputService.InputChanged, function(input)
		if self.Drag and isMove(input) then
			self.Drag(input.Position)
		end
	end)
	self:Bind(UserInputService.InputEnded, function(input)
		if isPointer(input) then
			self.Drag = nil
		end
	end)

	return self
end

Library.new = function(opts)
	return Library:CreateWindow(opts)
end

return Library

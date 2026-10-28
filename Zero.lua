local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local Lucide
pcall(function()
	Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function ResolveIcon(Icon)
	if type(Icon) == "number" then return "rbxassetid://" .. Icon end
	if type(Icon) == "string" then
		if string.match(Icon, "^rbxassetid://") then return Icon end
		if string.match(Icon, "^%d+$") then return "rbxassetid://" .. Icon end
		local Name = string.lower(Icon)
		if type(Lucide) == "function" then
			local ok, Data = pcall(Lucide, Name)
			if ok and type(Data) == "table" then
				local Id = Data.id or Data.Id or Data[1]
				local Size = Data.imageRectSize or Data.ImageRectSize or Data[2]
				local Offset = Data.imageRectOffset or Data.imageRectPosition or Data.ImageRectOffset or Data[3]
				if Id then return "rbxassetid://" .. tostring(Id), Offset, Size end
			end
		elseif type(Lucide) == "table" then
			for _, Set in { Lucide["48px"], Lucide["256px"], Lucide } do
				if type(Set) == "table" then
					local Data = Set[Name]
					if type(Data) == "table" and Data[1] then
						return "rbxassetid://" .. tostring(Data[1]), Data[3], Data[2]
					end
				end
			end
		end
	end
	return "rbxassetid://0"
end

local function ToVector2(Value)
	if typeof(Value) == "Vector2" then return Value end
	if type(Value) == "table" then return Vector2.new(Value[1] or Value.X or 0, Value[2] or Value.Y or 0) end
	return Vector2.new(0, 0)
end

local function ApplyIcon(Object, Icon)
	if not Icon then return end
	local Image, Offset, Size = ResolveIcon(Icon)
	Object.Image = Image
	if Offset then Object.ImageRectOffset = ToVector2(Offset) end
	if Size then Object.ImageRectSize = ToVector2(Size) end
end

local Zero = {}
Zero.__index = Zero
Zero.Version = "1.6.0"
Zero.Font = Enum.Font.Gotham
Zero.FontMedium = Enum.Font.GothamMedium
Zero.FontBold = Enum.Font.GothamBold
Zero.Logo = ""

Zero.Theme = {
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

local T = Zero.Theme

local Base = {}
for key, value in pairs(T) do
	Base[key] = value
end

local function preset(over)
	local out = {}
	for key, value in pairs(Base) do
		out[key] = over[key] or value
	end
	return out
end

Zero.ThemeOrder = { "Ocean", "Rose", "Emerald", "Amethyst", "Mono" }
Zero.Themes = {
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
local ThemedProps = {
	BackgroundColor3 = true,
	TextColor3 = true,
	ImageColor3 = true,
	Color = true,
	ScrollBarImageColor3 = true,
	PlaceholderColor3 = true,
}

local Quint = Enum.EasingStyle.Quint
local Back = Enum.EasingStyle.Back

local function themeKey(value)
	for key, color in pairs(T) do
		if color == value then
			return key
		end
	end
	return nil
end

local function create(class, props, children)
	local obj = Instance.new(class)
	local parent = nil
	local themed = true
	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		elseif key == "NoTheme" then
			themed = not value
		else
			obj[key] = value
		end
	end
	if themed then
		for key, value in pairs(props or {}) do
			if ThemedProps[key] and typeof(value) == "Color3" then
				local name = themeKey(value)
				if name then
					table.insert(Registry, { obj, key, name })
				end
			end
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = obj
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function tween(obj, props, time, style, dir)
	local info = TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function getStroke(obj)
	return obj:FindFirstChildOfClass("UIStroke")
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness)
	return create("UIStroke", {
		Color = color or T.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(left, top, right, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left),
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
	})
end

local function label(props)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.Font = props.Font or Zero.FontMedium
	props.TextSize = props.TextSize or 12
	props.TextColor3 = props.TextColor3 or T.Text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return create("TextLabel", props)
end

local function icon(parent, name, size, color)
	local img = create("ImageLabel", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageColor3 = color or T.SubText,
		Parent = parent,
	})
	ApplyIcon(img, name)
	return img
end

local function logo(parent, size)
	local source = Zero.Logo
	if source == nil or source == "" then
		return icon(parent, "zap", size, T.Accent)
	end
	local img = create("ImageLabel", {
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
				img.Image = getcustomasset(source)
				loaded = true
			end
		end)
	end
	if not loaded then
		ApplyIcon(img, source)
	end
	return img
end

local function safe(callback, ...)
	if type(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function nextOrder(container)
	local n = (container:GetAttribute("order") or 0) + 1
	container:SetAttribute("order", n)
	return n
end

local function getGuiParent()
	if gethui then
		local ok, ui = pcall(gethui)
		if ok and ui then
			return ui
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
		local row = create("Frame", {
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

	local function flag(opts, obj)
		if opts.Flag then
			window.Flags[opts.Flag] = obj
		end
		return obj
	end

	local function hitbox(row)
		return create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 2,
			Parent = row,
		})
	end

	local function field(parent, y, height)
		return create("Frame", {
			Size = UDim2.new(1, -2, 0, height),
			Position = UDim2.fromOffset(1, y),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Parent = parent,
		}, { corner(5), stroke(T.Stroke, 1) })
	end

	local function makeSwatch(row, default, callback)
		local color = default or Color3.new(1, 1, 1)
		local button = create("TextButton", {
			Size = UDim2.fromOffset(30, 14),
			Position = UDim2.new(1, -31, 0.5, -7),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
			NoTheme = true,
			Parent = row,
		}, { corner(4), stroke(T.Track, 1) })
		local ring = getStroke(button)
		local obj = {}
		function obj:Get()
			return color
		end
		function obj:Set(value, silent)
			color = value
			button.BackgroundColor3 = value
			if not silent then
				safe(callback, value)
			end
		end
		button.MouseEnter:Connect(function()
			tween(ring, { Color = T.Accent }, 0.12)
		end)
		button.MouseLeave:Connect(function()
			tween(ring, { Color = T.Track }, 0.12)
		end)
		button.MouseButton1Click:Connect(function()
			window:OpenPicker(button, color, function(value)
				obj:Set(value)
			end)
		end)
		return obj
	end

	function api:AddLabel(text)
		local lbl = label({
			Text = text or "",
			TextColor3 = T.SubText,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = nextOrder(container),
			Parent = container,
		})
		local obj = {}
		function obj:Set(value)
			lbl.Text = tostring(value)
		end
		return obj
	end

	function api:AddDivider()
		local row = newRow(1)
		create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = T.Stroke,
			BorderSizePixel = 0,
			Parent = row,
		})
	end

	function api:AddButton(opts)
		opts = opts or {}
		local row = newRow(28, opts.Name or "Button")
		local btn = create("TextButton", {
			Size = UDim2.new(1, -2, 1, 0),
			Position = UDim2.fromOffset(1, 0),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Text = opts.Name or "Button",
			Font = Zero.FontMedium,
			TextSize = 12,
			TextColor3 = T.Text,
			AutoButtonColor = false,
			Parent = row,
		}, { corner(5), stroke(T.Stroke, 1) })
		local ring = getStroke(btn)
		btn.MouseEnter:Connect(function()
			tween(btn, { BackgroundColor3 = T.ElementHover }, 0.12)
			tween(ring, { Color = T.Track }, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, { BackgroundColor3 = T.Element }, 0.15)
			tween(ring, { Color = T.Stroke }, 0.15)
		end)
		btn.MouseButton1Click:Connect(function()
			btn.BackgroundColor3 = T.Accent
			tween(btn, { BackgroundColor3 = T.Element }, 0.4, Quint)
			safe(opts.Callback)
		end)
		local obj = {}
		function obj:SetText(value)
			btn.Text = tostring(value)
		end
		return obj
	end

	function api:AddToggle(opts)
		opts = opts or {}
		local state = opts.Default == true
		local row = newRow(24, opts.Name or "Toggle")
		local hit = hitbox(row)
		local box = create("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0, 1, 0.5, -8),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Parent = row,
		}, { corner(4), stroke(T.Track, 1) })
		local boxStroke = getStroke(box)
		local check = icon(box, "check", 10, T.Background)
		check.AnchorPoint = Vector2.new(0.5, 0.5)
		check.Position = UDim2.fromScale(0.5, 0.5)
		check.Size = UDim2.fromOffset(4, 4)
		check.ImageTransparency = 1
		local lbl = label({
			Text = opts.Name or "Toggle",
			Size = UDim2.new(1, -28, 1, 0),
			Position = UDim2.fromOffset(26, 0),
			Parent = row,
		})

		local swatch
		if opts.Color then
			swatch = makeSwatch(row, opts.Color, opts.ColorCallback)
			lbl.Size = UDim2.new(1, -66, 1, 0)
			if opts.ColorFlag then
				window.Flags[opts.ColorFlag] = swatch
			end
		end

		local function render(animate)
			local boxColor = state and T.Accent or T.Element
			local strokeColor = state and T.Accent or T.Track
			local textColor = state and T.Text or T.SubText
			local alpha = state and 0 or 1
			local px = state and 10 or 4
			if animate then
				tween(box, { BackgroundColor3 = boxColor }, 0.15)
				tween(boxStroke, { Color = strokeColor }, 0.15)
				tween(check, { ImageTransparency = alpha }, 0.12)
				tween(check, { Size = UDim2.fromOffset(px, px) }, 0.22, Back)
				tween(lbl, { TextColor3 = textColor }, 0.15)
			else
				box.BackgroundColor3 = boxColor
				boxStroke.Color = strokeColor
				check.ImageTransparency = alpha
				check.Size = UDim2.fromOffset(px, px)
				lbl.TextColor3 = textColor
			end
		end

		local obj = {}
		local settings
		function obj:Set(value, silent)
			state = value and true or false
			render(true)
			if not silent then
				safe(opts.Callback, state)
			end
		end
		function obj:Get()
			return state
		end
		function obj:GetColor()
			return swatch and swatch:Get()
		end
		function obj:SetColor(value, silent)
			if swatch then
				swatch:Set(value, silent)
			end
		end
		function obj:AddSettings(sopts)
			sopts = sopts or {}
			if settings then
				return settings.Api
			end
			local gear = create("TextButton", {
				Size = UDim2.fromOffset(18, 18),
				Position = UDim2.new(1, swatch and -53 or -20, 0.5, -9),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 3,
				Parent = row,
			})
			local gearIcon = icon(gear, "settings", 14, T.SubText)
			gearIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			gearIcon.Position = UDim2.fromScale(0.5, 0.5)
			lbl.Size = UDim2.new(1, swatch and -84 or -50, 1, 0)
			settings = window:CreatePopup(sopts.Width or 220, sopts.Title or ((opts.Name or "Toggle") .. " Settings"))
			settings.Api = buildElements(window, settings.Panel, nil, true)
			settings.OnState = function(open)
				tween(gearIcon, { Rotation = open and 90 or 0, ImageColor3 = open and T.Accent or T.SubText }, 0.25, Quint)
			end
			gear.MouseEnter:Connect(function()
				if not settings.IsOpen then
					tween(gearIcon, { ImageColor3 = T.Text, Rotation = 45 }, 0.2, Quint)
				end
			end)
			gear.MouseLeave:Connect(function()
				if not settings.IsOpen then
					tween(gearIcon, { ImageColor3 = T.SubText, Rotation = 0 }, 0.2, Quint)
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
			obj:Set(not state)
		end)
		table.insert(window.Refreshers, function()
			render(false)
		end)
		render(false)
		return flag(opts, obj)
	end

	function api:AddColorPicker(opts)
		opts = opts or {}
		local row = newRow(24, opts.Name or "Color")
		label({
			Text = opts.Name or "Color",
			TextColor3 = T.SubText,
			Size = UDim2.new(1, -40, 1, 0),
			Parent = row,
		})
		local obj = makeSwatch(row, opts.Default, opts.Callback)
		return flag(opts, obj)
	end

	function api:AddKeybind(opts)
		opts = opts or {}
		local listening = false

		local function resolve(value)
			if typeof(value) == "EnumItem" then
				return value
			end
			if type(value) == "string" and value ~= "None" then
				local ok, found = pcall(function()
					return Enum.KeyCode[value]
				end)
				if ok then
					return found
				end
			end
			return nil
		end

		local key = resolve(opts.Default)
		local row = newRow(24, opts.Name or "Keybind")
		label({
			Text = opts.Name or "Keybind",
			TextColor3 = T.SubText,
			Size = UDim2.new(1, -80, 1, 0),
			Parent = row,
		})
		local button = create("TextButton", {
			Size = UDim2.fromOffset(70, 18),
			Position = UDim2.new(1, -71, 0.5, -9),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Text = "",
			Font = Zero.FontMedium,
			TextSize = 11,
			TextColor3 = T.SubText,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = row,
		}, { corner(4), stroke(T.Stroke, 1), padding(4, 0, 4, 0) })
		local ring = getStroke(button)

		local function render()
			button.Text = listening and "..." or (key and key.Name or "None")
			tween(button, { TextColor3 = listening and T.Accent or T.SubText }, 0.12)
			tween(ring, { Color = listening and T.Accent or T.Stroke }, 0.12)
			button.BackgroundColor3 = T.Element
		end

		local obj = {}
		function obj:Get()
			return key and key.Name or "None"
		end
		function obj:GetKey()
			return key
		end
		function obj:Set(value, silent)
			key = resolve(value)
			render()
			if not silent then
				safe(opts.ChangedCallback, key)
			end
		end

		button.MouseEnter:Connect(function()
			if not listening then
				tween(button, { BackgroundColor3 = T.ElementHover }, 0.12)
			end
		end)
		button.MouseLeave:Connect(function()
			tween(button, { BackgroundColor3 = T.Element }, 0.15)
		end)
		button.MouseButton1Click:Connect(function()
			listening = not listening
			window.Listening = listening
			render()
		end)

		window:Bind(UserInputService.InputBegan, function(input, processed)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					window.Listening = false
					if input.KeyCode == Enum.KeyCode.Escape then
						key = nil
					else
						key = input.KeyCode
					end
					render()
					safe(opts.ChangedCallback, key)
				end
				return
			end
			if not processed and key and input.KeyCode == key then
				safe(opts.Callback, key)
			end
		end)

		table.insert(window.Refreshers, render)
		render()
		return flag(opts, obj)
	end

	function api:AddSlider(opts)
		opts = opts or {}
		local min = opts.Min or 0
		local max = opts.Max or 100
		local step = opts.Increment or 1
		local suffix = opts.Suffix or ""
		local value = math.clamp(opts.Default or min, min, max)
		local row = newRow(36, opts.Name or "Slider")
		label({
			Text = opts.Name or "Slider",
			TextColor3 = T.SubText,
			Size = UDim2.new(1, -70, 0, 16),
			Parent = row,
		})
		local valueLabel = label({
			Size = UDim2.new(0, 70, 0, 16),
			Position = UDim2.new(1, -70, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})
		local track = create("Frame", {
			Size = UDim2.new(1, -2, 0, 6),
			Position = UDim2.fromOffset(1, 24),
			BackgroundColor3 = T.Track,
			BorderSizePixel = 0,
			Parent = row,
		}, { corner(3) })
		local fill = create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Parent = track,
		}, { corner(3) })
		local hit = create("TextButton", {
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
			valueLabel.Text = tostring(value) .. suffix
		end
		local obj = {}
		function obj:Get()
			return value
		end
		function obj:Set(v, silent)
			v = math.clamp(math.floor(((tonumber(v) or min) - min) / step + 0.5) * step + min, min, max)
			value = tonumber(string.format("%.4f", v))
			render()
			if not silent then
				safe(opts.Callback, value)
			end
		end
		window:Dragger(hit, function(pos)
			local alpha = math.clamp((pos.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			obj:Set(min + (max - min) * alpha)
		end)
		render()
		return flag(opts, obj)
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
		local head = create("TextButton", {
			Size = UDim2.new(1, -2, 0, 26),
			Position = UDim2.fromOffset(1, 0),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 2,
			Parent = row,
		}, { corner(5), stroke(T.Stroke, 1) })
		local title = label({
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.fromOffset(8, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = head,
		})
		local arrow = icon(head, "chevron-down", 14, T.SubText)
		arrow.AnchorPoint = Vector2.new(0.5, 0.5)
		arrow.Position = UDim2.new(1, -14, 0.5, 0)
		local list = create("ScrollingFrame", {
			Position = UDim2.fromOffset(1, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = T.Track,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = row,
		}, { create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }) })

		local function listHeight()
			return math.min(#items, 6) * 24
		end

		local function getValue()
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
				local current = getValue()
				title.Text = (opts.Name and (opts.Name .. ": ") or "") .. (#current > 0 and table.concat(current, ", ") or "None")
			else
				title.Text = (opts.Name and (opts.Name .. ": ") or "") .. (value ~= nil and tostring(value) or "None")
			end
			for item, button in pairs(buttons) do
				local on = multi and selected[item] or (not multi and value == item)
				tween(button, { TextColor3 = on and T.Accent or T.SubText }, 0.12)
			end
		end

		local function setOpen(state)
			open = state
			list.Size = UDim2.new(1, -2, 0, listHeight())
			tween(row, { Size = UDim2.new(1, 0, 0, state and (30 + listHeight()) or 26) }, 0.2, Quint)
			tween(arrow, { Rotation = state and 180 or 0 }, 0.2, Quint)
		end

		local obj = {}
		local function build()
			for _, button in pairs(buttons) do
				button:Destroy()
			end
			buttons = {}
			for index, item in ipairs(items) do
				local button = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundColor3 = T.Element,
					BorderSizePixel = 0,
					Text = tostring(item),
					Font = Zero.FontMedium,
					TextSize = 12,
					TextColor3 = T.SubText,
					AutoButtonColor = false,
					LayoutOrder = index,
					Parent = list,
				}, { corner(4) })
				buttons[item] = button
				button.MouseButton1Click:Connect(function()
					if multi then
						selected[item] = not selected[item] or nil
					else
						value = item
						setOpen(false)
					end
					render()
					safe(opts.Callback, getValue())
				end)
			end
			render()
			if open then
				setOpen(true)
			end
		end

		function obj:Get()
			return getValue()
		end
		function obj:Set(v, silent)
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
				safe(opts.Callback, getValue())
			end
		end
		function obj:Refresh(newItems)
			items = newItems or {}
			build()
		end
		head.MouseButton1Click:Connect(function()
			setOpen(not open)
		end)
		list.Size = UDim2.new(1, -2, 0, listHeight())
		build()
		return flag(opts, obj)
	end

	function api:AddTextbox(opts)
		opts = opts or {}
		local row = newRow(26, opts.Name or "Textbox")
		local frame = field(row, 0, 26)
		local box = create("TextBox", {
			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.fromOffset(6, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or opts.Name or "",
			PlaceholderColor3 = T.SubText,
			TextColor3 = T.Text,
			Font = Zero.FontMedium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = frame,
		})
		box.FocusLost:Connect(function()
			safe(opts.Callback, box.Text)
		end)
		local obj = {}
		function obj:Get()
			return box.Text
		end
		function obj:Set(value, silent)
			box.Text = tostring(value)
			if not silent then
				safe(opts.Callback, box.Text)
			end
		end
		return flag(opts, obj)
	end

	return api
end

function Window:CreatePopup(width, title)
	local pop = { IsOpen = false }
	local frame = create("Frame", {
		Size = UDim2.fromOffset(width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 50,
		Parent = self.Gui,
	}, {
		corner(6),
		stroke(T.Track, 1),
		padding(10, 8, 10, 10),
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
	})
	label({
		Text = title or "",
		Font = Zero.FontBold,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 0,
		Parent = frame,
	})
	pop.Panel = frame
	pop.Frame = frame
	function pop.Open(anchor)
		for _, other in ipairs(self.Popups) do
			if other ~= pop and other.IsOpen then
				other.Close()
			end
		end
		local origin = anchor.AbsolutePosition - self.Gui.AbsolutePosition
		local viewport = self.Gui.AbsoluteSize
		local x = math.clamp(origin.X + anchor.AbsoluteSize.X - width, 6, math.max(6, viewport.X - width - 6))
		local y = math.min(origin.Y + anchor.AbsoluteSize.Y + 6, math.max(6, viewport.Y - 160))
		frame.Position = UDim2.fromOffset(x, y)
		frame.Visible = true
		pop.IsOpen = true
		if pop.OnState then
			pop.OnState(true)
		end
	end
	function pop.Close()
		frame.Visible = false
		pop.IsOpen = false
		if pop.OnState then
			pop.OnState(false)
		end
	end
	table.insert(self.Popups, pop)
	return pop
end

function Window:ClosePopups()
	for _, pop in ipairs(self.Popups) do
		if pop.IsOpen then
			pop.Close()
		end
	end
end

function Window:OpenPicker(anchor, color, callback)
	local p = self.Picker
	if not p then
		p = { h = 0, s = 0, v = 1 }
		p.Pop = self:CreatePopup(190, "Color")
		local panel = p.Pop.Panel
		local sv = create("Frame", {
			Size = UDim2.new(1, 0, 0, 110),
			BackgroundColor3 = Color3.new(1, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = 1,
			NoTheme = true,
			Parent = panel,
		}, { corner(4) })
		create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			NoTheme = true,
			Parent = sv,
		}, { corner(4), create("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
		create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			NoTheme = true,
			Parent = sv,
		}, { corner(4), create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
		local svCursor = create("Frame", {
			Size = UDim2.fromOffset(10, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 3,
			NoTheme = true,
			Parent = sv,
		}, { corner(5), create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })
		local svHit = create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 4,
			Parent = sv,
		})
		local stops = {}
		for i = 0, 6 do
			table.insert(stops, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
		end
		local hue = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 2,
			NoTheme = true,
			Parent = panel,
		}, { corner(4), create("UIGradient", { Color = ColorSequence.new(stops) }) })
		local hueCursor = create("Frame", {
			Size = UDim2.fromOffset(4, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			NoTheme = true,
			Parent = hue,
		}, { corner(2), create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }) })
		function p.Update(fire)
			sv.BackgroundColor3 = Color3.fromHSV(p.h, 1, 1)
			svCursor.Position = UDim2.fromScale(p.s, 1 - p.v)
			hueCursor.Position = UDim2.fromScale(p.h, 0.5)
			if fire and p.Callback then
				p.Callback(Color3.fromHSV(p.h, p.s, p.v))
			end
		end
		self:Dragger(svHit, function(pos)
			p.s = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
			p.v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
			p.Update(true)
		end)
		self:Dragger(hue, function(pos)
			p.h = math.clamp((pos.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 0.999)
			p.Update(true)
		end)
		self.Picker = p
	end
	if p.Pop.IsOpen and p.Anchor == anchor then
		p.Pop.Close()
		return
	end
	p.Anchor = anchor
	p.Callback = callback
	p.h, p.s, p.v = color:ToHSV()
	p.Update(false)
	p.Pop.Open(anchor)
end

function Tab:Render()
	local on = self.Window.Current == self
	self.Page.Visible = on
	tween(self.Button, { BackgroundTransparency = on and 0 or 1 }, 0.15)
	tween(self.Label, { TextColor3 = on and T.Text or T.SubText }, 0.15)
	tween(self.Icon, { ImageColor3 = on and T.Accent or T.SubText }, 0.15)
end

function Tab:AddSection(name)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self.Page),
		Parent = self.Page,
	}, {
		corner(6),
		stroke(T.Stroke, 1),
		padding(10, 8, 10, 10),
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
	})
	label({
		Text = string.upper(name or ""),
		TextColor3 = T.SubText,
		Font = Zero.FontBold,
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
	tab.Button = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = T.Element,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabList,
	}, { corner(5) })
	tab.Icon = icon(tab.Button, opts.Icon or "circle", 14, T.SubText)
	tab.Icon.Position = UDim2.fromOffset(8, 7)
	tab.Label = label({
		Text = tab.Name,
		TextColor3 = T.SubText,
		Size = UDim2.new(1, -32, 1, 0),
		Position = UDim2.fromOffset(28, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = tab.Button,
	})
	tab.Page = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Track,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.Content,
	}, {
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
		padding(12, 12, 12, 12),
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
	local card = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = self.Notes,
	}, {
		corner(6),
		stroke(T.Accent, 1),
		padding(10, 8, 10, 8),
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
	})
	label({
		Text = opts.Title or "Zero",
		Font = Zero.FontBold,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})
	label({
		Text = opts.Content or "",
		TextColor3 = T.SubText,
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
	local set = Zero.Themes[name]
	if not set then
		return
	end
	for key, value in pairs(set) do
		T[key] = value
	end
	for _, entry in ipairs(Registry) do
		pcall(function()
			entry[1][entry[2]] = T[entry[3]]
		end)
	end
	for _, refresh in ipairs(self.Refreshers) do
		pcall(refresh)
	end
end

function Window:ExportConfig()
	local data = {}
	for name, obj in pairs(self.Flags) do
		local ok, value = pcall(obj.Get, obj)
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
		local obj = self.Flags[name]
		if obj then
			pcall(obj.Set, obj, decode(value))
		end
	end
	return true
end

function Window:SaveConfig(name)
	if writefile then
		pcall(writefile, (name or "ZeroConfig") .. ".json", self:ExportConfig())
	end
end

function Window:LoadConfig(name)
	local file = (name or "ZeroConfig") .. ".json"
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

function Zero:CreateWindow(opts)
	opts = opts or {}
	local self = setmetatable({
		Connections = {},
		Searchable = {},
		Refreshers = {},
		Flags = {},
		Tabs = {},
		Popups = {},
		Listening = false,
	}, Window)

	local size = typeof(opts.Size) == "Vector2" and opts.Size or Vector2.new(580, 380)

	local gui = create("ScreenGui", {
		Name = "Zero",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Parent = getGuiParent(),
	})
	self.Gui = gui

	local main = create("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(size.X, size.Y),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = T.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	}, { corner(8), stroke(T.Stroke, 1) })
	self.Main = main

	local scale = create("UIScale", { Parent = main })
	local function fit()
		local viewport = gui.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then
			return
		end
		scale.Scale = math.clamp(math.min((viewport.X - 20) / size.X, (viewport.Y - 20) / size.Y), 0.5, 1)
	end
	fit()
	self:Bind(gui:GetPropertyChangedSignal("AbsoluteSize"), fit)

	local top = create("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = main,
	})
	local mark = logo(top, 16)
	mark.Position = UDim2.fromOffset(12, 10)
	label({
		Text = opts.Title or "Zero",
		Font = Zero.FontBold,
		TextSize = 13,
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.fromOffset(34, 0),
		Parent = top,
	})
	label({
		Text = "v" .. Zero.Version,
		TextColor3 = T.SubText,
		TextSize = 10,
		Size = UDim2.new(0, 60, 1, 0),
		Position = UDim2.new(1, -100, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = top,
	})
	local close = create("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -32, 0, 4),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = top,
	})
	local closeIcon = icon(close, "x", 14, T.SubText)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Position = UDim2.fromScale(0.5, 0.5)
	close.MouseEnter:Connect(function()
		tween(closeIcon, { ImageColor3 = T.Danger }, 0.12)
	end)
	close.MouseLeave:Connect(function()
		tween(closeIcon, { ImageColor3 = T.SubText }, 0.12)
	end)
	close.MouseButton1Click:Connect(function()
		self:Toggle(false)
	end)
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = T.Stroke,
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

	local sidebar = create("Frame", {
		Size = UDim2.new(0, 150, 1, -36),
		Position = UDim2.fromOffset(0, 36),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = main,
	})
	local searchFrame = create("Frame", {
		Size = UDim2.new(1, -16, 0, 26),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = T.Element,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(5), stroke(T.Stroke, 1) })
	local searchIcon = icon(searchFrame, "search", 12, T.SubText)
	searchIcon.Position = UDim2.fromOffset(7, 7)
	local searchBox = create("TextBox", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.fromOffset(24, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = T.SubText,
		TextColor3 = T.Text,
		Font = Zero.FontMedium,
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
	self.TabList = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -42),
		Position = UDim2.fromOffset(0, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, {
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
		padding(8, 0, 8, 8),
	})
	create("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	self.Content = create("Frame", {
		Size = UDim2.new(1, -150, 1, -36),
		Position = UDim2.fromOffset(150, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = main,
	})

	self.Notes = create("Frame", {
		Size = UDim2.fromOffset(240, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		BackgroundTransparency = 1,
		ZIndex = 100,
		Parent = gui,
	}, { create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }) })

	if UserInputService.TouchEnabled then
		local floating = create("TextButton", {
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.fromOffset(10, 70),
			BackgroundColor3 = T.Section,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 60,
			Parent = gui,
		}, { corner(8), stroke(T.Stroke, 1) })
		local floatLogo = logo(floating, 18)
		floatLogo.AnchorPoint = Vector2.new(0.5, 0.5)
		floatLogo.Position = UDim2.fromScale(0.5, 0.5)
		floating.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	end

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
	local toggleKey = opts.Key or Enum.KeyCode.RightShift
	self:Bind(UserInputService.InputBegan, function(input, processed)
		if not processed and not self.Listening and input.KeyCode == toggleKey then
			self:Toggle()
		end
	end)

	return self
end

Zero.new = function(opts)
	return Zero:CreateWindow(opts)
end

return Zero

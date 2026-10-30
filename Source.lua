local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
Zero.Version = "1.9.2"
Zero.Font = Enum.Font.Arial
Zero.FontMedium = Enum.Font.Arial
Zero.FontBold = Enum.Font.ArialBold

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
	local custom = type(name) == "number"
		or (type(name) == "string" and (string.match(name, "^%d+$") ~= nil or string.match(name, "^rbxassetid://") ~= nil))
	local img = create("ImageLabel", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageColor3 = custom and Color3.new(1, 1, 1) or (color or T.SubText),
		NoTheme = custom,
		Parent = parent,
	})
	ApplyIcon(img, name)
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

local function accentGradient()
	return ColorSequence.new(T.Accent, T.Accent:Lerp(Color3.new(1, 1, 1), 0.3))
end

function Window:Bind(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
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
			BackgroundColor3 = T.Background,
			BorderSizePixel = 0,
			Parent = parent,
		}, { corner(6), stroke(T.Stroke, 1) })
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
		local obj = { Button = button }
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

	function api:AddRow(height)
		return newRow(height)
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

	function api:AddButton(opts)
		opts = opts or {}
		local row = newRow(30, opts.Name or "Button")
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
		}, { corner(6), stroke(T.Stroke, 1) })
		local ring = getStroke(btn)
		btn.MouseEnter:Connect(function()
			tween(btn, { BackgroundColor3 = T.ElementHover }, 0.12)
			tween(ring, { Color = T.Accent }, 0.12)
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
		local row = newRow(26, opts.Name or "Toggle")
		local hit = hitbox(row)
		local lbl = label({
			Text = opts.Name or "Toggle",
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(1, 0),
			Parent = row,
		})
		local track = create("Frame", {
			Size = UDim2.fromOffset(30, 16),
			Position = UDim2.new(1, -31, 0.5, -8),
			BackgroundColor3 = T.Track,
			BorderSizePixel = 0,
			Parent = row,
		}, { corner(8), stroke(T.Track, 1) })
		local trackStroke = getStroke(track)
		local knob = create("Frame", {
			Size = UDim2.fromOffset(10, 10),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = T.SubText,
			BorderSizePixel = 0,
			Parent = track,
		}, { corner(5) })

		local swatch
		if opts.Color then
			swatch = makeSwatch(row, opts.Color, opts.ColorCallback)
			swatch.Button.Position = UDim2.new(1, -67, 0.5, -7)
			lbl.Size = UDim2.new(1, -74, 1, 0)
			if opts.ColorFlag then
				window.Flags[opts.ColorFlag] = swatch
			end
		end

		local function render(animate)
			local trackColor = state and T.Accent or T.Track
			local knobColor = state and T.Text or T.SubText
			local textColor = state and T.Text or T.SubText
			local x = state and 17 or 3
			if animate then
				tween(track, { BackgroundColor3 = trackColor }, 0.18)
				tween(trackStroke, { Color = trackColor }, 0.18)
				tween(knob, { Position = UDim2.new(0, x, 0.5, 0), BackgroundColor3 = knobColor }, 0.24, Quint)
				tween(lbl, { TextColor3 = textColor }, 0.15)
			else
				track.BackgroundColor3 = trackColor
				trackStroke.Color = trackColor
				knob.Position = UDim2.new(0, x, 0.5, 0)
				knob.BackgroundColor3 = knobColor
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
				Position = UDim2.new(1, swatch and -89 or -53, 0.5, -9),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 3,
				Parent = row,
			})
			local gearIcon = icon(gear, "settings", 14, T.SubText)
			gearIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			gearIcon.Position = UDim2.fromScale(0.5, 0.5)
			lbl.Size = UDim2.new(1, swatch and -96 or -60, 1, 0)
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
		local row = newRow(26, opts.Name or "Color")
		label({
			Text = opts.Name or "Color",
			TextColor3 = T.SubText,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(1, 0),
			Parent = row,
		})
		local obj = makeSwatch(row, opts.Default, opts.Callback)
		return flag(opts, obj)
	end

	function api:AddKeybind(opts)
		opts = opts or {}
		local key = nil
		local listening = false

		local function toKey(value)
			if typeof(value) == "EnumItem" then
				return value
			end
			if type(value) == "string" then
				local ok, result = pcall(function()
					return Enum.KeyCode[value]
				end)
				if ok then
					return result
				end
			end
			return nil
		end

		key = toKey(opts.Default)
		local row = newRow(26, opts.Name or "Keybind")
		label({
			Text = opts.Name or "Keybind",
			TextColor3 = T.SubText,
			Size = UDim2.new(1, -80, 1, 0),
			Position = UDim2.fromOffset(1, 0),
			Parent = row,
		})
		local button = create("TextButton", {
			Size = UDim2.new(0, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -1, 0.5, 0),
			BackgroundColor3 = T.Background,
			BorderSizePixel = 0,
			Text = "",
			Font = Zero.FontMedium,
			TextSize = 11,
			TextColor3 = T.SubText,
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = row,
		}, {
			corner(5),
			stroke(T.Stroke, 1),
			padding(10, 0, 10, 0),
			create("UISizeConstraint", { MinSize = Vector2.new(48, 20) }),
		})
		local ring = getStroke(button)
		local hovering = false

		local function render()
			button.Text = listening and "..." or (key and key.Name or "None")
			button.TextColor3 = listening and T.Accent or T.SubText
			button.BackgroundColor3 = T.Background
			ring.Color = (listening or hovering) and T.Accent or T.Stroke
		end

		button.MouseEnter:Connect(function()
			hovering = true
			tween(ring, { Color = T.Accent }, 0.12)
		end)
		button.MouseLeave:Connect(function()
			hovering = false
			if not listening then
				tween(ring, { Color = T.Stroke }, 0.15)
			end
		end)
		button.MouseButton1Click:Connect(function()
			listening = not listening
			render()
		end)

		local obj = {}
		function obj:Get()
			return key and key.Name or nil
		end
		function obj:GetKey()
			return key
		end
		function obj:Set(value, silent)
			key = toKey(value)
			listening = false
			render()
			if not silent then
				safe(opts.Callback, key)
			end
		end

		window:Bind(UserInputService.InputBegan, function(input, processed)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			if listening then
				listening = false
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					key = nil
				else
					key = input.KeyCode
				end
				render()
				safe(opts.Callback, key)
				return
			end
			if key and not processed and input.KeyCode == key then
				safe(opts.Pressed)
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
		local increment = opts.Increment or 1
		local suffix = opts.Suffix or ""

		local function snap(v)
			v = math.floor((v - min) / increment + 0.5) * increment + min
			v = math.clamp(v, min, max)
			return tonumber(string.format("%.6f", v))
		end

		local value = snap(opts.Default or min)
		local row = newRow(40, opts.Name or "Slider")
		label({
			Text = opts.Name or "Slider",
			Size = UDim2.new(1, -70, 0, 16),
			Position = UDim2.fromOffset(1, 0),
			Parent = row,
		})
		local valueLabel = label({
			Size = UDim2.new(0, 66, 0, 16),
			Position = UDim2.new(1, -66, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = T.SubText,
			Parent = row,
		})
		local hit = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 18),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = row,
		})
		local bar = create("Frame", {
			Size = UDim2.new(1, -10, 0, 5),
			Position = UDim2.new(0, 5, 0.5, -2),
			BackgroundColor3 = T.Track,
			BorderSizePixel = 0,
			Parent = hit,
		}, { corner(3) })
		local fillGradient = create("UIGradient", { Color = accentGradient() })
		local fill = create("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			NoTheme = true,
			Parent = bar,
		}, { corner(3), fillGradient })
		local knob = create("Frame", {
			Size = UDim2.fromOffset(10, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = T.Text,
			BorderSizePixel = 0,
			Parent = fill,
		}, { corner(7), stroke(T.Accent, 1) })

		local function render(animate)
			local alpha = max == min and 0 or (value - min) / (max - min)
			if animate then
				tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, 0.08)
			else
				fill.Size = UDim2.new(alpha, 0, 1, 0)
			end
			valueLabel.Text = tostring(value) .. suffix
		end

		local obj = {}
		function obj:Set(v, silent)
			v = snap(v)
			local changed = v ~= value
			value = v
			render(true)
			if changed and not silent then
				safe(opts.Callback, value)
			end
		end
		function obj:Get()
			return value
		end

		local function update(x)
			local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
			obj:Set(min + (max - min) * alpha)
		end

		local dragging = false
		local hovering = false
		local function grow(on)
			tween(knob, { Size = UDim2.fromOffset(on and 14 or 10, on and 14 or 10) }, 0.15, Back)
			tween(valueLabel, { TextColor3 = on and T.Text or T.SubText }, 0.15)
		end
		hit.MouseEnter:Connect(function()
			hovering = true
			if not dragging then
				grow(true)
			end
		end)
		hit.MouseLeave:Connect(function()
			hovering = false
			if not dragging then
				grow(false)
			end
		end)
		hit.InputBegan:Connect(function(input)
			if isPointer(input) then
				dragging = true
				grow(true)
				update(input.Position.X)
			end
		end)
		window:Bind(UserInputService.InputChanged, function(input)
			if dragging and isMove(input) then
				update(input.Position.X)
			end
		end)
		window:Bind(UserInputService.InputEnded, function(input)
			if isPointer(input) and dragging then
				dragging = false
				if not hovering then
					grow(false)
				end
			end
		end)

		table.insert(window.Refreshers, function()
			fillGradient.Color = accentGradient()
		end)
		render(false)
		return flag(opts, obj)
	end

	function api:AddTextbox(opts)
		opts = opts or {}
		local row = newRow(48, opts.Name or "Textbox")
		label({
			Text = opts.Name or "Textbox",
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.fromOffset(1, 0),
			Parent = row,
		})
		local holder = field(row, 20, 26)
		local ring = getStroke(holder)
		local box = create("TextBox", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or "",
			PlaceholderColor3 = T.SubText,
			TextColor3 = T.Text,
			Font = Zero.FontMedium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = holder,
		}, { padding(9, 0, 9, 0) })
		box.Focused:Connect(function()
			tween(ring, { Color = T.Accent }, 0.15)
		end)
		box.FocusLost:Connect(function(enterPressed)
			tween(ring, { Color = T.Stroke }, 0.15)
			safe(opts.Callback, box.Text, enterPressed)
		end)
		local obj = { Box = box }
		function obj:Set(value, silent)
			box.Text = tostring(value)
			if not silent then
				safe(opts.Callback, box.Text, false)
			end
		end
		function obj:Get()
			return box.Text
		end
		return flag(opts, obj)
	end

	function api:AddDropdown(opts)
		opts = opts or {}
		local options = opts.Options or {}
		local multi = opts.Multi == true
		local selected = {}
		local current = nil
		local open = false
		local items = {}

		if multi then
			for _, name in ipairs(opts.Default or {}) do
				selected[name] = true
			end
		else
			current = opts.Default
		end

		local row = newRow(48, opts.Name or "Dropdown")
		label({
			Text = opts.Name or "Dropdown",
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.fromOffset(1, 0),
			Parent = row,
		})
		local head = field(row, 21, 26)
		local headStroke = getStroke(head)
		local headHit = hitbox(head)
		local valueLabel = label({
			Size = UDim2.new(1, -52, 1, 0),
			Position = UDim2.fromOffset(9, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = head,
		})
		local arrow = icon(head, "chevron-down", 14, T.SubText)
		arrow.AnchorPoint = Vector2.new(0.5, 0.5)
		arrow.Position = UDim2.new(1, -14, 0.5, 0)
		local badge = label({
			Size = UDim2.fromOffset(20, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -26, 0.5, 0),
			TextSize = 10,
			Font = Zero.FontBold,
			TextColor3 = T.Accent,
			TextXAlignment = Enum.TextXAlignment.Right,
			Visible = multi,
			Parent = head,
		})
		local overlay = create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 1,
			Visible = false,
			NoTheme = true,
			Parent = window.Layer,
		})
		local listFrame = create("Frame", {
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = T.Background,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 2,
			Visible = false,
			Parent = window.Layer,
		}, { corner(6), stroke(T.Stroke, 1) })
		local list = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = T.Accent,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = listFrame,
		}, {
			create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
			padding(3, 3, 5, 3),
		})

		local function listHeight()
			return math.min(#options * 28 + 6, 156)
		end

		local closer
		local function setOpen(state)
			if state == open then
				return
			end
			if state then
				window:ClosePicker()
				open = true
				local position = head.AbsolutePosition
				local size = head.AbsoluteSize
				local viewport = window.Layer.AbsoluteSize
				local height = listHeight()
				local below = viewport.Y - 8 - (position.Y + size.Y + 4)
				local above = position.Y - 12
				local up = height > below and above > below
				height = math.min(height, math.max(up and above or below, 60))
				local x = math.clamp(position.X, 8, math.max(viewport.X - size.X - 8, 8))
				overlay.Visible = true
				listFrame.Visible = true
				listFrame.AnchorPoint = Vector2.new(0, up and 1 or 0)
				listFrame.Position = up and UDim2.fromOffset(x, position.Y - 4) or UDim2.fromOffset(x, position.Y + size.Y + 4)
				listFrame.Size = UDim2.fromOffset(size.X, 0)
				tween(listFrame, { Size = UDim2.fromOffset(size.X, height) }, 0.22, Quint)
				window.PickerClose = closer
			else
				open = false
				overlay.Visible = false
				tween(listFrame, { Size = UDim2.fromOffset(head.AbsoluteSize.X, 0) }, 0.16, Quint)
				task.delay(0.18, function()
					if not open then
						listFrame.Visible = false
					end
				end)
				if window.PickerClose == closer then
					window.PickerClose = nil
				end
			end
			tween(arrow, { Rotation = open and 180 or 0, ImageColor3 = open and T.Accent or T.SubText }, 0.26, Quint)
			tween(headStroke, { Color = open and T.Accent or T.Stroke }, 0.18)
		end
		closer = function()
			setOpen(false)
		end
		overlay.MouseButton1Click:Connect(closer)

		local function collect()
			local out = {}
			for _, name in ipairs(options) do
				if selected[name] then
					table.insert(out, name)
				end
			end
			return out
		end

		local function refresh()
			for name, item in pairs(items) do
				local on
				if multi then
					on = selected[name] == true
				else
					on = current == name
				end
				item.On = on
				tween(item.Button, { BackgroundTransparency = on and 0.5 or 1 }, 0.15)
				tween(item.Label, { TextColor3 = on and T.Text or T.SubText }, 0.15)
				tween(item.Bar, { Size = UDim2.fromOffset(2, on and 12 or 0) }, 0.2, Quint)
				tween(item.Check, { ImageTransparency = on and 0 or 1 }, 0.15)
				item.Bar.BackgroundColor3 = T.Accent
				item.Check.ImageColor3 = T.Accent
				item.Button.BackgroundColor3 = T.Element
			end
			head.BackgroundColor3 = T.Background
			headStroke.Color = open and T.Accent or T.Stroke
			badge.TextColor3 = T.Accent
			list.ScrollBarImageColor3 = T.Accent
			if multi then
				local names = collect()
				valueLabel.Text = #names > 0 and table.concat(names, ", ") or "None"
				badge.Text = #names > 0 and tostring(#names) or ""
			else
				valueLabel.Text = current ~= nil and tostring(current) or "None"
			end
		end

		local function fire()
			if multi then
				safe(opts.Callback, collect())
			else
				safe(opts.Callback, current)
			end
		end

		local function build()
			for _, item in pairs(items) do
				item.Button:Destroy()
			end
			items = {}
			for index, name in ipairs(options) do
				local button = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = T.Element,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					LayoutOrder = index,
					Parent = list,
				}, { corner(4) })
				local bar = create("Frame", {
					Size = UDim2.fromOffset(2, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 3, 0.5, 0),
					BackgroundColor3 = T.Accent,
					BorderSizePixel = 0,
					Parent = button,
				}, { corner(1) })
				local text = label({
					Text = tostring(name),
					TextColor3 = T.SubText,
					Size = UDim2.new(1, -36, 1, 0),
					Position = UDim2.fromOffset(12, 0),
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = button,
				})
				local check = icon(button, "check", 12, T.Accent)
				check.AnchorPoint = Vector2.new(1, 0.5)
				check.Position = UDim2.new(1, -8, 0.5, 0)
				check.ImageTransparency = 1
				local item = { Button = button, Bar = bar, Label = text, Check = check, On = false }
				items[name] = item
				button.MouseEnter:Connect(function()
					tween(button, { BackgroundTransparency = item.On and 0.2 or 0.6 }, 0.1)
				end)
				button.MouseLeave:Connect(function()
					tween(button, { BackgroundTransparency = item.On and 0.5 or 1 }, 0.15)
				end)
				button.MouseButton1Click:Connect(function()
					if multi then
						selected[name] = not selected[name] or nil
					else
						current = name
						setOpen(false)
					end
					refresh()
					fire()
				end)
			end
			if open then
				listFrame.Size = UDim2.fromOffset(head.AbsoluteSize.X, math.min(listHeight(), listFrame.AbsoluteSize.Y > 0 and math.max(listFrame.AbsoluteSize.Y, 60) or listHeight()))
			end
			refresh()
		end

		headHit.MouseEnter:Connect(function()
			tween(head, { BackgroundColor3 = T.Element }, 0.12)
		end)
		headHit.MouseLeave:Connect(function()
			tween(head, { BackgroundColor3 = T.Background }, 0.15)
		end)
		headHit.MouseButton1Click:Connect(function()
			setOpen(not open)
		end)

		local obj = {}
		function obj:Get()
			if multi then
				return collect()
			end
			return current
		end
		function obj:Set(value, silent)
			if multi then
				selected = {}
				for _, name in ipairs(value or {}) do
					selected[name] = true
				end
			else
				current = value
			end
			refresh()
			if not silent then
				fire()
			end
		end
		function obj:SetOptions(newOptions)
			options = newOptions or {}
			if multi then
				local kept = {}
				for _, name in ipairs(options) do
					if selected[name] then
						kept[name] = true
					end
				end
				selected = kept
			else
				local found = false
				for _, name in ipairs(options) do
					if name == current then
						found = true
					end
				end
				if not found then
					current = nil
				end
			end
			build()
		end

		table.insert(window.Refreshers, refresh)
		build()
		return flag(opts, obj)
	end

	function api:AddThemeManager()
		local picker
		api:AddDropdown({
			Name = "Theme",
			Options = Zero.ThemeOrder,
			Default = "Ocean",
			Flag = "UITheme",
			Callback = function(name)
				local theme = Zero.Themes[name]
				if theme then
					window:SetTheme(theme)
					if picker then
						picker:Set(T.Accent, true)
					end
				end
			end,
		})
		picker = api:AddColorPicker({
			Name = "Accent",
			Default = T.Accent,
			Flag = "UIAccent",
			Callback = function(color)
				window:SetTheme({ Accent = color })
			end,
		})
		picker.Late = true
	end

	function api:AddConfigManager(folder)
		folder = folder or "ZeroConfigs"
		pcall(function()
			if not isfolder(folder) then
				makefolder(folder)
			end
		end)

		local autoPath = folder .. "/autoload.txt"
		local selected = nil
		local nameBox
		local list
		local autoLabel

		local function path(name)
			return folder .. "/" .. name .. ".json"
		end

		local function scan()
			local out = {}
			local ok, files = pcall(listfiles, folder)
			if ok and type(files) == "table" then
				for _, file in ipairs(files) do
					local name = string.match(file, "([^/\\]+)%.json$")
					if name then
						table.insert(out, name)
					end
				end
			end
			table.sort(out)
			return out
		end

		local function dump()
			local data = {}
			for key, obj in pairs(window.Flags) do
				local ok, value = pcall(obj.Get, obj)
				if ok and value ~= nil then
					data[key] = encode(value)
				end
			end
			return HttpService:JSONEncode(data)
		end

		local function apply(json)
			local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
			if not ok or type(data) ~= "table" then
				return false
			end
			for key, value in pairs(data) do
				local obj = window.Flags[key]
				if obj and not obj.Late then
					pcall(obj.Set, obj, decode(value))
				end
			end
			for key, value in pairs(data) do
				local obj = window.Flags[key]
				if obj and obj.Late then
					pcall(obj.Set, obj, decode(value))
				end
			end
			return true
		end

		local function note(text)
			window:Notify({ Title = "Configs", Content = text, Duration = 2.5 })
		end

		local function save(name)
			local ok = pcall(writefile, path(name), dump())
			if not ok then
				note("File system unavailable")
				return false
			end
			return true
		end

		local function readAuto()
			local ok, content = pcall(readfile, autoPath)
			if ok and type(content) == "string" then
				local name = string.match(content, "^%s*(.-)%s*$")
				if name ~= "" then
					return name
				end
			end
			return nil
		end

		local function renderAuto()
			if autoLabel then
				autoLabel:Set("Autoload: " .. (readAuto() or "none"))
			end
		end

		nameBox = api:AddTextbox({ Name = "Config name", Placeholder = "Config name" })
		list = api:AddDropdown({
			Name = "Configs",
			Options = scan(),
			Callback = function(value)
				selected = value
			end,
		})

		api:AddButton({
			Name = "Save",
			Callback = function()
				local name = string.gsub(nameBox:Get(), "[^%w%-_ ]", "")
				name = string.match(name, "^%s*(.-)%s*$")
				if name == "" then
					note("Enter a config name")
					return
				end
				local exists = false
				pcall(function()
					exists = isfile(path(name))
				end)
				if exists then
					note(name .. " already exists, use Overwrite")
					return
				end
				if save(name) then
					list:SetOptions(scan())
					list:Set(name, true)
					selected = name
					nameBox:Set("", true)
					note("Saved " .. name)
				end
			end,
		})
		api:AddButton({
			Name = "Load",
			Callback = function()
				if not selected then
					note("Select a config first")
					return
				end
				local ok, content = pcall(readfile, path(selected))
				if ok and apply(content) then
					note("Loaded " .. selected)
				else
					note("Failed to load " .. selected)
				end
			end,
		})
		api:AddButton({
			Name = "Overwrite",
			Callback = function()
				if not selected then
					note("Select a config first")
					return
				end
				local target = selected
				window:Confirm({
					Title = "Overwrite config",
					Content = "Overwrite " .. target .. " with current settings?",
					Callback = function()
						if save(target) then
							note("Overwrote " .. target)
						end
					end,
				})
			end,
		})
		api:AddButton({
			Name = "Set as Autoload",
			Callback = function()
				if not selected then
					note("Select a config first")
					return
				end
				local ok = pcall(writefile, autoPath, selected)
				if ok then
					renderAuto()
					note(selected .. " will load automatically")
				else
					note("File system unavailable")
				end
			end,
		})
		api:AddButton({
			Name = "Remove autoload",
			Callback = function()
				pcall(delfile, autoPath)
				renderAuto()
				note("Autoload removed")
			end,
		})
		autoLabel = api:AddLabel("Autoload: none")
		renderAuto()

		local auto = readAuto()
		if auto then
			for _, name in ipairs(scan()) do
				if name == auto then
					selected = auto
					list:Set(auto, true)
				end
			end
			task.defer(function()
				local ok, content = pcall(readfile, path(auto))
				if ok and apply(content) then
					note("Autoloaded " .. auto)
				end
			end)
		end
	end

	return api
end

local function makeColumns(parent, y)
	local columns = create("Frame", {
		Size = UDim2.new(1, -24, 0, 0),
		Position = UDim2.fromOffset(10, y),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
	})
	local left = create("Frame", {
		Size = UDim2.new(0.5, -5, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = columns,
	}, { create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local right = create("Frame", {
		Size = UDim2.new(0.5, -5, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = columns,
	}, { create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
	return columns, left, right
end

function Tab:AddSection(name, side, iconName, tag)
	local column
	if side == "Right" then
		column = self.Right
	elseif side == "Left" then
		column = self.Left
	else
		column = self.Counts.Left <= self.Counts.Right and self.Left or self.Right
	end
	local key = column == self.Left and "Left" or "Right"
	self.Counts[key] = self.Counts[key] + 1

	local frame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(column),
		Parent = column,
	}, {
		corner(10),
		stroke(T.Stroke, 1),
		padding(11, 0, 11, 12),
		create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = frame,
	})
	local textX = 0
	if iconName then
		local img = icon(header, iconName, 14, T.Accent)
		img.AnchorPoint = Vector2.new(0, 0.5)
		img.Position = UDim2.new(0, 0, 0.5, 0)
		textX = 22
	end
	label({
		Text = name or "Section",
		Font = Zero.FontBold,
		Size = UDim2.new(1, -textX, 1, 0),
		Position = UDim2.fromOffset(textX, 0),
		Parent = header,
	})
	if type(tag) == "string" then
		label({
			Text = tag,
			TextSize = 10,
			TextColor3 = T.SubText,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromScale(1, 1),
			Parent = header,
		})
	end
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = header,
	})

	return buildElements(self.Window, frame, self.Owner or self, false)
end

function Tab:SelectSubTab(sub)
	local changed = self.ActiveSub ~= sub
	for _, other in ipairs(self.SubTabs) do
		local on = other == sub
		other.Columns.Visible = on
		tween(other.Button, { BackgroundTransparency = on and 0.88 or 0.4, BackgroundColor3 = on and T.Accent or T.Element }, 0.2)
		tween(getStroke(other.Button), { Color = on and T.Accent or T.Stroke, Transparency = on and 0.45 or 0 }, 0.2)
		tween(other.Label, { TextColor3 = on and T.Text or T.SubText }, 0.15)
		if other.Icon then
			tween(other.Icon, { ImageColor3 = on and T.Accent or T.SubText }, 0.15)
		end
	end
	if changed then
		sub.Columns.Position = UDim2.fromOffset(10, 62)
		tween(sub.Columns, { Position = UDim2.fromOffset(10, 54) }, 0.3, Quint)
	end
	self.ActiveSub = sub
end

function Tab:AddSubTab(name, iconName)
	local parent = self
	local window = self.Window
	if not parent.SubBar then
		parent.SubTabs = {}
		parent.Columns.Visible = false
		parent.SubBar = create("ScrollingFrame", {
			Size = UDim2.new(1, -20, 0, 36),
			Position = UDim2.fromOffset(6, 8),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.X,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			Parent = parent.Page,
		}, {
			padding(4, 3, 4, 3),
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})
	end

	local sub = setmetatable({ Window = window, Owner = parent, Name = name, Counts = { Left = 0, Right = 0 } }, Tab)
	sub.Button = create("TextButton", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = T.Element,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #parent.SubTabs + 1,
		Parent = parent.SubBar,
	}, {
		corner(7),
		stroke(T.Stroke, 1),
		padding(11, 0, 11, 0),
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})
	if iconName then
		sub.Icon = icon(sub.Button, iconName, 14, T.SubText)
		sub.Icon.LayoutOrder = 1
	end
	sub.Label = label({
		Text = name or "Sub",
		TextColor3 = T.SubText,
		Size = UDim2.new(0, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
		Parent = sub.Button,
	})
	sub.Button.MouseEnter:Connect(function()
		if parent.ActiveSub ~= sub then
			tween(sub.Button, { BackgroundTransparency = 0.15 }, 0.12)
		end
	end)
	sub.Button.MouseLeave:Connect(function()
		if parent.ActiveSub ~= sub then
			tween(sub.Button, { BackgroundTransparency = 0.4 }, 0.15)
		end
	end)

	sub.Columns, sub.Left, sub.Right = makeColumns(parent.Page, 54)
	sub.Columns.Visible = false

	table.insert(parent.SubTabs, sub)
	sub.Button.MouseButton1Click:Connect(function()
		window:ClosePicker()
		parent:SelectSubTab(sub)
	end)
	if #parent.SubTabs == 1 then
		parent:SelectSubTab(sub)
	end
	return sub
end

function Window:SelectTab(tab)
	local changed = self.Active ~= tab
	for _, other in ipairs(self.Tabs) do
		local on = other == tab
		other.Page.Visible = on
		tween(other.Button, { BackgroundTransparency = on and 0.92 or 1, BackgroundColor3 = on and T.Accent or T.Element }, 0.2)
		tween(other.Label, { TextColor3 = on and T.Text or T.SubText }, 0.15)
		tween(other.Indicator, { Size = UDim2.new(on and 0.9 or 0, 0, 0, 2) }, 0.3, Quint)
		tween(other.Glow, { Size = UDim2.new(on and 0.9 or 0, 0, 0, 7) }, 0.3, Quint)
		other.Indicator.BackgroundColor3 = T.Accent
		other.Glow.BackgroundColor3 = T.Accent
		if other.Icon then
			tween(other.Icon, { ImageColor3 = on and T.Accent or T.SubText }, 0.15)
		end
	end
	if changed then
		tab.Page.Position = UDim2.fromOffset(0, 12)
		tween(tab.Page, { Position = UDim2.fromOffset(0, 0) }, 0.3, Quint)
	end
	self.Active = tab
end

function Window:ApplySearch(query)
	query = string.lower(query or "")
	local counts = {}
	for _, entry in ipairs(self.Searchable) do
		local match = query == "" or string.find(string.lower(entry.Name), query, 1, true) ~= nil
		entry.Row.Visible = match
		if match then
			counts[entry.Tab] = (counts[entry.Tab] or 0) + 1
		end
	end
	local first = nil
	for _, tab in ipairs(self.Tabs) do
		local show = query == "" or (counts[tab] or 0) > 0
		tab.Button.Visible = show
		if show and not first then
			first = tab
		end
	end
	if self.Active and not self.Active.Button.Visible and first then
		self:SelectTab(first)
	end
end

function Window:AddTab(name, iconName)
	local tab = setmetatable({ Window = self, Name = name, Counts = { Left = 0, Right = 0 } }, Tab)
	tab.Button = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = T.Element,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabList,
	}, { corner(7) })
	local fade = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	tab.Glow = create("Frame", {
		Size = UDim2.new(0, 0, 0, 7),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, -2),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		Parent = tab.Button,
	}, { corner(4), create("UIGradient", { Transparency = fade }) })
	tab.Indicator = create("Frame", {
		Size = UDim2.new(0, 0, 0, 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, -2),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Parent = tab.Button,
	}, { corner(1), create("UIGradient", { Transparency = fade }) })
	local textX = 14
	if iconName then
		tab.Icon = icon(tab.Button, iconName, 16, T.SubText)
		tab.Icon.AnchorPoint = Vector2.new(0, 0.5)
		tab.Icon.Position = UDim2.new(0, 12, 0.5, 0)
		textX = 36
	end
	tab.Label = label({
		Text = name or "Tab",
		TextColor3 = T.SubText,
		Size = UDim2.new(1, -textX - 6, 1, 0),
		Position = UDim2.fromOffset(textX, 0),
		Parent = tab.Button,
	})
	tab.Button.MouseEnter:Connect(function()
		if self.Active ~= tab then
			tween(tab.Button, { BackgroundTransparency = 0.6 }, 0.12)
		end
	end)
	tab.Button.MouseLeave:Connect(function()
		if self.Active ~= tab then
			tween(tab.Button, { BackgroundTransparency = 1 }, 0.15)
		end
	end)
	tab.Page = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Track,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.Pages,
	})

	tab.Columns, tab.Left, tab.Right = makeColumns(tab.Page, 10)

	table.insert(self.Tabs, tab)
	tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	return tab
end

function Window:AddSettingsManager(opts)
	opts = opts or {}
	local window = self
	local tab = self:AddTab(opts.Name or "UiSetting", opts.Icon or "settings")

	local interface = tab:AddSection("Interface", "Left", "layout-dashboard", "window")
	interface:AddToggle({
		Name = "Watermark",
		Default = true,
		Flag = "UIWatermark",
		Callback = function(value)
			window:SetWatermarkVisible(value)
		end,
	})
	interface:AddKeybind({
		Name = "Toggle UI",
		Default = opts.Key or Enum.KeyCode.RightShift,
		Flag = "UIToggleKey",
		Pressed = function()
			window:SetVisible(not window.Shown)
		end,
	})
	interface:AddButton({
		Name = "Unload",
		Callback = function()
			window:Confirm({
				Title = "Unload",
				Content = "Close the interface?",
				Callback = function()
					window:Close()
				end,
			})
		end,
	})

	local theming = tab:AddSection("Theming", "Left", "palette", "colors")
	theming:AddThemeManager()

	local configs = tab:AddSection("Configs", "Right", "save", "profiles")
	configs:AddConfigManager(opts.Folder or window.ConfigFolder)

	return tab
end

local function rejoinServer()
	local player = Players.LocalPlayer
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, player)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
	end
end

local function findServer()
	local cursor = nil
	for _ = 1, 5 do
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100"
		if cursor then
			url = url .. "&cursor=" .. cursor
		end
		local ok, data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if not ok or type(data) ~= "table" or type(data.data) ~= "table" then
			return nil
		end
		local pool = {}
		for _, server in ipairs(data.data) do
			if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers then
				table.insert(pool, server.id)
			end
		end
		if #pool > 0 then
			return pool[math.random(#pool)]
		end
		cursor = data.nextPageCursor
		if not cursor then
			return nil
		end
	end
	return nil
end

function Window:AddHomeManager(opts)
	opts = opts or {}
	local window = self
	local localPlayer = Players.LocalPlayer
	local anonymous = opts.Anonymous
	if anonymous == nil then
		anonymous = window.Anonymous
	end

	local userName = opts.User or opts.Username
	if not userName then
		local env = type(getgenv) == "function" and getgenv() or _G
		userName = env.ZeroUser or env.ZeroGGUser
	end
	userName = anonymous and "XXX" or tostring(userName or localPlayer.Name)

	local tab = self:AddTab(opts.Name or "Home", opts.Icon or "home")

	local profile = tab:AddSection("Profile", "Left", "user", "account")
	local card = profile:AddRow(64)
	local avatar = create("ImageLabel", {
		Size = UDim2.fromOffset(56, 56),
		Position = UDim2.fromOffset(1, 4),
		BackgroundColor3 = T.Element,
		BorderSizePixel = 0,
		Image = anonymous and "" or ("rbxthumb://type=AvatarHeadShot&id=" .. localPlayer.UserId .. "&w=150&h=150"),
		Parent = card,
	}, { corner(28), stroke(T.Accent, 1) })
	getStroke(avatar).Transparency = 0.5
	if anonymous then
		local mark = icon(avatar, "user", 24, T.SubText)
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Position = UDim2.fromScale(0.5, 0.5)
	end
	label({
		Text = userName,
		Font = Zero.FontBold,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -72, 0, 18),
		Position = UDim2.fromOffset(70, 8),
		Parent = card,
	})
	label({
		Text = "Zero.gg User",
		TextSize = 11,
		TextColor3 = T.Accent,
		Size = UDim2.new(1, -72, 0, 14),
		Position = UDim2.fromOffset(70, 27),
		Parent = card,
	})
	label({
		Text = anonymous and "@XXX" or ("@" .. localPlayer.Name),
		TextSize = 10,
		TextColor3 = T.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -72, 0, 14),
		Position = UDim2.fromOffset(70, 42),
		Parent = card,
	})

	local gameSection = tab:AddSection("Game", "Right", "gamepad-2", "session")
	local gameCard = gameSection:AddRow(64)
	create("ImageLabel", {
		Size = UDim2.fromOffset(56, 56),
		Position = UDim2.fromOffset(1, 4),
		BackgroundColor3 = T.Element,
		BorderSizePixel = 0,
		Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
		Parent = gameCard,
	}, { corner(10), stroke(T.Stroke, 1) })
	local gameName = label({
		Text = "Loading...",
		Font = Zero.FontBold,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -72, 0, 18),
		Position = UDim2.fromOffset(70, 8),
		Parent = gameCard,
	})
	label({
		Text = "Place " .. game.PlaceId,
		TextSize = 11,
		TextColor3 = T.Accent,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -72, 0, 14),
		Position = UDim2.fromOffset(70, 27),
		Parent = gameCard,
	})
	label({
		Text = game.JobId ~= "" and ("Server " .. string.sub(game.JobId, 1, 8)) or "Server",
		TextSize = 10,
		TextColor3 = T.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -72, 0, 14),
		Position = UDim2.fromOffset(70, 42),
		Parent = gameCard,
	})
	task.spawn(function()
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfo(game.PlaceId)
		end)
		if gameName.Parent then
			gameName.Text = ok and info and info.Name or game.Name
		end
	end)

	local playersRow = gameSection:AddRow(34)
	label({
		Text = "Players",
		TextColor3 = T.SubText,
		Size = UDim2.new(1, -2, 0, 14),
		Position = UDim2.fromOffset(1, 0),
		Parent = playersRow,
	})
	local playersCount = label({
		Text = "",
		Font = Zero.FontBold,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -2, 0, 14),
		Position = UDim2.fromOffset(1, 0),
		Parent = playersRow,
	})
	local track = create("Frame", {
		Size = UDim2.new(1, -2, 0, 6),
		Position = UDim2.fromOffset(1, 22),
		BackgroundColor3 = T.Track,
		BorderSizePixel = 0,
		Parent = playersRow,
	}, { corner(3) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(3), create("UIGradient", { Color = accentGradient() }) })

	local function updatePlayers()
		if not playersCount.Parent then
			return
		end
		local current = #Players:GetPlayers()
		local max = math.max(Players.MaxPlayers, current, 1)
		playersCount.Text = current .. " / " .. max
		tween(fill, { Size = UDim2.fromScale(current / max, 1) }, 0.25, Quint)
	end
	updatePlayers()
	window:Bind(Players.PlayerAdded, updatePlayers)
	window:Bind(Players.PlayerRemoving, function()
		task.delay(0.2, updatePlayers)
	end)

	local server = tab:AddSection("Server", "Left", "server", "teleport")
	local busy = false

	server:AddButton({
		Name = "Server Hop",
		Callback = function()
			if busy then
				return
			end
			busy = true
			window:Notify({ Title = "Server Hop", Content = "Searching for a server...", Duration = 3 })
			local id = findServer()
			if id then
				window:Notify({ Title = "Server Hop", Content = "Teleporting...", Duration = 3 })
				local ok = pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer)
				end)
				if not ok then
					window:Notify({ Title = "Server Hop", Content = "Teleport failed", Duration = 3 })
				end
			else
				window:Notify({ Title = "Server Hop", Content = "No server found", Duration = 3 })
			end
			task.delay(3, function()
				busy = false
			end)
		end,
	})

	server:AddButton({
		Name = "Rejoin Server",
		Callback = function()
			if busy then
				return
			end
			busy = true
			window:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 3 })
			local ok = pcall(rejoinServer)
			if not ok then
				window:Notify({ Title = "Rejoin", Content = "Teleport failed", Duration = 3 })
			end
			task.delay(3, function()
				busy = false
			end)
		end,
	})

	return tab
end

function Window:ApplyRivalsProtection()
	local runtime = type(getgenv) == "function" and getgenv() or _G
	if runtime.RivalsProtectionApplied then
		return
	end
	runtime.RivalsProtectionApplied = true

	local original_debug_info = debug.info

	local exec_funcs = {
		"getgenv", "hookfunction", "getrawmetatable", "hookmetamethod", "setreadonly",
		"islclosure", "checkcaller", "getnamecallmethod", "setnamecallmethod",
		"newcclosure", "getconnections", "getloadedmodules", "getsenv", "getreg",
		"getgc", "debug_getupvalues", "identifyexecutor", "getexecutorname",
		"request", "syn", "fluxus", "clonereference", "getcallingscript",
		"replicatesignal", "getscriptbytecode", "firesignal", "getupvalue",
		"getconstants", "getproto", "getstack"
	}

	local saved = {}
	local genv = getfenv()
	if not genv.getgenv then
		local ok, g = pcall(getgenv)
		if ok then genv = g end
	end

	for _, name in ipairs(exec_funcs) do
		if genv[name] then
			saved[name] = genv[name]
		end
	end

	local newcclosure = saved.newcclosure or function(f) return f end
	local setreadonly = saved.setreadonly or function() end
	local getnamecallmethod = saved.getnamecallmethod or function() return "" end
	local old_getfenv = genv.getfenv or getfenv
	local old_getgc = saved.getgc or getgc
	local old_getrawmetatable = saved.getrawmetatable or getmetatable

	local blocked_sources = {
		"LocalScript3", "MiscellaneousController", "ClientFighter", "Root",
		"CameraController", "ReplicatedController", "Camera", "out.lua"
	}

	local function is_anticheat(max_level)
		max_level = max_level or 5
		for i = 2, max_level do
			local info = original_debug_info(i, "s")
			if not info then break end
			for _, src in ipairs(blocked_sources) do
				if string.find(info, src, 1, true) then return true end
			end
		end
		return false
	end

	pcall(function()
		local function hooked_getfenv(level)
			if is_anticheat(5) then
				local real = old_getfenv(level)
				if type(real) == "table" then
					return setmetatable({}, {
						__index = function(_, k)
							if saved[k] then return nil end
							return real[k]
						end,
						__newindex = function(_, k, v) real[k] = v end,
						__metatable = "Locked"
					})
				end
			end
			return old_getfenv(level)
		end
		rawset(genv, "getfenv", newcclosure(hooked_getfenv))
	end)

	local function trap(obj)
		local ok, mt = pcall(old_getrawmetatable, obj)
		if not ok or not mt then return false end
		return mt.__tostring ~= nil
			or mt.__index ~= nil
			or mt.__newindex ~= nil
			or mt.__call ~= nil
			or mt.__len ~= nil
	end

	pcall(function()
		local function hooked_getgc(includeTables)
			local res = old_getgc(includeTables)
			local out = {}
			for _, v in ipairs(res) do
				if not trap(v) then
					table.insert(out, v)
				end
			end
			return out
		end
		rawset(genv, "getgc", newcclosure(hooked_getgc))
	end)

	pcall(function()
		if saved.debug_getupvalues or (debug and debug.getupvalue) then
			local noop = newcclosure(function() end)
			rawset(genv, "debug.getupvalue", noop)
			if debug then
				rawset(debug, "getupvalue", noop)
				rawset(debug, "getconstants", noop)
				rawset(debug, "getproto", noop)
				rawset(debug, "getstack", noop)
			end
		end
	end)

	local killed_r = false
	local function neutralize_shared_r_table(t)
		local ok, mt = pcall(old_getrawmetatable, t)
		if ok and mt then
			pcall(setreadonly, mt, false)
			pcall(function()
				mt.__index = function() return function() end end
				mt.__newindex = function() end
				mt.__call = function() end
			end)
			pcall(setreadonly, mt, true)
			return true
		end
		return false
	end

	local function kill_r()
		if not (shared and shared.r) then return false end
		if neutralize_shared_r_table(shared.r) then
			killed_r = true
			return true
		end
		return false
	end

	if not kill_r() then
		local ok_mt, shared_mt = pcall(old_getrawmetatable, shared)
		if ok_mt and shared_mt then
			pcall(setreadonly, shared_mt, false)
			local old_newindex = shared_mt.__newindex
			shared_mt.__newindex = function(t, k, v)
				if k == "r" and type(v) == "table" then
					if neutralize_shared_r_table(v) then
						killed_r = true
					end
				end
				return old_newindex(t, k, v)
			end
			pcall(setreadonly, shared_mt, true)
		else
			task.spawn(function()
				while not killed_r do
					pcall(kill_r)
					task.wait(0.1)
				end
			end)
		end
	end

	pcall(function()
		local mtInstance = old_getrawmetatable(game)
		local oldNamecall = mtInstance.__namecall
		local oldNewindex = mtInstance.__newindex
		local protected_services = {
			[game:GetService("Players")] = true,
			[workspace] = true,
			[ReplicatedStorage] = true,
			[game:GetService("ReplicatedFirst")] = true
		}
		pcall(setreadonly, mtInstance, false)
		mtInstance.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if method == "Kick" then
				error("Kick is disabled")
				return
			end
			if method == "PreloadAsync" and is_anticheat(5) then
				return
			end
			return oldNamecall(self, ...)
		end)
		mtInstance.__newindex = newcclosure(function(self, k, v)
			if type(k) ~= "string" then
				error("Invalid key type")
			end
			if k == "Name" and protected_services[self] then
				return
			end
			return oldNewindex(self, k, v)
		end)
		pcall(setreadonly, mtInstance, true)
	end)

	pcall(function()
		if not rawget(genv, "LPH_CRASH") then
			rawset(genv, "LPH_CRASH", function() end)
		end
	end)

	warn("wait atleast 4 seconds before running any detected scripts")
end

function Window:AddRivalsSkinChanger(opts)
	opts = opts or {}
	local window = self

	if opts.Protection ~= false then
		window:ApplyRivalsProtection()
	end
	local localPlayer = Players.LocalPlayer

	local cfg = {
		Name = opts.Name or "Skins",
		Icon = opts.Icon or "shirt",
		Timeout = opts.Timeout or 10,
		GalleryHeight = opts.GalleryHeight or 290,
	}

	local function loadGame()
		local modules = ReplicatedStorage:WaitForChild("Modules", cfg.Timeout)
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", cfg.Timeout)
		local remotes = ReplicatedStorage:WaitForChild("Remotes", cfg.Timeout)

		if not modules or not playerScripts or not remotes then
			return nil
		end

		local controllers = playerScripts:WaitForChild("Controllers", cfg.Timeout)
		local assets = playerScripts:WaitForChild("Assets", cfg.Timeout)
		local dataRemotes = remotes:WaitForChild("Data", cfg.Timeout)

		if not controllers or not assets or not dataRemotes then
			return nil
		end

		local viewModels = assets:WaitForChild("ViewModels", cfg.Timeout)
		local equipRemote = dataRemotes:WaitForChild("EquipCosmetic", cfg.Timeout)

		if not viewModels or not equipRemote then
			return nil
		end

		return {
			cosmetics = require(modules:WaitForChild("CosmeticLibrary", cfg.Timeout)),
			items = require(modules:WaitForChild("ItemLibrary", cfg.Timeout)),
			replicated = require(modules:WaitForChild("ReplicatedClass", cfg.Timeout)),
			data = require(controllers:WaitForChild("PlayerDataController", cfg.Timeout)),
			viewModels = viewModels,
			equipRemote = equipRemote,
		}
	end

	local loaded, gameData = pcall(loadGame)
	local tab = window:AddTab(cfg.Name, cfg.Icon)
	cfg.Tab = tab

	if not loaded or not gameData then
		local status = tab:AddSection("Skin Changer", "Left", "info", "status")
		status:AddLabel("Rivals was not detected. The skin changer only works inside Rivals.")
		local info = tab:AddSection("Info", "Right", "shirt", "rivals")
		info:AddLabel("Join Rivals and run the script again to use the skin changer.")
		return cfg
	end

	local env = type(getgenv) == "function" and getgenv() or _G
	env.RivalsSkinState = env.RivalsSkinState or { overrides = {}, originals = {}, hooked = false, unlock = true, applying = false }

	local state = env.RivalsSkinState
	state.game = gameData
	state.viewSet = {}

	for _, descendant in ipairs(gameData.viewModels:GetDescendants()) do
		if not state.viewSet[descendant.Name] or descendant:IsA("Model") then
			state.viewSet[descendant.Name] = descendant
		end
	end

	local rng = Random.new()
	local gallery = { entries = {}, search = "", filter = "All" }
	local byWeapon = {}
	local weaponNames = {}

	local function toImage(value)
		if type(value) == "number" and value > 0 then
			return "rbxassetid://" .. tostring(value)
		end

		if type(value) == "string" and value ~= "" then
			if tonumber(value) then
				return "rbxassetid://" .. value
			end

			if string.sub(value, 1, 13) == "rbxassetid://" or string.sub(value, 1, 11) == "rbxthumb://" or string.sub(value, 1, 4) == "http" then
				return value
			end
		end

		return nil
	end

	local imageTokens = { "image", "icon", "thumb", "preview", "decal" }

	local function findImage(info)
		for key, value in pairs(info) do
			if type(key) == "string" then
				local lowered = string.lower(key)

				for _, token in ipairs(imageTokens) do
					if string.find(lowered, token, 1, true) then
						local image = toImage(value)

						if image then
							return image
						end
					end
				end
			end
		end

		return nil
	end

	local function collect(strict)
		table.clear(byWeapon)
		table.clear(weaponNames)

		local total = 0

		for skinName, info in pairs(gameData.cosmetics.Cosmetics) do
			if type(skinName) == "string" and type(info) == "table" and info.Type == "Skin" and type(info.ItemName) == "string" then
				local usable = not strict or (gameData.items.ViewModels[skinName] ~= nil and state.viewSet[skinName] ~= nil)

				if usable then
					local list = byWeapon[info.ItemName]

					if not list then
						list = {}
						byWeapon[info.ItemName] = list
						table.insert(weaponNames, info.ItemName)
					end

					table.insert(list, { weapon = info.ItemName, skin = skinName, image = findImage(info) })
					total += 1
				end
			end
		end

		return total
	end

	if collect(true) == 0 then
		collect(false)
	end

	table.sort(weaponNames)

	for _, weaponName in ipairs(weaponNames) do
		table.sort(byWeapon[weaponName], function(a, b)
			return a.skin < b.skin
		end)
	end

	local function selectedSkin(weaponName)
		local entry = state.overrides[weaponName]

		if entry and entry.Skin and entry.Skin.Name then
			return entry.Skin.Name
		end

		return nil
	end

	local function replicate()
		local data = state.game.data.CurrentData

		if not data then
			return
		end

		state.applying = true

		pcall(function()
			data:Replicate("WeaponInventory")
		end)

		state.applying = false
	end

	local function applyAll()
		local controller = state.game.data

		if not controller.CurrentData then
			return
		end

		local changed = false

		for weaponName, types in pairs(state.overrides) do
			local weaponData = controller:GetWeaponData(weaponName)

			if weaponData then
				state.originals[weaponName] = state.originals[weaponName] or {}

				for cosmeticType, value in pairs(types) do
					local target = value or nil
					local current = weaponData[cosmeticType]

					if state.originals[weaponName][cosmeticType] == nil then
						state.originals[weaponName][cosmeticType] = current or false
					end

					if (current and current.Name) ~= (target and target.Name) then
						weaponData[cosmeticType] = target
						changed = true
					end
				end
			end
		end

		if changed then
			replicate()
		end
	end

	local function restore(weaponName)
		local controller = state.game.data
		local originals = state.originals[weaponName]

		state.originals[weaponName] = nil

		if not originals or not controller.CurrentData then
			return
		end

		local weaponData = controller:GetWeaponData(weaponName)

		if not weaponData then
			return
		end

		for cosmeticType, original in pairs(originals) do
			if not state.overrides[weaponName] or state.overrides[weaponName][cosmeticType] == nil then
				weaponData[cosmeticType] = original or nil
			end
		end

		replicate()
	end

	local function setSkin(weaponName, skinName)
		state.overrides[weaponName] = state.overrides[weaponName] or {}
		state.overrides[weaponName].Skin = { Name = skinName }
	end

	local function clearSkin(weaponName)
		local entry = state.overrides[weaponName]

		if entry then
			entry.Skin = nil

			if next(entry) == nil then
				state.overrides[weaponName] = nil
			end
		end

		restore(weaponName)
	end

	local function ownsFor(inventory, name, weaponName)
		if not inventory then
			return false
		end

		local owned = inventory[name]

		if owned == true then
			return true
		end

		if type(owned) == "table" then
			if owned.IsUniversal then
				return true
			end

			if weaponName and owned[weaponName] then
				return true
			end
		end

		return false
	end

	local refreshSelection

	local function handleEquip(weaponName, cosmeticType, name, extra)
		if type(weaponName) ~= "string" or type(cosmeticType) ~= "string" then
			return false
		end

		local inventory = state.game.data:Get("CosmeticInventory")

		if name ~= nil and ownsFor(inventory, name, weaponName) then
			if state.overrides[weaponName] then
				state.overrides[weaponName][cosmeticType] = nil
			end

			return false
		end

		if name == nil and not (state.overrides[weaponName] and state.overrides[weaponName][cosmeticType]) then
			return false
		end

		state.overrides[weaponName] = state.overrides[weaponName] or {}

		if name then
			state.overrides[weaponName][cosmeticType] = {
				Name = name,
				Inverted = type(extra) == "table" and extra.IsInverted or nil,
			}
		else
			state.overrides[weaponName][cosmeticType] = false
		end

		task.defer(function()
			applyAll()

			if state.refresh then
				state.refresh()
			end
		end)

		return true
	end

	state.handleEquip = handleEquip

	if not state.hooked then
		state.hooked = true

		pcall(function()
			if setreadonly then
				setreadonly(gameData.cosmetics, false)
			end
		end)

		for _, methodName in ipairs({ "OwnsCosmetic", "OwnsCosmeticNormally", "OwnsCosmeticUniversally", "OwnsCosmeticForWeapon", "OwnsCosmeticForSomething" }) do
			local original = gameData.cosmetics[methodName]

			gameData.cosmetics[methodName] = function(...)
				if state.unlock then
					return true
				end

				if original then
					return original(...)
				end

				return false
			end
		end

		pcall(function()
			if setreadonly then
				setreadonly(gameData.replicated, false)
			end
		end)

		local originalGet = gameData.replicated.Get

		gameData.replicated.Get = function(selfClass, key)
			local value = originalGet(selfClass, key)

			if key ~= "Name" or type(value) ~= "string" then
				return value
			end

			if not rawget(selfClass, "ClientItem") or rawget(selfClass, "Info") then
				return value
			end

			local current = state.game
			local info = current.cosmetics.Cosmetics[value]
			local base = info and info.Type == "Skin" and info.ItemName or value
			local weaponOverrides = state.overrides[base]

			if not weaponOverrides then
				return value
			end

			if weaponOverrides.Skin == false then
				return base
			end

			local skinName = weaponOverrides.Skin and weaponOverrides.Skin.Name

			if skinName and current.items.ViewModels[skinName] and (state.viewSet[skinName] or current.viewModels:FindFirstChild(skinName, true)) then
				return skinName
			end

			return value
		end

		if hookmetamethod and getnamecallmethod and newcclosure then
			local oldNamecall

			oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(selfRemote, ...)
				if selfRemote == state.game.equipRemote and getnamecallmethod() == "FireServer" then
					local weaponName, cosmeticType, name, extra = ...

					if state.handleEquip(weaponName, cosmeticType, name, extra) then
						return
					end
				end

				return oldNamecall(selfRemote, ...)
			end))
		end
	end

	task.spawn(function()
		state.game.data:WaitUntilLoaded()

		window:Bind(state.game.data:GetDataChangedSignal("WeaponInventory"), function()
			if not state.applying then
				applyAll()
			end
		end)

		applyAll()

		window:Bind(state.game.data.PlayerDataAdded, function()
			task.defer(applyAll)
		end)
	end)

	local function entryMatches(entry)
		if gallery.filter ~= "All" and gallery.filter ~= entry.weapon then
			return false
		end

		if gallery.search == "" then
			return true
		end

		return string.find(string.lower(entry.skin), gallery.search, 1, true) ~= nil
			or string.find(string.lower(entry.weapon), gallery.search, 1, true) ~= nil
	end

	local function applyFilters()
		for _, entry in ipairs(gallery.entries) do
			local visible = entryMatches(entry)

			if entry.card.Visible ~= visible then
				entry.card.Visible = visible
			end
		end
	end

	refreshSelection = function()
		for _, entry in ipairs(gallery.entries) do
			entry.setSelected(selectedSkin(entry.weapon) == entry.skin)
		end
	end

	state.refresh = refreshSelection
	table.insert(window.Refreshers, refreshSelection)

	local function selectEntry(entry)
		if selectedSkin(entry.weapon) == entry.skin then
			clearSkin(entry.weapon)
		else
			setSkin(entry.weapon, entry.skin)
			applyAll()
		end

		refreshSelection()
	end

	local function buildPreview(parent, skinName)
		local source = state.viewSet[skinName]

		if not source then
			return
		end

		local frame = create("ViewportFrame", {
			Name = "Preview",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.fromOffset(72, 42),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Ambient = Color3.fromRGB(200, 200, 200),
			LightColor = Color3.fromRGB(255, 255, 255),
			Parent = parent,
		})

		pcall(function()
			local model = Instance.new("Model")
			local clone = source:Clone()

			if clone:IsA("Model") then
				model = clone
			else
				for _, child in ipairs(clone:GetChildren()) do
					child.Parent = model
				end
			end

			for _, descendant in ipairs(model:GetDescendants()) do
				if descendant:IsA("BaseScript") then
					descendant:Destroy()
				end
			end

			model.Parent = frame

			local center, size = model:GetBoundingBox()
			local viewportCamera = Instance.new("Camera")

			viewportCamera.FieldOfView = 40
			viewportCamera.CFrame = CFrame.lookAt(center.Position + Vector3.new(size.Magnitude, size.Y * 0.3, size.Magnitude) * 0.9, center.Position)
			viewportCamera.Parent = frame

			frame.CurrentCamera = viewportCamera
		end)
	end

	local function buildCard(parent, entry, order)
		local card = create("TextButton", {
			Name = "Card",
			Size = UDim2.new(1, -2, 0, 56),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Visible = entryMatches(entry),
			Parent = parent,
		}, { corner(6), stroke(T.Stroke, 1) })

		local ring = getStroke(card)

		local accent = create("Frame", {
			Size = UDim2.new(0, 3, 1, -16),
			Position = UDim2.fromOffset(0, 8),
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = card,
		}, { corner(2) })

		if entry.image then
			create("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 8, 0.5, 0),
				Size = UDim2.fromOffset(72, 42),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Fit,
				Image = entry.image,
				Parent = card,
			})
		else
			buildPreview(card, entry.skin)
		end

		local skinLabel = label({
			Text = entry.skin,
			Font = Zero.FontBold,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(88, 10),
			Size = UDim2.new(1, -96, 0, 18),
			Parent = card,
		})

		label({
			Text = entry.weapon,
			TextSize = 11,
			TextColor3 = T.SubText,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(88, 30),
			Size = UDim2.new(1, -96, 0, 16),
			Parent = card,
		})

		function entry.setSelected(bool)
			skinLabel.TextColor3 = bool and T.Accent or T.Text
			accent.BackgroundColor3 = T.Accent
			tween(accent, { BackgroundTransparency = bool and 0 or 1 }, 0.15)
			tween(ring, { Color = bool and T.Accent or T.Stroke }, 0.15)
		end

		card.MouseEnter:Connect(function()
			tween(card, { BackgroundColor3 = T.ElementHover }, 0.12)
		end)

		card.MouseLeave:Connect(function()
			tween(card, { BackgroundColor3 = T.Element }, 0.15)
		end)

		entry.card = card

		card.MouseButton1Click:Connect(function()
			selectEntry(entry)
		end)
	end

	local function note(text)
		window:Notify({ Title = "Skins", Content = text, Duration = 2.5 })
	end

	local function resetAllSilent()
		local touched = {}

		for weaponName in pairs(state.overrides) do
			table.insert(touched, weaponName)
		end

		for _, weaponName in ipairs(touched) do
			clearSkin(weaponName)
		end
	end

	function cfg.RandomizeWeapon(weaponName)
		local list = byWeapon[weaponName]

		if not list or #list == 0 then
			return
		end

		setSkin(weaponName, list[rng:NextInteger(1, #list)].skin)
	end

	function cfg.RandomizeAll()
		for _, weaponName in ipairs(weaponNames) do
			cfg.RandomizeWeapon(weaponName)
		end

		applyAll()
		refreshSelection()
		note("Randomized all skins")
	end

	function cfg.RandomizeSelected()
		if gallery.filter == "All" then
			note("Select a weapon first")
			return
		end

		cfg.RandomizeWeapon(gallery.filter)
		applyAll()
		refreshSelection()
		note("Randomized " .. gallery.filter)
	end

	function cfg.ResetSelected()
		if gallery.filter == "All" then
			note("Select a weapon first")
			return
		end

		clearSkin(gallery.filter)
		refreshSelection()
		note("Reset " .. gallery.filter)
	end

	function cfg.ResetAll()
		resetAllSilent()
		refreshSelection()
		note("Reset all skins")
	end

	local skinsSub = tab:AddSubTab("Skins", "crosshair")
	local settingsSub = tab:AddSubTab("Settings", "settings")
	local configSub = tab:AddSubTab("Config", "folder")

	local filters = skinsSub:AddSection("Rivals Skins", "Left", "crosshair", "filter")

	local searchBox = filters:AddTextbox({
		Name = "Search",
		Placeholder = "Skin or weapon",
	})

	searchBox.Box:GetPropertyChangedSignal("Text"):Connect(function()
		gallery.search = string.lower(string.match(searchBox.Box.Text, "^%s*(.-)%s*$") or "")
		applyFilters()
	end)

	local filterItems = { "All" }

	for _, weaponName in ipairs(weaponNames) do
		table.insert(filterItems, weaponName)
	end

	filters:AddDropdown({
		Name = "Weapon",
		Options = filterItems,
		Default = "All",
		Callback = function(value)
			gallery.filter = type(value) == "string" and value or "All"
			applyFilters()
		end,
	})

	filters:AddButton({ Name = "Randomize Weapon", Callback = cfg.RandomizeSelected })
	filters:AddButton({ Name = "Reset Weapon", Callback = cfg.ResetSelected })

	local galleryTotal = 0

	for _, weaponName in ipairs(weaponNames) do
		galleryTotal += #byWeapon[weaponName]
	end

	local galleryBox = skinsSub:AddSection("Gallery", "Right", "layout-grid", tostring(galleryTotal) .. " skins")
	local galleryRow = galleryBox:AddRow(cfg.GalleryHeight)

	local grid = create("ScrollingFrame", {
		Size = UDim2.new(1, -2, 1, 0),
		Position = UDim2.fromOffset(1, 0),
		BackgroundColor3 = T.Background,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = galleryRow,
	}, {
		corner(6),
		stroke(T.Stroke, 1),
		padding(5, 5, 5, 5),
		create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	task.spawn(function()
		local order = 0

		for _, weaponName in ipairs(weaponNames) do
			for _, skinEntry in ipairs(byWeapon[weaponName]) do
				if not grid.Parent then
					return
				end

				order += 1

				local entry = { weapon = skinEntry.weapon, skin = skinEntry.skin, image = skinEntry.image }

				buildCard(grid, entry, order)
				table.insert(gallery.entries, entry)
				entry.setSelected(selectedSkin(entry.weapon) == entry.skin)

				if order % 12 == 0 then
					task.wait()
				end
			end
		end
	end)

	local actions = settingsSub:AddSection("Actions", "Left", "settings", "options")
	actions:AddLabel("Pick a weapon and click a skin to equip it. Click it again to go back to your default.")
	actions:AddToggle({
		Name = "Unlock All Cosmetics",
		Default = state.unlock,
		Flag = "RivalsSkinUnlock",
		Callback = function(value)
			state.unlock = value
		end,
	})

	local bulk = settingsSub:AddSection("Bulk", "Right", "shuffle", "all weapons")
	bulk:AddButton({ Name = "Randomize All", Callback = cfg.RandomizeAll })
	bulk:AddButton({ Name = "Reset All", Callback = cfg.ResetAll })

	local skinFolder = window.ConfigFolder .. "/rivals_skins"

	pcall(function()
		if not isfolder(window.ConfigFolder) then
			makefolder(window.ConfigFolder)
		end

		if not isfolder(skinFolder) then
			makefolder(skinFolder)
		end
	end)

	local function skinPath(name)
		return skinFolder .. "/" .. name .. ".json"
	end

	local function scanSkinConfigs()
		local out = {}
		local ok, files = pcall(listfiles, skinFolder)

		if ok and type(files) == "table" then
			for _, file in ipairs(files) do
				local name = string.match(file, "([^/\\]+)%.json$")

				if name then
					table.insert(out, name)
				end
			end
		end

		table.sort(out)

		return out
	end

	local function exportSelection()
		local result = {}

		for weaponName in pairs(state.overrides) do
			local skinName = selectedSkin(weaponName)

			if skinName then
				result[weaponName] = skinName
			end
		end

		return result
	end

	local function importSelection(data)
		resetAllSilent()

		for weaponName, skinName in pairs(data) do
			if type(weaponName) == "string" and type(skinName) == "string" and byWeapon[weaponName] then
				setSkin(weaponName, skinName)
			end
		end

		applyAll()
		refreshSelection()
	end

	local selectedConfig = nil

	local saved = configSub:AddSection("Skin Configs", "Left", "folder", "files")
	local nameBox = saved:AddTextbox({ Name = "Config name", Placeholder = "Config name" })
	local configList = saved:AddDropdown({
		Name = "Saved configs",
		Options = scanSkinConfigs(),
		Callback = function(value)
			selectedConfig = value
		end,
	})

	local manage = configSub:AddSection("Manage", "Right", "settings", "actions")

	manage:AddButton({
		Name = "Save",
		Callback = function()
			local typed = string.gsub(nameBox:Get(), "[^%w%-_ ]", "")
			local name = string.match(typed, "^%s*(.-)%s*$")

			if name == "" then
				name = selectedConfig
			end

			if type(name) ~= "string" or name == "" then
				note("Enter a config name")
				return
			end

			local ok = pcall(writefile, skinPath(name), HttpService:JSONEncode(exportSelection()))

			if not ok then
				note("File system unavailable")
				return
			end

			configList:SetOptions(scanSkinConfigs())
			configList:Set(name, true)
			selectedConfig = name
			nameBox:Set("", true)
			note("Saved " .. name)
		end,
	})

	manage:AddButton({
		Name = "Load",
		Callback = function()
			if not selectedConfig then
				note("Select a config first")
				return
			end

			local ok, data = pcall(function()
				return HttpService:JSONDecode(readfile(skinPath(selectedConfig)))
			end)

			if not ok or type(data) ~= "table" then
				note("Failed to load " .. selectedConfig)
				return
			end

			importSelection(data)
			note("Loaded " .. selectedConfig)
		end,
	})

	manage:AddButton({
		Name = "Delete",
		Callback = function()
			if not selectedConfig then
				note("Select a config first")
				return
			end

			local target = selectedConfig

			window:Confirm({
				Title = "Delete config",
				Content = "Delete " .. target .. "?",
				Callback = function()
					pcall(delfile, skinPath(target))
					selectedConfig = nil
					configList:SetOptions(scanSkinConfigs())
					note("Deleted " .. target)
				end,
			})
		end,
	})

	return cfg
end

function Window:Notify(opts)
	opts = opts or {}
	local duration = opts.Duration or 4
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Notes,
	})
	local card = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.fromOffset(270, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = holder,
	}, {
		corner(8),
		stroke(T.Stroke, 1),
		padding(12, 10, 12, 12),
		create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	label({
		Text = opts.Title or "Zero",
		Font = Zero.FontBold,
		TextSize = 13,
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
	local track = create("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = T.Track,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		Parent = card,
	}, { corner(1) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		NoTheme = true,
		Parent = track,
	}, { corner(1), create("UIGradient", { Color = accentGradient() }) })
	tween(card, { Position = UDim2.fromOffset(0, 0) }, 0.4, Quint)
	tween(fill, { Size = UDim2.fromScale(0, 1) }, duration, Enum.EasingStyle.Linear)
	task.delay(duration, function()
		if not card.Parent then
			return
		end
		tween(card, { Position = UDim2.fromOffset(270, 0) }, 0.3, Quint)
		task.wait(0.32)
		holder:Destroy()
	end)
end

function Window:Confirm(opts)
	opts = opts or {}
	local overlay = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 120,
		NoTheme = true,
		Parent = self.Gui,
	})
	local card = create("Frame", {
		Size = UDim2.new(0, 260, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Active = true,
		Parent = overlay,
	}, {
		corner(10),
		stroke(T.Stroke, 1),
		padding(14, 12, 14, 14),
		create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		create("UIScale", { Scale = 0.9 }),
	})
	local scale = card:FindFirstChildOfClass("UIScale")
	tween(overlay, { BackgroundTransparency = 0.5 }, 0.2)
	tween(scale, { Scale = 1 }, 0.3, Back)
	label({
		Text = opts.Title or "Confirm",
		Font = Zero.FontBold,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})
	label({
		Text = opts.Content or "Are you sure?",
		TextColor3 = T.SubText,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = card,
	})
	local buttons = create("Frame", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = card,
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local function button(text, order, primary)
		local btn = create("TextButton", {
			Size = UDim2.new(0.5, -4, 1, 0),
			BackgroundColor3 = primary and T.Accent or T.Element,
			BorderSizePixel = 0,
			Text = text,
			Font = Zero.FontMedium,
			TextSize = 12,
			TextColor3 = primary and T.Background or T.Text,
			AutoButtonColor = false,
			LayoutOrder = order,
			Parent = buttons,
		}, { corner(6), stroke(T.Stroke, 1) })
		if not primary then
			btn.MouseEnter:Connect(function()
				tween(btn, { BackgroundColor3 = T.ElementHover }, 0.12)
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, { BackgroundColor3 = T.Element }, 0.15)
			end)
		end
		return btn
	end
	local cancel = button(opts.Cancel or "Cancel", 1, false)
	local confirm = button(opts.Confirm or "Confirm", 2, true)
	local function dismiss(after)
		tween(overlay, { BackgroundTransparency = 1 }, 0.15)
		tween(scale, { Scale = 0.92 }, 0.15)
		task.delay(0.16, function()
			overlay:Destroy()
			if after then
				safe(after)
			end
		end)
	end
	cancel.MouseButton1Click:Connect(function()
		dismiss()
	end)
	confirm.MouseButton1Click:Connect(function()
		dismiss(opts.Callback)
	end)
end

function Window:CreatePopup(width, title)
	local window = self
	local pop = { IsOpen = false }
	local token = 0

	pop.Overlay = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 50,
		Visible = false,
		NoTheme = true,
		Parent = self.Gui,
	})
	pop.Panel = create("CanvasGroup", {
		Size = UDim2.new(0, width, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 51,
		Visible = false,
		GroupTransparency = 1,
		Parent = self.Gui,
	}, {
		corner(10),
		stroke(T.Stroke, 1),
		padding(10, 4, 10, 12),
		create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local head = create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = pop.Panel,
	})
	label({
		Text = title or "Settings",
		Font = Zero.FontBold,
		Size = UDim2.fromScale(1, 1),
		Parent = head,
	})
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = head,
	})

	function pop.Open(anchor)
		if window.PopupClose then
			window.PopupClose()
		end
		window:ClosePicker()
		token = token + 1
		local mine = token
		pop.IsOpen = true
		pop.Overlay.Visible = true
		pop.Panel.Visible = true
		pop.Panel.GroupTransparency = 1
		window.PopupClose = pop.Close
		if pop.OnState then
			pop.OnState(true)
		end
		task.spawn(function()
			RunService.Heartbeat:Wait()
			if mine ~= token then
				return
			end
			local viewport = window.Gui.AbsoluteSize
			local size = pop.Panel.AbsoluteSize
			local x = math.clamp(anchor.AbsolutePosition.X + anchor.AbsoluteSize.X - size.X, 8, math.max(viewport.X - size.X - 8, 8))
			local y = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + 8
			if y + size.Y > viewport.Y - 8 then
				y = math.max(anchor.AbsolutePosition.Y - size.Y - 8, 8)
			end
			pop.X = x
			pop.Y = y
			pop.Panel.Position = UDim2.fromOffset(x, y + 10)
			tween(pop.Panel, { Position = UDim2.fromOffset(x, y), GroupTransparency = 0 }, 0.28, Quint)
		end)
	end

	function pop.Close()
		if not pop.IsOpen then
			return
		end
		pop.IsOpen = false
		token = token + 1
		local mine = token
		pop.Overlay.Visible = false
		if window.PopupClose == pop.Close then
			window.PopupClose = nil
		end
		if pop.OnState then
			pop.OnState(false)
		end
		tween(pop.Panel, { GroupTransparency = 1, Position = UDim2.fromOffset(pop.X or 0, (pop.Y or 0) + 8) }, 0.18, Quint)
		task.delay(0.2, function()
			if mine == token and pop.Panel.Parent then
				pop.Panel.Visible = false
			end
		end)
	end

	pop.Overlay.MouseButton1Click:Connect(pop.Close)
	return pop
end

function Window:ClosePicker()
	if self.PickerClose then
		self.PickerClose()
	end
end

function Window:OpenPicker(anchor, color, callback)
	self:ClosePicker()
	local gui = self.Gui
	local h, s, v = Color3.toHSV(color)
	local connections = {}
	local mode = nil
	local shift = 0
	local closing = false

	local overlay = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 80,
		NoTheme = true,
		Parent = gui,
	})

	local width, height = 216, 196
	local viewport = gui.AbsoluteSize
	local x = math.clamp(anchor.AbsolutePosition.X + anchor.AbsoluteSize.X - width, 8, math.max(viewport.X - width - 8, 8))
	local y = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + 6
	if y + height > viewport.Y - 8 then
		y = math.max(anchor.AbsolutePosition.Y - height - 6, 8)
	end

	local panel = create("CanvasGroup", {
		Size = UDim2.fromOffset(width, height),
		Position = UDim2.fromOffset(x, y + 10),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 81,
		GroupTransparency = 1,
		Parent = gui,
	}, { corner(10), stroke(T.Stroke, 1) })

	local sv = create("Frame", {
		Size = UDim2.fromOffset(196, 112),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		NoTheme = true,
		Parent = panel,
	}, { corner(5) })

	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 1,
		NoTheme = true,
		Parent = sv,
	}, { create("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })

	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 2,
		NoTheme = true,
		Parent = sv,
	}, { create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })

	local knob = create("Frame", {
		Size = UDim2.fromOffset(12, 12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 4,
		NoTheme = true,
		Parent = sv,
	}, { corner(6), create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })

	local svHit = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
		Parent = sv,
	})

	local keypoints = {}
	for i = 0, 6 do
		table.insert(keypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 >= 1 and 0.999 or i / 6, 1, 1)))
	end
	local hueBar = create("Frame", {
		Size = UDim2.fromOffset(196, 12),
		Position = UDim2.fromOffset(10, 132),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		NoTheme = true,
		Parent = panel,
	}, { corner(6), create("UIGradient", { Color = ColorSequence.new(keypoints) }) })

	local hueKnob = create("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 2,
		NoTheme = true,
		Parent = hueBar,
	}, { corner(7), create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })

	local hueHit = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 22),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
		Parent = hueBar,
	})

	local preview = create("Frame", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.fromOffset(10, 156),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		NoTheme = true,
		Parent = panel,
	}, { corner(6), stroke(T.Track, 1) })

	local hexHolder = create("Frame", {
		Size = UDim2.fromOffset(158, 28),
		Position = UDim2.fromOffset(48, 156),
		BackgroundColor3 = T.Background,
		BorderSizePixel = 0,
		Parent = panel,
	}, { corner(6), stroke(T.Stroke, 1) })
	local hexStroke = getStroke(hexHolder)
	local hex = create("TextBox", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "#RRGGBB",
		PlaceholderColor3 = T.SubText,
		TextColor3 = T.Text,
		Font = Zero.FontMedium,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = hexHolder,
	}, { padding(10, 0, 10, 0) })
	hex.Focused:Connect(function()
		tween(hexStroke, { Color = T.Accent }, 0.15)
	end)

	local function current()
		return Color3.fromHSV(h, s, v)
	end

	local function refresh(fire)
		local now = current()
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		knob.Position = UDim2.fromScale(s, 1 - v)
		hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
		hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		preview.BackgroundColor3 = now
		hex.Text = "#" .. now:ToHex()
		if fire then
			callback(now)
		end
	end

	local function inset()
		local ok, value = pcall(function()
			return GuiService:GetGuiInset()
		end)
		return ok and value.Y or 0
	end

	local function calibrate(input, hit)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local top = hit.AbsolutePosition.Y
		local bottom = top + hit.AbsoluteSize.Y
		if input.Position.Y >= top and input.Position.Y <= bottom then
			shift = 0
		else
			shift = inset()
		end
	end

	local function pointer(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			return input.Position.X, input.Position.Y + shift
		end
		local location = UserInputService:GetMouseLocation()
		return location.X, location.Y
	end

	local function updateSV(input)
		local px, py = pointer(input)
		s = math.clamp((px - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
		v = 1 - math.clamp((py - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
		refresh(true)
	end

	local function updateHue(input)
		local px = pointer(input)
		h = math.clamp((px - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1)
		refresh(true)
	end

	svHit.InputBegan:Connect(function(input)
		if isPointer(input) then
			calibrate(input, svHit)
			mode = "sv"
			tween(knob, { Size = UDim2.fromOffset(16, 16) }, 0.15, Back)
			updateSV(input)
		end
	end)
	hueHit.InputBegan:Connect(function(input)
		if isPointer(input) then
			calibrate(input, hueHit)
			mode = "hue"
			tween(hueKnob, { Size = UDim2.fromOffset(18, 18) }, 0.15, Back)
			updateHue(input)
		end
	end)
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if isMove(input) then
			if mode == "sv" then
				updateSV(input)
			elseif mode == "hue" then
				updateHue(input)
			end
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if isPointer(input) and mode then
			mode = nil
			tween(knob, { Size = UDim2.fromOffset(12, 12) }, 0.15, Back)
			tween(hueKnob, { Size = UDim2.fromOffset(14, 14) }, 0.15, Back)
		end
	end))

	hex.FocusLost:Connect(function()
		tween(hexStroke, { Color = T.Stroke }, 0.15)
		local ok, parsed = pcall(Color3.fromHex, hex.Text)
		if ok and parsed then
			h, s, v = Color3.toHSV(parsed)
			refresh(true)
		else
			refresh(false)
		end
	end)

	local function close()
		if closing then
			return
		end
		closing = true
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		overlay:Destroy()
		self.PickerClose = nil
		tween(panel, { GroupTransparency = 1, Position = UDim2.fromOffset(x, y + 8) }, 0.16, Quint)
		task.delay(0.18, function()
			panel:Destroy()
		end)
	end

	overlay.MouseButton1Click:Connect(close)
	self.PickerClose = close
	refresh(false)
	tween(panel, { GroupTransparency = 0, Position = UDim2.fromOffset(x, y) }, 0.26, Quint)
end

function Window:SetTheme(new)
	for key, value in pairs(new) do
		if T[key] ~= nil then
			T[key] = value
		end
	end
	local alive = {}
	for _, entry in ipairs(Registry) do
		local obj = entry[1]
		if obj.Parent ~= nil then
			obj[entry[2]] = T[entry[3]]
			table.insert(alive, entry)
		end
	end
	Registry = alive
	for _, refresh in ipairs(self.Refreshers) do
		refresh()
	end
end

function Window:SetWatermark(text)
	if not self.Watermark then
		local frame = create("Frame", {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Position = UDim2.fromOffset(12, 12),
			BackgroundColor3 = T.Section,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = self.Gui,
		}, {
			corner(8),
			stroke(T.Stroke, 1),
			padding(9, 6, 11, 6),
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 7),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})
		local mark = icon(frame, self.LogoIcon or "atom", 13, T.Accent)
		mark.LayoutOrder = 1
		local lbl = label({
			Size = UDim2.new(0, 0, 0, 14),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			Parent = frame,
		})
		local info = { Frame = frame, Label = lbl, Text = "" }
		self.Watermark = info

		local frames = 0
		local last = os.clock()
		local fps = 60
		local function update()
			local ping = 0
			pcall(function()
				ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			local line = info.Text .. "  |  " .. fps .. " fps  |  " .. ping .. " ms"
			if lbl.Text ~= line then
				lbl.Text = line
			end
		end
		self:Bind(RunService.RenderStepped, function()
			frames = frames + 1
			local now = os.clock()
			if now - last >= 0.5 then
				fps = math.floor(frames / (now - last) + 0.5)
				frames = 0
				last = now
				update()
			end
		end)
		info.Update = update
	end
	self.Watermark.Text = text or ""
	self.Watermark.Update()
end

function Window:SetFooter(text)
	if self.FooterLabel then
		self.FooterLabel.Text = tostring(text or "")
	end
end

function Window:SetFooterVisible(state)
	if self.Footer then
		self.Footer.Visible = state
	end
end

function Window:SetWatermarkVisible(state)
	if self.Watermark then
		self.Watermark.Frame.Visible = state
	end
end

function Window:SetVisible(state)
	self.Shown = state
	if state then
		self.Main.Visible = true
		tween(self.Scale, { Scale = 1 }, 0.3, Back)
	else
		self:ClosePicker()
		if self.PopupClose then
			self.PopupClose()
		end
		tween(self.Scale, { Scale = 0.9 }, 0.18, Quint)
		task.delay(0.19, function()
			if not self.Shown then
				self.Main.Visible = false
			end
		end)
	end
end

function Window:Close()
	self:ClosePicker()
	if self.PopupClose then
		self.PopupClose()
	end
	tween(self.Scale, { Scale = 0.9 }, 0.18, Quint)
	task.delay(0.2, function()
		self:Destroy()
	end)
end

function Window:Destroy()
	self:ClosePicker()
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	self.Connections = {}
	self.Gui:Destroy()
	Registry = {}
end

function Zero:CreateWindow(opts)
	opts = opts or {}
	Registry = {}
	local window = setmetatable({ Connections = {}, Tabs = {}, Flags = {}, Searchable = {}, Refreshers = {}, Shown = true }, Window)
	window.LogoIcon = opts.Logo or "97669122739360"
	window.ConfigFolder = opts.ConfigFolder or "ZeroConfigs"
	window.Anonymous = opts.Anonymous == true

	local parent = getGuiParent()
	local old = parent:FindFirstChild("ZeroUi")
	if old then
		old:Destroy()
	end

	local gui = create("ScreenGui", {
		Name = "ZeroUi",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = parent
	window.Gui = gui
	window.Layer = create("Frame", {
		Name = "Layer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 500,
		NoTheme = true,
		Parent = gui,
	})

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local width = math.floor(math.min(opts.Width or 620, viewport.X - 20) / 2) * 2
	local height = math.floor(math.min(opts.Height or 380, viewport.Y - 20) / 2) * 2

	local main = create("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(width, height),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = T.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	}, {
		corner(12),
		stroke(T.Stroke, 1),
		create("UIScale", { Scale = 0.88 }),
	})
	window.Main = main
	window.Scale = main:FindFirstChildOfClass("UIScale")
	local intro = opts.Intro ~= false
	if not intro then
		tween(window.Scale, { Scale = 1 }, 0.45, Back)
	end

	local top = create("Frame", {
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = main,
	}, { corner(12) })
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 1, -20),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = top,
	})
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = top,
	})

	local brand = create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = top,
	}, {
		padding(10, 0, 10, 0),
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})
	local logoBox = create("Frame", {
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = T.Element,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = brand,
	}, { corner(8), stroke(T.Accent, 1) })
	getStroke(logoBox).Transparency = 0.55
	local logo = icon(logoBox, window.LogoIcon, 20, T.Accent)
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.5)
	label({
		Text = opts.Title or "Zero",
		Font = Zero.FontBold,
		TextSize = 14,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
		Parent = brand,
	})
	label({
		Text = "v" .. tostring(opts.Version or Zero.Version),
		TextSize = 11,
		TextColor3 = T.SubText,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 3,
		Parent = brand,
	})

	local function topButton(iconName, offset, hoverColor)
		local button = create("TextButton", {
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.new(1, offset, 0, 6),
			BackgroundColor3 = hoverColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = top,
		}, { corner(13) })
		local img = icon(button, iconName, 14, T.SubText)
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromScale(0.5, 0.5)
		button.MouseEnter:Connect(function()
			tween(button, { BackgroundTransparency = 0 }, 0.12)
			tween(img, { ImageColor3 = T.Text }, 0.12)
		end)
		button.MouseLeave:Connect(function()
			tween(button, { BackgroundTransparency = 1 }, 0.15)
			tween(img, { ImageColor3 = T.SubText }, 0.15)
		end)
		return button
	end

	local closeButton = topButton("x", -34, T.Danger)
	local minimizeButton = topButton("minus", -62, T.Element)

	local dragging = false
	local dragStart = nil
	local startPosition = nil
	top.InputBegan:Connect(function(input)
		if isPointer(input) then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position
		end
	end)
	window:Bind(UserInputService.InputChanged, function(input)
		if dragging and isMove(input) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
	window:Bind(UserInputService.InputEnded, function(input)
		if isPointer(input) then
			dragging = false
		end
	end)

	local body = create("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -38),
		Position = UDim2.fromOffset(0, 38),
		BackgroundTransparency = 1,
		Parent = main,
	})

	local minimized = false
	local shrink = (38 - height) / 2
	minimizeButton.MouseButton1Click:Connect(function()
		minimized = not minimized
		local pos = main.Position
		window:ClosePicker()
		if window.PopupClose then
			window.PopupClose()
		end
		if minimized then
			tween(main, {
				Size = UDim2.fromOffset(width, 38),
				Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + shrink),
			}, 0.3, Quint)
			task.delay(0.12, function()
				if minimized then
					body.Visible = false
				end
			end)
		else
			body.Visible = true
			tween(main, {
				Size = UDim2.fromOffset(width, height),
				Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset - shrink),
			}, 0.3, Quint)
		end
	end)
	closeButton.MouseButton1Click:Connect(function()
		window:SetVisible(false)
	end)

	local toggle = create("TextButton", {
		Name = "Toggle",
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.new(0, 14, 0.5, -24),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 60,
		Parent = gui,
	}, { corner(24), stroke(T.Accent, 1) })
	local toggleLogo = icon(toggle, window.LogoIcon, 30, T.Accent)
	toggleLogo.AnchorPoint = Vector2.new(0.5, 0.5)
	toggleLogo.Position = UDim2.fromScale(0.5, 0.5)
	toggleLogo.ZIndex = 61
	window.Toggle = toggle

	local toggleDragging = false
	local toggleMoved = false
	local toggleStart = nil
	local togglePosition = nil
	toggle.InputBegan:Connect(function(input)
		if isPointer(input) then
			toggleDragging = true
			toggleMoved = false
			toggleStart = input.Position
			togglePosition = toggle.Position
			tween(toggle, { Size = UDim2.fromOffset(44, 44) }, 0.12)
		end
	end)
	window:Bind(UserInputService.InputChanged, function(input)
		if toggleDragging and isMove(input) then
			local delta = input.Position - toggleStart
			if delta.Magnitude > 6 then
				toggleMoved = true
			end
			if toggleMoved then
				local screen = gui.AbsoluteSize
				local x = math.clamp(togglePosition.X.Offset + delta.X, 0, math.max(screen.X - 48, 0))
				local y = math.clamp(togglePosition.Y.Offset + delta.Y + screen.Y * togglePosition.Y.Scale, 0, math.max(screen.Y - 48, 0))
				toggle.Position = UDim2.fromOffset(x, y)
			end
		end
	end)
	window:Bind(UserInputService.InputEnded, function(input)
		if isPointer(input) and toggleDragging then
			toggleDragging = false
			tween(toggle, { Size = UDim2.fromOffset(48, 48) }, 0.2, Back)
			if not toggleMoved then
				window:SetVisible(not window.Shown)
			end
		end
	end)

	local sidebar = create("Frame", {
		Size = UDim2.new(0, 130, 1, 0),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = body,
	}, { corner(12) })
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	create("Frame", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -20, 0, 0),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	create("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	window.TabList = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -96),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, {
		create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
		padding(8, 10, 9, 8),
	})

	local searchHolder = create("Frame", {
		Size = UDim2.new(1, -17, 0, 28),
		Position = UDim2.new(0, 8, 1, -92),
		BackgroundColor3 = T.Background,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(7), stroke(T.Stroke, 1) })
	local searchStroke = getStroke(searchHolder)
	local searchIcon = icon(searchHolder, "search", 14, T.SubText)
	searchIcon.AnchorPoint = Vector2.new(0, 0.5)
	searchIcon.Position = UDim2.new(0, 8, 0.5, 0)
	local searchBox = create("TextBox", {
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.fromOffset(28, 0),
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
		Parent = searchHolder,
	})
	searchBox.Focused:Connect(function()
		tween(searchStroke, { Color = T.Accent }, 0.15)
		tween(searchIcon, { ImageColor3 = T.Accent }, 0.15)
	end)
	searchBox.FocusLost:Connect(function()
		tween(searchStroke, { Color = T.Stroke }, 0.15)
		tween(searchIcon, { ImageColor3 = T.SubText }, 0.15)
	end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		window:ApplySearch(searchBox.Text)
	end)

	local profile = create("Frame", {
		Size = UDim2.new(1, -17, 0, 40),
		Position = UDim2.new(0, 8, 1, -50),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	local localPlayer = Players.LocalPlayer
	local avatar = create("ImageLabel", {
		Size = UDim2.fromOffset(32, 32),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = T.Element,
		BorderSizePixel = 0,
		Parent = profile,
	}, { corner(16), stroke(T.Accent, 1) })
	getStroke(avatar).Transparency = 0.5
	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and avatar.Parent then
			avatar.Image = image
		end
	end)
	label({
		Text = opts.Anonymous and "XXX" or localPlayer.DisplayName,
		Font = Zero.FontBold,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -40, 0, 16),
		Position = UDim2.fromOffset(40, 5),
		Parent = profile,
	})
	label({
		Text = opts.Anonymous and "@XXX" or "@" .. localPlayer.Name,
		TextSize = 10,
		TextColor3 = T.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -40, 0, 14),
		Position = UDim2.fromOffset(40, 21),
		Parent = profile,
	})

	window.Pages = create("Frame", {
		Size = UDim2.new(1, -130, 1, -26),
		Position = UDim2.fromOffset(130, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = body,
	})

	local footer = create("Frame", {
		Name = "Footer",
		Size = UDim2.new(1, -130, 0, 26),
		Position = UDim2.new(0, 130, 1, -26),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = body,
	}, { corner(12) })
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = footer,
	})
	create("Frame", {
		Size = UDim2.new(0, 14, 1, 0),
		BackgroundColor3 = T.Section,
		BorderSizePixel = 0,
		Parent = footer,
	})
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = footer,
	})
	window.FooterLabel = label({
		Text = opts.Footer or "Zero.gg",
		TextSize = 11,
		TextColor3 = T.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(0.6, -12, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = footer,
	})
	label({
		Text = "v" .. tostring(opts.Version or Zero.Version),
		TextSize = 11,
		TextColor3 = T.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0.4, -12, 1, 0),
		Position = UDim2.fromScale(0.6, 0),
		Parent = footer,
	})
	window.Footer = footer

	window.Notes = create("Frame", {
		Size = UDim2.new(0, 240, 1, -24),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	})

	table.insert(window.Refreshers, function()
		if window.Active then
			window:SelectTab(window.Active)
		end
	end)

	if intro then
		main.Visible = false
		toggle.Visible = false
		local duration = opts.IntroTime or 1.6
		local card = create("CanvasGroup", {
			Name = "Intro",
			Size = UDim2.fromOffset(240, 132),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = T.Section,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			ZIndex = 900,
			Parent = gui,
		}, {
			corner(14),
			stroke(T.Stroke, 1),
			create("UIScale", { Scale = 0.85 }),
		})
		local introBox = create("Frame", {
			Size = UDim2.fromOffset(44, 44),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 16),
			BackgroundColor3 = T.Element,
			BorderSizePixel = 0,
			Parent = card,
		}, { corner(12), stroke(T.Accent, 1) })
		getStroke(introBox).Transparency = 0.45
		local introLogo = icon(introBox, window.LogoIcon, 30, T.Accent)
		introLogo.AnchorPoint = Vector2.new(0.5, 0.5)
		introLogo.Position = UDim2.fromScale(0.5, 0.5)
		label({
			Text = opts.Title or "Zero",
			Font = Zero.FontBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 68),
			Parent = card,
		})
		local introText = label({
			Text = opts.IntroText or "Loading...",
			TextSize = 11,
			TextColor3 = T.SubText,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, 88),
			Parent = card,
		})
		local introTrack = create("Frame", {
			Size = UDim2.new(1, -40, 0, 4),
			Position = UDim2.new(0, 20, 1, -16),
			BackgroundColor3 = T.Track,
			BorderSizePixel = 0,
			Parent = card,
		}, { corner(2) })
		local introFill = create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Parent = introTrack,
		}, { corner(2), create("UIGradient", { Color = accentGradient() }) })

		local introScale = card:FindFirstChildOfClass("UIScale")
		tween(card, { GroupTransparency = 0 }, 0.3)
		tween(introScale, { Scale = 1 }, 0.45, Back)
		tween(introFill, { Size = UDim2.fromScale(1, 1) }, duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		task.spawn(function()
			task.wait(duration * 0.6)
			if introText.Parent then
				introText.Text = "Almost ready..."
			end
			task.wait(duration * 0.4 + 0.15)
			if not gui.Parent then
				return
			end
			tween(card, { GroupTransparency = 1 }, 0.25)
			tween(introScale, { Scale = 0.92 }, 0.25, Quint)
			task.wait(0.25)
			card:Destroy()
			if not gui.Parent then
				return
			end
			main.Visible = true
			toggle.Visible = true
			tween(window.Scale, { Scale = 1 }, 0.45, Back)
		end)
	end

	return window
end

return Zero

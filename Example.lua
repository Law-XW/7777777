local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Law-XW/7777777/refs/heads/main/Source.lua"))()

local Window = Library:CreateWindow({
	Title = "Zero",
	Logo = "97669122739360",
	ConfigFolder = "ZeroConfigs",
	Version = "1.9.0",
	Footer = "Zero.gg",
	Intro = true,
	IntroText = "Loading...",
	Anonymous = true,
})

Window:SetWatermark("Zero")

Window:AddHomeManager()

local Tab = Window:AddTab("Example", "home")

local Controls = Tab:AddSection("Example Controls", "Left", "sliders-horizontal", "controls")
local Inputs = Tab:AddSection("Example Inputs", "Right", "list", "inputs")

Controls:AddLabel("Example Label")

local Toggle = Controls:AddToggle({
	Name = "Example Toggle",
	Default = false,
	Flag = "ExampleToggle",
	Color = Color3.fromRGB(52, 168, 222),
	ColorFlag = "ExampleToggleColor",
	Callback = function(Value)
		print("Example Toggle", Value)
	end,
	ColorCallback = function(Color)
		print("Example Toggle Color", Color)
	end,
})

local ToggleSettings = Toggle:AddSettings({ Title = "Example Settings" })
ToggleSettings:AddSlider({
	Name = "Example Strength",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
	Flag = "ExampleStrength",
})
ToggleSettings:AddDropdown({
	Name = "Example Style",
	Options = { "Smooth", "Snappy", "Instant" },
	Default = "Smooth",
	Flag = "ExampleStyle",
})
ToggleSettings:AddToggle({
	Name = "Example Visible Only",
	Default = true,
	Flag = "ExampleVisibleOnly",
})

Controls:AddSlider({
	Name = "Example Slider",
	Min = 0,
	Max = 100,
	Default = 16,
	Increment = 1,
	Suffix = " st",
	Flag = "ExampleSlider",
	Callback = function(Value)
		print("Example Slider", Value)
	end,
})

Controls:AddKeybind({
	Name = "Example Keybind",
	Default = Enum.KeyCode.E,
	Flag = "ExampleKeybind",
	Callback = function(Key)
		print("Example Keybind set to", Key and Key.Name or "None")
	end,
	Pressed = function()
		Window:Notify({ Title = "Example", Content = "Keybind pressed", Duration = 2 })
	end,
})

Controls:AddButton({
	Name = "Example Button",
	Callback = function()
		Window:Notify({ Title = "Example", Content = "Button pressed", Duration = 3 })
	end,
})

Controls:AddButton({
	Name = "Example Dialog",
	Callback = function()
		Window:Confirm({
			Title = "Example",
			Content = "Do you want to continue?",
			Callback = function()
				Window:Notify({ Title = "Example", Content = "Confirmed", Duration = 2 })
			end,
		})
	end,
})

Inputs:AddDropdown({
	Name = "Example Dropdown",
	Options = { "Ocean", "Reef", "Abyss" },
	Default = "Ocean",
	Flag = "ExampleDropdown",
	Callback = function(Value)
		print("Example Dropdown", Value)
	end,
})

Inputs:AddDropdown({
	Name = "Example Multi Dropdown",
	Options = { "Players", "NPCs", "Items", "Vehicles" },
	Default = { "Players" },
	Multi = true,
	Flag = "ExampleMultiDropdown",
	Callback = function(Values)
		print("Example Multi Dropdown", table.concat(Values, ", "))
	end,
})

Inputs:AddTextbox({
	Name = "Example Textbox",
	Placeholder = "Type here",
	Flag = "ExampleTextbox",
	Callback = function(Text)
		print("Example Textbox", Text)
	end,
})

Inputs:AddColorPicker({
	Name = "Example Color Picker",
	Default = Color3.fromRGB(255, 120, 90),
	Flag = "ExampleColorPicker",
	Callback = function(Color)
		print("Example Color Picker", Color)
	end,
})

local Combat = Window:AddTab("Combat", "swords")

local Aimbot = Combat:AddSubTab("Aimbot", "crosshair")
local AimbotMain = Aimbot:AddSection("Aimbot", "Left", "crosshair", "main")
AimbotMain:AddToggle({
	Name = "Enabled",
	Default = false,
	Flag = "AimbotEnabled",
})
AimbotMain:AddSlider({
	Name = "Smoothness",
	Min = 0,
	Max = 100,
	Default = 20,
	Increment = 1,
	Suffix = "%",
	Flag = "AimbotSmoothness",
})
local AimbotFov = Aimbot:AddSection("Field of View", "Right", "circle", "fov")
AimbotFov:AddSlider({
	Name = "Radius",
	Min = 10,
	Max = 500,
	Default = 120,
	Increment = 1,
	Suffix = " px",
	Flag = "AimbotRadius",
})
AimbotFov:AddColorPicker({
	Name = "Circle Color",
	Default = Color3.fromRGB(52, 168, 222),
	Flag = "AimbotCircleColor",
})

local Visuals = Combat:AddSubTab("Visuals", "eye")
local VisualsMain = Visuals:AddSection("ESP", "Left", "eye", "visuals")
VisualsMain:AddToggle({
	Name = "Boxes",
	Default = false,
	Flag = "EspBoxes",
})
VisualsMain:AddToggle({
	Name = "Names",
	Default = false,
	Flag = "EspNames",
})
local VisualsColors = Visuals:AddSection("Colors", "Right", "palette", "colors")
VisualsColors:AddColorPicker({
	Name = "Box Color",
	Default = Color3.fromRGB(255, 120, 90),
	Flag = "EspBoxColor",
})

Window:AddSettingsManager()

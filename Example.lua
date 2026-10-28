local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Law-XW/7777777/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
	Title = "Example",
	Size = Vector2.new(580, 380),
})

local Main = Window:AddTab({ Name = "Example", Icon = "home" })
local Visuals = Window:AddTab({ Name = "Example Visuals", Icon = "eye" })
local Settings = Window:AddTab({ Name = "Example Settings", Icon = "settings" })

local Controls = Main:AddSection("Example Controls")

Controls:AddLabel("Example label")
Controls:AddDivider()

Controls:AddButton({
	Name = "Example Button",
	Callback = function()
		Window:Notify({
			Title = "Example",
			Content = "Example button pressed",
			Duration = 3,
		})
	end,
})

local Toggle = Controls:AddToggle({
	Name = "Example Toggle",
	Default = false,
	Flag = "ExampleToggle",
	Color = Color3.fromRGB(52, 168, 222),
	ColorFlag = "ExampleToggleColor",
	Callback = function(value)
		print("Example Toggle", value)
	end,
	ColorCallback = function(color)
		print("Example Toggle Color", color)
	end,
})

local ToggleSettings = Toggle:AddSettings({ Title = "Example Toggle Settings" })

ToggleSettings:AddSlider({
	Name = "Example Power",
	Min = 0,
	Max = 10,
	Default = 5,
	Increment = 1,
	Flag = "ExamplePower",
	Callback = function(value)
		print("Example Power", value)
	end,
})

ToggleSettings:AddToggle({
	Name = "Example Option",
	Default = true,
	Flag = "ExampleOption",
})

Controls:AddSlider({
	Name = "Example Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
	Flag = "ExampleSlider",
	Callback = function(value)
		print("Example Slider", value)
	end,
})

Controls:AddTextbox({
	Name = "Example Textbox",
	Placeholder = "Example text",
	Flag = "ExampleTextbox",
	Callback = function(value)
		print("Example Textbox", value)
	end,
})

local Choices = Visuals:AddSection("Example Choices")

Choices:AddDropdown({
	Name = "Example Dropdown",
	Options = { "Example 1", "Example 2", "Example 3" },
	Default = "Example 1",
	Flag = "ExampleDropdown",
	Callback = function(value)
		print("Example Dropdown", value)
	end,
})

Choices:AddDropdown({
	Name = "Example Multi",
	Options = { "Example A", "Example B", "Example C", "Example D" },
	Default = { "Example A" },
	Multi = true,
	Flag = "ExampleMulti",
	Callback = function(values)
		print("Example Multi", table.concat(values, ", "))
	end,
})

Choices:AddColorPicker({
	Name = "Example Color",
	Default = Color3.fromRGB(255, 80, 80),
	Flag = "ExampleColor",
	Callback = function(color)
		print("Example Color", color)
	end,
})

local Appearance = Settings:AddSection("Example Appearance")

Appearance:AddDropdown({
	Name = "Example Theme",
	Options = Library.ThemeOrder,
	Default = "Ocean",
	Callback = function(name)
		Window:SetTheme(name)
	end,
})

local Config = Settings:AddSection("Example Config")

Config:AddButton({
	Name = "Example Save",
	Callback = function()
		Window:SaveConfig("Example")
		Window:Notify({ Title = "Example", Content = "Config saved" })
	end,
})

Config:AddButton({
	Name = "Example Load",
	Callback = function()
		local loaded = Window:LoadConfig("Example")
		Window:Notify({
			Title = "Example",
			Content = loaded and "Config loaded" or "No config found",
		})
	end,
})

Config:AddButton({
	Name = "Example Unload",
	Callback = function()
		Window:Destroy()
	end,
})

Window:Notify({
	Title = "Example",
	Content = "Example loaded",
	Duration = 4,
})

-- WAVE EXECUTOR UI (SYNAPSE STYLE 32PX) -- BY SPDM TEAM

local ModernUILibrary = {}
ModernUILibrary.__index = ModernUILibrary

ModernUILibrary.Themes = {
	Dark = {
		Accent = Color3.fromRGB(30, 34, 34),
		Background = Color3.fromRGB(19, 19, 21),
		SidebarBg = Color3.fromRGB(18, 18, 20),
		ElementBg = Color3.fromRGB(23, 23, 25),
		InlineBg = Color3.fromRGB(29, 29, 31),
		Border = Color3.fromRGB(65, 65, 70),
		Text = Color3.fromRGB(255, 255, 255),
		TextDark = Color3.fromRGB(150, 150, 150),
		Circle = Color3.fromRGB(210, 210, 210)
	}
}

---------------------------------------------------------------------

function ModernUILibrary.new(title, theme)
	local self = setmetatable({}, ModernUILibrary)
	self.Theme = theme or ModernUILibrary.Themes.Dark
	self.Tabs = {}
	self.ActiveTab = nil

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Name = "WaveUI"

	-- WINDOW
	self.Window = Instance.new("Frame")
	self.Window.Size = UDim2.new(0, 880, 0, 520)
	self.Window.Position = UDim2.new(0.5, -440, 0.5, -260)
	self.Window.BackgroundColor3 = self.Theme.Background
	self.Window.BorderSizePixel = 0
	self.Window.Parent = self.ScreenGui

	Instance.new("UICorner", self.Window).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", self.Window).Color = self.Theme.Border

	-- HEADER
	local Header = Instance.new("Frame", self.Window)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = self.Theme.Background
	Header.BorderSizePixel = 0

	local Title = Instance.new("TextLabel", Header)
	Title.Position = UDim2.new(0, 16, 0, 0)
	Title.Size = UDim2.new(0, 300, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = title
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = self.Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local X = Instance.new("TextButton", Header)
	X.Size = UDim2.new(0, 32, 0, 32)
	X.Position = UDim2.new(1, -10, 0.5, 0)
	X.AnchorPoint = Vector2.new(1, .5)
	X.BackgroundColor3 = self.Theme.InlineBg
	X.Text = "X"
	X.Font = Enum.Font.GothamMedium
	X.TextSize = 14
	X.TextColor3 = self.Theme.Text
	Instance.new("UICorner", X).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", X).Color = self.Theme.Border
	X.MouseButton1Click:Connect(function()
		self.Window.Visible = false
	end)

	-- MAIN CONTENT
	local Main = Instance.new("Frame", self.Window)
	Main.Position = UDim2.new(0, 0, 0, 50)
	Main.Size = UDim2.new(1, 0, 1, -50)
	Main.BackgroundTransparency = 1

	-- SIDEBAR
	self.Sidebar = Instance.new("Frame", Main)
	self.Sidebar.Size = UDim2.new(0, 200, 1, 0)
	self.Sidebar.BackgroundColor3 = self.Theme.SidebarBg
	self.Sidebar.BorderSizePixel = 0
	Instance.new("UIStroke", self.Sidebar).Color = self.Theme.Border

	local TabHolder = Instance.new("UIListLayout", self.Sidebar)
	TabHolder.Padding = UDim.new(0, 6)
	TabHolder.SortOrder = Enum.SortOrder.LayoutOrder

	-- CONTENT AREA
	self.ContentArea = Instance.new("ScrollingFrame", Main)
	self.ContentArea.Position = UDim2.new(0, 200, 0, 0)
	self.ContentArea.Size = UDim2.new(1, -200, 1, 0)
	self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.ContentArea.ScrollBarThickness = 4
	self.ContentArea.BorderSizePixel = 0
	self.ContentArea.BackgroundColor3 = self.Theme.Background

	local BG = Instance.new("ImageLabel", self.ContentArea)
	BG.Image = "rbxassetid://80547362214007"
	BG.ImageTransparency = 0.93
	BG.Size = UDim2.new(1, 0, 1, 0)
	BG.BackgroundTransparency = 1
	BG.ZIndex = 0

	local Content = Instance.new("Frame", self.ContentArea)
	Content.Name = "Content"
	Content.Position = UDim2.new(0, 12, 0, 12)
	Content.Size = UDim2.new(1, -24, 1, -24)
	Content.BackgroundTransparency = 1

	local ContentLayout = Instance.new("UIListLayout", Content)
	ContentLayout.Padding = UDim.new(0, 10)
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	self.Content = Content

	return self
end

---------------------------------------------------------------------

function ModernUILibrary:CreateTab(name)
	local tab = {}
	tab.Elements = {}

	local TabBtn = Instance.new("TextButton", self.Sidebar)
	TabBtn.Text = name
	TabBtn.Size = UDim2.new(1, -12, 0, 38)
	TabBtn.Position = UDim2.new(0, 6, 0, 0)
	TabBtn.BackgroundColor3 = self.Theme.SidebarBg
	TabBtn.Font = Enum.Font.GothamMedium
	TabBtn.TextSize = 15
	TabBtn.TextColor3 = self.Theme.Text
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left

	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIPadding", TabBtn).PaddingLeft = UDim.new(0, 14)

	local TabContent = Instance.new("Frame", self.Content)
	TabContent.Size = UDim2.new(1, 0, 0, 0)
	TabContent.BackgroundTransparency = 1
	TabContent.Visible = false

	Instance.new("UIListLayout", TabContent).Padding = UDim.new(0, 8)

	tab.Button = TabBtn
	tab.Content = TabContent

	TabBtn.MouseButton1Click:Connect(function()
		for _, t in ipairs(self.Tabs) do
			t.Button.BackgroundColor3 = self.Theme.SidebarBg
			t.Content.Visible = false
		end
		TabBtn.BackgroundColor3 = self.Theme.InlineBg
		TabContent.Visible = true
	end)

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self.ActiveTab = tab
		tab.Button.BackgroundColor3 = self.Theme.InlineBg
		tab.Content.Visible = true
	end

	return tab
end

---------------------------------------------------------------------
-- ELEMENTS (32px Synapse Style)

local function CreateBase(self, tab)
	local Frame = Instance.new("Frame", tab.Content)
	Frame.Size = UDim2.new(1, 0, 0, 32)
	Frame.BackgroundColor3 = self.Theme.ElementBg
	Frame.BorderSizePixel = 0
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", Frame).Color = self.Theme.Border
	return Frame
end

---------------------------------------------------------------------

function ModernUILibrary:CreateButton(tab, text, callback)
	local Frame = CreateBase(self, tab)

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -10, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Btn = Instance.new("TextButton", Frame)
	Btn.BackgroundTransparency = 1
	Btn.Size = UDim2.new(1, 0, 1, 0)
	Btn.Text = ""

	Btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
end

---------------------------------------------------------------------

function ModernUILibrary:CreateToggle(tab, text, default, callback)
	local Frame = CreateBase(self, tab)

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -60, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Toggle = Instance.new("Frame", Frame)
	Toggle.Size = UDim2.new(0, 36, 0, 18)
	Toggle.Position = UDim2.new(1, -46, 0.5, 0)
	Toggle.AnchorPoint = Vector2.new(0, .5)
	Toggle.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 9)

	local Ball = Instance.new("Frame", Toggle)
	Ball.Size = UDim2.new(0, 14, 0, 14)
	Ball.Position = UDim2.new(0, 2, 0.5, 0)
	Ball.AnchorPoint = Vector2.new(0, .5)
	Ball.BackgroundColor3 = self.Theme.Circle
	Instance.new("UICorner", Ball).CornerRadius = UDim.new(0, 7)

	local Btn = Instance.new("TextButton", Frame)
	Btn.BackgroundTransparency = 1
	Btn.Size = UDim2.new(1, 0, 1, 0)
	Btn.Text = ""

	local state = default

	local function Update()
		if state then
			Toggle.BackgroundColor3 = self.Theme.Accent
			Ball.Position = UDim2.new(1, -16, 0.5, 0)
		else
			Toggle.BackgroundColor3 = self.Theme.InlineBg
			Ball.Position = UDim2.new(0, 2, 0.5, 0)
		end
	end

	Update()

	Btn.MouseButton1Click:Connect(function()
		state = not state
		Update()
		if callback then callback(state) end
	end)
end

---------------------------------------------------------------------

function ModernUILibrary:CreateSlider(tab, text, min, max, default, callback)
	local Frame = CreateBase(self, tab)

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(0.5, -14, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Val = Instance.new("TextLabel", Frame)
	Val.Text = tostring(default)
	Val.Size = UDim2.new(0.5, -14, 1, 0)
	Val.Position = UDim2.new(0.5, 0, 0, 0)
	Val.BackgroundTransparency = 1
	Val.Font = Enum.Font.GothamMedium
	Val.TextSize = 14
	Val.TextColor3 = self.Theme.Text
	Val.TextXAlignment = Enum.TextXAlignment.Right

	local Track = Instance.new("Frame", Frame)
	Track.Size = UDim2.new(1, -20, 0, 4)
	Track.Position = UDim2.new(0, 10, 1, -8)
	Track.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)

	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new(0, 0, 1, 0)
	Fill.BackgroundColor3 = self.Theme.Text
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)

	local Knob = Instance.new("Frame", Track)
	Knob.Size = UDim2.new(0, 10, 0, 10)
	Knob.Position = UDim2.new(0, 0, 0.5, 0)
	Knob.AnchorPoint = Vector2.new(.5, .5)
	Knob.BackgroundColor3 = self.Theme.Circle
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 5)

	local dragging = false
	local value = default

	local function UpdateSlider(x)
		local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * rel)
		Val.Text = tostring(value)
		Fill.Size = UDim2.new(rel, 0, 1, 0)
		Knob.Position = UDim2.new(rel, 0, 0.5, 0)
		if callback then callback(value) end
	end

	Track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateSlider(inp.Position.X)
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateSlider(inp.Position.X)
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

---------------------------------------------------------------------

function ModernUILibrary:CreateKeybind(tab, text, defaultKey, callback)
	local Frame = CreateBase(self, tab)

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -90, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Btn = Instance.new("TextButton", Frame)
	Btn.Text = defaultKey
	Btn.Size = UDim2.new(0, 60, 0, 24)
	Btn.Position = UDim2.new(1, -70, 0.5, 0)
	Btn.AnchorPoint = Vector2.new(0, .5)
	Btn.BackgroundColor3 = self.Theme.InlineBg
	Btn.Font = Enum.Font.GothamMedium
	Btn.TextSize = 14
	Btn.TextColor3 = self.Theme.Text

	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", Btn).Color = self.Theme.Border

	local listening = false

	Btn.MouseButton1Click:Connect(function()
		Btn.Text = "..."
		listening = true
	end)

	game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
		if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			Btn.Text = inp.KeyCode.Name
			if callback then callback(inp.KeyCode.Name) end
		end
	end)
end

---------------------------------------------------------------------

function ModernUILibrary:Init(parent)
	self.ScreenGui.Parent = parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	return self
end

return ModernUILibrary

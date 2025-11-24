-- WAVE EXECUTOR UI (SYNAPSE STYLE 32PX) -- BY SPDM TEAM (PATCHEd: sections + groups + spacing + bg)
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

-- Helper: resolve container (tab or group) to a Frame where elements should be parented
local function resolveContainer(container)
	-- container may be: tab table { Button, Content }, group table { Frame/Content }, or just a Frame
	if type(container) ~= "table" then
		-- assume it's a Frame
		return container
	end
	-- tab produced by CreateTab has .Content
	if container.Content and typeof(container.Content) == "Instance" then
		return container.Content
	end
	-- group produced by CreateGroup has .Frame or .Content
	if container.Frame and typeof(container.Frame) == "Instance" then
		return container.Frame
	end
	if container.Content and typeof(container.Content) == "Instance" then
		return container.Content
	end
	return nil
end

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
	self.Window.AnchorPoint = Vector2.new(0.5,0.5)
	self.Window.BackgroundColor3 = self.Theme.Background
	self.Window.BorderSizePixel = 0
	self.Window.Parent = self.ScreenGui

	Instance.new("UICorner", self.Window).CornerRadius = UDim.new(0, 12)
	local windowStroke = Instance.new("UIStroke", self.Window)
	windowStroke.Color = self.Theme.Border
	windowStroke.Thickness = 1

	-- SHADOW (parented to ScreenGui so Window ClipsDescendants won't cut it)
	local Shadow = Instance.new("ImageLabel", self.ScreenGui)
	Shadow.Name = "Shadow"
	Shadow.Size = UDim2.new(1, 40, 1, 40)
	Shadow.Position = UDim2.new(0.5, -20, 0.5, -20)
	Shadow.AnchorPoint = Vector2.new(0.5,0.5)
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://2615687895"
	Shadow.ImageColor3 = Color3.new(0,0,0)
	Shadow.ImageTransparency = 0.82
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceScale = 0.1
	Shadow.ZIndex = -1

	-- HEADER
	local Header = Instance.new("Frame", self.Window)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = self.Theme.Background
	Header.BorderSizePixel = 0

	local Title = Instance.new("TextLabel", Header)
	Title.Position = UDim2.new(0, 16, 0, 0)
	Title.Size = UDim2.new(0, 300, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = title or "Wave UI"
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
		self.Window.Visible = not self.Window.Visible
	end)

	-- MAIN
	local Main = Instance.new("Frame", self.Window)
	Main.Position = UDim2.new(0, 0, 0, 50)
	Main.Size = UDim2.new(1, 0, 1, -50)
	Main.BackgroundTransparency = 1
	Main.ClipsDescendants = true

	-- SIDEBAR
	self.Sidebar = Instance.new("Frame", Main)
	self.Sidebar.Size = UDim2.new(0, 200, 1, 0)
	self.Sidebar.BackgroundColor3 = self.Theme.SidebarBg
	self.Sidebar.BorderSizePixel = 0
	Instance.new("UIStroke", self.Sidebar).Color = self.Theme.Border

	local TabHolder = Instance.new("Frame", self.Sidebar)
	TabHolder.Size = UDim2.new(1, -12, 1, -24)
	TabHolder.Position = UDim2.new(0, 6, 0, 12)
	TabHolder.BackgroundTransparency = 1
	local TabList = Instance.new("UIListLayout", TabHolder)
	TabList.Padding = UDim.new(0, 6)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder

	-- CONTENT AREA
	self.ContentArea = Instance.new("ScrollingFrame", Main)
	self.ContentArea.Position = UDim2.new(0, 200, 0, 0)
	self.ContentArea.Size = UDim2.new(1, -200, 1, 0)
	self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.ContentArea.ScrollBarThickness = 4
	self.ContentArea.BorderSizePixel = 0
	self.ContentArea.BackgroundColor3 = self.Theme.Background
	self.ContentArea.ClipsDescendants = true

	local BG = Instance.new("ImageLabel", self.ContentArea)
	BG.Name = "Background"
	BG.Image = "rbxassetid://80547362214007"
	BG.ImageTransparency = 0.92
	BG.Size = UDim2.new(1, 0, 1, 0)
	BG.BackgroundTransparency = 1
	BG.ZIndex = 0
	BG.ScaleType = Enum.ScaleType.Crop

	local Content = Instance.new("Frame", self.ContentArea)
	Content.Name = "Content"
	Content.Position = UDim2.new(0, 12, 0, 12)
	Content.Size = UDim2.new(1, -24, 1, -24)
	Content.BackgroundTransparency = 1
	Content.ZIndex = 2

	local ContentLayout = Instance.new("UIListLayout", Content)
	ContentLayout.Padding = UDim.new(0, 10)
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	self.Content = Content
	self.TabHolderFrame = TabHolder

	-- draggable header
	local UserInputService = game:GetService("UserInputService")
	local dragging, dragInput, dragStart, startPos
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	Header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	return self
end

-- CREATE TAB
function ModernUILibrary:CreateTab(name)
	local tab = {}
	tab.Elements = {}

	local TabBtn = Instance.new("TextButton")
	TabBtn.Text = name
	TabBtn.Size = UDim2.new(1, -12, 0, 38)
	TabBtn.Position = UDim2.new(0, 6, 0, 0)
	TabBtn.BackgroundColor3 = self.Theme.SidebarBg
	TabBtn.Font = Enum.Font.GothamMedium
	TabBtn.TextSize = 15
	TabBtn.TextColor3 = self.Theme.Text
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
	local pad = Instance.new("UIPadding", TabBtn)
	pad.PaddingLeft = UDim.new(0, 14)

	TabBtn.Parent = self.TabHolderFrame

	local TabContent = Instance.new("Frame", self.Content)
	TabContent.Size = UDim2.new(1, 0, 0, 0)
	TabContent.BackgroundTransparency = 1
	TabContent.Visible = false
	local list = Instance.new("UIListLayout", TabContent)
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder

	tab.Button = TabBtn
	tab.Content = TabContent

	TabBtn.MouseButton1Click:Connect(function()
		for _, t in ipairs(self.Tabs) do
			t.Button.BackgroundColor3 = self.Theme.SidebarBg
			t.Content.Visible = false
		end
		TabBtn.BackgroundColor3 = self.Theme.InlineBg
		TabContent.Visible = true
		self.ActiveTab = tab
	end)

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self.ActiveTab = tab
		TabBtn.BackgroundColor3 = self.Theme.InlineBg
		TabContent.Visible = true
	end

	return tab
end

-- BASE element creator (32px compact) - accepts tab or group or Frame
local function CreateBase(self, container)
	local parent = resolveContainer(container)
	if not parent then return nil end
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1, 0, 0, 32)
	Frame.BackgroundColor3 = self.Theme.ElementBg
	Frame.BorderSizePixel = 0
	Frame.BackgroundTransparency = 0.03 -- slight transparency so BG shows subtly
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke", Frame)
	stroke.Color = self.Theme.Border
	stroke.Thickness = 1
	return Frame
end

-- BUTTON
function ModernUILibrary:CreateButton(container, text, callback)
	local Frame = CreateBase(self, container)
	if not Frame then return end
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
	return Frame
end

-- TOGGLE
function ModernUILibrary:CreateToggle(container, text, default, callback)
	local Frame = CreateBase(self, container)
	if not Frame then return end
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

	local state = default or false

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
	return Frame, function(v) state = v; Update() end, function() return state end
end

-- SLIDER
function ModernUILibrary:CreateSlider(container, text, min, max, default, callback)
	local Frame = CreateBase(self, container)
	if not Frame then return end
	min = min or 0
	max = max or 100
	default = default or min

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(0.45, -14, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Val = Instance.new("TextLabel", Frame)
	Val.Text = tostring(default)
	Val.Size = UDim2.new(0.25, -14, 1, 0)
	Val.Position = UDim2.new(0.75, 0, 0, 0)
	Val.BackgroundTransparency = 1
	Val.Font = Enum.Font.GothamMedium
	Val.TextSize = 14
	Val.TextColor3 = self.Theme.Text
	Val.TextXAlignment = Enum.TextXAlignment.Right

	local Track = Instance.new("Frame", Frame)
	Track.Size = UDim2.new(1, -28, 0, 4)
	Track.Position = UDim2.new(0, 10, 1, -9)
	Track.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)

	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new(0, 0, 1, 0)
	Fill.BackgroundColor3 = self.Theme.Text
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)

	local Knob = Instance.new("ImageButton", Track)
	Knob.Size = UDim2.new(0, 12, 0, 12)
	Knob.Position = UDim2.new(0, 0, 0.5, 0)
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Image = ""
	Knob.BackgroundColor3 = self.Theme.Circle
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 6)
	local knobStroke = Instance.new("UIStroke", Knob)
	knobStroke.Color = self.Theme.Border

	local dragging = false
	local value = default

	local function updateFromX(x)
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
			updateFromX(inp.Position.X)
		end
	end)

	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromX(inp.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	-- initialize
	coroutine.wrap(function()
		wait()
		updateFromX(Track.AbsolutePosition.X + (Track.AbsoluteSize.X * ((default - min) / math.max(1, (max - min)))))
	end)()

	return Frame, function(v) value = v; updateFromX(Track.AbsolutePosition.X + (Track.AbsoluteSize.X * ((v - min) / math.max(1, (max - min))))) end, function() return value end
end

-- KEYBIND
function ModernUILibrary:CreateKeybind(container, text, defaultKey, callback)
	local Frame = CreateBase(self, container)
	if not Frame then return end

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -110, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Btn = Instance.new("TextButton", Frame)
	Btn.Text = defaultKey or "F4"
	Btn.Size = UDim2.new(0, 64, 0, 24)
	Btn.Position = UDim2.new(1, -78, 0.5, 0)
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

	local UserInputService = game:GetService("UserInputService")
	local conn
	conn = UserInputService.InputBegan:Connect(function(inp, gpe)
		if listening and not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			Btn.Text = inp.KeyCode.Name
			if callback then callback(inp.KeyCode.Name) end
		end
	end)

	return Frame, function(k) Btn.Text = k end, function() return Btn.Text end
end

-- SECTION (Synapse X style header)
function ModernUILibrary:CreateSection(container, title)
	-- container can be tab or Frame
	local parent = resolveContainer(container)
	if not parent then return end

	local SectionFrame = Instance.new("Frame", parent)
	SectionFrame.Size = UDim2.new(1, 0, 0, 24)
	SectionFrame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel", SectionFrame)
	Label.Text = ("  %s"):format(title or "")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 12
	Label.TextColor3 = self.Theme.TextDark
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Line = Instance.new("Frame", SectionFrame)
	Line.Size = UDim2.new(1, 0, 0, 1)
	Line.Position = UDim2.new(0, 0, 1, -1)
	Line.BackgroundColor3 = self.Theme.Border
	Line.BorderSizePixel = 0

	return SectionFrame
end

-- GROUP (boxed rounded container)
function ModernUILibrary:CreateGroup(container, title)
	local parent = resolveContainer(container)
	if not parent then return end

	local GroupFrame = Instance.new("Frame", parent)
	GroupFrame.Size = UDim2.new(1, 0, 0, 0) -- will grow based on children
	GroupFrame.BackgroundColor3 = Color3.fromRGB(17,17,18)
	GroupFrame.BackgroundTransparency = 0.02
	Instance.new("UICorner", GroupFrame).CornerRadius = UDim.new(0, 8)
	local groupStroke = Instance.new("UIStroke", GroupFrame)
	groupStroke.Color = self.Theme.Border

	-- layout inside group
	local inner = Instance.new("Frame", GroupFrame)
	inner.Size = UDim2.new(1, -12, 1, -12)
	inner.Position = UDim2.new(0, 6, 0, 6)
	inner.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", inner)
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	-- header label optional
	if title and title ~= "" then
		local header = Instance.new("TextLabel", GroupFrame)
		header.Text = title
		header.Size = UDim2.new(1, -12, 0, 20)
		header.Position = UDim2.new(0, 10, 0, -10)
		header.BackgroundTransparency = 1
		header.Font = Enum.Font.GothamBold
		header.TextSize = 13
		header.TextColor3 = self.Theme.Text
		header.TextXAlignment = Enum.TextXAlignment.Left
	end

	-- grow group to fit children automatically
	inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local y = inner.AbsoluteSize.Y + 16
		GroupFrame.Size = UDim2.new(1, 0, 0, y)
	end)

	local group = { Frame = inner }
	return group
end

-- INIT
function ModernUILibrary:Init(parent)
	self.ScreenGui.Parent = parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	return self
end

return ModernUILibrary

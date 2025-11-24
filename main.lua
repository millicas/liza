local ModernUILibrary = {}
ModernUILibrary.__index = ModernUILibrary

-- Theme (Liza colors / feel)
ModernUILibrary.Themes = {
	Dark = {
		Accent = Color3.fromRGB(30,34,34),
		Background = Color3.fromRGB(18,18,20),
		ContentBg = Color3.fromRGB(17,17,18),
		SidebarBg = Color3.fromRGB(16,16,18),
		ElementBg = Color3.fromRGB(24,24,26),
		InlineBg = Color3.fromRGB(28,28,30),
		Border = Color3.fromRGB(60,60,64),
		Text = Color3.fromRGB(245,245,245),
		TextDark = Color3.fromRGB(160,160,160),
		Highlight = Color3.fromRGB(98, 179, 255),
		Circle = Color3.fromRGB(210,210,210)
	}
}

local DEFAULT_THEME = ModernUILibrary.Themes.Dark

-- constants
local ELEMENT_HEIGHT = 38
local SLIDER_HEIGHT = 48

-- helper resolve container (tab, group, frame)
local function resolveContainer(container)
	if not container then return nil end
	if typeof(container) == "Instance" then return container end
	if type(container) == "table" then
		-- tab: {Button, Content}
		if container.Content and typeof(container.Content) == "Instance" then
			return container.Content
		end
		-- group: {Frame, Wrapper}
		if container.Frame and typeof(container.Frame) == "Instance" then
			return container.Frame
		end
		if container.Instance and typeof(container.Instance) == "Instance" then
			return container.Instance
		end
	end
	return nil
end

-- Notification system (Balright-like, adapted)
-- Creates a small top-right notification queue inside ScreenGui
local function CreateNotificationSystem(screenGui, theme)
	local notif = {}
	notif.Container = Instance.new("Frame")
	notif.Container.Name = "Notifications"
	notif.Container.Size = UDim2.new(0, 300, 0, 200)
	notif.Container.Position = UDim2.new(1, -320, 0, 20)
	notif.Container.BackgroundTransparency = 1
	notif.Container.Parent = screenGui
	local layout = Instance.new("UIListLayout", notif.Container)
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	notif.Queue = {}

	function notif:Push(text, duration)
		duration = duration or 2
		local entry = Instance.new("Frame")
		entry.Size = UDim2.new(1, 0, 0, 48)
		entry.BackgroundColor3 = theme.InlineBg
		entry.BorderSizePixel = 0
		entry.Parent = self.Container
		entry.LayoutOrder = 1
		entry.ZIndex = 50
		local corner = Instance.new("UICorner", entry); corner.CornerRadius = UDim.new(0,8)
		local stroke = Instance.new("UIStroke", entry); stroke.Color = theme.Border; stroke.Thickness = 1

		local label = Instance.new("TextLabel", entry)
		label.Size = UDim2.new(1, -12, 1, 0)
		label.Position = UDim2.new(0, 8, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = tostring(text)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = theme.Text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.ZIndex = 51

		entry.Visible = false
		table.insert(self.Queue, entry)

		-- show with tween
		entry.Visible = true
		entry.Position = UDim2.new(1, -320, 0, 20)
		spawn(function()
			task.wait(duration)
			if entry and entry.Parent then
				entry:Destroy()
			end
		end)
	end

	return notif
end

-- Main constructor
function ModernUILibrary.new(title, theme)
	local self = setmetatable({}, ModernUILibrary)
	self.Theme = theme or DEFAULT_THEME
	self.Tabs = {}
	self.ActiveTab = nil

	-- ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "WaveUI_Merged"
	self.ScreenGui.ResetOnSpawn = false

	-- main window frame
	self.Window = Instance.new("Frame")
	self.Window.Name = "Window"
	self.Window.Size = UDim2.new(0, 980, 0, 620) -- wider layout (Balright-like)
	self.Window.Position = UDim2.new(0.5, -490, 0.5, -310)
	self.Window.AnchorPoint = Vector2.new(0.5,0.5)
	self.Window.BackgroundColor3 = self.Theme.Background
	self.Window.BorderSizePixel = 0
	self.Window.Parent = self.ScreenGui
	self.Window.ClipsDescendants = true

	local winCorner = Instance.new("UICorner", self.Window); winCorner.CornerRadius = UDim.new(0,14)
	local winStroke = Instance.new("UIStroke", self.Window); winStroke.Color = self.Theme.Border; winStroke.Thickness = 1

	-- shadow (parent to screenGui to avoid clipping)
	local Shadow = Instance.new("ImageLabel", self.ScreenGui)
	Shadow.Name = "Shadow"
	Shadow.Size = UDim2.new(1, 80, 1, 80)
	Shadow.Position = UDim2.new(0.5, -40, 0.5, -40)
	Shadow.AnchorPoint = Vector2.new(0.5,0.5)
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://2615687895"
	Shadow.ImageColor3 = Color3.new(0,0,0); Shadow.ImageTransparency = 0.85
	Shadow.ScaleType = Enum.ScaleType.Slice; Shadow.SliceScale = 0.1
	Shadow.ZIndex = -1

	-- Header (big title)
	local Header = Instance.new("Frame", self.Window)
	Header.Size = UDim2.new(1, 0, 0, 64)
	Header.Position = UDim2.new(0,0,0,0)
	Header.BackgroundColor3 = self.Theme.Background
	Header.BorderSizePixel = 0
	local headerTitle = Instance.new("TextLabel", Header)
	headerTitle.Text = title or "Wave UI (Merged)"
	headerTitle.Size = UDim2.new(1, -140, 1, 0)
	headerTitle.Position = UDim2.new(0, 20, 0, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = Enum.Font.GothamBold
	headerTitle.TextSize = 20
	headerTitle.TextColor3 = self.Theme.Text
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	local headerRight = Instance.new("Frame", Header)
	headerRight.Size = UDim2.new(0, 120, 1, 0)
	headerRight.Position = UDim2.new(1, -140, 0, 0)
	headerRight.BackgroundTransparency = 1
	local closeBtn = Instance.new("TextButton", headerRight)
	closeBtn.Text = "X"
	closeBtn.Size = UDim2.new(0, 48, 0, 36)
	closeBtn.Position = UDim2.new(1, -56, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(1,0.5)
	closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16
	closeBtn.TextColor3 = self.Theme.Text
	closeBtn.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
	Instance.new("UIStroke", closeBtn).Color = self.Theme.Border
	closeBtn.MouseButton1Click:Connect(function()
		self.Window.Visible = not self.Window.Visible
	end)

	-- main area: left categories column + right content pane
	local Main = Instance.new("Frame", self.Window)
	Main.Size = UDim2.new(1, 0, 1, -64)
	Main.Position = UDim2.new(0, 0, 0, 64)
	Main.BackgroundTransparency = 1

	-- Left: category pane (bigger, vertical)
	self.CategoryPane = Instance.new("Frame", Main)
	self.CategoryPane.Size = UDim2.new(0, 260, 1, 0)
	self.CategoryPane.Position = UDim2.new(0,0,0,0)
	self.CategoryPane.BackgroundColor3 = self.Theme.SidebarBg
	self.CategoryPane.BorderSizePixel = 0
	Instance.new("UIStroke", self.CategoryPane).Color = self.Theme.Border

	local CatPadding = Instance.new("Frame", self.CategoryPane)
	CatPadding.Size = UDim2.new(1, -24, 1, -24)
	CatPadding.Position = UDim2.new(0, 12, 0, 12)
	CatPadding.BackgroundTransparency = 1

	local CatLayout = Instance.new("UIListLayout", CatPadding)
	CatLayout.SortOrder = Enum.SortOrder.LayoutOrder
	CatLayout.Padding = UDim.new(0, 12)

	-- Right: content area with big panes and background
	self.ContentArea = Instance.new("Frame", Main)
	self.ContentArea.Size = UDim2.new(1, -260, 1, 0)
	self.ContentArea.Position = UDim2.new(0, 260, 0, 0)
	self.ContentArea.BackgroundColor3 = self.Theme.ContentBg
	self.ContentArea.BorderSizePixel = 0
	Instance.new("UICorner", self.ContentArea).CornerRadius = UDim.new(0,12)
	Instance.new("UIStroke", self.ContentArea).Color = self.Theme.Border

	-- background image in content area (subtle)
	local bgImg = Instance.new("ImageLabel", self.ContentArea)
	bgImg.Size = UDim2.new(1, 0, 1, 0)
	bgImg.Position = UDim2.new(0, 0, 0, 0)
	bgImg.BackgroundTransparency = 1
	bgImg.Image = "rbxassetid://80547362214007"
	bgImg.ImageTransparency = 0.92
	bgImg.ScaleType = Enum.ScaleType.Crop
	bgImg.ZIndex = 1

	-- Scroll area for content (over bg)
	self.ContentScroller = Instance.new("ScrollingFrame", self.ContentArea)
	self.ContentScroller.Size = UDim2.new(1, 0, 1, 0)
	self.ContentScroller.Position = UDim2.new(0, 0, 0, 0)
	self.ContentScroller.BackgroundTransparency = 1
	self.ContentScroller.BorderSizePixel = 0
	self.ContentScroller.ScrollBarThickness = 6
	self.ContentScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.ContentScroller.ZIndex = 2

	local contentInner = Instance.new("Frame", self.ContentScroller)
	contentInner.Name = "ContentInner"
	contentInner.Size = UDim2.new(1, -32, 0, 10)
	contentInner.Position = UDim2.new(0, 16, 0, 16)
	contentInner.BackgroundTransparency = 1

	local contentLayout = Instance.new("UIListLayout", contentInner)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 16)

	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ContentScroller.CanvasSize = UDim2.new(0,0,0, contentLayout.AbsoluteContentSize.Y + 32)
		contentInner.Size = UDim2.new(1, -32, 0, contentLayout.AbsoluteContentSize.Y + 4)
	end)

	self.Content = contentInner
	self.CategoryHolder = CatPadding

	-- Add notification system
	self.Notifs = CreateNotificationSystem(self.ScreenGui, self.Theme)

	-- Make header draggable
	do
		local dragging, dragInput, dragStart, startPos
		local UIS = game:GetService("UserInputService")
		Header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = self.Window.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		Header.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
		end)
		UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	return self
end

-- Notification wrapper
function ModernUILibrary:Notify(text, secs)
	if not self.Notifs then return end
	self.Notifs:Push(text, secs or 2)
end

-- Create a big category pane (Balright style) in the left column
function ModernUILibrary:CreateCategory(name, icon)
	local cat = {}
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 56)
	btn.BackgroundColor3 = self.Theme.SidebarBg
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = self.Theme.Text
	btn.Text = "   "..(name or "Category")
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = #self.CategoryHolder:GetChildren()
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 12)

	btn.Parent = self.CategoryHolder

	-- Associated pane on right
	local pane = Instance.new("Frame", self.Content)
	pane.Size = UDim2.new(1, -32, 0, 0)
	pane.BackgroundTransparency = 1
	pane.Visible = false
	local title = Instance.new("TextLabel", pane)
	title.Text = name
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = self.Theme.Text
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 8, 0, 0)
	title.Size = UDim2.new(1, -16, 0, 28)

	local inner = Instance.new("Frame", pane)
	inner.Position = UDim2.new(0, 8, 0, 32)
	inner.Size = UDim2.new(1, -16, 0, 10)
	inner.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", inner)
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local h = layout.AbsoluteContentSize.Y + 24
		pane.Size = UDim2.new(1, -32, 0, h + 36)
	end)

	cat.Button = btn
	cat.Pane = pane
	cat.Inner = inner

	btn.MouseButton1Click:Connect(function()
		-- hide other panes
		for _, t in ipairs(self.Tabs or {}) do
			if t.Pane then t.Pane.Visible = false end
		end
		pane.Visible = true
		self.ActivePane = cat
	end)

	table.insert(self.Tabs, cat)
	if #self.Tabs == 1 then
		-- show first by default
		pane.Visible = true
		self.ActivePane = cat
	end

	return cat
end

-- Create a tab (keeps compatibility with previous API)
function ModernUILibrary:CreateTab(name)
	-- for backward compatibility build a category as a tab
	local tab = self:CreateCategory(name)
	return {
		Button = tab.Button,
		Content = tab.Inner,
		Pane = tab.Pane
	}
end

-- Textbox (Balright-like) - returns frame, textbox instance
function ModernUILibrary:CreateTextbox(container, params)
	params = params or {}
	local parent = resolveContainer(container) or self.Content
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
	frame.BackgroundColor3 = self.Theme.ElementBg
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
	Instance.new("UIStroke", frame).Color = self.Theme.Border

	local label = Instance.new("TextLabel", frame)
	label.Text = params.Name or "Input"
	label.Size = UDim2.new(0.4, -12, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 15
	label.TextColor3 = self.Theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(0.55, -16, 0, 24)
	box.Position = UDim2.new(0.45, 0, 0.5, 0)
	box.AnchorPoint = Vector2.new(0, 0.5)
	box.PlaceholderText = params.Placeholder or ""
	box.Text = params.Default and tostring(params.Default) or ""
	box.BackgroundColor3 = self.Theme.InlineBg
	box.TextColor3 = self.Theme.Text
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
	Instance.new("UIStroke", box).Color = self.Theme.Border

	if params.Callback then
		box.FocusLost:Connect(function(enter)
			if enter then
				pcall(function() params.Callback(box.Text) end)
			end
		end)
	end

	return frame, box
end

-- Base element creator (38px by default, slightly translucent so bg shows)
local function CreateBase(self, container, height)
	local parent = resolveContainer(container) or self.Content
	if not parent then return nil end
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1, 0, 0, height or ELEMENT_HEIGHT)
	Frame.BackgroundColor3 = self.Theme.ElementBg
	Frame.BorderSizePixel = 0
	Frame.BackgroundTransparency = 0.03
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)
	local stroke = Instance.new("UIStroke", Frame); stroke.Color = self.Theme.Border; stroke.Thickness = 1
	return Frame
end

-- Button
function ModernUILibrary:CreateButton(container, text, callback)
	local Frame = CreateBase(self, container, ELEMENT_HEIGHT)
	if not Frame then return end
	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -12, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 15
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Btn = Instance.new("TextButton", Frame)
	Btn.BackgroundTransparency = 1
	Btn.Size = UDim2.new(1, 0, 1, 0)
	Btn.Text = ""
	Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
	return Frame
end

-- Toggle
function ModernUILibrary:CreateToggle(container, text, default, callback)
	local Frame = CreateBase(self, container, ELEMENT_HEIGHT)
	if not Frame then return end
	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -100, 1, 0)
	Label.Position = UDim2.new(0,12,0,0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 15
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Toggle = Instance.new("Frame", Frame)
	Toggle.Size = UDim2.new(0, 44, 0, 24)
	Toggle.Position = UDim2.new(1, -64, 0.5, 0)
	Toggle.AnchorPoint = Vector2.new(0,0.5)
	Toggle.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,12)
	local Ball = Instance.new("Frame", Toggle)
	Ball.Size = UDim2.new(0, 18, 0, 18)
	Ball.Position = UDim2.new(0,2,0.5,0); Ball.AnchorPoint = Vector2.new(0,0.5)
	Ball.BackgroundColor3 = self.Theme.Circle
	Instance.new("UICorner", Ball).CornerRadius = UDim.new(0,9)

	local state = default or false
	local function Update()
		if state then Toggle.BackgroundColor3 = self.Theme.Highlight; Ball.Position = UDim2.new(1, -20, 0.5, 0)
		else Toggle.BackgroundColor3 = self.Theme.InlineBg; Ball.Position = UDim2.new(0,2,0.5,0) end
		if callback then pcall(callback, state) end
	end
	Update()

	local Btn = Instance.new("TextButton", Frame)
	Btn.BackgroundTransparency = 1
	Btn.Size = UDim2.new(1,0,1,0)
	Btn.Text = ""
	Btn.MouseButton1Click:Connect(function() state = not state; Update() end)
	return Frame, function(v) state = v; Update() end, function() return state end
end

-- Slider (two-row style; uses SLIDER_HEIGHT)
function ModernUILibrary:CreateSlider(container, text, min, max, default, callback)
	local parent = resolveContainer(container) or self.Content
	if not parent then return end
	min = min or 0; max = max or 100; default = default or min

	local Frame = CreateBase(self, container, SLIDER_HEIGHT)
	if not Frame then return end

	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(0.6, -12, 0, 22)
	Label.Position = UDim2.new(0, 12, 0, 6)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 15
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Center

	local Val = Instance.new("TextLabel", Frame)
	Val.Text = tostring(default)
	Val.Size = UDim2.new(0.25, -12, 0, 22)
	Val.Position = UDim2.new(0.75, 0, 0, 6)
	Val.BackgroundTransparency = 1
	Val.Font = Enum.Font.GothamMedium
	Val.TextSize = 15
	Val.TextColor3 = self.Theme.Text
	Val.TextXAlignment = Enum.TextXAlignment.Right
	Val.TextYAlignment = Enum.TextYAlignment.Center

	local Track = Instance.new("Frame", Frame)
	Track.Size = UDim2.new(1, -36, 0, 10)
	Track.Position = UDim2.new(0, 18, 0, 34)
	Track.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", Track).CornerRadius = UDim.new(0,5)

	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new(0,0,1,0)
	Fill.BackgroundColor3 = self.Theme.Text
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,4)

	local Knob = Instance.new("ImageButton", Track)
	Knob.Size = UDim2.new(0, 16, 0, 16)
	Knob.AnchorPoint = Vector2.new(0.5,0.5)
	Knob.Position = UDim2.new(0, 0, 0.5, 0)
	Knob.BackgroundColor3 = self.Theme.Circle
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(0,8)
	Instance.new("UIStroke", Knob).Color = self.Theme.Border

	local dragging = false
	local value = default

	local function updateFromX(x)
		local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * rel)
		Val.Text = tostring(value)
		Fill.Size = UDim2.new(rel, 0, 1, 0)
		Knob.Position = UDim2.new(rel, 0, 0.5, 0)
		if callback then pcall(callback, value) end
	end

	Track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromX(inp.Position.X)
		end
	end)
	local UIS = game:GetService("UserInputService")
	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then updateFromX(inp.Position.X) end
	end)
	UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

	-- init pos
	task.defer(function()
		if Track.AbsoluteSize.X > 2 then
			local rel = 0
			if max - min ~= 0 then rel = (default - min) / (max - min) end
			Fill.Size = UDim2.new(rel, 0, 1, 0)
			Knob.Position = UDim2.new(rel, 0, 0.5, 0)
		end
	end)

	return Frame, function(v) value = v; updateFromX(Track.AbsolutePosition.X + (Track.AbsoluteSize.X * ((v - min) / math.max(1, (max - min))))) end, function() return value end
end

-- Keybind
function ModernUILibrary:CreateKeybind(container, text, defaultKey, callback)
	local Frame = CreateBase(self, container, ELEMENT_HEIGHT)
	if not Frame then return end
	local Label = Instance.new("TextLabel", Frame)
	Label.Text = text
	Label.Size = UDim2.new(1, -160, 1, 0)
	Label.Position = UDim2.new(0,12,0,0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 15
	Label.TextColor3 = self.Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Btn = Instance.new("TextButton", Frame)
	Btn.Text = (defaultKey and tostring(defaultKey)) or "Key"
	Btn.Size = UDim2.new(0, 120, 0, 28)
	Btn.Position = UDim2.new(1, -132, 0.5, 0)
	Btn.AnchorPoint = Vector2.new(1,0.5)
	Btn.BackgroundColor3 = self.Theme.InlineBg
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,8)
	Instance.new("UIStroke", Btn).Color = self.Theme.Border
	Btn.Font = Enum.Font.GothamMedium; Btn.TextSize = 14; Btn.TextColor3 = self.Theme.Text

	local listening = false
	Btn.MouseButton1Click:Connect(function()
		listening = true
		Btn.Text = "..."
		Btn.BackgroundColor3 = self.Theme.Highlight
	end)

	local UIS = game:GetService("UserInputService")
	local conn
	conn = UIS.InputBegan:Connect(function(inp, gpe)
		if listening and not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			local keyname = inp.KeyCode.Name
			Btn.Text = keyname
			Btn.BackgroundColor3 = self.Theme.InlineBg
			if callback then pcall(callback, inp.KeyCode) end
		end
	end)

	return Frame, function(k) if typeof(k) == "EnumItem" then Btn.Text = k.Name end end, function() return Btn.Text end
end

-- Section (big header line like Balright)
function ModernUILibrary:CreateSection(container, title)
	local parent = resolveContainer(container) or self.Content
	local SectionFrame = Instance.new("Frame", parent)
	SectionFrame.Size = UDim2.new(1, 0, 0, 28)
	SectionFrame.BackgroundTransparency = 1
	local Label = Instance.new("TextLabel", SectionFrame)
	Label.Text = ("  %s"):format(title or "")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 13
	Label.TextColor3 = self.Theme.TextDark
	Label.TextXAlignment = Enum.TextXAlignment.Left
	local Line = Instance.new("Frame", SectionFrame)
	Line.Size = UDim2.new(1, 0, 0, 1)
	Line.Position = UDim2.new(0,0,1,-1)
	Line.BackgroundColor3 = self.Theme.Border
	Line.BorderSizePixel = 0
	return SectionFrame
end

-- Grouped boxed section (like Balright boxed groups)
function ModernUILibrary:CreateGroup(container, title)
	local parent = resolveContainer(container) or self.Content
	local Wrapper = Instance.new("Frame", parent)
	Wrapper.Size = UDim2.new(1, 0, 0, 8)
	Wrapper.BackgroundTransparency = 1

	local Frame = Instance.new("Frame", Wrapper)
	Frame.Size = UDim2.new(1, 0, 0, 0)
	Frame.Position = UDim2.new(0, 0, 0, 8)
	Frame.BackgroundColor3 = self.Theme.ContentBg
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)
	Instance.new("UIStroke", Frame).Color = self.Theme.Border

	local inner = Instance.new("Frame", Frame)
	inner.Size = UDim2.new(1, -20, 1, -20)
	inner.Position = UDim2.new(0, 10, 0, 10)
	inner.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", inner)
	layout.Padding = UDim.new(0,12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local h = layout.AbsoluteContentSize.Y + 28
		Frame.Size = UDim2.new(1, 0, 0, h)
		Wrapper.Size = UDim2.new(1, 0, 0, h + 12)
	end)

	if title and title ~= "" then
		local head = Instance.new("TextLabel", Wrapper)
		head.Text = title
		head.Size = UDim2.new(1, -24, 0, 20)
		head.Position = UDim2.new(0, 12, 0, -6)
		head.BackgroundTransparency = 1
		head.Font = Enum.Font.GothamBold
		head.TextSize = 13
		head.TextColor3 = self.Theme.Text
		head.TextXAlignment = Enum.TextXAlignment.Left
	end

	return { Frame = inner, Wrapper = Wrapper }
end

-- Init: parent to PlayerGui (or passed parent)
function ModernUILibrary:Init(parent)
	self.ScreenGui.Parent = parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	return self
end

-- Destroy
function ModernUILibrary:Destroy()
	if self.ScreenGui then self.ScreenGui:Destroy() end
end

return ModernUILibrary

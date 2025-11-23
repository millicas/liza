local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Core = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local v2, v3 = Vector2.new, Vector3.new
local udim2, udim = UDim2.new, UDim.new
local rgb = Color3.fromRGB

local Colors = {
    Accent = rgb(0, 102, 255),
    AccentDark = rgb(0, 85, 220),
    Background = rgb(255, 255, 255),
    SidebarBg = rgb(250, 250, 250),
    ElementBg = rgb(255, 255, 255),
    InlineBg = rgb(245, 245, 247),
    Border = rgb(230, 230, 235),
    BorderDark = rgb(200, 200, 210),
    Text = rgb(20, 20, 30),
    TextDark = rgb(100, 100, 110),
    TextDarker = rgb(150, 150, 160),
    Circle = rgb(255, 255, 255),
    Icon = rgb(120, 120, 130)
}

local Modern = {}
Modern.__index = Modern

local function create(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

local function tween(obj, props, time, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function roundCorners(parent, radius)
    local uc = create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 8)})
    return uc
end

local function subtleStroke(parent, color, thickness)
    local s = create("UIStroke", {
        Parent = parent,
        Color = color or Colors.Border,
        Thickness = thickness or 1,
        Transparency = 0
    })
    return s
end

local Library = {
    Flags = {},
    Conns = {},
    ScreenGui = nil,
    TweenSpeed = 0.2
}
Library.__index = Library

function Library:Connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(self.Conns, c)
    return c
end

function Library:Unload()
    for _,c in ipairs(self.Conns) do
        pcall(function() c:Disconnect() end)
    end
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
    end
end

function Library:Window(opts)
    opts = opts or {}
    local win = {}
    win.Name = opts.Name or "Liza"
    win.Size = opts.Size or udim2(0, 900, 0, 600)
    win.Tabs = {}
    win.CurrentTab = nil
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    self.ScreenGui = create("ScreenGui", {
        Parent = Core,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    local container = create("Frame", {
        Parent = self.ScreenGui,
        Size = win.Size,
        Position = udim2(0.5, -win.Size.X.Offset/2, 0.5, -win.Size.Y.Offset/2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    roundCorners(container, 16)
    subtleStroke(container, Colors.Border)
    
    -- Add shadow effect
    local shadow = create("ImageLabel", {
        Parent = container,
        Size = udim2(1, 40, 1, 40),
        Position = udim2(0.5, 0, 0.5, 0),
        AnchorPoint = v2(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        ImageTransparency = 0.9,
        ZIndex = 0
    })

    local header = create("Frame", {
        Parent = container,
        Size = udim2(1, 0, 0, 64),
        Position = udim2(0, 0, 0, 0),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    
    local divider = create("Frame", {
        Parent = header,
        Size = udim2(1, 0, 0, 1),
        Position = udim2(0, 0, 1, -1),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    
    local title = create("TextLabel", {
        Parent = header,
        Position = udim2(0, 24, 0.5, 0),
        AnchorPoint = v2(0, 0.5),
        BackgroundTransparency = 1,
        Text = win.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Colors.Text
    })

    local sidebar = create("Frame", {
        Parent = container,
        Size = udim2(0, 220, 1, -64),
        Position = udim2(0, 0, 0, 64),
        BackgroundColor3 = Colors.SidebarBg,
        BorderSizePixel = 0
    })
    
    local sidebarDivider = create("Frame", {
        Parent = sidebar,
        Size = udim2(0, 1, 1, 0),
        Position = udim2(1, 0, 0, 0),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    
    local tabHolder = create("ScrollingFrame", {
        Parent = sidebar,
        Size = udim2(1, -24, 1, -24),
        Position = udim2(0, 12, 0, 12),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        CanvasSize = udim2(0, 0, 0, 0)
    })
    
    local list = create("UIListLayout", {
        Parent = tabHolder,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Left
    })
    
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabHolder.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12)
    end)

    -- Main content area with background
    local contentContainer = create("Frame", {
        Parent = container,
        Size = udim2(1, -220, 1, -64),
        Position = udim2(0, 220, 0, 64),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Background image for content area only
    local backgroundImage = create("ImageLabel", {
        Parent = contentContainer,
        Size = udim2(1, 0, 1, 0),
        Position = udim2(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://80547362214007",
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.94,
        ZIndex = 1
    })
    
    local contentArea = create("ScrollingFrame", {
        Parent = contentContainer,
        Size = udim2(1, -32, 1, -32),
        Position = udim2(0, 16, 0, 16),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 2
    })
    
    local contentLayout = create("UIListLayout", {
        Parent = contentArea,
        Padding = UDim.new(0, 20),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)

    win.Root = container
    win.Header = header
    win.Title = title
    win.Sidebar = sidebar
    win.TabHolder = tabHolder
    win.Content = contentArea
    win.ContentContainer = contentContainer

    do
        local dragging, start, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                start = input.Position
                startPos = container.Position
            end
        end)
        
        header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        self:Connect(UserInputService.InputChanged, function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - start
                container.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    return setmetatable(win, Library)
end

function Library:Tab(opts)
    opts = opts or {}
    local tab = {}
    tab.Name = opts.Name or "Tab"
    tab.Icon = opts.Icon or ""
    
    local tabBtn = create("TextButton", {
        Parent = self.TabHolder,
        Size = udim2(1, 0, 0, 44),
        BackgroundColor3 = Colors.SidebarBg,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = #self.Tabs
    })
    roundCorners(tabBtn, 8)
    
    local btnContent = create("Frame", {
        Parent = tabBtn,
        Size = udim2(1, -16, 1, -8),
        Position = udim2(0, 8, 0, 4),
        BackgroundTransparency = 1
    })
    
    local btnTitle = create("TextLabel", {
        Parent = btnContent,
        Size = udim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tab.Name,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextColor3 = Colors.TextDark,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local content = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local contentList = create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    tab.Btn = tabBtn
    tab.Content = content
    tab.Elements = {}

    self:Connect(tabBtn.MouseEnter, function()
        if self.CurrentTab ~= tab then
            tween(tabBtn, {BackgroundColor3 = Colors.InlineBg})
            tween(btnTitle, {TextColor3 = Colors.Text})
        end
    end)
    
    self:Connect(tabBtn.MouseLeave, function()
        if self.CurrentTab ~= tab then
            tween(tabBtn, {BackgroundColor3 = Colors.SidebarBg})
            tween(btnTitle, {TextColor3 = Colors.TextDark})
        end
    end)

    self:Connect(tabBtn.MouseButton1Click, function()
        self:SwitchTab(tab)
    end)

    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    return setmetatable(tab, {__index = Library.TabMethods})
end

Library.TabMethods = {}

function Library.TabMethods:Section(opts)
    opts = opts or {}
    local section = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Elements
    })
    
    local sectionLabel = create("TextLabel", {
        Parent = section,
        Size = udim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "SECTION",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Colors.TextDarker,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom
    })
    
    table.insert(self.Elements, section)
    return section
end

function Library.TabMethods:Button(opts)
    opts = opts or {}
    local button = create("TextButton", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 48),
        BackgroundColor3 = Colors.ElementBg,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = #self.Elements
    })
    roundCorners(button, 10)
    subtleStroke(button, Colors.Border)
    
    local btnContent = create("Frame", {
        Parent = button,
        Size = udim2(1, -32, 1, -16),
        Position = udim2(0, 16, 0, 8),
        BackgroundTransparency = 1
    })
    
    local btnTitle = create("TextLabel", {
        Parent = btnContent,
        Size = udim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "Button",
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    self:Connect(button.MouseEnter, function()
        tween(button, {BackgroundColor3 = Colors.InlineBg})
    end)
    
    self:Connect(button.MouseLeave, function()
        tween(button, {BackgroundColor3 = Colors.ElementBg})
    end)
    
    self:Connect(button.MouseButton1Click, function()
        tween(button, {BackgroundColor3 = Colors.Accent}, 0.1)
        tween(btnTitle, {TextColor3 = Colors.Background}, 0.1)
        wait(0.15)
        tween(button, {BackgroundColor3 = Colors.ElementBg}, 0.2)
        tween(btnTitle, {TextColor3 = Colors.Text}, 0.2)
        if opts.Callback then
            opts.Callback()
        end
    end)
    
    table.insert(self.Elements, button)
    return button
end

function Library.TabMethods:Toggle(opts)
    opts = opts or {}
    local toggle = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 48),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        LayoutOrder = #self.Elements
    })
    roundCorners(toggle, 10)
    subtleStroke(toggle, Colors.Border)
    
    local toggleContent = create("Frame", {
        Parent = toggle,
        Size = udim2(1, -32, 1, -16),
        Position = udim2(0, 16, 0, 8),
        BackgroundTransparency = 1
    })
    
    local label = create("TextLabel", {
        Parent = toggleContent,
        Size = udim2(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local toggleContainer = create("TextButton", {
        Parent = toggleContent,
        Size = udim2(0, 44, 0, 24),
        Position = udim2(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Colors.Border,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0
    })
    roundCorners(toggleContainer, 12)
    
    local toggleCircle = create("Frame", {
        Parent = toggleContainer,
        Size = udim2(0, 20, 0, 20),
        Position = udim2(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Circle,
        BorderSizePixel = 0
    })
    roundCorners(toggleCircle, 10)
    
    local state = opts.Default or false
    
    local function updateToggle()
        if state then
            tween(toggleContainer, {BackgroundColor3 = Colors.Accent})
            tween(toggleCircle, {Position = UDim2.new(1, -22, 0.5, 0)})
        else
            tween(toggleContainer, {BackgroundColor3 = Colors.Border})
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)})
        end
    end
    
    updateToggle()
    
    self:Connect(toggleContainer.MouseButton1Click, function()
        state = not state
        updateToggle()
        if opts.Callback then
            opts.Callback(state)
        end
    end)
    
    table.insert(self.Elements, toggle)
    return toggle
end

function Library.TabMethods:Slider(opts)
    opts = opts or {}
    local slider = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 64),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        LayoutOrder = #self.Elements
    })
    roundCorners(slider, 10)
    subtleStroke(slider, Colors.Border)
    
    local sliderContent = create("Frame", {
        Parent = slider,
        Size = udim2(1, -32, 1, -16),
        Position = udim2(0, 16, 0, 8),
        BackgroundTransparency = 1
    })
    
    local label = create("TextLabel", {
        Parent = sliderContent,
        Size = udim2(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = opts.Name or "Slider",
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    local valueLabel = create("TextLabel", {
        Parent = sliderContent,
        Size = udim2(0, 50, 0, 24),
        Position = udim2(1, 0, 0, 0),
        AnchorPoint = v2(1, 0),
        BackgroundTransparency = 1,
        Text = tostring(opts.Default or opts.Min or 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        TextColor3 = Colors.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    local sliderTrack = create("Frame", {
        Parent = sliderContent,
        Size = udim2(1, 0, 0, 6),
        Position = udim2(0, 0, 1, -6),
        AnchorPoint = v2(0, 1),
        BackgroundColor3 = Colors.InlineBg,
        BorderSizePixel = 0
    })
    roundCorners(sliderTrack, 3)
    
    local sliderFill = create("Frame", {
        Parent = sliderTrack,
        Size = udim2(0, 0, 1, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0
    })
    roundCorners(sliderFill, 3)
    
    local sliderButton = create("TextButton", {
        Parent = sliderTrack,
        Size = udim2(0, 18, 0, 18),
        Position = udim2(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Background,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0
    })
    roundCorners(sliderButton, 9)
    subtleStroke(sliderButton, Colors.Accent, 2)
    
    local min = opts.Min or 0
    local max = opts.Max or 100
    local default = opts.Default or min
    local value = default
    local dragging = false
    
    local function updateSlider(val)
        val = math.clamp(val, min, max)
        value = val
        local percentage = (val - min) / (max - min)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderButton.Position = UDim2.new(percentage, 0, 0.5, 0)
        valueLabel.Text = tostring(math.floor(val))
        
        if opts.Callback then
            opts.Callback(val)
        end
    end
    
    self:Connect(sliderButton.MouseButton1Down, function()
        dragging = true
    end)
    
    self:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    self:Connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local trackAbsPos = sliderTrack.AbsolutePosition
            local trackAbsSize = sliderTrack.AbsoluteSize
            local relativeX = (mousePos.X - trackAbsPos.X) / trackAbsSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newValue = min + (relativeX * (max - min))
            updateSlider(newValue)
        end
    end)
    
    updateSlider(default)
    table.insert(self.Elements, slider)
    return slider
end

function Library.TabMethods:Keybind(opts)
    opts = opts or {}
    local keybind = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 48),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        LayoutOrder = #self.Elements
    })
    roundCorners(keybind, 10)
    subtleStroke(keybind, Colors.Border)
    
    local keybindContent = create("Frame", {
        Parent = keybind,
        Size = udim2(1, -32, 1, -16),
        Position = udim2(0, 16, 0, 8),
        BackgroundTransparency = 1
    })
    
    local label = create("TextLabel", {
        Parent = keybindContent,
        Size = udim2(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "Keybind",
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local keybindButton = create("TextButton", {
        Parent = keybindContent,
        Size = udim2(0, 90, 0, 32),
        Position = udim2(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Colors.InlineBg,
        AutoButtonColor = false,
        Text = opts.Default and opts.Default.Name or "None",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    roundCorners(keybindButton, 8)
    subtleStroke(keybindButton, Colors.Border)
    
    local currentKey = opts.Default
    local listening = false
    
    local function updateKeybind(key)
        currentKey = key
        keybindButton.Text = key and key.Name or "None"
        
        if opts.Callback then
            opts.Callback(key)
        end
    end
    
    self:Connect(keybindButton.MouseButton1Click, function()
        listening = true
        keybindButton.Text = "..."
        tween(keybindButton, {BackgroundColor3 = Colors.Accent})
        tween(keybindButton, {TextColor3 = Colors.Background})
    end)
    
    self:Connect(UserInputService.InputBegan, function(input)
        if listening then
            listening = false
            if input.UserInputType == Enum.UserInputType.Keyboard then
                updateKeybind(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateKeybind(Enum.KeyCode.LeftControl)
            end
            tween(keybindButton, {BackgroundColor3 = Colors.InlineBg})
            tween(keybindButton, {TextColor3 = Colors.Text})
        elseif currentKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            if opts.Pressed then
                opts.Pressed()
            end
        end
    end)
    
    table.insert(self.Elements, keybind)
    return keybind
end

function Library.TabMethods:Dropdown(opts)
    opts = opts or {}
    local dropdown = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 64),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        LayoutOrder = #self.Elements
    })
    roundCorners(dropdown, 10)
    subtleStroke(dropdown, Colors.Border)
    
    local dropdownContent = create("Frame", {
        Parent = dropdown,
        Size = udim2(1, -32, 1, -16),
        Position = udim2(0, 16, 0, 8),
        BackgroundTransparency = 1
    })
    
    local label = create("TextLabel", {
        Parent = dropdownContent,
        Size = udim2(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = opts.Name or "Dropdown",
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    local dropdownButton = create("TextButton", {
        Parent = dropdownContent,
        Size = udim2(1, 0, 0, 32),
        Position = udim2(0, 0, 1, -6),
        AnchorPoint = v2(0, 1),
        BackgroundColor3 = Colors.InlineBg,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0
    })
    roundCorners(dropdownButton, 8)
    subtleStroke(dropdownButton, Colors.Border)
    
    local dropdownText = create("TextLabel", {
        Parent = dropdownButton,
        Size = udim2(1, -40, 1, 0),
        Position = udim2(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = opts.Default or "Select...",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Colors.TextDark,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local dropdownIcon = create("TextLabel", {
        Parent = dropdownButton,
        Size = udim2(0, 20, 0, 20),
        Position = udim2(1, -30, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Colors.Icon,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local dropdownList = create("ScrollingFrame", {
        Parent = dropdownContent,
        Size = udim2(1, 0, 0, 0),
        Position = udim2(0, 0, 1, 4),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10
    })
    roundCorners(dropdownList, 8)
    subtleStroke(dropdownList, Colors.Border)
    
    local listLayout = create("UIListLayout", {
        Parent = dropdownList,
        Padding = UDim.new(0, 2)
    })
    
    local options = opts.Options or {}
    local open = false
    local selected = opts.Default
    
    local function updateDropdown()
        dropdownText.Text = selected or "Select..."
        if opts.Callback then
            opts.Callback(selected)
        end
    end
    
    local function toggleDropdown()
        open = not open
        dropdownList.Visible = open
        
        if open then
            local height = math.min(#options * 38, 180)
            tween(dropdownList, {Size = udim2(1, 0, 0, height)})
            tween(dropdownIcon, {Rotation = 180})
            tween(dropdownButton, {BackgroundColor3 = Colors.Background})
        else
            tween(dropdownList, {Size = udim2(1, 0, 0, 0)})
            tween(dropdownIcon, {Rotation = 0})
            tween(dropdownButton, {BackgroundColor3 = Colors.InlineBg})
        end
    end
    
    for i, option in ipairs(options) do
        local optionButton = create("TextButton", {
            Parent = dropdownList,
            Size = udim2(1, 0, 0, 36),
            BackgroundColor3 = Colors.Background,
            AutoButtonColor = false,
            Text = "",
            BorderSizePixel = 0
        })
        
        local optionLabel = create("TextLabel", {
            Parent = optionButton,
            Size = udim2(1, -24, 1, 0),
            Position = udim2(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        
        self:Connect(optionButton.MouseEnter, function()
            tween(optionButton, {BackgroundColor3 = Colors.InlineBg})
        end)
        
        self:Connect(optionButton.MouseLeave, function()
            tween(optionButton, {BackgroundColor3 = Colors.Background})
        end)
        
        self:Connect(optionButton.MouseButton1Click, function()
            selected = option
            updateDropdown()
            toggleDropdown()
        end)
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    self:Connect(dropdownButton.MouseButton1Click, function()
        toggleDropdown()
    end)
    
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Library:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        tween(self.CurrentTab.Btn, {BackgroundColor3 = Colors.SidebarBg})
        local btnLabel = self.CurrentTab.Btn:FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("TextLabel")
        if btnLabel then
            tween(btnLabel, {TextColor3 = Colors.TextDark})
        end
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    tween(tab.Btn, {BackgroundColor3 = Colors.Accent})
    local btnLabel = tab.Btn:FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("TextLabel")
    if btnLabel then
        tween(btnLabel, {TextColor3 = Colors.Background})
    end
end

function Library:Toggle()
    if self.Root then
        self.Root.Visible = not self.Root.Visible
    end
end

return setmetatable({
    New = function()
        return Library
    end,
}, {__call = function(_, ...)
    return Library
end})

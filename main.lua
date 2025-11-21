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
    Accent = rgb(255, 255, 255),
    AccentDark = rgb(200, 200, 200),
    Background = rgb(16, 18, 18),
    SidebarBg = rgb(21, 24, 24),
    ElementBg = rgb(30, 34, 34),
    InlineBg = rgb(21, 24, 24),
    Border = rgb(30, 34, 34),
    BorderDark = rgb(56, 62, 62),
    Text = rgb(255, 255, 255),
    TextDark = rgb(100, 100, 100),
    TextDarker = rgb(75, 75, 75),
    Circle = rgb(200, 200, 200),
    Icon = rgb(100, 100, 100)
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
        Transparency = 0.6
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
    win.Size = opts.Size or udim2(0, 800, 0, 560)
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
    
    local background = create("Frame", {
        Parent = self.ScreenGui,
        Size = udim2(1, 0, 1, 0),
        Position = udim2(0, 0, 0, 0),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    
    local backgroundImage = create("ImageLabel", {
        Parent = self.ScreenGui,
        Size = udim2(1, 0, 1, 0),
        Position = udim2(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://80547362214007",
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.1
    })
    
    local container = create("Frame", {
        Parent = self.ScreenGui,
        Size = win.Size,
        Position = udim2(0.5, -win.Size.X.Offset/2, 0.5, -win.Size.Y.Offset/2),
        BackgroundColor3 = Colors.SidebarBg,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    roundCorners(container, 12)
    subtleStroke(container, Colors.Border)

    local header = create("Frame", {
        Parent = container,
        Size = udim2(1, 0, 0, 56),
        Position = udim2(0, 0, 0, 0),
        BackgroundColor3 = Colors.SidebarBg,
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
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        TextColor3 = Colors.Text
    })

    local sidebar = create("Frame", {
        Parent = container,
        Size = udim2(0, 200, 1, -56),
        Position = udim2(0, 0, 0, 56),
        BackgroundColor3 = Colors.SidebarBg,
        BorderSizePixel = 0
    })
    
    local sidebarDivider = create("Frame", {
        Parent = sidebar,
        Size = udim2(0, 1, 1, 0),
        Position = udim2(1, -1, 0, 0),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    
    local tabHolder = create("Frame", {
        Parent = sidebar,
        Size = udim2(1, -16, 1, -24),
        Position = udim2(0, 16, 0, 16),
        BackgroundTransparency = 1,
    })
    
    local list = create("UIListLayout", {
        Parent = tabHolder,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Left
    })

    local contentArea = create("ScrollingFrame", {
        Parent = container,
        Size = udim2(1, -216, 1, -72),
        Position = udim2(0, 200, 0, 56),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local contentLayout = create("UIListLayout", {
        Parent = contentArea,
        Padding = UDim.new(0, 16),
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
        Size = udim2(1, 0, 0, 40),
        BackgroundColor3 = Colors.SidebarBg,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = #self.Tabs
    })
    roundCorners(tabBtn, 6)
    
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
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.TextDark,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local content = create("Frame", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false
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
        Size = udim2(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Elements
    })
    
    local sectionLabel = create("TextLabel", {
        Parent = section,
        Size = udim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.upper(opts.Name or "SECTION"),
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 12,
        TextColor3 = Colors.TextDarker,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    table.insert(self.Elements, section)
    return section
end

function Library.TabMethods:Button(opts)
    opts = opts or {}
    local button = create("TextButton", {
        Parent = self.Content,
        Size = udim2(1, 0, 0, 42),
        BackgroundColor3 = Colors.ElementBg,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = #self.Elements
    })
    roundCorners(button, 8)
    subtleStroke(button, Colors.Border)
    
    local btnContent = create("Frame", {
        Parent = button,
        Size = udim2(1, -24, 1, -16),
        Position = udim2(0, 12, 0, 8),
        BackgroundTransparency = 1
    })
    
    local btnTitle = create("TextLabel", {
        Parent = btnContent,
        Size = udim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "Button",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    self:Connect(button.MouseEnter, function()
        tween(button, {BackgroundColor3 = Colors.InlineBg})
    end)
    
    self:Connect(button.MouseLeave, function()
        tween(button, {BackgroundColor3 = Colors.ElementBg})
    end)
    
    self:Connect(button.MouseButton1Click, function()
        tween(button, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.Background}, 0.1)
        wait(0.1)
        tween(button, {BackgroundColor3 = Colors.InlineBg}, 0.1)
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
        Size = udim2(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Elements
    })
    
    local label = create("TextLabel", {
        Parent = toggle,
        Size = udim2(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "Toggle",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleContainer = create("TextButton", {
        Parent = toggle,
        Size = udim2(0, 36, 0, 20),
        Position = udim2(1, -36, 0.5, -10),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Colors.Border,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0
    })
    roundCorners(toggleContainer, 10)
    
    local toggleCircle = create("Frame", {
        Parent = toggleContainer,
        Size = udim2(0, 16, 0, 16),
        Position = udim2(0, 2, 0.5, -8),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0
    })
    roundCorners(toggleCircle, 8)
    
    local state = opts.Default or false
    
    local function updateToggle()
        if state then
            tween(toggleContainer, {BackgroundColor3 = Colors.Accent})
            tween(toggleCircle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Colors.ElementBg})
        else
            tween(toggleContainer, {BackgroundColor3 = Colors.Border})
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Colors.ElementBg})
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
        Size = udim2(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Elements
    })
    
    local label = create("TextLabel", {
        Parent = slider,
        Size = udim2(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = opts.Name or "Slider",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = create("TextLabel", {
        Parent = slider,
        Size = udim2(0, 40, 0, 20),
        Position = udim2(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(opts.Default or opts.Min or 0),
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.TextDark,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderTrack = create("Frame", {
        Parent = slider,
        Size = udim2(1, 0, 0, 6),
        Position = udim2(0, 0, 1, -16),
        BackgroundColor3 = Colors.Border,
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
        Size = udim2(0, 16, 0, 16),
        Position = udim2(0, 0, 0.5, -8),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Circle,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0
    })
    roundCorners(sliderButton, 8)
    subtleStroke(sliderButton, Colors.BorderDark)
    
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
        sliderButton.Position = UDim2.new(percentage, 0, 0.5, -8)
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
        Size = udim2(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Elements
    })
    
    local label = create("TextLabel", {
        Parent = keybind,
        Size = udim2(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Name or "Keybind",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local keybindButton = create("TextButton", {
        Parent = keybind,
        Size = udim2(0, 80, 0, 30),
        Position = udim2(1, -80, 0.5, -15),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Colors.ElementBg,
        AutoButtonColor = false,
        Text = opts.Default and opts.Default.Name or "None",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    roundCorners(keybindButton, 6)
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
        keybindButton.BackgroundColor3 = Colors.Accent
    end)
    
    self:Connect(UserInputService.InputBegan, function(input)
        if listening then
            listening = false
            if input.UserInputType == Enum.UserInputType.Keyboard then
                updateKeybind(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateKeybind(Enum.KeyCode.LeftControl)
            end
            tween(keybindButton, {BackgroundColor3 = Colors.ElementBg})
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
        Size = udim2(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Elements
    })
    
    local label = create("TextLabel", {
        Parent = dropdown,
        Size = udim2(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = opts.Name or "Dropdown",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = create("TextButton", {
        Parent = dropdown,
        Size = udim2(1, 0, 0, 32),
        Position = udim2(0, 0, 1, -32),
        BackgroundColor3 = Colors.ElementBg,
        AutoButtonColor = false,
        Text = opts.Default or "Select...",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Colors.TextDark,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    roundCorners(dropdownButton, 6)
    subtleStroke(dropdownButton, Colors.Border)
    
    local dropdownIcon = create("TextLabel", {
        Parent = dropdownButton,
        Size = udim2(0, 20, 0, 20),
        Position = udim2(1, -25, 0.5, -10),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextColor3 = Colors.Icon,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    local dropdownList = create("ScrollingFrame", {
        Parent = dropdown,
        Size = udim2(1, 0, 0, 0),
        Position = udim2(0, 0, 1, 4),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true
    })
    roundCorners(dropdownList, 6)
    subtleStroke(dropdownList, Colors.Border)
    
    local listLayout = create("UIListLayout", {
        Parent = dropdownList,
        Padding = UDim.new(0, 1)
    })
    
    local options = opts.Options or {}
    local open = false
    local selected = opts.Default
    
    local function updateDropdown()
        dropdownButton.Text = selected or "Select..."
        if opts.Callback then
            opts.Callback(selected)
        end
    end
    
    local function toggleDropdown()
        open = not open
        dropdownList.Visible = open
        
        if open then
            local height = math.min(#options * 32, 160)
            tween(dropdownList, {Size = udim2(1, 0, 0, height)})
            tween(dropdownIcon, {Rotation = 180})
        else
            tween(dropdownList, {Size = udim2(1, 0, 0, 0)})
            tween(dropdownIcon, {Rotation = 0})
        end
    end
    
    for i, option in ipairs(options) do
        local optionButton = create("TextButton", {
            Parent = dropdownList,
            Size = udim2(1, 0, 0, 32),
            BackgroundColor3 = Colors.ElementBg,
            AutoButtonColor = false,
            Text = option,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextColor3 = Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        })
        
        local optionPadding = create("UIPadding", {
            Parent = optionButton,
            PaddingLeft = UDim.new(0, 12)
        })
        
        self:Connect(optionButton.MouseEnter, function()
            tween(optionButton, {BackgroundColor3 = Colors.InlineBg})
        end)
        
        self:Connect(optionButton.MouseLeave, function()
            tween(optionButton, {BackgroundColor3 = Colors.ElementBg})
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
        tween(self.CurrentTab.Btn:FindFirstChildOfClass("TextLabel"), {TextColor3 = Colors.TextDark})
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    tween(tab.Btn, {BackgroundColor3 = Colors.Accent})
    tween(tab.Btn:FindFirstChildOfClass("TextLabel"), {TextColor3 = Colors.Background})
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

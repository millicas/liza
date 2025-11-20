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
    Primary = rgb(0, 153, 255),       -- Framer blue
    PrimaryHover = rgb(0, 102, 204),  -- darker blue for hover
    Background = rgb(26, 26, 26),     -- dark background
    Surface = rgb(40, 40, 40),        -- panels / cards
    Border = rgb(70, 70, 70),         -- subtle borders
    TextPrimary = rgb(230, 230, 230), -- main text
    TextSecondary = rgb(160, 160, 160), -- secondary text
    TextTertiary = rgb(120, 120, 120),  -- tertiary / muted text
    Divider = rgb(60, 60, 60),        -- divider lines
    Hover = rgb(50, 50, 50)           -- hover background for panels/buttons
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
    for _,c in ipairs(self.Conns) do pcall(function() c:Disconnect() end) end
    if self.ScreenGui then pcall(function() self.ScreenGui:Destroy() end) end
end

function Library:Window(opts)
    opts = opts or {}
    local win = {}
    win.Name = opts.Name or "Liza"
    win.Size = opts.Size or udim2(0, 800, 0, 560)
    win.Tabs = {}
    win.CurrentTab = nil

    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui = create("ScreenGui", {
        Parent = Core,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })

    -- Main container with subtle shadow effect
    local container = create("Frame", {
        Parent = self.ScreenGui,
        Size = win.Size,
        Position = udim2(0.5, -win.Size.X.Offset/2, 0.5, -win.Size.Y.Offset/2),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    roundCorners(container, 12)
    subtleStroke(container, Colors.Border)

    -- Header
    local header = create("Frame", {
        Parent = container,
        Size = udim2(1, 0, 0, 56),
        Position = udim2(0, 0, 0, 0),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0
    })
    
    local divider = create("Frame", {
        Parent = header,
        Size = udim2(1, 0, 0, 1),
        Position = udim2(0, 0, 1, -1),
        BackgroundColor3 = Colors.Divider,
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
        TextColor3 = Colors.TextPrimary
    })

    -- Sidebar
    local sidebar = create("Frame", {
        Parent = container,
        Size = udim2(0, 200, 1, -56),
        Position = udim2(0, 0, 0, 56),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })

    local sidebarDivider = create("Frame", {
        Parent = sidebar,
        Size = udim2(0, 1, 1, 0),
        Position = udim2(1, -1, 0, 0),
        BackgroundColor3 = Colors.Divider,
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

    -- Content area
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

    -- Dragging functionality
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

-- Tab methods
function Library:Tab(opts)
    opts = opts or {}
    local tab = {}
    tab.Name = opts.Name or "Tab"
    tab.Icon = opts.Icon or ""

    -- Create tab button
    local tabBtn = create("TextButton", {
        Parent = self.TabHolder,
        Size = udim2(1, 0, 0, 40),
        BackgroundColor3 = Colors.Background,
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
        TextColor3 = Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Create tab content frame
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

    -- Hover effects
    self:Connect(tabBtn.MouseEnter, function()
        if self.CurrentTab ~= tab then
            tween(tabBtn, {BackgroundColor3 = Colors.Hover})
            tween(btnTitle, {TextColor3 = Colors.TextPrimary})
        end
    end)

    self:Connect(tabBtn.MouseLeave, function()
        if self.CurrentTab ~= tab then
            tween(tabBtn, {BackgroundColor3 = Colors.Background})
            tween(btnTitle, {TextColor3 = Colors.TextSecondary})
        end
    end)

    -- Tab switch logic
    self:Connect(tabBtn.MouseButton1Click, function()
        self:SwitchTab(tab)
    end)

    table.insert(self.Tabs, tab)

    -- Set first tab as active
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    return setmetatable(tab, {__index = Library.TabMethods})
end

-- Tab methods table
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
        TextColor3 = Colors.TextTertiary,
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
        BackgroundColor3 = Colors.Surface,
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
        TextColor3 = Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Hover effects
    self:Connect(button.MouseEnter, function()
        tween(button, {BackgroundColor3 = Colors.Hover})
    end)

    self:Connect(button.MouseLeave, function()
        tween(button, {BackgroundColor3 = Colors.Surface})
    end)

    self:Connect(button.MouseButton1Click, function()
        -- Click animation
        tween(button, {BackgroundColor3 = Colors.Primary, TextColor3 = Colors.Surface}, 0.1)
        wait(0.1)
        tween(button, {BackgroundColor3 = Colors.Hover}, 0.1)
        
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
        TextColor3 = Colors.TextPrimary,
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
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0
    })
    roundCorners(toggleCircle, 8)

    local state = opts.Default or false

    local function updateToggle()
        if state then
            tween(toggleContainer, {BackgroundColor3 = Colors.Primary})
            tween(toggleCircle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Colors.Surface})
        else
            tween(toggleContainer, {BackgroundColor3 = Colors.Border})
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Colors.Surface})
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

function Library:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        tween(self.CurrentTab.Btn, {BackgroundColor3 = Colors.Background})
        tween(self.CurrentTab.Btn:FindFirstChildOfClass("TextLabel"), {TextColor3 = Colors.TextSecondary})
    end

    self.CurrentTab = tab
    tab.Content.Visible = true
    tween(tab.Btn, {BackgroundColor3 = Colors.Primary})
    tween(tab.Btn:FindFirstChildOfClass("TextLabel"), {TextColor3 = Colors.Surface})
end

function Library:Toggle()
    if self.Root then
        self.Root.Visible = not self.Root.Visible
    end
end

return setmetatable({
    New = function() return Library end,
}, {__call = function(_, ...) return Library end})

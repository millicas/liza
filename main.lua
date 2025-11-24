-- Modern UI Library for Roblox (PATCHED)
-- Fixed: spacing, keybind alignment, slider visibility, close button corner,
-- sidebar label border removed, background image replaced, rounded corners fixed, border color applied.

local ModernUILibrary = {}
ModernUILibrary.__index = ModernUILibrary

-- Theme
ModernUILibrary.Themes = {
    Dark = {
        Accent = Color3.fromRGB(30, 34, 34),
        AccentDark = Color3.fromRGB(200, 200, 200),
        Background = Color3.fromRGB(19, 19, 21),
        SidebarBg = Color3.fromRGB(19, 19, 21),
        ElementBg = Color3.fromRGB(19, 19, 21),
        InlineBg = Color3.fromRGB(21, 24, 24),
        Border = Color3.fromRGB(70, 70, 73),
        BorderDark = Color3.fromRGB(56, 62, 62),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(100, 100, 100),
        TextDarker = Color3.fromRGB(75, 75, 75),
        Circle = Color3.fromRGB(200, 200, 200),
        Icon = Color3.fromRGB(100, 100, 100)
    }
}

function ModernUILibrary.new(windowTitle, theme)
    local self = setmetatable({}, ModernUILibrary)
    self.Theme = theme or ModernUILibrary.Themes.Dark
    self.Elements = {}
    self.ActiveTab = nil
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ModernUILibrary"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false

    self:CreateWindow(windowTitle or "^_^")
    return self
end

function ModernUILibrary:CreateWindow(title)
    self.Window = Instance.new("Frame")
    self.Window.Name = "Window"
    self.Window.Size = UDim2.new(0, 900, 0, 600)
    self.Window.Position = UDim2.new(0.5, -450, 0.5, -300)
    self.Window.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Window.BackgroundColor3 = self.Theme.Background
    self.Window.BorderSizePixel = 0
    self.Window.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = self.Window

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Parent = self.Window

    -- Shadow: place outside window so rounded corners don't poke shadow image out
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0.5, -20, 0.5, -20)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://2615687895"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.8
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceScale = 0.1
    Shadow.ZIndex = -1
    Shadow.Parent = self.ScreenGui -- parent to ScreenGui so Window's clips don't cut it

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 64)
    Header.BackgroundColor3 = self.Theme.Background
    Header.BorderSizePixel = 0

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color = self.Theme.Border
    HeaderStroke.Thickness = 1
    HeaderStroke.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 24, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = self.Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Close button fixed to true corner
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -12, 0.5, -17.5)
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.BackgroundColor3 = self.Theme.Accent
    CloseButton.Text = "X"
    CloseButton.TextColor3 = self.Theme.Text
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = self.Theme.Border
    CloseStroke.Thickness = 1
    CloseStroke.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    CloseButton.Parent = Header

    Header.Parent = self.Window

    -- Main content
    local MainContent = Instance.new("Frame")
    MainContent.Name = "MainContent"
    MainContent.Size = UDim2.new(1, 0, 1, -64)
    MainContent.Position = UDim2.new(0, 0, 0, 64)
    MainContent.BackgroundTransparency = 1
    MainContent.ClipsDescendants = true

    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 220, 1, 0)
    self.Sidebar.BackgroundColor3 = self.Theme.SidebarBg
    self.Sidebar.BorderSizePixel = 0

    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = self.Theme.Border
    SidebarStroke.Thickness = 1
    SidebarStroke.Parent = self.Sidebar

    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(1, -24, 1, -24)
    TabHolder.Position = UDim2.new(0, 12, 0, 12)
    TabHolder.BackgroundTransparency = 1

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = TabHolder

    TabHolder.Parent = self.Sidebar

    -- Content area with background image (now using assetid and only inside content area)
    self.ContentArea = Instance.new("ScrollingFrame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -220, 1, 0)
    self.ContentArea.Position = UDim2.new(0, 220, 0, 0)
    self.ContentArea.BackgroundColor3 = self.Theme.Background
    self.ContentArea.BorderSizePixel = 0
    self.ContentArea.ScrollBarThickness = 4
    self.ContentArea.ScrollBarImageColor3 = self.Theme.Border
    self.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentArea.ClipsDescendants = true

    -- Background image replaced and kept within content area
    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = "rbxassetid://80547362214007"
    BackgroundImage.ImageTransparency = 0.94
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = 0
    BackgroundImage.Parent = self.ContentArea

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -32, 1, -32)
    Content.Position = UDim2.new(0, 16, 0, 16)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 2

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 20)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Content

    Content.Parent = self.ContentArea

    self.Sidebar.Parent = MainContent
    self.ContentArea.Parent = MainContent
    MainContent.Parent = self.Window
    self.Window.Parent = self.ScreenGui

    -- Make window draggable
    self:MakeDraggable(Header)

    return self.Window
end

function ModernUILibrary:MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function ModernUILibrary:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}

    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 44)
    TabButton.BackgroundColor3 = self.Theme.SidebarBg
    TabButton.Text = name
    TabButton.TextColor3 = self.Theme.Text
    TabButton.TextSize = 15
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.TextXAlignment = Enum.TextXAlignment.Left

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    -- Removed TabStroke to remove border around sidebar text

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 16)
    TabPadding.Parent = TabButton

    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.ZIndex = 2

    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Padding = UDim.new(0, 0)
    TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabContentLayout.Parent = TabContent

    TabContent.Parent = self.ContentArea:FindFirstChild("Content")

    TabButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.InlineBg}):Play()
    end)

    TabButton.MouseLeave:Connect(function()
        if tab ~= self.ActiveTab then
            game:GetService("TweenService"):Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.SidebarBg}):Play()
        end
    end)

    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)

    TabButton.Parent = self.Sidebar:FindFirstChild("TabHolder")

    tab.Button = TabButton
    tab.Content = TabContent

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    return tab
end

function ModernUILibrary:SwitchTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Button.BackgroundColor3 = self.Theme.SidebarBg
        t.Button.TextColor3 = self.Theme.Text
        t.Content.Visible = false
    end

    tab.Button.BackgroundColor3 = self.Theme.Accent
    tab.Button.TextColor3 = self.Theme.Text
    tab.Content.Visible = true

    self.ActiveTab = tab
end

function ModernUILibrary:CreateSection(tab, name)
    local section = {}

    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section"
    SectionFrame.Size = UDim2.new(1, 0, 0, 30)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.LayoutOrder = #tab.Content:GetChildren()
    SectionFrame.ZIndex = 2

    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "SectionLabel"
    SectionLabel.Size = UDim2.new(1, 0, 0, 20)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = string.upper(name)
    SectionLabel.TextColor3 = self.Theme.TextDarker
    SectionLabel.TextSize = 13
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionFrame

    section.Frame = SectionFrame
    SectionFrame.Parent = tab.Content

    return section
end

function ModernUILibrary:CreateButton(tab, text, callback)
    local button = {}

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = "Button"
    ButtonFrame.Size = UDim2.new(1, 0, 0, 48)
    ButtonFrame.BackgroundColor3 = self.Theme.ElementBg
    ButtonFrame.LayoutOrder = #tab.Content:GetChildren()
    ButtonFrame.ZIndex = 2

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = ButtonFrame

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = self.Theme.Border
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = ButtonFrame

    local ButtonTitle = Instance.new("TextLabel")
    ButtonTitle.Name = "ButtonTitle"
    ButtonTitle.Size = UDim2.new(1, -32, 1, 0)
    ButtonTitle.Position = UDim2.new(0, 16, 0, 0)
    ButtonTitle.BackgroundTransparency = 1
    ButtonTitle.Text = text
    ButtonTitle.TextColor3 = self.Theme.Text
    ButtonTitle.TextSize = 15
    ButtonTitle.Font = Enum.Font.Gotham
    ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
    ButtonTitle.Parent = ButtonFrame

    local ButtonButton = Instance.new("TextButton")
    ButtonButton.Size = UDim2.new(1, 0, 1, 0)
    ButtonButton.BackgroundTransparency = 1
    ButtonButton.Text = ""
    ButtonButton.ZIndex = 3
    ButtonButton.Parent = ButtonFrame

    ButtonButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.InlineBg}):Play()
    end)

    ButtonButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.ElementBg}):Play()
    end)

    ButtonButton.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    button.Frame = ButtonFrame
    ButtonFrame.Parent = tab.Content

    return button
end

function ModernUILibrary:CreateToggle(tab, text, default, callback)
    local toggle = {}
    toggle.State = default or false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 48)
    ToggleFrame.BackgroundColor3 = self.Theme.ElementBg
    ToggleFrame.LayoutOrder = #tab.Content:GetChildren()
    ToggleFrame.ZIndex = 2

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = self.Theme.Border
    ToggleStroke.Thickness = 1
    ToggleStroke.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 16, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = self.Theme.Text
    ToggleLabel.TextSize = 15
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Name = "ToggleContainer"
    ToggleContainer.Size = UDim2.new(0, 44, 0, 24)
    ToggleContainer.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleContainer.AnchorPoint = Vector2.new(1, 0.5)
    ToggleContainer.BackgroundColor3 = self.Theme.InlineBg
    ToggleContainer.ZIndex = 3

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 12)
    ContainerCorner.Parent = ToggleContainer

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
    ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    ToggleCircle.BackgroundColor3 = self.Theme.Circle
    ToggleCircle.ZIndex = 4

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(0, 10)
    CircleCorner.Parent = ToggleCircle

    ToggleCircle.Parent = ToggleContainer
    ToggleContainer.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.ZIndex = 5
    ToggleButton.Parent = ToggleFrame

    local function UpdateToggle()
        if toggle.State then
            game:GetService("TweenService"):Create(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Accent}):Play()
            game:GetService("TweenService"):Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
        else
            game:GetService("TweenService"):Create(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.InlineBg}):Play()
            game:GetService("TweenService"):Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        toggle.State = not toggle.State
        UpdateToggle()
        if callback then
            callback(toggle.State)
        end
    end)

    ToggleFrame.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.InlineBg}):Play()
    end)

    ToggleFrame.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.ElementBg}):Play()
    end)

    UpdateToggle()

    toggle.Frame = ToggleFrame
    ToggleFrame.Parent = tab.Content

    function toggle:SetValue(value)
        toggle.State = value
        UpdateToggle()
    end

    function toggle:GetValue()
        return toggle.State
    end

    return toggle
end

function ModernUILibrary:CreateSlider(tab, text, min, max, default, callback)
    local slider = {}
    slider.Value = default or (min or 0)
    slider.Min = min or 0
    slider.Max = max or 100

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 64)
    SliderFrame.BackgroundColor3 = self.Theme.ElementBg
    SliderFrame.LayoutOrder = #tab.Content:GetChildren()
    SliderFrame.ZIndex = 2

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = SliderFrame

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = self.Theme.Border
    SliderStroke.Thickness = 1
    SliderStroke.Parent = SliderFrame

    local SliderHeader = Instance.new("Frame")
    SliderHeader.Name = "SliderHeader"
    SliderHeader.Size = UDim2.new(1, -32, 0, 20)
    SliderHeader.Position = UDim2.new(0, 16, 0, 16)
    SliderHeader.BackgroundTransparency = 1
    SliderHeader.ZIndex = 3

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "SliderLabel"
    SliderLabel.Size = UDim2.new(0.5, 0, 1, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text
    SliderLabel.TextColor3 = self.Theme.Text
    SliderLabel.TextSize = 15
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderHeader

    local SliderValue = Instance.new("TextLabel")
    SliderValue.Name = "SliderValue"
    SliderValue.Size = UDim2.new(0.5, 0, 1, 0)
    SliderValue.Position = UDim2.new(0.5, 0, 0, 0)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(slider.Value)
    SliderValue.TextColor3 = self.Theme.Text
    SliderValue.TextSize = 15
    SliderValue.Font = Enum.Font.GothamMedium
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = SliderHeader

    SliderHeader.Parent = SliderFrame

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "SliderTrack"
    SliderTrack.Size = UDim2.new(1, -32, 0, 6)
    SliderTrack.Position = UDim2.new(0, 16, 1, -28)
    SliderTrack.AnchorPoint = Vector2.new(0, 1)
    SliderTrack.BackgroundColor3 = self.Theme.InlineBg
    SliderTrack.ZIndex = 3

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 3)
    TrackCorner.Parent = SliderTrack

    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    local fillScale = 0
    if slider.Max - slider.Min ~= 0 then
        fillScale = (slider.Value - slider.Min) / (slider.Max - slider.Min)
    end
    SliderFill.Size = UDim2.new(fillScale, 0, 1, 0)
    SliderFill.BackgroundColor3 = self.Theme.Text
    SliderFill.ZIndex = 4

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = SliderFill

    SliderFill.Parent = SliderTrack

    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.Position = UDim2.new(fillScale, 0, 0.5, -9)
    SliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderButton.BackgroundColor3 = self.Theme.Circle
    SliderButton.Text = ""
    SliderButton.ZIndex = 5

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 9)
    ButtonCorner.Parent = SliderButton

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = self.Theme.Border
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = SliderButton

    SliderButton.Parent = SliderTrack
    SliderTrack.Parent = SliderFrame

    -- Slider functionality
    local function UpdateSlider(value)
        value = math.clamp(value, slider.Min, slider.Max)
        slider.Value = value

        local fillWidth = 0
        if slider.Max - slider.Min ~= 0 then
            fillWidth = (value - slider.Min) / (slider.Max - slider.Min)
        end
        SliderFill.Size = UDim2.new(fillWidth, 0, 1, 0)
        SliderButton.Position = UDim2.new(fillWidth, 0, 0.5, -9)
        SliderValue.Text = tostring(math.floor(value))

        if callback then
            callback(value)
        end
    end

    local dragging = false

    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local trackPos = SliderTrack.AbsolutePosition.X
            local trackSize = SliderTrack.AbsoluteSize.X
            local relativeX = (mouse.X - trackPos) / trackSize
            relativeX = math.clamp(relativeX, 0, 1)
            local value = slider.Min + (relativeX * (slider.Max - slider.Min))
            UpdateSlider(value)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local trackPos = SliderTrack.AbsolutePosition.X
            local trackSize = SliderTrack.AbsoluteSize.X
            local relativeX = (mouse.X - trackPos) / trackSize
            relativeX = math.clamp(relativeX, 0, 1)
            local value = slider.Min + (relativeX * (slider.Max - slider.Min))
            UpdateSlider(value)
        end
    end)

    SliderFrame.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(SliderFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.InlineBg}):Play()
    end)

    SliderFrame.MouseLeave:Connect(function()
        if not dragging then
            game:GetService("TweenService"):Create(SliderFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.ElementBg}):Play()
        end
    end)

    SliderFrame.Parent = tab.Content

    function slider:SetValue(value)
        UpdateSlider(value)
    end

    function slider:GetValue()
        return slider.Value
    end

    return slider
end

function ModernUILibrary:CreateKeybind(tab, text, defaultKey, callback)
    local keybind = {}
    keybind.Key = defaultKey or "F4"
    keybind.Listening = false

    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Name = "Keybind"
    KeybindFrame.Size = UDim2.new(1, 0, 0, 48)
    KeybindFrame.BackgroundColor3 = self.Theme.ElementBg
    KeybindFrame.LayoutOrder = #tab.Content:GetChildren()
    KeybindFrame.ZIndex = 2

    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 10)
    KeybindCorner.Parent = KeybindFrame

    local KeybindStroke = Instance.new("UIStroke")
    KeybindStroke.Color = self.Theme.Border
    KeybindStroke.Thickness = 1
    KeybindStroke.Parent = KeybindFrame

    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "KeybindLabel"
    KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    KeybindLabel.Position = UDim2.new(0, 16, 0, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = text
    KeybindLabel.TextColor3 = self.Theme.Text
    KeybindLabel.TextSize = 15
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindFrame

    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Size = UDim2.new(0, 90, 0, 32)
    KeybindButton.Position = UDim2.new(1, -16, 0.5, 0)
    KeybindButton.AnchorPoint = Vector2.new(1, 0.5)
    KeybindButton.BackgroundColor3 = self.Theme.InlineBg
    KeybindButton.Text = keybind.Key
    KeybindButton.TextColor3 = self.Theme.Text
    KeybindButton.TextSize = 14
    KeybindButton.Font = Enum.Font.GothamMedium
    KeybindButton.ZIndex = 3

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = KeybindButton

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = self.Theme.Border
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = KeybindButton

    KeybindButton.Parent = KeybindFrame

    KeybindButton.MouseButton1Click:Connect(function()
        keybind.Listening = true
        KeybindButton.Text = "..."
        KeybindButton.BackgroundColor3 = self.Theme.Accent
        KeybindButton.TextColor3 = self.Theme.Background

        local connection
        connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keybind.Key = input.KeyCode.Name
                KeybindButton.Text = keybind.Key
                KeybindButton.BackgroundColor3 = self.Theme.InlineBg
                KeybindButton.TextColor3 = self.Theme.Text
                keybind.Listening = false
                connection:Disconnect()
                if callback then
                    callback(keybind.Key)
                end
            end
        end)
    end)

    KeybindFrame.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(KeybindFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.InlineBg}):Play()
    end)

    KeybindFrame.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(KeybindFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.ElementBg}):Play()
    end)

    KeybindFrame.Parent = tab.Content

    function keybind:SetKey(key)
        keybind.Key = key
        KeybindButton.Text = key
    end

    function keybind:GetKey()
        return keybind.Key
    end

    return keybind
end

function ModernUILibrary:Toggle()
    self.Window.Visible = not self.Window.Visible
end

function ModernUILibrary:Show()
    self.Window.Visible = true
end

function ModernUILibrary:Hide()
    self.Window.Visible = false
end

function ModernUILibrary:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function ModernUILibrary:Init(parent)
    if not parent then
        local player = game:GetService("Players").LocalPlayer
        if player then
            parent = player:WaitForChild("PlayerGui")
        else
            parent = game:GetService("StarterGui")
        end
    end

    self.ScreenGui.Parent = parent
    return self
end

return ModernUILibrary

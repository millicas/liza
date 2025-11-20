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
  Accent = rgb(40, 116, 240),
  AccentMuted = rgb(84, 135, 255),
  Bg = rgb(246, 247, 249),
  Panel = rgb(255, 255, 255),
  Subtle = rgb(229, 231, 235),
  Text = rgb(26, 32, 44),
  TextMuted = rgb(99, 110, 121),
  Ghost = rgb(250, 251, 252),
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
  local t = TweenService:Create(obj, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
  t:Play()
  return t
end

local function roundCorners(parent, radius)
  local uc = create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 12)})
  return uc
end

local function subtleStroke(parent, thickness)
  local s = create("UIStroke", {Parent = parent, Color = Colors.Subtle, Thickness = thickness or 1, Transparency = 0.75})
  return s
end

local Library = {
  Flags = {},
  Conns = {},
  ScreenGui = nil,
  TweenSpeed = 0.18
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
  win.Name = opts.Name or "Modern"
  win.Size = opts.Size or udim2(0, 760, 0, 520)
  win.Tabs = {}
  win.CurrentTab = nil

  if self.ScreenGui then self.ScreenGui:Destroy() end
  self.ScreenGui = create("ScreenGui", {
    Parent = Core,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true
  })

  local root = create("Frame", {
    Parent = self.ScreenGui,
    Size = win.Size,
    Position = udim2(0.5, -win.Size.X.Offset/2, 0.5, -win.Size.Y.Offset/2),
    BackgroundColor3 = Colors.Bg,
    BorderSizePixel = 0
  })
  roundCorners(root, 16)

  local panel = create("Frame", {
    Parent = root,
    Size = udim2(1, -28, 1, -28),
    Position = udim2(0, 14, 0, 14),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0
  })
  roundCorners(panel, 14)

  local shadow = create("Frame", {
    Parent = root,
    Size = UDim2.new(1, 28, 1, 28),
    Position = UDim2.new(0, -14, 0, -14),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 0
  })
  create("UIGradient", {Parent = shadow, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Colors.Ghost), ColorSequenceKeypoint.new(1, Colors.Panel)})})

  local top = create("Frame", {
    Parent = panel,
    Size = udim2(1, 0, 0, 70),
    Position = udim2(0, 0, 0, 0),
    BackgroundTransparency = 1
  })

  local title = create("TextLabel", {
    Parent = top,
    Position = udim2(0, 24, 0.5, 0),
    AnchorPoint = v2(0,0.5),
    BackgroundTransparency = 1,
    Text = win.Name,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Colors.Text
  })

  local rightControls = create("Frame", {
    Parent = top,
    Size = udim2(0, 200, 1, 0),
    Position = udim2(1, -12, 0, 0),
    AnchorPoint = v2(1,0),
    BackgroundTransparency = 1
  })

  local ver = create("TextLabel", {
    Parent = rightControls,
    Size = udim2(1, -12, 1, 0),
    Position = udim2(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "v2",
    TextColor3 = Colors.TextMuted,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right
  })

  local sidebar = create("Frame", {
    Parent = panel,
    Size = udim2(0, 84, 1, -70),
    Position = udim2(0, 0, 0, 70),
    BackgroundTransparency = 1
  })

  local sidebarCard = create("Frame", {
    Parent = sidebar,
    Size = udim2(1, -16, 1, -24),
    Position = udim2(0, 8, 0, 12),
    BackgroundColor3 = Colors.Bg,
    BorderSizePixel = 0
  })
  roundCorners(sidebarCard, 12)
  subtleStroke(sidebarCard, 1)

  local tabHolder = create("Frame", {
    Parent = sidebarCard,
    Size = udim2(1, 0, 1, 0),
    BackgroundTransparency = 1,
  })

  local list = create("UIListLayout", {Parent = tabHolder, Padding = UDim.new(0, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center})
  list.SortOrder = Enum.SortOrder.LayoutOrder

  local contentArea = create("Frame", {
    Parent = panel,
    Size = udim2(1, -104, 1, -94),
    Position = udim2(0, 104, 0, 84),
    BackgroundTransparency = 1
  })

  win.Root = root
  win.Panel = panel
  win.Top = top
  win.Title = title
  win.Sidebar = sidebarCard
  win.TabHolder = tabHolder
  win.Content = contentArea

  do
    local dragging, start, startPos
    top.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        start = input.Position
        startPos = root.Position
      end
    end)
    top.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    self:Connect(UserInputService.InputChanged, function(input)
      if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - start
        root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
      end
    end)
  end

  return setmetatable(win, Library)
end

return setmetatable({
  New = function() return Library end,
}, {__call = function(_, ...) return Library end})

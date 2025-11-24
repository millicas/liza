-- Balright-Lite (Wave-safe) — Minimal UI library rewritten for Wave
-- No custom fonts, no getcustomasset, no file ops. Lightweight: Window / Page / Section / Button / Toggle / Slider / Keybind / Textbox / Dropdown
-- Made by WaveAI for Wave executor (SPDM Team)
local BalLite = {}
BalLite.__index = BalLite

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local function create(class, props)
	local obj = Instance.new(class)
	if props then
		for k,v in pairs(props) do
			pcall(function() obj[k] = v end)
		end
	end
	return obj
end

local function setFont(obj)
	if obj and (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
		obj.Font = Enum.Font.Gotham
		obj.TextSize = obj.TextSize or 14
	end
end

-- Basic theme
local Theme = {
	Background = Color3.fromRGB(21,24,24),
	Panel = Color3.fromRGB(30,33,33),
	Accent = Color3.fromRGB(98, 178, 255),
	Text = Color3.fromRGB(230,230,230),
	DimText = Color3.fromRGB(160,160,160)
}

-- Utilities
local Connections = {}
local function connect(event, fn)
	local c = event:Connect(fn)
	table.insert(Connections, c)
	return c
end

function BalLite:Unload()
	for _,c in ipairs(Connections) do
		if c and c.Disconnect then pcall(function() c:Disconnect() end) end
	end
end

-- Root: create ScreenGui
local function rootHolder(name)
	local sg = create("ScreenGui", {Name = name or "BalLite", ResetOnSpawn = false, DisplayOrder = 2})
	sg.Parent = (syn and syn.protect_gui) and gethui() or (gethui and gethui()) or game:GetService("CoreGui")
	return sg
end

-- Window constructor
function BalLite:Window(opts)
	opts = opts or {}
	local Win = {}
	Win.Pages = {}
	Win.Root = rootHolder(opts.Name or "BalLite")
	Win.Frame = create("Frame", {
		Parent = Win.Root,
		Size = UDim2.new(0, 700, 0, 420),
		Position = UDim2.new(0.5, -350, 0.5, -210),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
	})
	create("UICorner", {Parent = Win.Frame, CornerRadius = UDim.new(0,8)})
	
	-- Titlebar
	Win.Top = create("Frame", {Parent = Win.Frame, Size = UDim2.new(1,0,0,48), BackgroundTransparency = 1})
	Win.Title = create("TextLabel", {
		Parent = Win.Top, Position = UDim2.new(0,16,0,12),
		Text = opts.Name or "BalLite", TextColor3 = Theme.Text, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
	})
	setFont(Win.Title)
	Win.Sub = create("TextLabel", {
		Parent = Win.Top, Position = UDim2.new(0,16,0,28), Text = opts.SubTitle or "", TextColor3 = Theme.DimText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12
	})
	setFont(Win.Sub)
	
	-- Side pages list
	Win.Side = create("Frame", {Parent = Win.Frame, Position = UDim2.new(0,12,0,60), Size = UDim2.new(0,200,1,-72), BackgroundColor3 = Theme.Panel})
	create("UICorner", {Parent = Win.Side, CornerRadius = UDim.new(0,6)})
	create("UIListLayout", {Parent = Win.Side, Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder})
	
	-- Content area
	Win.Content = create("Frame", {Parent = Win.Frame, Position = UDim2.new(0,224,0,60), Size = UDim2.new(1,-236,1,-72), BackgroundColor3 = Theme.Background})
	create("UICorner", {Parent = Win.Content, CornerRadius = UDim.new(0,6)})
	
	-- Page management
	function Win:Page(data)
		data = data or {}
		local Page = {}
		Page.Name = data.Name or "Page"
		Page.Sections = {}
		
		-- Side button
		local btn = create("TextButton", {Parent = Win.Side, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1, AutoButtonColor = false, Text = Page.Name, TextColor3 = Theme.Text})
		setFont(btn)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.TextWrapped = false
		btn.ClipsDescendants = false
		
		-- Page frame
		Page.Frame = create("Frame", {Parent = Win.Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
		
		function Page:Section(opts)
			local Section = {}
			opts = opts or {}
			local secFrame = create("Frame", {Parent = Page.Frame, Size = UDim2.new(1,0,0,120), BackgroundTransparency = 1})
			create("UIListLayout", {Parent = secFrame, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
			local header = create("TextLabel", {Parent = secFrame, Text = opts.Name or "Section", BackgroundTransparency = 1, TextColor3 = Theme.DimText})
			setFont(header)
			
			Section.Container = secFrame
			Page.Sections[#Page.Sections+1] = Section
			return Section
		end
		
		-- toggle display on click
		connect(btn.MouseButton1Down, function()
			for _,p in pairs(Win.Pages) do p.Frame.Visible = false end
			Page.Frame.Visible = true
		end)
		
		Win.Pages[#Win.Pages+1] = Page
		-- auto select first page
		if #Win.Pages == 1 then
			Page.Frame.Visible = true
		end
		return Page
	end
	
	-- helper UI element creators inside Section
	local function addButton(section, name, cb)
		local b = create("TextButton", {Parent = section.Container, Size = UDim2.new(1, -12, 0, 28), Text = name, BackgroundColor3 = Theme.Panel, BorderSizePixel = 0})
		create("UICorner", {Parent = b, CornerRadius = UDim.new(0,6)})
		setFont(b)
		connect(b.MouseButton1Down, function()
			pcall(cb)
		end)
		return b
	end
	
	local function addToggle(section, name, default, cb)
		local row = create("Frame", {Parent = section.Container, Size = UDim2.new(1,-12,0,28), BackgroundTransparency = 1})
		local lbl = create("TextLabel", {Parent = row, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.7,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.Text})
		setFont(lbl)
		local btn = create("TextButton", {Parent = row, Position = UDim2.new(0.72,0,0.12,0), Size = UDim2.new(0.28, -0, 0.76, 0), BackgroundColor3 = default and Theme.Accent or Theme.Panel, Text = ""})
		create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
		local state = default and true or false
		connect(btn.MouseButton1Down, function()
			state = not state
			btn.BackgroundColor3 = state and Theme.Accent or Theme.Panel
			pcall(cb, state)
		end)
		return {
			Set = function(v) state = v; btn.BackgroundColor3 = (v and Theme.Accent or Theme.Panel) end,
			Get = function() return state end
		}
	end
	
	local function addSlider(section, name, min, max, default, cb)
		local frame = create("Frame", {Parent = section.Container, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1})
		local lbl = create("TextLabel", {Parent = frame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,12), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.Text})
		setFont(lbl)
		local barBack = create("Frame", {Parent = frame, Position = UDim2.new(0,0,0,16), Size = UDim2.new(1,0,0,12), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0})
		create("UICorner", {Parent = barBack, CornerRadius = UDim.new(0,6)})
		local barFill = create("Frame", {Parent = barBack, Size = UDim2.new(((default - min)/(max - min)),0,1,0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0})
		create("UICorner", {Parent = barFill, CornerRadius = UDim.new(0,6)})
		local dragging = false
		connect(barBack.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local absPos = barBack.AbsolutePosition
				local absSize = barBack.AbsoluteSize
				local mx = UserInputService:GetMouseLocation().X
				local rel = math.clamp((mx - absPos.X) / absSize.X, 0, 1)
				barFill.Size = UDim2.new(rel,0,1,0)
				local val = min + (rel * (max - min))
				pcall(cb, val)
			end
		end)
		return {
			Set = function(v) local rel = math.clamp((v - min)/(max-min), 0, 1); barFill.Size = UDim2.new(rel,0,1,0) end
		}
	end
	
	local function addTextbox(section, name, placeholder, cb)
		local frame = create("Frame", {Parent = section.Container, Size = UDim2.new(1,-12,0,28), BackgroundTransparency = 1})
		local lbl = create("TextLabel", {Parent = frame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.Text})
		setFont(lbl)
		local box = create("TextBox", {Parent = frame, Position = UDim2.new(0.42,0,0.12,0), Size = UDim2.new(0.58,0,0.76,0), Text = "", PlaceholderText = placeholder or "", BackgroundColor3 = Theme.Panel, ClearTextOnFocus = false})
		create("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
		setFont(box)
		connect(box.FocusLost, function(enter)
			if enter then pcall(cb, box.Text) end
		end)
		return box
	end
	
	local function addKeybind(section, name, default, cb)
		local frame = create("Frame", {Parent = section.Container, Size = UDim2.new(1,-12,0,28), BackgroundTransparency = 1})
		local lbl = create("TextLabel", {Parent = frame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.Text})
		setFont(lbl)
		local btn = create("TextButton", {Parent = frame, Position = UDim2.new(0.62,0,0.12,0), Size = UDim2.new(0.36,0,0.76,0), Text = tostring(default and default.Name or "NONE"), BackgroundColor3 = Theme.Panel})
		setFont(btn)
		create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
		local current = default
		connect(btn.MouseButton1Down, function()
			btn.Text = "Press Key..."
			local conn
			conn = connect(UserInputService.InputBegan, function(input,gameProcessed)
				if input.KeyCode then
					current = input.KeyCode
					btn.Text = input.KeyCode.Name
					pcall(cb, current)
					if conn then conn:Disconnect() end
				end
			end)
		end)
		return {
			Get = function() return current end,
			Set = function(k) current = k; btn.Text = tostring(k and k.Name or "NONE") end
		}
	end
	
	local function addDropdown(section, name, items, cb)
		local frame = create("Frame", {Parent = section.Container, Size = UDim2.new(1,-12,0,28), BackgroundTransparency = 1})
		local lbl = create("TextLabel", {Parent = frame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.Text})
		setFont(lbl)
		local btn = create("TextButton", {Parent = frame, Position = UDim2.new(0.42,0,0.12,0), Size = UDim2.new(0.58,0,0.76,0), Text = items[1] or "Select", BackgroundColor3 = Theme.Panel, AutoButtonColor = false})
		create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
		setFont(btn)
		local menu
		connect(btn.MouseButton1Down, function()
			if menu and menu.Parent then menu:Destroy(); menu = nil; return end
			menu = create("Frame", {Parent = Win.Root, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0,200,0,#items*28)})
			create("UICorner", {Parent = menu, CornerRadius = UDim.new(0,6)})
			for i,v in ipairs(items) do
				local it = create("TextButton", {Parent = menu, Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,0,(i-1)*28), Text = v, BackgroundTransparency = 1})
				setFont(it)
				connect(it.MouseButton1Down, function()
					btn.Text = v
					pcall(cb, v)
					if menu then menu:Destroy(); menu = nil end
				end)
			end
			-- position under btn
			local pos = btn.AbsolutePosition
			menu.Position = UDim2.new(0, pos.X, 0, pos.Y + btn.AbsoluteSize.Y)
		end)
		return {
			Set = function(v) btn.Text = v end,
			Get = function() return btn.Text end
		}
	end
	
	-- expose API on Win
	function Win:CreateSection(name)
		local p = self:Page({Name = "HiddenTemp"}) -- dummy page to reuse section builder? not needed externally
		-- create a section-like object in main content (quick helper)
		local sec = {}
		local secFrame = create("Frame", {Parent = self.Content, Size = UDim2.new(1,0,0,120), BackgroundTransparency = 1})
		create("UIListLayout", {Parent = secFrame, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
		local header = create("TextLabel", {Parent = secFrame, Text = name, BackgroundTransparency = 1, TextColor3 = Theme.DimText})
		setFont(header)
		sec.Container = secFrame
		sec.Button = function(name, cb) return addButton(sec, name, cb) end
		sec.Toggle = function(name, default, cb) return addToggle(sec, name, default, cb) end
		sec.Slider = function(name, min, max, default, cb) return addSlider(sec, name, min, max, default, cb) end
		sec.Textbox = function(name, ph, cb) return addTextbox(sec, name, ph, cb) end
		sec.Keybind = function(name, def, cb) return addKeybind(sec, name, def, cb) end
		sec.Dropdown = function(name, items, cb) return addDropdown(sec, name, items, cb) end
		return sec
	end
	
	-- Convenience: create pages/sections rapidly (used by scripts)
	Win.Page = Win.Page -- already defined
	return Win
end

-- Module return
return setmetatable(BalLite, {__call = function(_,...) return BalLite:Window(...) end})

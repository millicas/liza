-- Balright (Wave-safe) — Rewritten for Wave executor
-- No getcustomasset, no downloads. Uses Roblox fonts and Wave-safe API.
-- Provides: Library:Window -> Window:Category / Window:Page -> Page:SubPage -> SubPage:Section -> Section elements (Button, Toggle, Slider, Keybind, Textbox, Dropdown, Label)
-- Designed to visually match Balright: dark panels, rounded cards, side nav + top title + content cards.

local Library = {}
Library.__index = Library

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Helpers
local function new(class, props)
	local obj = Instance.new(class)
	if props then
		for k,v in pairs(props) do
			pcall(function() obj[k] = v end)
		end
	end
	return obj
end

local function applyTextStyle(obj, size)
	if not obj then return end
	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		obj.Font = Enum.Font.Gotham
		obj.TextSize = size or 14
		obj.TextColor3 = Color3.fromRGB(235,235,235)
		obj.TextXAlignment = Enum.TextXAlignment.Left
	end
end

local Theme = {
	Window = Color3.fromRGB(21,24,24),
	Panel = Color3.fromRGB(28,31,31),
	Card = Color3.fromRGB(30,33,33),
	Accent = Color3.fromRGB(98,178,255),
	Muted = Color3.fromRGB(130,130,130),
	Border = Color3.fromRGB(25,27,27),
	Text = Color3.fromRGB(235,235,235)
}

local Connections = {}
local function connect(event, fn)
	local ok, conn = pcall(function() return event:Connect(fn) end)
	if ok and conn then table.insert(Connections, conn); return conn end
end

-- Simple tween helper
local function tween(instance, props, time)
	local info = TweenInfo.new(time or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

-- Safe root holder
local function root(name)
	local sg = new("ScreenGui", {Name = name or "BalrightWave", ResetOnSpawn = false})
	local parent = (gethui and gethui()) or (syn and syn.protect_gui and gethui()) or game:GetService("CoreGui")
	sg.Parent = parent
	return sg
end

-- Window builder
function Library:Window(opts)
	opts = opts or {}
	local Win = {}
	Win.Pages = {}
	Win.Categories = {}
	Win.Root = root(opts.Name or "Balright")
	
	-- Main frame
	Win.Frame = new("Frame", {
		Parent = Win.Root,
		Size = UDim2.new(0, 920, 0, 520),
		Position = UDim2.new(0.5, -460, 0.5, -260),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
	})
	new("UICorner", {Parent = Win.Frame, CornerRadius = UDim.new(0,10)})
	
	-- Title / subtitle
	Win.Header = new("Frame", {Parent = Win.Frame, Size = UDim2.new(1, -24, 0, 56), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1})
	Win.Title = new("TextLabel", {Parent = Win.Header, Position = UDim2.new(0,4,0,6), Size = UDim2.new(1,-8,0,20), BackgroundTransparency = 1, Text = opts.Name or "Balright", TextColor3 = Theme.Text})
	applyTextStyle(Win.Title, 16)
	Win.Sub = new("TextLabel", {Parent = Win.Header, Position = UDim2.new(0,4,0,28), Size = UDim2.new(1,-8,0,18), BackgroundTransparency = 1, Text = opts.SubTitle or "", TextColor3 = Theme.Muted})
	applyTextStyle(Win.Sub, 12)
	
	-- Left side nav
	Win.Side = new("Frame", {Parent = Win.Frame, Position = UDim2.new(0,12,0,80), Size = UDim2.new(0,220,1,-92), BackgroundColor3 = Theme.Panel})
	new("UICorner", {Parent = Win.Side, CornerRadius = UDim.new(0,8)})
	new("UIListLayout", {Parent = Win.Side, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
	new("UIPadding", {Parent = Win.Side, PaddingLeft = UDim.new(0,10), PaddingTop = UDim.new(0,10)})
	
	-- Content area
	Win.Content = new("Frame", {Parent = Win.Frame, Position = UDim2.new(0,244,0,80), Size = UDim2.new(1,-256,1,-92), BackgroundColor3 = Theme.Window})
	new("UICorner", {Parent = Win.Content, CornerRadius = UDim.new(0,8)})
	
	-- Internal helpers for pages & categories
	function Win:Category(name)
		local cat = {}
		cat.Name = name or "Category"
		cat.Pane = new("TextButton", {Parent = self.Side, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1, Text = cat.Name, AutoButtonColor = false})
		applyTextStyle(cat.Pane, 14)
		cat.Pane.TextColor3 = Theme.Text
		cat.Pane.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(self.Categories, cat)
		return cat
	end
	
	function Win:Page(data)
		data = data or {}
		local Page = {}
		Page.Name = data.Name or "Page"
		Page.Icon = data.Icon or ""
		Page.Frame = new("Frame", {Parent = self.Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
		Page.Sections = {}
		new("UIListLayout", {Parent = Page.Frame, Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder})
		new("UIPadding", {Parent = Page.Frame, PaddingLeft = UDim.new(0,12), PaddingTop = UDim.new(0,12)})
		
		-- SubPage factory (for multi-tab pages)
		function Page:SubPage(opts)
			opts = opts or {}
			local Sub = {}
			Sub.Name = opts.Name or "Sub"
			Sub.Frame = new("Frame", {Parent = Page.Frame, Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1}) -- sections added inside will expand
			new("UIListLayout", {Parent = Sub.Frame, Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder})
			new("UIPadding", {Parent = Sub.Frame, PaddingLeft = UDim.new(0,8), PaddingTop = UDim.new(0,6)})
			
			function Sub:Section(opts)
				opts = opts or {}
				local Section = {}
				Section.Name = opts.Name or "Section"
				Section.Side = opts.Side or 1
				
				-- Card container
				local card = new("Frame", {Parent = Sub.Frame, Size = UDim2.new(1,0,0,160), BackgroundColor3 = Theme.Card})
				new("UICorner", {Parent = card, CornerRadius = UDim.new(0,6)})
				new("UIStroke", {Parent = card, Color = Theme.Border, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
				
				-- header
				local header = new("TextLabel", {Parent = card, Position = UDim2.new(0,12,0,8), Size = UDim2.new(1,-24,0,18), BackgroundTransparency = 1, Text = Section.Name, TextColor3 = Theme.Text})
				applyTextStyle(header, 14)
				
				local container = new("Frame", {Parent = card, Position = UDim2.new(0,12,0,34), Size = UDim2.new(1,-24,1,-42), BackgroundTransparency = 1})
				new("UIListLayout", {Parent = container, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
				
				-- element creators
				function Section:Button(name, cb)
					local b = new("TextButton", {Parent = container, Size = UDim2.new(1,0,0,32), BackgroundColor3 = Theme.Panel, Text = name or "Button", AutoButtonColor = false})
					new("UICorner", {Parent = b, CornerRadius = UDim.new(0,6)})
					applyTextStyle(b, 14)
					connect(b.MouseButton1Down, function() pcall(cb) end)
					return b
				end
				
				function Section:Toggle(name, default, cb)
					local row = new("Frame", {Parent = container, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
					local lbl = new("TextLabel", {Parent = row, Size = UDim2.new(0.7,0,1,0), BackgroundTransparency = 1, Text = name or "Toggle"})
					applyTextStyle(lbl, 14)
					local indicator = new("TextButton", {Parent = row, Size = UDim2.new(0.22,0,0.7,0), Position = UDim2.new(0.76,0,0.15,0), BackgroundColor3 = default and Theme.Accent or Theme.Panel, Text = ""})
					new("UICorner", {Parent = indicator, CornerRadius = UDim.new(0,6)})
					local state = default and true or false
					connect(indicator.MouseButton1Down, function()
						state = not state
						indicator.BackgroundColor3 = state and Theme.Accent or Theme.Panel
						pcall(cb, state)
					end)
					return {
						Set = function(v) state = v; indicator.BackgroundColor3 = v and Theme.Accent or Theme.Panel end,
						Get = function() return state end
					}
				end
				
				function Section:Slider(name, min, max, default, cb)
					min = min or 0; max = max or 100; default = default or min
					local frame = new("Frame", {Parent = container, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
					local lbl = new("TextLabel", {Parent = frame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,14), BackgroundTransparency = 1, Text = name or "Slider"})
					applyTextStyle(lbl, 13)
					local barBack = new("Frame", {Parent = frame, Position = UDim2.new(0,0,0,18), Size = UDim2.new(1,0,0,12), BackgroundColor3 = Theme.Panel})
					new("UICorner", {Parent = barBack, CornerRadius = UDim.new(0,6)})
					local rel = math.clamp((default - min)/(max - min), 0, 1)
					local barFill = new("Frame", {Parent = barBack, Size = UDim2.new(rel,0,1,0), BackgroundColor3 = Theme.Accent})
					new("UICorner", {Parent = barFill, CornerRadius = UDim.new(0,6)})
					
					local dragging = false
					connect(barBack.InputBegan, function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
					end)
					connect(UserInputService.InputEnded, function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
					end)
					connect(UserInputService.InputChanged, function(inp)
						if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
							local pos = barBack.AbsolutePosition
							local size = barBack.AbsoluteSize
							local mx = UserInputService:GetMouseLocation().X
							local r = math.clamp((mx - pos.X)/size.X, 0, 1)
							barFill.Size = UDim2.new(r,0,1,0)
							local val = min + r*(max-min)
							pcall(cb, val)
						end
					end)
					return {
						Set = function(v) local r = math.clamp((v-min)/(max-min),0,1); barFill.Size = UDim2.new(r,0,1,0) end
					}
				end
				
				function Section:Textbox(name, placeholder, cb)
					local row = new("Frame", {Parent = container, Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1})
					local lbl = new("TextLabel", {Parent = row, Size = UDim2.new(0.34,0,1,0), BackgroundTransparency = 1, Text = name or "Text"})
					applyTextStyle(lbl, 14)
					local box = new("TextBox", {Parent = row, Position = UDim2.new(0.36,0,0.12,0), Size = UDim2.new(0.62,0,0.76,0), BackgroundColor3 = Theme.Panel, Text = "", PlaceholderText = placeholder or ""})
					new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
					applyTextStyle(box, 14)
					connect(box.FocusLost, function(enter)
						if enter then pcall(cb, box.Text) end
					end)
					return box
				end
				
				function Section:Keybind(name, default, cb)
					local row = new("Frame", {Parent = container, Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1})
					local lbl = new("TextLabel", {Parent = row, Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, Text = name or "Keybind"})
					applyTextStyle(lbl, 14)
					local btn = new("TextButton", {Parent = row, Position = UDim2.new(0.52,0,0.12,0), Size = UDim2.new(0.46,0,0.76,0), BackgroundColor3 = Theme.Panel, Text = default and default.Name or "NONE"})
					new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
					applyTextStyle(btn, 14)
					local current = default
					connect(btn.MouseButton1Down, function()
						btn.Text = "Press Key..."
						local conn
						conn = connect(UserInputService.InputBegan, function(inp, processed)
							if inp.KeyCode and inp.KeyCode.Name ~= "Unknown" then
								current = inp.KeyCode
								btn.Text = current.Name
								pcall(cb, current)
								if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
							end
						end)
					end)
					return {
						Get = function() return current end,
						Set = function(k) current = k; btn.Text = k and k.Name or "NONE" end
					}
				end
				
				function Section:Dropdown(name, items, cb)
					local row = new("Frame", {Parent = container, Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1})
					local lbl = new("TextLabel", {Parent = row, Size = UDim2.new(0.34,0,1,0), BackgroundTransparency = 1, Text = name or "Dropdown"})
					applyTextStyle(lbl, 14)
					local btn = new("TextButton", {Parent = row, Position = UDim2.new(0.36,0,0.12,0), Size = UDim2.new(0.62,0,0.76,0), BackgroundColor3 = Theme.Panel, Text = items[1] or "Select"})
					new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
					applyTextStyle(btn, 14)
					local menu
					connect(btn.MouseButton1Down, function()
						if menu and menu.Parent then menu:Destroy(); menu = nil; return end
						menu = new("Frame", {Parent = Win.Root, Size = UDim2.new(0, 220, 0, #items*28), BackgroundColor3 = Theme.Panel})
						new("UICorner", {Parent = menu, CornerRadius = UDim.new(0,6)})
						for i,v in ipairs(items) do
							local it = new("TextButton", {Parent = menu, Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,0,(i-1)*28), Text = v, BackgroundTransparency = 1})
							applyTextStyle(it, 14)
							connect(it.MouseButton1Down, function()
								btn.Text = v
								pcall(cb, v)
								if menu then menu:Destroy(); menu = nil end
							end)
						end
						local pos = btn.AbsolutePosition
						menu.Position = UDim2.new(0, pos.X, 0, pos.Y + btn.AbsoluteSize.Y)
					end)
					return {
						Set = function(v) btn.Text = v end,
						Get = function() return btn.Text end
					}
				end
				
				Section.Container = container
				table.insert(Sub.Frame:GetChildren(), card) -- keep reference (harmless)
				Section.Card = card
				return Section
			end
			
			table.insert(Page.Sections, Sub)
			return Sub
		end
		
		table.insert(self.Pages, Page)
		return Page
	end

	-- Minimal settings to create classic side nav -> page mapping
	function Win:Init()
		-- select first page visible
		if #self.Pages > 0 then
			self.Pages[1].Frame.Visible = true
		end
		-- attach category buttons if present (map first n categories to pages)
		for i,cat in ipairs(self.Categories) do
			local page = self.Pages[i]
			if page then
				cat.Pane.MouseButton1Down:Connect(function()
					for _,p in ipairs(self.Pages) do p.Frame.Visible = false end
					page.Frame.Visible = true
				end)
			end
		end
		return self
	end

	-- small API helpers used by many scripts expecting older balright method names
	function Win:CreateCategory(name) return self:Category(name) end
	function Win:CreateSection(cat, name) -- cat is category object or page name
		-- create a simple section in the content area
		local secFrame = new("Frame", {Parent = self.Content, Size = UDim2.new(1,0,0,120), BackgroundTransparency = 1})
		new("UIListLayout", {Parent = secFrame, Padding = UDim.new(0,8)})
		local header = new("TextLabel", {Parent = secFrame, Text = name or "Section", BackgroundTransparency = 1, TextColor3 = Theme.Text})
		applyTextStyle(header, 14)
		local section = {}
		section.Container = secFrame
		function section:Button(name, cb) return (function() local b = new("TextButton", {Parent = section.Container, Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0,10,0,0), BackgroundColor3 = Theme.Panel, Text = name}); new("UICorner", {Parent = b, CornerRadius = UDim.new(0,6)}); applyTextStyle(b); connect(b.MouseButton1Down, function() pcall(cb) end); return b end)() end
		function section:Toggle(name, default, cb) return (function() local f = new("Frame", {Parent = section.Container, Size = UDim2.new(1,-20,0,28)}); local l = new("TextLabel", {Parent = f, Text = name, BackgroundTransparency = 1}); applyTextStyle(l); local t = new("TextButton", {Parent = f, Size = UDim2.new(0.28,0,0.75,0), Position = UDim2.new(0.7,0,0.12,0), BackgroundColor3 = default and Theme.Accent or Theme.Panel}); new("UICorner", {Parent = t, CornerRadius = UDim.new(0,6)}); local state = default; connect(t.MouseButton1Down, function() state = not state; t.BackgroundColor3 = state and Theme.Accent or Theme.Panel; pcall(cb, state) end); return {Set=function(v) state=v; t.BackgroundColor3 = v and Theme.Accent or Theme.Panel end, Get=function() return state end} end)() end
		return section
	end

	-- return window
	return Win
end

-- small cleanup function
function Library:UnloadAll()
	for _,c in ipairs(Connections) do
		pcall(function() c:Disconnect() end)
	end
	Connections = {}
end

return setmetatable(Library, {__call = function(_,...) return Library:Window(...) end})

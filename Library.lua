local Players = game:GetService("Players");
local TextService = game:GetService("TextService");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");

local Library = { };

local Theme = {
	Accent = Color3.fromRGB(217, 105, 132);
	AccentDim = Color3.fromRGB(165, 78, 99);
	Outer = Color3.fromRGB(27, 27, 34);
	OuterDark = Color3.fromRGB(5, 5, 8);
	OuterLight = Color3.fromRGB(74, 72, 82);
	Background = Color3.fromRGB(25, 24, 31);
	Body = Color3.fromRGB(26, 25, 33);
	Workspace = Color3.fromRGB(27, 27, 34);
	BodyDark = Color3.fromRGB(6, 6, 9);
	Tab = Color3.fromRGB(18, 17, 22);
	TabActive = Color3.fromRGB(43, 41, 52);
	TabHover = Color3.fromRGB(35, 33, 42);
	Border = Color3.fromRGB(61, 59, 70);
	BorderSoft = Color3.fromRGB(45, 43, 53);
	BorderDark = Color3.fromRGB(3, 3, 5);
	Text = Color3.fromRGB(238, 238, 238);
	TextDim = Color3.fromRGB(185, 183, 190);
	ControlTop = Color3.fromRGB(66, 65, 72);
	ControlBottom = Color3.fromRGB(45, 44, 52);
	ControlOpen = Color3.fromRGB(72, 70, 78);
	DropdownMenu = Color3.fromRGB(48, 47, 55);
	DropdownHover = Color3.fromRGB(64, 62, 70);
	Track = Color3.fromRGB(38, 38, 47);
	CheckboxOff = Color3.fromRGB(73, 73, 84);
	White = Color3.fromRGB(255, 255, 255);
};

Library.Theme = Theme;
Library.Windows = { };
Library.Options = { };
Library.Toggles = { };

local TEXT_SIZE = 11;
local SYMBOL_TEXT_SIZE = 12;
local TAB_HEIGHT = 26;
local TWEEN_TIME = 0.12;

local BaseFont = Enum.Font.SourceSansBold;
pcall(function()
	BaseFont = Enum.Font.ArialBold;
end);

local TahomaBold;
pcall(function()
	TahomaBold = Font.fromName("Tahoma", Enum.FontWeight.Bold);
end);

local Window = { };
Window.__index = Window;

local Tab = { };
Tab.__index = Tab;

local Groupbox = { };
Groupbox.__index = Groupbox;

local SubTabs = { };
SubTabs.__index = SubTabs;

local Checkbox = { };
Checkbox.__index = Checkbox;

local Dropdown = { };
Dropdown.__index = Dropdown;

local KeyPicker = { };
KeyPicker.__index = KeyPicker;

local Slider = { };
Slider.__index = Slider;

local Button = { };
Button.__index = Button;

local ColorPicker = { };
ColorPicker.__index = ColorPicker;

local function create(className, props)
	local instance = Instance.new(className);

	for key, value in pairs(props or { }) do
		instance[key] = value;
	end

	return instance;
end

local function cleanName(text)
	return tostring(text or "Object"):gsub("%W+", "_");
end

local function applyFont(instance, size)
	instance.Font = BaseFont;
	instance.TextSize = size or TEXT_SIZE;

	if (TahomaBold) then
		pcall(function()
			instance.FontFace = TahomaBold;
		end);
	end
end

local function frame(parent, name, position, size, color, zIndex)
	return create("Frame", {
		Name = name;
		Parent = parent;
		Position = position;
		Size = size;
		BackgroundColor3 = color;
		BorderSizePixel = 0;
		ZIndex = zIndex or 1;
	});
end

local function line(parent, name, position, size, color, zIndex)
	local instance = frame(parent, name, position, size, color, zIndex);
	instance.BorderSizePixel = 0;
	return instance;
end

local function label(parent, name, text, position, size, color, align, zIndex)
	local instance = create("TextLabel", {
		Name = name;
		Parent = parent;
		Position = position;
		Size = size;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Text = text or "";
		TextColor3 = color or Theme.Text;
		TextStrokeTransparency = 1;
		TextTruncate = Enum.TextTruncate.AtEnd;
		TextWrapped = false;
		TextXAlignment = align or Enum.TextXAlignment.Left;
		TextYAlignment = Enum.TextYAlignment.Center;
		ZIndex = zIndex or 10;
	});
	applyFont(instance);
	return instance;
end

local function button(parent, name, position, size, text, zIndex)
	local instance = create("TextButton", {
		Name = name;
		Parent = parent;
		Position = position;
		Size = size;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		AutoButtonColor = false;
		Text = text or "";
		TextColor3 = Theme.Text;
		TextStrokeTransparency = 1;
		TextWrapped = false;
		TextXAlignment = Enum.TextXAlignment.Center;
		TextYAlignment = Enum.TextYAlignment.Center;
		ZIndex = zIndex or 20;
	});
	applyFont(instance);
	return instance;
end

local function stroke(parent, color, thickness)
	local instance = Instance.new("UIStroke");
	instance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	instance.Color = color;
	instance.Thickness = thickness or 1;
	instance.Parent = parent;
	return instance;
end

local function gradient(parent, topColor, bottomColor, rotation)
	local instance = Instance.new("UIGradient");
	instance.Color = ColorSequence.new(topColor, bottomColor);
	instance.Rotation = rotation or 90;
	instance.Parent = parent;
	return instance;
end

local function tween(instance, props, duration)
	local info = TweenInfo.new(duration or TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local activeTween = TweenService:Create(instance, info, props);
	activeTween:Play();
	return activeTween;
end

local function measureText(text, size)
	local ok, result = pcall(function()
		return TextService:GetTextSize(tostring(text), size or TEXT_SIZE, BaseFont, Vector2.new(1000, 32)).X;
	end);

	if (ok) then
		return result;
	end

	return #tostring(text) * 6;
end

local function resolveParent(options)
	if (options and options.Parent) then
		return options.Parent;
	end

	local player = Players.LocalPlayer;
	if (not player) then
		return nil;
	end

	return player:WaitForChild("PlayerGui");
end

local function isDragInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch;
end

local function isMoveInput(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch;
end

local function pointInFrame(instance, point)
	if (not instance) or (not instance.Parent) or (not instance.Visible) then
		return false;
	end

	local position, size = instance.AbsolutePosition, instance.AbsoluteSize;
	return point.X >= position.X
		and point.X <= position.X + size.X
		and point.Y >= position.Y
		and point.Y <= position.Y + size.Y;
end

local function formatInput(input)
	if (input.UserInputType == Enum.UserInputType.Keyboard) then
		return input.KeyCode.Name;
	end

	if (input.UserInputType == Enum.UserInputType.MouseButton1) then
		return "Mouse 1";
	elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
		return "Mouse 2";
	elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
		return "Mouse 3";
	end

	return input.UserInputType.Name;
end

local function makeControl(parent, name, position, size, zIndex)
	local control = frame(parent, name, position, size, Theme.ControlTop, zIndex or 120);
	stroke(control, Color3.fromRGB(24, 23, 29), 1);
	gradient(control, Theme.ControlTop, Theme.ControlBottom);
	return control;
end

local function setCheckboxVisual(square, value)
	square.BackgroundColor3 = value and Theme.Accent or Theme.CheckboxOff;
end

local function safeCallback(callback, ...)
	if (not callback) then
		return;
	end

	local ok, err = pcall(callback, ...);
	if (not ok) then
		warn(err);
	end
end

local function hueSequence()
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00, 1, 1));
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1));
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1));
		ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1));
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1));
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1));
		ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1));
	});
end

function Window:_signal(signal, callback)
	local connection = signal:Connect(callback);
	table.insert(self._connections, connection);
	return connection;
end

function Window:_makeDraggable(handle)
	local dragging = false;
	local dragStart;
	local startPosition;

	self:_signal(handle.InputBegan, function(input)
		if (not isDragInput(input)) then
			return;
		end

		dragging = true;
		dragStart = input.Position;
		startPosition = self.Root.Position;
	end);

	self:_signal(UserInputService.InputEnded, function(input)
		if (isDragInput(input)) then
			dragging = false;
		end
	end);

	self:_signal(UserInputService.InputChanged, function(input)
		if (not dragging) or (not isMoveInput(input)) then
			return;
		end

		local delta = input.Position - dragStart;
		self.Root.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		);
	end);
end

function Window:_layoutTabs()
	local count = #self.TabOrder;
	if (count == 0) then
		return;
	end

	local totalWidth = self.TabBar.AbsoluteSize.X;
	if (totalWidth <= 0) then
		totalWidth = math.max(1, self.Root.Size.X.Offset - 38);
	end

	local baseWidth = math.floor(totalWidth / count);
	local x = 0;

	for index, name in ipairs(self.TabOrder) do
		local tab = self.Tabs[name];
		local width = index == count and totalWidth - x or baseWidth;

		tab.Frame.Position = UDim2.fromOffset(x, 0);
		tab.Frame.Size = UDim2.fromOffset(width, TAB_HEIGHT);
		x = x + width;
	end
end

function Window:_positionPopup(popup, anchor, yOffset)
	local anchorPosition = anchor.AbsolutePosition;
	local rootPosition = self.Root.AbsolutePosition;
	local popupSize = popup.AbsoluteSize;

	if (popupSize.X <= 0) or (popupSize.Y <= 0) then
		popupSize = Vector2.new(popup.Size.X.Offset, popup.Size.Y.Offset);
	end

	local maxX = math.max(4, self.Root.AbsoluteSize.X - popupSize.X - 4);
	local maxY = math.max(4, self.Root.AbsoluteSize.Y - popupSize.Y - 4);
	local x = math.clamp(anchorPosition.X - rootPosition.X, 4, maxX);
	local y = math.clamp(anchorPosition.Y - rootPosition.Y + anchor.AbsoluteSize.Y + (yOffset or 2), 4, maxY);

	popup.Position = UDim2.fromOffset(x, y);
end

function Window:_closeDropdown(except)
	if (self.OpenDropdown) and (self.OpenDropdown ~= except) then
		self.OpenDropdown:SetOpen(false);
	end
end

function Window:_closeColorPicker(except)
	if (self.OpenColorPicker) and (self.OpenColorPicker ~= except) then
		self.OpenColorPicker:SetOpen(false);
	end
end

function Window:_registerDropdown(dropdown)
	table.insert(self.Dropdowns, dropdown);
	return dropdown;
end

function Window:_registerColorPicker(colorPicker)
	table.insert(self.ColorPickers, colorPicker);
	return colorPicker;
end

function Window:_bindPopupCloser()
	self:_signal(UserInputService.InputBegan, function(input, gameProcessed)
		if (gameProcessed) or (input.UserInputType ~= Enum.UserInputType.MouseButton1) then
			return;
		end

		local point = input.Position;

		if (self.OpenDropdown) then
			local dropdown = self.OpenDropdown;
			if (not pointInFrame(dropdown.Frame, point)) and (not pointInFrame(dropdown.Menu, point)) then
				dropdown:SetOpen(false);
			end
		end

		if (self.OpenColorPicker) then
			local picker = self.OpenColorPicker;
			if (not pointInFrame(picker.Instance, point)) and (not pointInFrame(picker.Popup, point)) then
				picker:SetOpen(false);
			end
		end
	end);
end

function Library.new(options)
	options = options or { };

	local parent = resolveParent(options);
	if (not parent) then
		warn("PinkVisualsUILibrary requires a LocalScript/client context or an explicit Parent.");
		return nil;
	end

	local guiName = options.Name or "PinkVisualsUILibrary";
	if (options.RemoveExisting ~= false) then
		local oldGui = parent:FindFirstChild(guiName);
		if (oldGui) then
			oldGui:Destroy();
		end
	end

	local screenGui = create("ScreenGui", {
		Name = guiName;
		ResetOnSpawn = false;
		IgnoreGuiInset = true;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		Parent = parent;
	});

	local root = frame(screenGui, "Window", options.Position or UDim2.new(0.5, -306, 0.5, -207), options.Size or UDim2.fromOffset(612, 414), Theme.Outer, 100);
	stroke(root, Theme.OuterLight, 1);

	local outerBlack = frame(root, "OuterBlack", UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.OuterDark, 101);
	local outerMiddle = frame(outerBlack, "OuterMiddle", UDim2.fromOffset(2, 2), UDim2.new(1, -4, 1, -4), Theme.Outer, 102);
	stroke(outerMiddle, Theme.BorderSoft, 1);

	local body = frame(outerMiddle, "Body", UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8), Theme.Body, 103);
	stroke(body, Color3.fromRGB(15, 14, 19), 1);

	line(body, "TopAccent", UDim2.fromOffset(0, 3), UDim2.new(1, 0, 0, 1), Theme.Accent, 104);

	local tabBar = frame(body, "TabBar", UDim2.fromOffset(18, 17), UDim2.new(1, -26, 0, TAB_HEIGHT), Theme.Tab, 105);
	stroke(tabBar, Color3.fromRGB(45, 43, 52), 1);

	local content = frame(body, "Content", UDim2.fromOffset(17, 49), UDim2.new(1, -24, 1, -55), Theme.Workspace, 105);
	stroke(content, Theme.BorderSoft, 1);

	local contentInner = frame(content, "InnerShade", UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.Workspace, 106);
	stroke(contentInner, Color3.fromRGB(18, 17, 23), 1);

	local popupLayer = frame(root, "PopupLayer", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Body, 500);
	popupLayer.BackgroundTransparency = 1;
	popupLayer.ClipsDescendants = false;
	popupLayer.Active = false;

	local self = setmetatable({
		Gui = screenGui;
		Root = root;
		Body = body;
		TabBar = tabBar;
		Content = contentInner;
		PopupLayer = popupLayer;
		Tabs = { };
		TabOrder = { };
		Dropdowns = { };
		ColorPickers = { };
		OpenDropdown = nil;
		OpenColorPicker = nil;
		ActiveTab = nil;
		_connections = { };
	}, Window);

	table.insert(Library.Windows, self);

	if (options.Draggable ~= false) then
		self:_makeDraggable(tabBar);
	end

	self:_bindPopupCloser();
	self:_signal(tabBar:GetPropertyChangedSignal("AbsoluteSize"), function()
		self:_layoutTabs();
	end);

	return self;
end

function Library:CreateWindow(options)
	if (self ~= Library) and (options == nil) then
		options = self;
	end

	return Library.new(options);
end

function Window:AddTab(name)
	local tabFrame = frame(self.TabBar, "Tab_" .. tostring(name), UDim2.fromOffset(0, 0), UDim2.fromOffset(1, TAB_HEIGHT), Theme.Tab, 107);
	local divider = line(tabFrame, "Divider", UDim2.fromOffset(0, 0), UDim2.fromOffset(1, TAB_HEIGHT), Color3.fromRGB(6, 6, 9), 109);
	divider.Visible = #self.TabOrder > 0;

	local tabText = label(tabFrame, "Text", name, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 110);
	local activeLine = line(tabFrame, "ActiveLine", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), Theme.Accent, 111);
	activeLine.BackgroundTransparency = 1;

	local page = frame(self.Content, "Page_" .. tostring(name), UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Body, 106);
	page.BackgroundTransparency = 1;
	page.Visible = false;

	local tab = setmetatable({
		Window = self;
		Name = name;
		Frame = tabFrame;
		Text = tabText;
		ActiveLine = activeLine;
		Page = page;
		Groupboxes = { };
	}, Tab);

	local hitbox = button(tabFrame, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 120);
	self:_signal(hitbox.MouseButton1Click, function()
		self:SetTab(name);
	end);
	self:_signal(hitbox.MouseEnter, function()
		if (self.ActiveTab ~= name) then
			tween(tabFrame, { BackgroundColor3 = Theme.TabHover }, 0.1);
		end
	end);
	self:_signal(hitbox.MouseLeave, function()
		if (self.ActiveTab ~= name) then
			tween(tabFrame, { BackgroundColor3 = Theme.Tab }, 0.1);
		end
	end);

	self.Tabs[name] = tab;
	table.insert(self.TabOrder, name);
	self:_layoutTabs();

	if (not self.ActiveTab) then
		self:SetTab(name, true);
	end

	return tab;
end

function Window:SetTab(name, instant)
	self.ActiveTab = name;
	self:_closeDropdown(nil);
	self:_closeColorPicker(nil);

	for tabName, tab in pairs(self.Tabs) do
		local active = tabName == name;
		tab.Page.Visible = active;

		if (instant) then
			tab.Frame.BackgroundColor3 = active and Theme.TabActive or Theme.Tab;
			tab.ActiveLine.BackgroundTransparency = active and 0 or 1;
		else
			tween(tab.Frame, { BackgroundColor3 = active and Theme.TabActive or Theme.Tab }, 0.14);
			tween(tab.ActiveLine, { BackgroundTransparency = active and 0 or 1 }, 0.14);
		end
	end
end

function Window:Destroy()
	for index = #self._connections, 1, -1 do
		local connection = table.remove(self._connections, index);
		connection:Disconnect();
	end

	if (self.Gui) then
		self.Gui:Destroy();
	end
end

function Tab:AutoHeight(width, topY, bottomY)
	bottomY = bottomY or topY;
	return UDim2.new(0, width, 1, -(topY + bottomY));
end

function Tab:AddFillGroupbox(title, x, topY, width, bottomY)
	bottomY = bottomY or topY;

	local groupbox = self:AddGroupbox(title, UDim2.fromOffset(x, topY), UDim2.fromOffset(width, 1));

	local function updateHeight()
		local parentHeight = self.Page.AbsoluteSize.Y;
		if (parentHeight <= 0) then
			return;
		end

		groupbox.Frame.Size = UDim2.fromOffset(width, math.max(1, math.floor(parentHeight - topY - bottomY)));
	end

	self.Window:_signal(self.Page:GetPropertyChangedSignal("AbsoluteSize"), updateHeight);
	task.defer(updateHeight);

	return groupbox;
end

function Tab:AddLeftGroupbox(title, height, y)
	return self:AddGroupbox(title, UDim2.fromOffset(10, y or 12), UDim2.new(0.5, -16, 0, height or 170));
end

function Tab:AddRightGroupbox(title, height, y)
	return self:AddGroupbox(title, UDim2.new(0.5, 6, 0, y or 12), UDim2.new(0.5, -16, 0, height or 170));
end

function Tab:AddGroupbox(title, position, size)
	local box = frame(self.Page, "Groupbox_" .. cleanName(title), position, size, Theme.Body, 108);

	local titleX = 12;
	local titlePadding = 1;
	local titleTextWidth = math.max(1, math.ceil(measureText(title, TEXT_SIZE)) - 4);
	local titleWidth = titleTextWidth + titlePadding * 2;
	local rightLineX = titleX + titleWidth + 1;

	local topLeft = line(box, "TopLeft", UDim2.fromOffset(0, 0), UDim2.fromOffset(titleX - 1, 1), Theme.Border, 111);
	local topRight = line(box, "TopRight", UDim2.fromOffset(rightLineX, 0), UDim2.new(1, -rightLineX, 0, 1), Theme.Border, 111);
	line(box, "Left", UDim2.fromOffset(0, 0), UDim2.new(0, 1, 1, 0), Theme.Border, 111);
	line(box, "Right", UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0), Theme.Border, 111);
	line(box, "Bottom", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), Theme.Border, 111);

	local titleBack = frame(box, "TitleBack", UDim2.fromOffset(titleX, -7), UDim2.fromOffset(titleWidth, 14), Theme.Body, 112);
	local titleLabel = label(titleBack, "Title", title, UDim2.fromOffset(titlePadding, 0), UDim2.fromOffset(titleTextWidth, 14), Theme.Text, Enum.TextXAlignment.Left, 113);

	local function updateTitleCutout()
		local measured = math.ceil(titleLabel.TextBounds.X);
		if (measured <= 0) then
			return;
		end

		local nextTitleWidth = measured + titlePadding * 2;
		local nextRightLineX = titleX + nextTitleWidth + 1;
		topLeft.Size = UDim2.fromOffset(titleX - 1, 1);
		topRight.Position = UDim2.fromOffset(nextRightLineX, 0);
		topRight.Size = UDim2.new(1, -nextRightLineX, 0, 1);
		titleBack.Size = UDim2.fromOffset(nextTitleWidth, 14);
		titleLabel.Size = UDim2.fromOffset(measured, 14);
	end

	self.Window:_signal(titleLabel:GetPropertyChangedSignal("TextBounds"), updateTitleCutout);
	task.defer(updateTitleCutout);

	local groupbox = setmetatable({
		Tab = self;
		Window = self.Window;
		Frame = box;
		Title = title;
	}, Groupbox);

	table.insert(self.Groupboxes, groupbox);
	return groupbox;
end

function Groupbox:AddSubTabs(names, activeIndex, position, size)
	activeIndex = activeIndex or 1;
	position = position or UDim2.fromOffset(10, 13);
	size = size or UDim2.fromOffset(240, 25);

	local holder = frame(self.Frame, "SubTabs", position, size, Theme.Tab, 116);
	stroke(holder, Color3.fromRGB(47, 45, 55), 1);

	local subTabs = setmetatable({
		Groupbox = self;
		Frame = holder;
		Items = { };
		ActiveIndex = nil;
	}, SubTabs);

	local count = #names;
	local baseWidth = math.floor(size.X.Offset / count);

	for index, name in ipairs(names) do
		local width = index == count and size.X.Offset - (index - 1) * baseWidth or baseWidth;
		local itemFrame = frame(holder, "SubTab_" .. tostring(name), UDim2.fromOffset((index - 1) * baseWidth, 0), UDim2.fromOffset(width, size.Y.Offset), Theme.Tab, 117);

		if (index > 1) then
			line(itemFrame, "Divider", UDim2.fromOffset(0, 0), UDim2.fromOffset(1, size.Y.Offset), Color3.fromRGB(11, 10, 15), 119);
		end

		local activeLine = line(itemFrame, "ActiveLine", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), Theme.Accent, 120);
		activeLine.BackgroundTransparency = 1;

		label(itemFrame, "Text", name, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 121);

		local hitbox = button(itemFrame, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
		self.Window:_signal(hitbox.MouseButton1Click, function()
			subTabs:Set(index);
		end);

		table.insert(subTabs.Items, {
			Frame = itemFrame;
			ActiveLine = activeLine;
		});
	end

	subTabs:Set(activeIndex, true);
	return subTabs;
end

function SubTabs:Set(index, instant)
	self.ActiveIndex = index;

	for itemIndex, item in ipairs(self.Items) do
		local active = itemIndex == index;

		if (instant) then
			item.Frame.BackgroundColor3 = active and Theme.TabActive or Theme.Tab;
			item.ActiveLine.BackgroundTransparency = active and 0 or 1;
		else
			tween(item.Frame, { BackgroundColor3 = active and Theme.TabActive or Theme.Tab }, TWEEN_TIME);
			tween(item.ActiveLine, { BackgroundTransparency = active and 0 or 1 }, TWEEN_TIME);
		end
	end
end

function Groupbox:AddText(text, x, y, width)
	return label(self.Frame, "Text_" .. cleanName(text), text, UDim2.fromOffset(x, y), UDim2.fromOffset(width or 180, 14), Theme.Text, Enum.TextXAlignment.Left, 118);
end

function Groupbox:AddCheckbox(text, x, y, checked, colorBox, callback)
	local row = frame(self.Frame, "Checkbox_" .. cleanName(text), UDim2.fromOffset(x, y), UDim2.fromOffset(210, 14), Theme.Body, 118);
	row.BackgroundTransparency = 1;

	local square = frame(row, "Square", UDim2.fromOffset(0, 4), UDim2.fromOffset(6, 6), Theme.CheckboxOff, 119);
	local textLabel = label(row, "Text", text, UDim2.fromOffset(19, 0), UDim2.fromOffset(colorBox and 154 or 182, 14), Theme.Text, Enum.TextXAlignment.Left, 119);
	local swatch;

	if (colorBox) then
		swatch = frame(row, "Color", UDim2.fromOffset(181, 4), UDim2.fromOffset(14, 7), colorBox, 120);
	end

	local checkbox = setmetatable({
		Type = "Checkbox";
		Instance = row;
		Square = square;
		TextLabel = textLabel;
		Swatch = swatch;
		Value = checked == true;
		Callback = callback;
	}, Checkbox);

	checkbox:Set(checkbox.Value, true);
	Library.Toggles[text] = checkbox;

	local hitbox = button(row, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
	self.Window:_signal(hitbox.MouseButton1Click, function()
		checkbox:Set(not checkbox.Value);
	end);

	return checkbox;
end

function Checkbox:Set(value, silent)
	self.Value = value == true;
	setCheckboxVisual(self.Square, self.Value);

	if (not silent) then
		safeCallback(self.Callback, self.Value);
		safeCallback(self.Changed, self.Value);
	end
end

function Checkbox:OnChanged(callback)
	self.Changed = callback;
	callback(self.Value);
end

function Checkbox:Get()
	return self.Value;
end

function Groupbox:AddDropdown(text, x, y, width, values, default, callback)
	values = values or { };
	default = default or values[1] or "";

	self:AddText(text, x, y, width);

	local control = makeControl(self.Frame, "Dropdown_" .. cleanName(text), UDim2.fromOffset(x, y + 14), UDim2.fromOffset(width, 19), 118);
	local valueLabel = label(control, "Value", default, UDim2.fromOffset(6, 0), UDim2.new(1, -24, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 120);
	local symbol = label(control, "Symbol", "+", UDim2.new(1, -18, 0, 0), UDim2.fromOffset(13, 19), Theme.Text, Enum.TextXAlignment.Center, 120);
	symbol.TextSize = SYMBOL_TEXT_SIZE;

	local menuHeight = math.max(1, #values) * 18 + 4;
	local menu = frame(self.Window.PopupLayer, "Menu_" .. cleanName(text), UDim2.fromOffset(0, 0), UDim2.fromOffset(width, menuHeight), Theme.DropdownMenu, 520);
	menu.Visible = false;
	stroke(menu, Color3.fromRGB(24, 23, 29), 1);

	local dropdown = setmetatable({
		Type = "Dropdown";
		Window = self.Window;
		Frame = control;
		Menu = menu;
		Symbol = symbol;
		ValueLabel = valueLabel;
		Values = values;
		Value = default;
		Callback = callback;
		MenuHeight = menuHeight;
		Open = false;
	}, Dropdown);

	for index, value in ipairs(values) do
		dropdown:_addOption(index, value);
	end

	local hitbox = button(control, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 19), "", 145);
	self.Window:_signal(hitbox.MouseButton1Click, function()
		dropdown:SetOpen(not dropdown.Open);
	end);

	Library.Options[text] = dropdown;
	return self.Window:_registerDropdown(dropdown);
end

function Dropdown:_addOption(index, value)
	local option = button(self.Menu, "Option_" .. tostring(index), UDim2.fromOffset(1, 2 + (index - 1) * 18), UDim2.new(1, -2, 0, 18), "  " .. tostring(value), 525);
	option.BackgroundTransparency = 0;
	option.BackgroundColor3 = Theme.DropdownMenu;
	option.TextXAlignment = Enum.TextXAlignment.Left;

	self.Window:_signal(option.MouseEnter, function()
		option.BackgroundColor3 = Theme.DropdownHover;
	end);
	self.Window:_signal(option.MouseLeave, function()
		option.BackgroundColor3 = Theme.DropdownMenu;
	end);
	self.Window:_signal(option.MouseButton1Click, function()
		self:Set(value);
		self:SetOpen(false);
	end);
end

function Dropdown:Set(value, silent)
	self.Value = value;
	self.ValueLabel.Text = tostring(value);

	if (not silent) then
		safeCallback(self.Callback, value);
		safeCallback(self.Changed, value);
	end
end

function Dropdown:OnChanged(callback)
	self.Changed = callback;
	callback(self.Value);
end

function Dropdown:Get()
	return self.Value;
end

function Dropdown:SetOpen(open)
	open = open == true;

	if (open) then
		self.Window:_closeColorPicker(nil);
		self.Window:_closeDropdown(self);
		self.Window.OpenDropdown = self;
		self.Menu.Visible = true;
		self.Menu.Size = UDim2.fromOffset(self.Frame.AbsoluteSize.X, self.MenuHeight);
		self.Window:_positionPopup(self.Menu, self.Frame, 1);
	elseif (self.Window.OpenDropdown == self) then
		self.Window.OpenDropdown = nil;
	end

	self.Open = open;
	self.Menu.Visible = open;
	self.Symbol.Text = open and "-" or "+";
	self.Frame.BackgroundColor3 = open and Theme.ControlOpen or Theme.ControlTop;
end

function Groupbox:AddKeyPicker(text, x, y, width, default, callback)
	self:AddText(text, x, y, width);

	local control = makeControl(self.Frame, "KeyPicker_" .. cleanName(text), UDim2.fromOffset(x, y + 14), UDim2.fromOffset(width, 19), 118);
	local valueLabel = label(control, "Value", default or "None", UDim2.fromOffset(6, 0), UDim2.new(1, -24, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 120);
	local clear = button(control, "Clear", UDim2.new(1, -18, 0, 0), UDim2.fromOffset(13, 19), "x", 123);

	local keyPicker = setmetatable({
		Type = "KeyPicker";
		Instance = control;
		ValueLabel = valueLabel;
		Value = default or "None";
		Callback = callback;
		Listening = false;
	}, KeyPicker);

	local hitbox = button(control, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, -20, 1, 0), "", 122);
	self.Window:_signal(hitbox.MouseButton1Click, function()
		keyPicker.Listening = true;
		valueLabel.Text = "...";
	end);
	self.Window:_signal(clear.MouseButton1Click, function()
		keyPicker.Listening = false;
		keyPicker:Set("None");
	end);
	self.Window:_signal(UserInputService.InputBegan, function(input, gameProcessed)
		if (gameProcessed) or (not keyPicker.Listening) then
			return;
		end

		keyPicker.Listening = false;
		keyPicker:Set(formatInput(input));
	end);

	Library.Options[text] = keyPicker;
	return keyPicker;
end

Groupbox.AddKeybind = Groupbox.AddKeyPicker;

function KeyPicker:Set(value, silent)
	self.Value = tostring(value);
	self.ValueLabel.Text = self.Value;

	if (not silent) then
		safeCallback(self.Callback, self.Value);
		safeCallback(self.Changed, self.Value);
	end
end

function KeyPicker:OnChanged(callback)
	self.Changed = callback;
	callback(self.Value);
end

function KeyPicker:Get()
	return self.Value;
end

function Groupbox:AddSlider(text, x, y, width, ratio, valueText, callback)
	local holder = frame(self.Frame, "Slider_" .. cleanName(text), UDim2.fromOffset(x, y), UDim2.fromOffset(width, 28), Theme.Body, 118);
	holder.BackgroundTransparency = 1;

	label(holder, "Text", text, UDim2.fromOffset(0, 0), UDim2.fromOffset(width, 13), Theme.Text, Enum.TextXAlignment.Left, 119);

	local track = frame(holder, "Track", UDim2.fromOffset(0, 17), UDim2.fromOffset(width, 5), Theme.Track, 119);
	stroke(track, Color3.fromRGB(18, 18, 22), 1);
	local fill = frame(track, "Fill", UDim2.fromOffset(0, 0), UDim2.fromOffset(1, 5), Theme.Accent, 120);
	local valueLabel = label(holder, "Value", valueText == nil and "" or tostring(valueText), UDim2.fromOffset(0, 17), UDim2.fromOffset(32, 12), Theme.Text, Enum.TextXAlignment.Center, 130);

	local slider = setmetatable({
		Type = "Slider";
		Window = self.Window;
		Instance = holder;
		Track = track;
		Fill = fill;
		ValueLabel = valueLabel;
		Width = width;
		Ratio = math.clamp(ratio or 0, 0, 1);
		Callback = callback;
		Dragging = false;
	}, Slider);

	slider:_cacheNumberScale();
	slider:Set(slider.Ratio, nil, true);

	local hitbox = button(track, "Hitbox", UDim2.fromOffset(0, -8), UDim2.new(1, 0, 1, 16), "", 126);
	self.Window:_signal(hitbox.InputBegan, function(input)
		if (isDragInput(input)) then
			slider.Dragging = true;
			slider:_setFromInput(input);
		end
	end);
	self.Window:_signal(hitbox.InputEnded, function(input)
		if (isDragInput(input)) then
			slider.Dragging = false;
		end
	end);
	self.Window:_signal(UserInputService.InputChanged, function(input)
		if (slider.Dragging) and (isMoveInput(input)) then
			slider:_setFromInput(input);
		end
	end);
	self.Window:_signal(UserInputService.InputEnded, function(input)
		if (isDragInput(input)) then
			slider.Dragging = false;
		end
	end);

	Library.Options[text] = slider;
	return slider;
end

function Slider:_cacheNumberScale()
	local numeric = tonumber(self.ValueLabel.Text);
	self._decimals = 0;

	local decimalText = self.ValueLabel.Text:match("%.(%d+)$");
	if (decimalText) then
		self._decimals = #decimalText;
	end

	self._valueScale = numeric and self.Ratio > 0 and numeric / self.Ratio or nil;
end

function Slider:_syncLabelToRatio()
	if (not self._valueScale) then
		return;
	end

	local value = self.Ratio * self._valueScale;
	if (self._decimals > 0) then
		self.ValueLabel.Text = string.format("%." .. tostring(self._decimals) .. "f", value);
	else
		self.ValueLabel.Text = tostring(math.floor(value + 0.5));
	end
end

function Slider:_positionLabel()
	local fillWidth = math.floor(self.Width * self.Ratio);
	local valueWidth = math.max(20, math.ceil(measureText(self.ValueLabel.Text, TEXT_SIZE)) + 4);
	self.ValueLabel.Size = UDim2.fromOffset(valueWidth, 12);
	self.ValueLabel.Position = UDim2.fromOffset(fillWidth - math.floor(valueWidth / 2), 17);
end

function Slider:_setFromInput(input)
	if (self.Track.AbsoluteSize.X <= 0) then
		return;
	end

	local localX = math.clamp(input.Position.X - self.Track.AbsolutePosition.X, 0, self.Track.AbsoluteSize.X);
	self:Set(localX / self.Track.AbsoluteSize.X);
end

function Slider:Set(ratio, text, silent)
	if (text ~= nil) then
		self.ValueLabel.Text = tostring(text);
		self.Ratio = math.clamp(ratio or self.Ratio, 0, 1);
		self:_cacheNumberScale();
	else
		self.Ratio = math.clamp(ratio or self.Ratio, 0, 1);
		self:_syncLabelToRatio();
	end

	self.Fill.Size = UDim2.fromOffset(math.floor(self.Width * self.Ratio), 5);
	self:_positionLabel();

	if (not silent) then
		safeCallback(self.Callback, self.Ratio);
		safeCallback(self.Changed, self.Ratio);
	end
end

function Slider:OnChanged(callback)
	self.Changed = callback;
	callback(self.Ratio);
end

function Slider:Get()
	return self.Ratio;
end

function Groupbox:AddButton(text, x, y, width, height, callback)
	local control = makeControl(self.Frame, "Button_" .. cleanName(text), UDim2.fromOffset(x, y), UDim2.fromOffset(width, height or 20), 118);
	label(control, "Text", text, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 120);

	local buttonObject = setmetatable({
		Type = "Button";
		Instance = control;
		Callback = callback;
	}, Button);

	local hitbox = button(control, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
	self.Window:_signal(hitbox.MouseButton1Click, function()
		buttonObject:Press();
	end);

	return buttonObject;
end

function Button:Press()
	safeCallback(self.Callback);
	safeCallback(self.Clicked);
end

function Button:OnClick(callback)
	self.Clicked = callback;
end

local function parseColorPickerArgs(text, x, y, width, default, callback)
	local flag;

	if (type(x) == "table") then
		local info = x;
		flag = text;
		text = info.Text or info.Title or text;
		x = info.X or 10;
		y = info.Y or 10;
		width = info.Width or 180;
		default = info.Default or Theme.Accent;
		callback = info.Callback or callback;
	else
		default = default or Theme.Accent;
	end

	if (typeof(default) ~= "Color3") then
		default = Theme.Accent;
	end

	return tostring(text), x or 10, y or 10, width or 180, default, callback, flag;
end

function Groupbox:AddColorPicker(text, x, y, width, default, callback)
	local flag;
	text, x, y, width, default, callback, flag = parseColorPickerArgs(text, x, y, width, default, callback);

	local holder = frame(self.Frame, "ColorPicker_" .. cleanName(text), UDim2.fromOffset(x, y), UDim2.fromOffset(width, 16), Theme.Body, 118);
	holder.BackgroundTransparency = 1;

	local title = label(holder, "Title", text, UDim2.fromOffset(0, 0), UDim2.new(1, -34, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 119);
	local swatch = frame(holder, "Swatch", UDim2.new(1, -29, 0, 3), UDim2.fromOffset(28, 10), default, 120);
	stroke(swatch, Color3.fromRGB(22, 21, 27), 1);

	local popupWidth = 166;
	local mapWidth = popupWidth - 16;
	local mapHeight = 94;
	local popupHeight = mapHeight + 45;

	local popup = frame(self.Window.PopupLayer, "ColorMenu_" .. cleanName(text), UDim2.fromOffset(0, 0), UDim2.fromOffset(popupWidth, popupHeight), Theme.DropdownMenu, 540);
	popup.Visible = false;
	stroke(popup, Color3.fromRGB(24, 23, 29), 1);

	local popupTitle = label(popup, "Title", text, UDim2.fromOffset(7, 3), UDim2.new(1, -14, 0, 16), Theme.Text, Enum.TextXAlignment.Left, 545);

	local map = frame(popup, "SatVal", UDim2.fromOffset(8, 22), UDim2.fromOffset(mapWidth, mapHeight), Color3.fromHSV(0, 1, 1), 545);
	stroke(map, Color3.fromRGB(16, 15, 20), 1);

	local whiteLayer = frame(map, "White", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.White, 546);
	whiteLayer.BackgroundTransparency = 0;
	local whiteGradient = Instance.new("UIGradient");
	whiteGradient.Color = ColorSequence.new(Theme.White, Theme.White);
	whiteGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0);
		NumberSequenceKeypoint.new(1, 1);
	});
	whiteGradient.Rotation = 0;
	whiteGradient.Parent = whiteLayer;

	local blackLayer = frame(map, "Black", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), Color3.new(0, 0, 0), 547);
	local blackGradient = Instance.new("UIGradient");
	blackGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0));
	blackGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1);
		NumberSequenceKeypoint.new(1, 0);
	});
	blackGradient.Rotation = 90;
	blackGradient.Parent = blackLayer;

	local cursor = frame(map, "Cursor", UDim2.fromOffset(0, 0), UDim2.fromOffset(7, 7), Theme.White, 550);
	cursor.AnchorPoint = Vector2.new(0.5, 0.5);
	local cursorCorner = Instance.new("UICorner");
	cursorCorner.CornerRadius = UDim.new(1, 0);
	cursorCorner.Parent = cursor;
	stroke(cursor, Color3.fromRGB(0, 0, 0), 1);

	local mapHitbox = button(map, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 552);

	local hue = frame(popup, "Hue", UDim2.fromOffset(8, 22 + mapHeight + 10), UDim2.fromOffset(mapWidth, 8), Theme.White, 545);
	stroke(hue, Color3.fromRGB(16, 15, 20), 1);
	local hueGradient = Instance.new("UIGradient");
	hueGradient.Color = hueSequence();
	hueGradient.Rotation = 0;
	hueGradient.Parent = hue;

	local hueCursor = frame(hue, "Cursor", UDim2.fromScale(0, 0.5), UDim2.fromOffset(1, 12), Theme.White, 550);
	hueCursor.AnchorPoint = Vector2.new(0.5, 0.5);
	stroke(hueCursor, Color3.fromRGB(0, 0, 0), 1);

	local hueHitbox = button(hue, "Hitbox", UDim2.fromOffset(0, -4), UDim2.new(1, 0, 1, 8), "", 552);

	local colorPicker = setmetatable({
		Type = "ColorPicker";
		Window = self.Window;
		Instance = holder;
		Title = title;
		PopupTitle = popupTitle;
		Swatch = swatch;
		Popup = popup;
		Map = map;
		MapHitbox = mapHitbox;
		Cursor = cursor;
		Hue = 0;
		Sat = 0;
		Val = 1;
		HueTrack = hue;
		HueHitbox = hueHitbox;
		HueCursor = hueCursor;
		Value = default;
		Callback = callback;
		Open = false;
		DraggingMap = false;
		DraggingHue = false;
	}, ColorPicker);

	colorPicker:Set(default, true);

	local hitbox = button(holder, "Hitbox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
	self.Window:_signal(hitbox.MouseButton1Click, function()
		colorPicker:SetOpen(not colorPicker.Open);
	end);

	self.Window:_signal(mapHitbox.InputBegan, function(input)
		if (isDragInput(input)) then
			colorPicker.DraggingMap = true;
			colorPicker:_setMapFromInput(input);
		end
	end);
	self.Window:_signal(hueHitbox.InputBegan, function(input)
		if (isDragInput(input)) then
			colorPicker.DraggingHue = true;
			colorPicker:_setHueFromInput(input);
		end
	end);
	self.Window:_signal(UserInputService.InputChanged, function(input)
		if (not isMoveInput(input)) then
			return;
		end

		if (colorPicker.DraggingMap) then
			colorPicker:_setMapFromInput(input);
		elseif (colorPicker.DraggingHue) then
			colorPicker:_setHueFromInput(input);
		end
	end);
	self.Window:_signal(UserInputService.InputEnded, function(input)
		if (isDragInput(input)) then
			colorPicker.DraggingMap = false;
			colorPicker.DraggingHue = false;
		end
	end);

	Library.Options[flag or text] = colorPicker;
	return self.Window:_registerColorPicker(colorPicker);
end

function ColorPicker:_setHSVFromRGB(color)
	self.Hue, self.Sat, self.Val = Color3.toHSV(color);
end

function ColorPicker:_display(fire)
	self.Value = Color3.fromHSV(self.Hue, self.Sat, self.Val);
	self.Swatch.BackgroundColor3 = self.Value;
	self.Map.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1);
	self.Cursor.Position = UDim2.fromScale(self.Sat, 1 - self.Val);
	self.HueCursor.Position = UDim2.fromScale(self.Hue, 0.5);

	if (fire) then
		safeCallback(self.Callback, self.Value);
		safeCallback(self.Changed, self.Value);
	end
end

function ColorPicker:_setMapFromInput(input)
	if (self.Map.AbsoluteSize.X <= 0) or (self.Map.AbsoluteSize.Y <= 0) then
		return;
	end

	local localX = math.clamp(input.Position.X - self.Map.AbsolutePosition.X, 0, self.Map.AbsoluteSize.X);
	local localY = math.clamp(input.Position.Y - self.Map.AbsolutePosition.Y, 0, self.Map.AbsoluteSize.Y);

	self.Sat = localX / self.Map.AbsoluteSize.X;
	self.Val = 1 - (localY / self.Map.AbsoluteSize.Y);
	self:_display(true);
end

function ColorPicker:_setHueFromInput(input)
	if (self.HueTrack.AbsoluteSize.X <= 0) then
		return;
	end

	local localX = math.clamp(input.Position.X - self.HueTrack.AbsolutePosition.X, 0, self.HueTrack.AbsoluteSize.X);
	self.Hue = localX / self.HueTrack.AbsoluteSize.X;
	self:_display(true);
end

function ColorPicker:SetOpen(open)
	open = open == true;

	if (open) then
		self.Window:_closeDropdown(nil);
		self.Window:_closeColorPicker(self);
		self.Window.OpenColorPicker = self;
		self.Popup.Visible = true;
		self.Window:_positionPopup(self.Popup, self.Instance, 2);
	elseif (self.Window.OpenColorPicker == self) then
		self.Window.OpenColorPicker = nil;
	end

	self.Open = open;
	self.Popup.Visible = open;
end

function ColorPicker:Set(color, silent)
	if (type(color) == "table") then
		color = Color3.fromHSV(color[1] or self.Hue, color[2] or self.Sat, color[3] or self.Val);
	end

	if (typeof(color) ~= "Color3") then
		return;
	end

	self:_setHSVFromRGB(color);
	self:_display(not silent);
end

function ColorPicker:SetValueRGB(color, silent)
	self:Set(color, silent);
end

function ColorPicker:SetValue(hsv, silent)
	self:Set(hsv, silent);
end

function ColorPicker:OnChanged(callback)
	self.Changed = callback;
	callback(self.Value);
end

function ColorPicker:Get()
	return self.Value;
end

function ColorPicker:GetHSV()
	return self.Hue, self.Sat, self.Val;
end

return Library;

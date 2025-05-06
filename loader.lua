-- Venera UI Library
local Venera = {}

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Colors
Venera.Colors = {
    MainBg = Color3.fromRGB(10, 10, 10),
    ElementBg = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(125, 75, 255),
    Text = Color3.fromRGB(220, 220, 255),
    MutedText = Color3.fromRGB(150, 150, 180),
    Border = Color3.fromRGB(40, 40, 40)
}

-- Main UI Instance
Venera.UI = Instance.new("ScreenGui")
Venera.UI.Name = "VeneraUI"
Venera.UI.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Destroy any existing UI
function Venera:Destroy()
    if self.UI then
        self.UI:Destroy()
        self.UI = nil
    end
end

-- Button Component
function Venera:CreateButton(config)
    local Button = Instance.new("TextButton")
    Button.Name = config.Name or "Button"
    Button.Text = config.Text or "Button"
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = config.TextSize or 14
    Button.TextColor3 = config.TextColor or self.Colors.Text
    Button.Size = config.Size or UDim2.new(1, 0, 0, 30)
    Button.BackgroundColor3 = config.BackgroundColor or self.Colors.ElementBg
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    
    local buttonCorner = Instance.new("UICorner", Button)
    buttonCorner.CornerRadius = UDim.new(0, 4)
    
    local buttonStroke = Instance.new("UIStroke", Button)
    buttonStroke.Color = self.Colors.Border
    buttonStroke.Thickness = 1
    buttonStroke.LineJoinMode = Enum.LineJoinMode.Round

    local hoverFrame = Instance.new("Frame", Button)
    hoverFrame.Size = UDim2.new(1, 0, 1, 0)
    hoverFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    hoverFrame.BackgroundTransparency = 1
    hoverFrame.ZIndex = -1
    Instance.new("UICorner", hoverFrame).CornerRadius = UDim.new(0, 4)

    local pressFrame = Instance.new("Frame", Button)
    pressFrame.Size = UDim2.new(1, 0, 1, 0)
    pressFrame.BackgroundColor3 = self.Colors.Accent
    pressFrame.BackgroundTransparency = 0.9
    pressFrame.ZIndex = -1
    pressFrame.Visible = false
    Instance.new("UICorner", pressFrame).CornerRadius = UDim.new(0, 4)

    local originalSize = Button.Size
    local originalPosition = Button.Position

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = originalSize + UDim2.new(0.05, 0, 0.05, 0),
            Position = originalPosition - UDim2.new(0.025, 0, 0.025, 0)
        }):Play()
        
        TweenService:Create(hoverFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = originalSize,
            Position = originalPosition
        }):Play()
        
        TweenService:Create(hoverFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end)

    Button.MouseButton1Down:Connect(function()
        pressFrame.Visible = true
        TweenService:Create(pressFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.7}):Play()
        TweenService:Create(Button, TweenInfo.new(0.1), {Position = Button.Position + UDim2.new(0, 0, 0, 1)}):Play()
    end)

    Button.MouseButton1Up:Connect(function()
        TweenService:Create(pressFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.9}):Play()
        TweenService:Create(Button, TweenInfo.new(0.1), {Position = Button.Position - UDim2.new(0, 0, 0, 1)}):Play()
        task.wait(0.1)
        pressFrame.Visible = false
    end)

    if config.Callback then
        Button.MouseButton1Click:Connect(config.Callback)
    end

    if config.Parent then
        Button.Parent = config.Parent
    end

    return Button
end

-- Toggle Component
function Venera:CreateToggle(config)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = config.Size or UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Name = config.Name or "Toggle"

    local ToggleText = Instance.new("TextLabel", ToggleFrame)
    ToggleText.Text = config.Text or "Toggle"
    ToggleText.Font = Enum.Font.GothamMedium
    ToggleText.TextSize = config.TextSize or 13
    ToggleText.TextColor3 = config.TextColor or self.Colors.Text
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.BackgroundTransparency = 1
    ToggleText.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleText.Position = UDim2.new(0, 10, 0, 0)

    local ToggleSwitch = Instance.new("Frame", ToggleFrame)
    ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
    ToggleSwitch.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleSwitch.BackgroundColor3 = self.Colors.ElementBg
    ToggleSwitch.BorderSizePixel = 0
    Instance.new("UICorner", ToggleSwitch).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", ToggleSwitch).Color = self.Colors.Border

    local ToggleButton = Instance.new("Frame", ToggleSwitch)
    ToggleButton.Size = UDim2.new(0, 16, 0, 16)
    ToggleButton.Position = config.Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    ToggleButton.BackgroundColor3 = config.Default and self.Colors.Accent or Color3.fromRGB(100, 100, 100)
    ToggleButton.BorderSizePixel = 0
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)
    
    local isToggled = config.Default or false

    local function UpdateToggle()
        if isToggled then
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = self.Colors.Accent
            }):Play()
        else
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            }):Play()
        end
        
        if config.Callback then
            config.Callback(isToggled)
        end
    end

    ToggleSwitch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isToggled = not isToggled
            UpdateToggle()
        end
    end)

    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isToggled = not isToggled
            UpdateToggle()
        end
    end)

    if config.Parent then
        ToggleFrame.Parent = config.Parent
    end

    local ToggleObject = {}
    function ToggleObject:Set(value)
        isToggled = value
        UpdateToggle()
    end
    
    function ToggleObject:Get()
        return isToggled
    end

    return ToggleObject, ToggleFrame
end

-- Label Component
function Venera:CreateLabel(config)
    local Label = Instance.new("TextLabel")
    Label.Text = config.Text or "Label"
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = config.TextSize or 14
    Label.TextColor3 = config.TextColor or self.Colors.Text
    Label.TextXAlignment = config.Alignment or Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Size = config.Size or UDim2.new(1, 0, 0, 20)
    
    if config.Parent then
        Label.Parent = config.Parent
    end

    return Label
end

-- Window Component
function Venera:CreateWindow(config)
    -- Destroy existing UI if any
    if CoreGui:FindFirstChild("VeneraUI") then 
        CoreGui.VeneraUI:Destroy() 
    end

    self.UI.Name = "VeneraUI"
    self.UI.Parent = CoreGui

    -- Main Frame
    local Window = Instance.new("Frame")
    Window.Size = config.Size or UDim2.new(0, 650, 0, 400)
    Window.Position = config.Position or UDim2.new(0.5, -325, 0.5, -200)
    Window.BackgroundColor3 = self.Colors.MainBg
    Window.Parent = self.UI
    
    local mainCorner = Instance.new("UICorner", Window)
    mainCorner.CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Window).Color = self.Colors.Border

    -- Drag System
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Window.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Top Header
    local Header = Instance.new("Frame", Window)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundTransparency = 1

    -- Gradient Top Separator
    local TopSeparator = Instance.new("Frame", Header)
    TopSeparator.Size = UDim2.new(1, 0, 0, 1)
    TopSeparator.Position = UDim2.new(0, 0, 1, 0)
    TopSeparator.BackgroundColor3 = Color3.new(1, 1, 1)
    TopSeparator.BorderSizePixel = 0
    local TopGradient = Instance.new("UIGradient", TopSeparator)
    TopGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 85, 176)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(160, 108, 255))
    })

    -- Header Title
    local Title1 = Instance.new("TextLabel", Header)
    Title1.Text = config.Title or "VENERA UI"
    Title1.Font = Enum.Font.GothamBold
    Title1.TextSize = 14
    Title1.TextColor3 = Color3.new(1, 1, 1)
    Title1.TextXAlignment = Enum.TextXAlignment.Left
    Title1.BackgroundTransparency = 1
    Title1.Size = UDim2.new(0, 100, 1, 0)
    Title1.Position = UDim2.new(0, 15, 0, 0)

    if config.Subtitle then
        local Separator1 = Instance.new("TextLabel", Header)
        Separator1.Text = "      |"
        Separator1.Font = Enum.Font.GothamBold
        Separator1.TextSize = 14
        Separator1.TextColor3 = Color3.new(1, 1, 1)
        Separator1.TextXAlignment = Enum.TextXAlignment.Center
        Separator1.BackgroundTransparency = 1
        Separator1.Size = UDim2.new(0, 10, 1, 0)
        Separator1.Position = UDim2.new(0, 115, 0, 0)

        local Title2 = Instance.new("TextLabel", Header)
        Title2.Text = "    "..config.Subtitle
        Title2.Font = Enum.Font.GothamBold
        Title2.TextSize = 14
        Title2.TextColor3 = Color3.new(1, 1, 1)
        Title2.TextXAlignment = Enum.TextXAlignment.Left
        Title2.BackgroundTransparency = 1
        Title2.Size = UDim2.new(0, 150, 1, 0)
        Title2.Position = UDim2.new(0, 125, 0, 0)

        local Gradient = Instance.new("UIGradient", Title2)
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 85, 176)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(160, 108, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(105, 70, 230))
        })
    end

    -- Window Controls
    local Controls = Instance.new("Frame", Header)
    Controls.Size = UDim2.new(0, 50, 1, 0)
    Controls.Position = UDim2.new(1, -50, 0, 0)
    Controls.BackgroundTransparency = 1

    local Minimize = Instance.new("TextButton", Controls)
    Minimize.Text = "-"
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 16
    Minimize.TextColor3 = self.Colors.Text
    Minimize.Size = UDim2.new(0, 20, 1, 0)
    Minimize.Position = UDim2.new(0, 0, 0, 0)
    Minimize.BackgroundTransparency = 1
    Minimize.Name = "Minimize"

    local Close = Instance.new("TextButton", Controls)
    Close.Text = "X"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.TextColor3 = self.Colors.Text
    Close.Size = UDim2.new(0, 20, 1, 0)
    Close.Position = UDim2.new(0, 30, 0, 0)
    Close.BackgroundTransparency = 1
    Close.Name = "Close"

    local CloseHover = Instance.new("Frame", Close)
    CloseHover.Size = UDim2.new(1, 0, 1, 0)
    CloseHover.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseHover.BackgroundTransparency = 1
    CloseHover.ZIndex = -1
    Instance.new("UICorner", CloseHover).CornerRadius = UDim.new(0, 4)

    Close.MouseEnter:Connect(function()
        TweenService:Create(CloseHover, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    Close.MouseLeave:Connect(function()
        TweenService:Create(CloseHover, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end)

    Minimize.MouseButton1Click:Connect(function()
        Window.Visible = false
    end)

    Close.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    -- Sidebar
    local TabButtons = Instance.new("Frame", Window)
    TabButtons.Size = UDim2.new(0, 120, 1, -65)
    TabButtons.Position = UDim2.new(0, 0, 0, 35)
    TabButtons.BackgroundColor3 = self.Colors.ElementBg
    local tabCorner = Instance.new("UICorner", TabButtons)
    tabCorner.CornerRadius = UDim.new(0, 6)

    local sidebarStroke = Instance.new("UIStroke", TabButtons)
    sidebarStroke.Color = self.Colors.Border
    sidebarStroke.Thickness = 1
    sidebarStroke.LineJoinMode = Enum.LineJoinMode.Round

    -- Sidebar Buttons Container
    local ButtonContainer = Instance.new("Frame", TabButtons)
    ButtonContainer.Size = UDim2.new(1, -15, 1, -10)
    ButtonContainer.Position = UDim2.new(0, 10, 0, 5)
    ButtonContainer.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", ButtonContainer)
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)

    -- Content Area
    local ContentArea = Instance.new("Frame", Window)
    ContentArea.Size = UDim2.new(1, -150, 1, -80)
    ContentArea.Position = UDim2.new(0, 140, 0, 40)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Name = "ContentArea"

    -- Bottom Footer
    local BottomHeader = Instance.new("Frame", Window)
    BottomHeader.Size = UDim2.new(1, 0, 0, 25)
    BottomHeader.Position = UDim2.new(0, 0, 1, -25)
    BottomHeader.BackgroundColor3 = self.Colors.ElementBg
    BottomHeader.BorderSizePixel = 0
    local bottomCorner = Instance.new("UICorner", BottomHeader)
    bottomCorner.CornerRadius = UDim.new(0, 6)

    local bottomStroke = Instance.new("UIStroke", BottomHeader)
    bottomStroke.Color = self.Colors.Border
    bottomStroke.Thickness = 1
    bottomStroke.LineJoinMode = Enum.LineJoinMode.Round

    -- Gradient Bottom Separator
    local BottomSeparator = Instance.new("Frame", BottomHeader)
    BottomSeparator.Size = UDim2.new(1, 0, 0, 1)
    BottomSeparator.Position = UDim2.new(0, 0, 0, 0)
    BottomSeparator.BackgroundColor3 = Color3.new(1, 1, 1)
    BottomSeparator.BorderSizePixel = 0
    local BottomGradient = Instance.new("UIGradient", BottomSeparator)
    BottomGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 85, 176)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(160, 108, 255))
    })

    -- Watermark & Version
    local WatermarkText = Instance.new("TextLabel", BottomHeader)
    WatermarkText.Text = config.Watermark or "Venera UI Library"
    WatermarkText.Font = Enum.Font.GothamMedium
    WatermarkText.TextSize = 12
    WatermarkText.TextColor3 = self.Colors.MutedText
    WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
    WatermarkText.BackgroundTransparency = 1
    WatermarkText.Size = UDim2.new(0, 200, 1, 0)
    WatermarkText.Position = UDim2.new(0, 15, 0, 0)

    local VersionText = Instance.new("TextLabel", BottomHeader)
    VersionText.Text = config.Version or "v1.0"
    VersionText.Font = Enum.Font.GothamMedium
    VersionText.TextSize = 12
    VersionText.TextColor3 = self.Colors.MutedText
    VersionText.TextXAlignment = Enum.TextXAlignment.Right
    VersionText.BackgroundTransparency = 1
    VersionText.Size = UDim2.new(0, 100, 1, 0)
    VersionText.Position = UDim2.new(1, -115, 0, 0)

    -- Toggle UI visibility
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightShift then
            Window.Visible = not Window.Visible
        end
    end)

    -- Tab System
    local Tabs = {}
    local ActiveTab = nil

    function Tabs:CreateTab(tabConfig)
        -- Create tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabConfig.Name
        TabButton.Text = tabConfig.Name
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 14
        TabButton.TextColor3 = #ButtonContainer:GetChildren() == 1 and self.Colors.Accent or self.Colors.MutedText
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = self.Colors.MainBg
        TabButton.BorderSizePixel = 0
        TabButton.AutoButtonColor = false
        TabButton.ClipsDescendants = true
        TabButton.Parent = ButtonContainer

        local buttonCorner = Instance.new("UICorner", TabButton)
        buttonCorner.CornerRadius = UDim.new(0, 4)
        
        local buttonStroke = Instance.new("UIStroke", TabButton)
        buttonStroke.Color = self.Colors.Border
        buttonStroke.Thickness = 1

        -- Underline indicator
        local Underline = Instance.new("Frame", TabButton)
        Underline.Size = UDim2.new(0, #ButtonContainer:GetChildren() == 1 and 30 or 0, 0, 2)
        Underline.Position = UDim2.new(0.5, #ButtonContainer:GetChildren() == 1 and -15 or 0, 1, -2)
        Underline.BackgroundColor3 = #ButtonContainer:GetChildren() == 1 and self.Colors.Accent or Color3.new(0, 0, 0)
        Underline.BorderSizePixel = 0

        -- Create tab content frame
        local TabFrame = Instance.new("ScrollingFrame", ContentArea)
        TabFrame.Name = tabConfig.Name.."Content"
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = #ButtonContainer:GetChildren() == 1
        TabFrame.ScrollBarThickness = 5
        TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabFrame.ScrollBarImageColor3 = self.Colors.Accent

        local ContentLayout = Instance.new("UIListLayout", TabFrame)
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Tab button interactions
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, child in pairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Show this tab
            TabFrame.Visible = true
            ActiveTab = tabConfig.Name

            -- Update all tab buttons appearance
            for _, btn in pairs(ButtonContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.TextColor3 = self.Colors.MutedText
                    local line = btn:FindFirstChildOfClass("Frame")
                    if line then
                        line.BackgroundColor3 = Color3.new(0, 0, 0)
                    end
                end
            end

            -- Update active tab appearance
            TabButton.TextColor3 = self.Colors.Accent
            Underline.BackgroundColor3 = self.Colors.Accent
            Underline.Size = UDim2.new(0, 10, 0, 2)
            Underline.Position = UDim2.new(0.5, -5, 1, -2)

            -- Animate underline
            TweenService:Create(Underline, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 30, 0, 2),
                Position = UDim2.new(0.5, -15, 1, -2)
            }):Play()
        end)

        -- Return tab object with methods to add elements
        local Tab = {}
        
        function Tab:CreateButton(btnConfig)
            btnConfig.Parent = TabFrame
            return Venera:CreateButton(btnConfig)
        end
        
        function Tab:CreateToggle(toggleConfig)
            toggleConfig.Parent = TabFrame
            return Venera:CreateToggle(toggleConfig)
        end
        
        function Tab:CreateLabel(labelConfig)
            labelConfig.Parent = labelConfig.Parent or TabFrame
            return Venera:CreateLabel(labelConfig)
        end

        return Tab
    end

    return Tabs
end

return Venera

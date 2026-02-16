local CloneRef = (cloneref or clonereference or function(Instance: any) return Instance end)
local CoreGui = CloneRef(game:GetService("CoreGui"))
local UserInputService = CloneRef(game:GetService("UserInputService"))
local TweenService = CloneRef(game:GetService("TweenService"))

local Library = {
    Accent = Color3.fromRGB(203, 133, 203),
    MainColor = Color3.fromRGB(15, 15, 15),
    TextColor = Color3.fromRGB(180, 180, 180),
    Font = Enum.Font.GothamMedium,
    ActiveTab = nil,
    ToggleKey = Enum.KeyCode.RightControl
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Simpliness_Restored_V3"
ScreenGui.Parent = (gethui and gethui()) or CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false

local Watermark = Instance.new("Frame", ScreenGui)
Watermark.Size = UDim2.fromOffset(300, 26)
Watermark.Position = UDim2.new(1, -315, 0, 15)
Watermark.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Watermark.BackgroundTransparency = 0.1
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)

local WLabel = Instance.new("TextLabel", Watermark)
WLabel.Size = UDim2.fromScale(1, 1)
WLabel.BackgroundTransparency = 1
WLabel.Text = "desktop | .gg/idontfuckingknow | nyxly"
WLabel.TextColor3 = Color3.new(1, 1, 1)
WLabel.Font = Library.Font
WLabel.TextSize = 12

local WLine = Instance.new("Frame", Watermark)
WLine.Size = UDim2.new(0, 2, 0.6, 0)
WLine.Position = UDim2.new(0, 5, 0.2, 0)
WLine.BackgroundColor3 = Library.Accent
WLine.BorderSizePixel = 0

local function MakeDraggable(Frame, Handle)
    local Dragging, DragInput, DragStart, StartPos

    Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = Frame.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
                Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            }):Play()
        end
    end)
end

local UiVisible = false
local MainFrame
local OriginalTransparencies = {}

local function StoreTransparency(Obj)
    if not OriginalTransparencies[Obj] then
        OriginalTransparencies[Obj] = Obj.BackgroundTransparency
    end
end

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == Library.ToggleKey then
        UiVisible = not UiVisible
        if MainFrame then
            if UiVisible then
                ScreenGui.Enabled = true
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.05}):Play()
                for _, Child in pairs(MainFrame:GetDescendants()) do
                    if Child:IsA("TextLabel") or Child:IsA("TextButton") then
                        TweenService:Create(Child, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                    elseif Child:IsA("Frame") and Child.Name ~= "Indicator" then
                        local TargetTrans = OriginalTransparencies[Child] or 0
                        if Child.BackgroundTransparency ~= 1 or TargetTrans ~= 1 then
                            TweenService:Create(Child, TweenInfo.new(0.3), {BackgroundTransparency = TargetTrans}):Play()
                        end
                    end
                end
            else
                for _, Child in MainFrame:GetDescendants() do
                    if Child:IsA("Frame") then
                        StoreTransparency(Child)
                    end
                end

                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
                for _, Child in pairs(MainFrame:GetDescendants()) do
                    if Child:IsA("TextLabel") or Child:IsA("TextButton") then
                        TweenService:Create(Child, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                    elseif Child:IsA("Frame") and Child.Name ~= "Indicator" then
                        if Child.BackgroundTransparency ~= 1 then
                            TweenService:Create(Child, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                        end
                    end
                end
                task.wait(0.3)
                if not UiVisible then
                    for _, Child in pairs(ScreenGui:GetChildren()) do
                        if Child:IsA("Frame") and Child.Name == "ColorPicker" then
                            Child.Visible = false
                        end
                    end
                    ScreenGui.Enabled = false
                end
            end
        end
    end
end)

function Library:CreateWindow(Title)
    MainFrame = Instance.new("Frame", ScreenGui)
    local MainCorner = Instance.new("UICorner", MainFrame)
    local TitleLabel = Instance.new("TextLabel", MainFrame)
    local TabHolder = Instance.new("Frame", MainFrame)
    local Container = Instance.new("Frame", MainFrame)

    MainFrame.Size = UDim2.fromOffset(580, 620)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -310)
    MainFrame.BackgroundColor3 = Library.MainColor
    MainFrame.BackgroundTransparency = 1
    MainCorner.CornerRadius = UDim.new(0, 8)

    TitleLabel.Size = UDim2.new(1, -60, 0, 45)
    TitleLabel.Position = UDim2.fromOffset(15, 0)
    TitleLabel.Text = "←  " .. Title
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.Font = Library.Font
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextTransparency = 1
    MakeDraggable(MainFrame, TitleLabel)

    TabHolder.Size = UDim2.new(1, -30, 0, 35)
    TabHolder.Position = UDim2.fromOffset(15, 50)
    TabHolder.BackgroundTransparency = 1
    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 0)

    Container.Size = UDim2.new(1, -30, 1, -110)
    Container.Position = UDim2.fromOffset(15, 95)
    Container.BackgroundTransparency = 1

    task.spawn(function()
        task.wait(0.5)
        UiVisible = true
        ScreenGui.Enabled = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(TitleLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    end)

    local Window = {}

    function Window:CreateTab(Name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        local Indicator = Instance.new("Frame", TabBtn)
        local Page = Instance.new("Frame", Container)

        local LeftSide = Instance.new("ScrollingFrame", Page)
        local RightSide = Instance.new("ScrollingFrame", Page)

        TabBtn.Size = UDim2.fromOffset(100, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = Name
        TabBtn.TextColor3 = Library.TextColor
        TabBtn.Font = Library.Font
        TabBtn.TextSize = 14
        TabBtn.TextTransparency = 1

        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 0, 0, 2)
        Indicator.Position = UDim2.new(0.5, 0, 1, -1)
        Indicator.BackgroundColor3 = Library.Accent
        Indicator.BorderSizePixel = 0

        Page.Size = UDim2.fromScale(1, 1)
        Page.Visible = false
        Page.BackgroundTransparency = 1

        for _, Side in pairs({LeftSide, RightSide}) do
            Side.BackgroundTransparency = 1
            Side.ScrollBarThickness = 0
            Side.Size = UDim2.new(0.5, -5, 1, 0)
            Side.CanvasSize = UDim2.new(0, 0, 0, 0)
            Side.AutomaticSize = Enum.AutomaticSize.Y
            Side.ClipsDescendants = false
            local Layout = Instance.new("UIListLayout", Side)
            Layout.Padding = UDim.new(0, 10)
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        end
        RightSide.Position = UDim2.fromScale(0.51, 0)

        task.spawn(function()
            task.wait(0.6)
            TweenService:Create(TabBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        end)

        local function Switch()
            for _, V in pairs(Container:GetChildren()) do
                if V:IsA("Frame") then
                    V.Visible = false
                end
            end
            for _, V in pairs(TabHolder:GetChildren()) do
                if V:IsA("TextButton") then
                    TweenService:Create(V, TweenInfo.new(0.2), {TextColor3 = Library.TextColor}):Play()
                    TweenService:Create(V.Indicator, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 0, 0, 2),
                        Position = UDim2.new(0.5, 0, 1, -1)
                    }):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                Size = UDim2.new(0.8, 0, 0, 2),
                Position = UDim2.new(0.1, 0, 1, -1)
            }):Play()
        end

        TabBtn.MouseButton1Click:Connect(Switch)
        if not Library.ActiveTab then
            Library.ActiveTab = Name
            Page.Visible = true
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
            Indicator.Size = UDim2.new(0.8, 0, 0, 2)
            Indicator.Position = UDim2.new(0.1, 0, 1, -1)
        end

        local Tab = {}

        function Tab:CreateGroup(Side, GroupName)
            local GFrame = Instance.new("Frame", Side == "Left" and LeftSide or RightSide)
            local GCorner = Instance.new("UICorner", GFrame)
            local GTitle = Instance.new("TextLabel", GFrame)
            local GContainer = Instance.new("Frame", GFrame)
            local GLayout = Instance.new("UIListLayout", GContainer)

            GFrame.Size = UDim2.new(1, 0, 0, 30)
            GFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            GFrame.AutomaticSize = Enum.AutomaticSize.Y
            GFrame.BackgroundTransparency = 1
            GFrame.ClipsDescendants = false
            GCorner.CornerRadius = UDim.new(0, 6)

            GTitle.Size = UDim2.new(1, -10, 0, 25)
            GTitle.Position = UDim2.fromOffset(10, 0)
            GTitle.Text = GroupName:upper()
            GTitle.TextColor3 = Library.Accent
            GTitle.Font = Library.Font
            GTitle.TextSize = 11
            GTitle.TextXAlignment = Enum.TextXAlignment.Left
            GTitle.BackgroundTransparency = 1
            GTitle.TextTransparency = 1

            GContainer.Size = UDim2.new(1, -20, 1, -30)
            GContainer.Position = UDim2.fromOffset(10, 30)
            GContainer.BackgroundTransparency = 1
            GLayout.Padding = UDim.new(0, 6)

            task.spawn(function()
                task.wait(0.7)
                TweenService:Create(GFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
                TweenService:Create(GTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            end)

            local Elements = {}

            function Elements:CreateDropdown(Text, List, Callback)
                local DropFrame = Instance.new("Frame", GContainer)
                local DropBtn = Instance.new("TextButton", DropFrame)
                local DropList = Instance.new("Frame", DropFrame)
                local DropLayout = Instance.new("UIListLayout", DropList)
                local DropArrow = Instance.new("TextLabel", DropBtn)

                DropFrame.Size = UDim2.new(1, 0, 0, 42)
                DropFrame.BackgroundTransparency = 1
                DropFrame.ZIndex = 5

                local DLbl = Instance.new("TextLabel", DropFrame)
                DLbl.Text = Text
                DLbl.Size = UDim2.new(1, 0, 0, 18)
                DLbl.TextColor3 = Library.TextColor
                DLbl.Font = Library.Font
                DLbl.TextSize = 12
                DLbl.TextXAlignment = Enum.TextXAlignment.Left
                DLbl.BackgroundTransparency = 1

                DropBtn.Size = UDim2.new(1, 0, 0, 22)
                DropBtn.Position = UDim2.fromOffset(0, 20)
                DropBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                DropBtn.Text = "  None"
                DropBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropBtn.Font = Library.Font
                DropBtn.TextSize = 11
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.AutoButtonColor = false
                Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)

                DropArrow.Text = "▼"
                DropArrow.Size = UDim2.new(0, 20, 1, 0)
                DropArrow.Position = UDim2.new(1, -20, 0, 0)
                DropArrow.TextColor3 = Library.TextColor
                DropArrow.Font = Library.Font
                DropArrow.TextSize = 10
                DropArrow.BackgroundTransparency = 1

                DropList.Size = UDim2.new(1, 0, 0, 0)
                DropList.Position = UDim2.fromOffset(0, 44)
                DropList.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                DropList.Visible = false
                DropList.ClipsDescendants = true
                DropList.ZIndex = 500
                Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", DropList).Color = Color3.fromRGB(45, 45, 45)
                DropLayout.Padding = UDim.new(0, 2)

                local Dropped = false
                local OptionButtons = {}

                DropBtn.MouseButton1Click:Connect(function()
                    Dropped = not Dropped
                    if Dropped then
                        DropList.Visible = true
                        DropFrame.ZIndex = 1000
                    end
                    TweenService:Create(DropList, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                        Size = Dropped and UDim2.new(1, 0, 0, DropLayout.AbsoluteContentSize.Y + 4) or UDim2.new(1, 0, 0, 0)
                    }):Play()
                    DropArrow.Text = Dropped and "▲" or "▼"
                    if not Dropped then
                        task.delay(0.2, function()
                            if not Dropped then
                                DropList.Visible = false
                                DropFrame.ZIndex = 5
                            end
                        end)
                    end
                end)

                for _, Option in pairs(List) do
                    local OptBtn = Instance.new("TextButton", DropList)
                    OptBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. Option
                    OptBtn.TextColor3 = Library.TextColor
                    OptBtn.Font = Library.Font
                    OptBtn.TextSize = 11
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.AutoButtonColor = false
                    OptionButtons[Option] = OptBtn

                    OptBtn.MouseEnter:Connect(function()
                        if OptBtn.TextColor3 ~= Library.Accent then
                            TweenService:Create(OptBtn, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
                        end
                    end)

                    OptBtn.MouseLeave:Connect(function()
                        if OptBtn.TextColor3 ~= Library.Accent then
                            TweenService:Create(OptBtn, TweenInfo.new(0.2), {TextColor3 = Library.TextColor}):Play()
                        end
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        for OptionName, Btn in pairs(OptionButtons) do
                            Btn.TextColor3 = (OptionName == Option) and Library.Accent or Library.TextColor
                        end
                        Dropped = false
                        TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        DropBtn.Text = "  " .. Option
                        DropBtn.TextColor3 = Library.Accent
                        DropArrow.Text = "▼"
                        task.delay(0.2, function()
                            DropList.Visible = false
                            DropFrame.ZIndex = 5
                        end)
                        Callback(Option)
                    end)
                end
            end

            function Elements:CreateCheckbox(Text, Default, Callback)
                local CFrame = Instance.new("Frame", GContainer)
                local CBox = Instance.new("Frame", CFrame)
                local Fill = Instance.new("Frame", CBox)
                local Grad = Instance.new("UIGradient", Fill)

                CFrame.Size = UDim2.new(1, 0, 0, 26)
                CFrame.BackgroundTransparency = 1

                local CLbl = Instance.new("TextLabel", CFrame)
                CLbl.Text = Text
                CLbl.Size = UDim2.new(1, 0, 1, 0)
                CLbl.TextColor3 = Library.TextColor
                CLbl.Font = Library.Font
                CLbl.TextSize = 12
                CLbl.TextXAlignment = Enum.TextXAlignment.Left
                CLbl.BackgroundTransparency = 1

                CBox.Size = UDim2.fromOffset(16, 16)
                CBox.Position = UDim2.new(1, -16, 0.5, -8)
                CBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Instance.new("UICorner", CBox).CornerRadius = UDim.new(0, 4)

                Fill.Size = Default and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0)
                Fill.Position = UDim2.fromScale(0.5, 0.5)
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundColor3 = Color3.new(1, 1, 1)
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

                Grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Library.Accent),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
                Grad.Rotation = 45

                local State = Default
                CFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        State = not State
                        TweenService:Create(Fill, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            Size = State and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0)
                        }):Play()
                        Callback(State)
                    end
                end)
            end

            function Elements:CreateSlider(Text, Min, Max, Default, Callback)
                local SFrame = Instance.new("Frame", GContainer)
                local Bar = Instance.new("Frame", SFrame)
                local Fill = Instance.new("Frame", Bar)
                local Knob = Instance.new("Frame", Fill)
                local ValLbl = Instance.new("TextLabel", SFrame)

                SFrame.Size = UDim2.new(1, 0, 0, 38)
                SFrame.BackgroundTransparency = 1

                local SLbl = Instance.new("TextLabel", SFrame)
                SLbl.Text = Text
                SLbl.Size = UDim2.new(1, 0, 0, 18)
                SLbl.TextColor3 = Library.TextColor
                SLbl.Font = Library.Font
                SLbl.TextSize = 12
                SLbl.TextXAlignment = Enum.TextXAlignment.Left
                SLbl.BackgroundTransparency = 1

                ValLbl.Parent = SFrame
                ValLbl.Text = tostring(Default)
                ValLbl.Size = UDim2.new(1, 0, 0, 18)
                ValLbl.TextColor3 = Color3.new(1, 1, 1)
                ValLbl.Font = Library.Font
                ValLbl.TextSize = 11
                ValLbl.TextXAlignment = Enum.TextXAlignment.Right
                ValLbl.BackgroundTransparency = 1

                Bar.Size = UDim2.new(1, 0, 0, 4)
                Bar.Position = UDim2.fromOffset(0, 24)
                Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

                Fill.Size = UDim2.fromScale((Default - Min) / (Max - Min), 1)
                Fill.BackgroundColor3 = Library.Accent
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                Knob.Size = UDim2.fromOffset(12, 12)
                Knob.Position = UDim2.new(1, -6, 0.5, -6)
                Knob.BackgroundColor3 = Color3.new(1, 1, 1)
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local Dragging = false
                local function Update(Input)
                    local Size = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Val = math.floor(Min + (Max - Min) * Size)
                    TweenService:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(Size, 1)}):Play()
                    ValLbl.Text = tostring(Val)
                    Callback(Val)
                end

                Bar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Update(Input)
                    end
                end)

                Bar.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(Input)
                    end
                end)
            end

            function Elements:CreateColorpicker(Text, Default, Callback)
                local CpFrame = Instance.new("Frame", GContainer)
                local CpBox = Instance.new("Frame", CpFrame)
                local CpPicker = Instance.new("Frame", ScreenGui)
                local PickerCorner = Instance.new("UICorner", CpPicker)

                CpFrame.Size = UDim2.new(1, 0, 0, 26)
                CpFrame.BackgroundTransparency = 1

                local CpLbl = Instance.new("TextLabel", CpFrame)
                CpLbl.Text = Text
                CpLbl.Size = UDim2.new(1, 0, 1, 0)
                CpLbl.TextColor3 = Library.TextColor
                CpLbl.Font = Library.Font
                CpLbl.TextSize = 12
                CpLbl.TextXAlignment = Enum.TextXAlignment.Left
                CpLbl.BackgroundTransparency = 1

                CpBox.Size = UDim2.fromOffset(26, 16)
                CpBox.Position = UDim2.new(1, -26, 0.5, -8)
                CpBox.BackgroundColor3 = Default or Library.Accent
                Instance.new("UICorner", CpBox).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", CpBox).Color = Color3.fromRGB(60, 60, 60)

                CpPicker.Name = "ColorPicker"
                CpPicker.Size = UDim2.fromOffset(220, 220)
                CpPicker.Position = UDim2.new(0.5, -110, 0.5, -110)
                CpPicker.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                CpPicker.Visible = false
                CpPicker.ZIndex = 1000
                PickerCorner.CornerRadius = UDim.new(0, 6)
                Instance.new("UIStroke", CpPicker).Color = Color3.fromRGB(45, 45, 45)

                MakeDraggable(CpPicker, CpPicker)

                local PickerTitle = Instance.new("TextLabel", CpPicker)
                PickerTitle.Text = Text
                PickerTitle.Size = UDim2.new(1, -10, 0, 30)
                PickerTitle.Position = UDim2.fromOffset(10, 5)
                PickerTitle.TextColor3 = Color3.new(1, 1, 1)
                PickerTitle.Font = Library.Font
                PickerTitle.TextSize = 13
                PickerTitle.TextXAlignment = Enum.TextXAlignment.Left
                PickerTitle.BackgroundTransparency = 1

                local SvPicker = Instance.new("ImageButton", CpPicker)
                SvPicker.Size = UDim2.new(1, -20, 0, 150)
                SvPicker.Position = UDim2.fromOffset(10, 40)
                SvPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                SvPicker.AutoButtonColor = false
                Instance.new("UICorner", SvPicker).CornerRadius = UDim.new(0, 4)

                local SvWhite = Instance.new("Frame", SvPicker)
                SvWhite.Size = UDim2.fromScale(1, 1)
                SvWhite.BackgroundColor3 = Color3.new(1, 1, 1)
                SvWhite.BackgroundTransparency = 0
                Instance.new("UICorner", SvWhite).CornerRadius = UDim.new(0, 4)
                local SvWhiteGrad = Instance.new("UIGradient", SvWhite)
                SvWhiteGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                SvWhiteGrad.Rotation = 90

                local SvBlack = Instance.new("Frame", SvPicker)
                SvBlack.Size = UDim2.fromScale(1, 1)
                SvBlack.BackgroundColor3 = Color3.new(0, 0, 0)
                SvBlack.BackgroundTransparency = 0
                Instance.new("UICorner", SvBlack).CornerRadius = UDim.new(0, 4)
                local SvBlackGrad = Instance.new("UIGradient", SvBlack)
                SvBlackGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })

                local SvCursor = Instance.new("Frame", SvPicker)
                SvCursor.Size = UDim2.fromOffset(8, 8)
                SvCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SvCursor.Position = UDim2.fromScale(1, 0)
                SvCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SvCursor.BorderSizePixel = 0
                Instance.new("UICorner", SvCursor).CornerRadius = UDim.new(1, 0)
                Instance.new("UIStroke", SvCursor).Color = Color3.new(0, 0, 0)

                local CurrentHue = 0
                local CurrentSat = 1
                local CurrentVal = 1

                local function HsvToRgb(H, S, V)
                    local R, G, B
                    local I = math.floor(H * 6)
                    local F = H * 6 - I
                    local P = V * (1 - S)
                    local Q = V * (1 - F * S)
                    local T = V * (1 - (1 - F) * S)
                    I = I % 6

                    if I == 0 then R, G, B = V, T, P
                    elseif I == 1 then R, G, B = Q, V, P
                    elseif I == 2 then R, G, B = P, V, T
                    elseif I == 3 then R, G, B = P, Q, V
                    elseif I == 4 then R, G, B = T, P, V
                    elseif I == 5 then R, G, B = V, P, Q
                    end

                    return Color3.fromRGB(R * 255, G * 255, B * 255)
                end

                local function UpdateColor()
                    local Color = HsvToRgb(CurrentHue, CurrentSat, CurrentVal)
                    CpBox.BackgroundColor3 = Color
                    Callback(Color)
                end

                local HueBar = Instance.new("Frame", CpPicker)
                HueBar.Size = UDim2.new(1, -20, 0, 12)
                HueBar.Position = UDim2.fromOffset(10, 200)
                HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
                Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

                local HueGrad = Instance.new("UIGradient", HueBar)
                HueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })

                local HueCursor = Instance.new("Frame", HueBar)
                HueCursor.Size = UDim2.fromOffset(4, 16)
                HueCursor.Position = UDim2.new(0, -2, 0.5, -8)
                HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                HueCursor.BorderSizePixel = 0
                Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0, 2)
                Instance.new("UIStroke", HueCursor).Color = Color3.new(0, 0, 0)

                local HueSelecting = false

                local function UpdateHue(Input)
                    local PosX = math.clamp((Input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                    CurrentHue = PosX
                    HueCursor.Position = UDim2.new(PosX, -2, 0.5, -8)
                    SvPicker.BackgroundColor3 = HsvToRgb(CurrentHue, 1, 1)
                    UpdateColor()
                end

                HueBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        HueSelecting = true
                        UpdateHue(Input)
                    end
                end)

                HueBar.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        HueSelecting = false
                    end
                end)

                HueBar.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement and HueSelecting then
                        UpdateHue(Input)
                    end
                end)

                local SvDragging = false
                SvPicker.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SvDragging = true
                        local PosX = math.clamp((Input.Position.X - SvPicker.AbsolutePosition.X) / SvPicker.AbsoluteSize.X, 0, 1)
                        local PosY = math.clamp((Input.Position.Y - SvPicker.AbsolutePosition.Y) / SvPicker.AbsoluteSize.Y, 0, 1)

                        CurrentSat = PosX
                        CurrentVal = 1 - PosY

                        SvCursor.Position = UDim2.fromScale(PosX, PosY)
                        UpdateColor()
                    end
                end)

                SvPicker.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SvDragging = false
                    end
                end)

                local function UpdateSv(Input)
                    local PosX = math.clamp((Input.Position.X - SvPicker.AbsolutePosition.X) / SvPicker.AbsoluteSize.X, 0, 1)
                    local PosY = math.clamp((Input.Position.Y - SvPicker.AbsolutePosition.Y) / SvPicker.AbsoluteSize.Y, 0, 1)

                    CurrentSat = PosX
                    CurrentVal = 1 - PosY

                    SvCursor.Position = UDim2.fromScale(PosX, PosY)
                    UpdateColor()
                end

                SvPicker.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement and SvDragging then
                        UpdateSv(Input)
                    end
                end)

                local PickerOpen = false
                CpBox.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        PickerOpen = not PickerOpen
                        CpPicker.Visible = PickerOpen
                    end
                end)

                UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and PickerOpen then
                        local Mouse = UserInputService:GetMouseLocation()
                        local PickerPos = CpPicker.AbsolutePosition
                        local PickerSize = CpPicker.AbsoluteSize

                        if Mouse.X < PickerPos.X or Mouse.X > PickerPos.X + PickerSize.X or
                           Mouse.Y < PickerPos.Y or Mouse.Y > PickerPos.Y + PickerSize.Y then
                            local BoxPos = CpBox.AbsolutePosition
                            local BoxSize = CpBox.AbsoluteSize

                            if not (Mouse.X >= BoxPos.X and Mouse.X <= BoxPos.X + BoxSize.X and
                                    Mouse.Y >= BoxPos.Y and Mouse.Y <= BoxPos.Y + BoxSize.Y) then
                                PickerOpen = false
                                CpPicker.Visible = false
                            end
                        end
                    end
                end)

                if Default then
                    CpBox.BackgroundColor3 = Default
                    Callback(Default)
                end
            end

            return Elements
        end
        return Tab
    end
    return Window
end

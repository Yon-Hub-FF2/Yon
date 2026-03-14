local UI = game:GetObjects("rbxassetid://133215015127433")[1]:Clone()
local Objects = UI.Objects

-- // Color Palette (edit here to retheme everything)
local Colors = {
    Accent       = Color3.fromRGB(0,  210, 255),   -- electric cyan
    AccentAlt    = Color3.fromRGB(130, 80, 255),   -- violet purple
    ToggleOn     = Color3.fromRGB(0,  210, 255),   -- cyan when active
    ToggleOff    = Color3.fromRGB(14,  16,  26),   -- deep navy when off
    SliderHead   = Color3.fromRGB(0,  210, 255),   -- cyan slider head
    TabSelected  = Color3.fromRGB(0,  210, 255),   -- tab highlight tint
    Surface      = Color3.fromRGB(10,  12,  20),   -- main dark background
    Elevated     = Color3.fromRGB(18,  20,  32),   -- slightly lifted surfaces
    TextPrimary  = Color3.fromRGB(220, 230, 255),  -- near-white with blue tint
    TextMuted    = Color3.fromRGB(110, 120, 160),  -- muted blue-grey
    Border       = Color3.fromRGB(40,  50,  90),   -- subtle border
    Notch        = Color3.fromRGB(0,  210, 255),   -- tab notch indicator
    ButtonHover  = Color3.fromRGB(20,  22,  40),   -- button hover surface
}

local riff = {
    Toggled = false,
    ToggleKey = Enum.KeyCode.LeftControl
}

riff.__index = riff

local SelectedTab;

local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui    = game:GetService("CoreGui")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Tabs     = {}
local TabIndex = 1
local Old
local Size = workspace.CurrentCamera.ViewportSize

-- // Tween infos — snappier "out" for techy feel, smooth "inout" for transitions
local ti = {
    ["in"]    = TweenInfo.new(0.6, Enum.EasingStyle.Quart,       Enum.EasingDirection.In),
    ["out"]   = TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    ["inout"] = TweenInfo.new(0.7,  Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
    ["notch"] = TweenInfo.new(0.45, Enum.EasingStyle.Quart,       Enum.EasingDirection.Out),
    ["tab"]   = TweenInfo.new(1.2,  Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    ["pop"]   = TweenInfo.new(0.35, Enum.EasingStyle.Back,        Enum.EasingDirection.Out),
}

local function padding(height)
    return (-18 + (height - 2) * (-24)) + height
end

function notchPos(index)
    return 0.222 + (index - 1) * 0.133
end

local function uiscale(size)
    local scales = {
        {Vector2.new(1920, 1080), 1.6},
        {Vector2.new(1366, 768),  1},
        {Vector2.new(780,  360),  0.65},
        {Vector2.new(568,  320),  0.57},
        {Vector2.new(3840, 2160), 3.5},
    }
    local width    = size.X
    local minWidth = scales[#scales][1].X
    local maxWidth = scales[1][1].X
    return scales[#scales][2] + (scales[1][2] - scales[#scales][2]) * (width - minWidth) / (maxWidth - minWidth)
end

-- // Utility: tween a color property cleanly
local function tweenColor(obj, prop, color, info)
    local goal = {}
    goal[prop] = color
    TweenService:Create(obj, info or ti["out"], goal):Play()
end

function riff:Create(settings)

    settings = settings or { Name = "riff" }

    local gui = Instance.new("ScreenGui")
    gui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui")
    gui.Name          = settings.Name
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn  = false
    gui.Enabled       = true

    local Main = UI.Main:Clone()
    Main.Position = UDim2.new(0.5, 0, 1.5, 0)
    task.wait()
    Main.Parent  = gui

    -- // Apply surface colors to the window chrome
    if Main:FindFirstChild("BackgroundColor") then
        Main.BackgroundColor3 = Colors.Surface
    end

    Main.Title.Text      = settings.Name
    Main.Title.TextColor3 = Colors.TextPrimary
    Main.Visible          = true

    TweenService:Create(Main, ti["out"], {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

    local Window = {
        Root             = Main,
        OriginalPosition = UDim2.new(0.5, 0, 0.5, 0),
        Screen           = Vector2.new(Size.X, Size.Y)
    }

    print(uiscale(Window.Screen))
    Main.UIScale.Scale = uiscale(Window.Screen)

    -- // Style the notch with accent color
    if Main:FindFirstChild("Notch") then
        Main.Notch.BackgroundColor3 = Colors.Notch
    end

    function Window:Toggle()
        if not self.Toggled then
            self.OriginalPosition = Main.Position
        end

        self.Toggled = not self.Toggled

        if self.Toggled then
            TweenService:Create(Main, ti["inout"], {
                Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset, 1.5, 0)
            }):Play()
        else
            TweenService:Create(Main, ti["out"], {
                Position = self.OriginalPosition
            }):Play()
        end
    end

    Main.Close.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)

    if self.ToggleKey then
        UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == self.ToggleKey then
                Window:Toggle()
            end
        end)
    end

    function Window:Tab(settings)
        settings = settings or {
            Name = "Tab",
            Icon = "rbxassetid://1"
        }

        local TabRoot = Objects.Tab:Clone()
        TabRoot.Name       = settings.Name
        TabRoot.Visible    = true
        TabRoot.Parent     = self.Root.Tabs
        TabRoot.Icon.Image = settings.Icon
        TabRoot.Button.Text = settings.Name

        -- Apply techy tab styling
        TabRoot.Button.TextColor3 = Colors.TextMuted

        local TabContainer = Objects.TabContainer:Clone()
        TabContainer.Name   = settings.Name
        TabContainer.Parent = self.Root.Container
        TabContainer.Title.TextLabel.Text       = settings.Name
        TabContainer.Title.TextLabel.TextColor3 = Colors.Accent

        local Tab = {
            Root      = TabRoot,
            Container = TabContainer,
        }

        table.insert(Tabs, TabRoot)
        Main.Notch.Visible = true

        function Tab:Activate()
            if SelectedTab then
                -- Deactivate old tab: fade button, dim text
                TweenService:Create(SelectedTab.Root.Button, ti["tab"], {
                    BackgroundTransparency = 1,
                    TextColor3             = Colors.TextMuted,
                }):Play()
                SelectedTab.Root.Button.FontFace = Font.new(
                    "rbxasset://fonts/families/Montserrat.json",
                    Enum.FontWeight.Regular,
                    Enum.FontStyle.Normal
                )
                SelectedTab.Container.Visible = false
            end

            -- Activate new tab: subtle cyan tint + bold
            TweenService:Create(self.Root.Button, ti["tab"], {
                BackgroundTransparency = 0.88,
                BackgroundColor3       = Colors.Accent,
                TextColor3             = Colors.Accent,
            }):Play()
            self.Root.Button.FontFace = Font.new(
                "rbxasset://fonts/families/Montserrat.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            )
            self.Container.Visible = true
            SelectedTab = self

            if table.find(Tabs, SelectedTab.Root) then
                TabIndex = table.find(Tabs, SelectedTab.Root)

                -- Notch animation: expand → slide → contract
                local t2 = TweenService:Create(Main.Notch, ti["notch"], {
                    Size             = UDim2.new(0.007, 0, 0.12, 0),
                    BackgroundColor3 = Colors.Notch,
                })
                if Old then Old.Visible = false end
                Main.Notch.Visible = true
                t2:Play()

                local t1 = TweenService:Create(Main.Notch, ti["inout"], {
                    Position = UDim2.new(0.012, 0, notchPos(TabIndex), 0)
                })
                t1:Play()

                local t3 = TweenService:Create(Main.Notch, ti["notch"], {
                    Size = UDim2.new(0.007, 0, 0.05, 0)
                })

                t2.Completed:Connect(function()
                    task.delay(0.04, function()
                        t3:Play()
                        t3.Completed:Connect(function()
                            Old         = Tabs[TabIndex].Notch
                            Old.Visible = true
                            -- Tint the per-tab notch dot with accent color
                            Old.BackgroundColor3 = Colors.Notch
                            Main.Notch.Visible   = false
                        end)
                    end)
                end)
            end
        end

        if not SelectedTab then
            Tab:Activate()
        end

        TabRoot.Button.MouseButton1Click:Connect(function()
            Tab:Activate()
        end)

        -- // Button
        function Tab:Button(settings)
            settings = settings or {
                Name     = "Button",
                Callback = function() print("button pressed!") end
            }

            local Button = Objects.Button:Clone()
            Button.Parent   = TabContainer.Items
            Button.Name     = settings.Name
            Button.Visible  = true
            Button.TextButton.Text      = settings.Name
            Button.TextButton.TextColor3 = Colors.TextPrimary

            -- Hover: cyan tint flash
            Button.TextButton.MouseEnter:Connect(function()
                TweenService:Create(Button.TextButton, ti["pop"], {
                    TextColor3 = Colors.Accent
                }):Play()
            end)
            Button.TextButton.MouseLeave:Connect(function()
                TweenService:Create(Button.TextButton, ti["pop"], {
                    TextColor3 = Colors.TextPrimary
                }):Play()
            end)

            Button.TextButton.MouseButton1Click:Connect(settings.Callback)
        end

        -- // Toggle
        function Tab:Toggle(settings)
            settings = settings or {
                Name         = "Toggle",
                Callback     = function(v) if v then print("on") else print("off") end end,
                DefaultState = false
            }

            local Toggle = Objects.Toggle.Toggle:Clone()
            Toggle.Parent      = TabContainer.Items
            Toggle.Name        = settings.Name
            Toggle.Visible     = true
            Toggle.Title.Text  = settings.Name
            Toggle.Title.TextColor3 = Colors.TextPrimary

            local Part = Objects.Toggle.Part:Clone()
            Part.Parent  = Toggle
            Part.Visible = true

            local state = settings.DefaultState

            local function upd()
                if state then
                    -- ON: electric cyan
                    TweenService:Create(Part.Button.Head, ti["out"], {
                        AnchorPoint = Vector2.new(0.9, 0.5),
                        Position    = UDim2.new(0.9, 0, 0.5, 0),
                        BackgroundColor3 = Colors.Surface,
                    }):Play()
                    TweenService:Create(Part.Button, ti["out"], {
                        BackgroundColor3 = Colors.ToggleOn
                    }):Play()
                else
                    -- OFF: deep navy
                    TweenService:Create(Part.Button.Head, ti["out"], {
                        AnchorPoint = Vector2.new(0.1, 0.5),
                        Position    = UDim2.new(0.1, 0, 0.5, 0),
                        BackgroundColor3 = Colors.TextMuted,
                    }):Play()
                    TweenService:Create(Part.Button, ti["out"], {
                        BackgroundColor3 = Colors.ToggleOff
                    }):Play()
                end
            end

            upd()

            Part.Button.MouseButton1Click:Connect(function()
                state = not state
                upd()
                settings.Callback(state)
            end)
        end

        -- // Slider
        function Tab:Slider(settings)
            settings = settings or {
                Name     = "Slider",
                Default  = 30,
                Min      = 0,
                Max      = 100,
                Callback = function(val) print(val) end
            }

            local Slider = Objects.Slider.Slider:Clone()
            Slider.Visible      = true
            Slider.Parent       = TabContainer.Items
            Slider.Name         = settings.Name
            Slider.Title.Text   = settings.Name
            Slider.Title.TextColor3 = Colors.TextPrimary

            local Part = Objects.Slider.Part:Clone()
            Part.Parent  = Slider
            Part.Visible = true

            -- Accent the track head with cyan
            if Part:FindFirstChild("Track") and Part.Track:FindFirstChild("Head") then
                Part.Track.Head.BackgroundColor3 = Colors.Accent
            end
            if Part:FindFirstChild("Value") then
                Part.Value.TextColor3 = Colors.Accent
            end

            local down = false

            Part.Track.Head.MouseButton1Down:Connect(function()
                down = true
                while RunService.RenderStepped:Wait() and down do
                    local percentage = math.clamp(
                        (LocalPlayer:GetMouse().X - Part.Track.AbsolutePosition.X) / Part.Track.AbsoluteSize.X,
                        0, 1.00
                    )
                    local value = ((settings.Max - settings.Min) * percentage) + settings.Min
                    local pos   = math.clamp(percentage, -0.2, 1.1)
                    Part.Track.Head.AnchorPoint = Vector2.new(pos, 0.5)
                    Part.Track.Head.Position    = UDim2.new(pos, 0, 0.5, 0)
                    value = math.floor(value)
                    Part.Value.Text = value
                    settings.Callback(value)
                end
            end)

            UIS.InputEnded:Connect(function(key)
                if key.UserInputType == Enum.UserInputType.MouseButton1 then
                    down = false
                end
            end)
        end

        -- // Dropdown
        function Tab:Dropdown(settings)
            settings = settings or {
                Name     = "Dropdown",
                Items    = {"Option 1", "Option 2", "Option 3", "4", "5", "6", "7", "8"},
                Default  = "Option 1",
                Callback = function(selected) print("Selected: " .. selected) end
            }

            local IdxItem    = #settings.Items
            local SelectedItem = settings.Default

            local Dropdown = Objects.Dropdown.Dropdown:Clone()
            Dropdown.Visible       = true
            Dropdown.Parent        = TabContainer.Items
            Dropdown.Name          = settings.Name
            Dropdown.Title.Text    = settings.Name
            Dropdown.Title.TextColor3 = Colors.TextPrimary

            local Part = Objects.Dropdown.Part:Clone()
            Part.Parent  = Dropdown
            Part.Visible = true
            Part.Text    = SelectedItem

            -- Style dropdown button with accent border
            Part.BackgroundColor3    = Colors.Elevated
            Part.TextColor3          = Colors.TextPrimary
            if Part:FindFirstChild("UIStroke") then
                Part.UIStroke.Color = Colors.Border
            end

            Part.Items.Size = UDim2.new(1.214, 0, 0, 0)

            local UIPageLayout = Part.Items.UIPageLayout
            local UIListLayout = Objects.UIListLayout:Clone()
            UIPageLayout.Padding = UDim.new(0.03, padding(IdxItem))

            for idx, item in pairs(settings.Items) do
                local button = Objects.Dropdown.Button:Clone()
                button.Parent  = Part.Items
                button.Size    = UDim2.new(0.95, 0, 1 / IdxItem, 0)
                button.Text    = item
                button.Name    = item
                button.Visible = true

                -- Techy item styling
                button.TextColor3       = Colors.TextMuted
                button.BackgroundColor3 = Colors.Elevated

                -- Hover effect
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, ti["pop"], {
                        TextColor3 = Colors.Accent
                    }):Play()
                end)
                button.MouseLeave:Connect(function()
                    if SelectedItem ~= button then
                        TweenService:Create(button, ti["pop"], {
                            TextColor3 = Colors.TextMuted
                        }):Play()
                    end
                end)

                if settings.Default == item then
                    SelectedItem              = button
                    Part.Text                 = item
                    button.FontFace           = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                    button.TextColor3         = Colors.Accent
                    button.Notch.Visible      = true
                    button.Notch.BackgroundColor3 = Colors.Accent
                end

                button.MouseButton1Click:Connect(function()
                    if SelectedItem then
                        SelectedItem.Notch.Visible = false
                        TweenService:Create(SelectedItem, ti["pop"], {
                            TextColor3 = Colors.TextMuted
                        }):Play()
                        SelectedItem.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                    end

                    SelectedItem                       = button
                    SelectedItem:WaitForChild("Notch").Visible           = true
                    SelectedItem:WaitForChild("Notch").BackgroundColor3  = Colors.Accent
                    SelectedItem.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                    TweenService:Create(SelectedItem, ti["pop"], {
                        TextColor3 = Colors.Accent
                    }):Play()
                    Part.Text = item
                    settings.Callback(item)
                end)
            end

            UIPageLayout.Parent = nil
            UIListLayout.Parent = Part.Items

            local vis = false

            Part.MouseButton1Click:Connect(function()
                Part.Items.Visible = true
                task.wait()
                vis = not vis

                UIPageLayout.Parent = nil
                UIListLayout.Parent = Part.Items

                if vis then
                    local t = TweenService:Create(Part.Items, ti["out"], {
                        Size = UDim2.new(1.214, 0, IdxItem, 0)
                    })
                    t:Play()
                    t.Completed:Connect(function()
                        UIListLayout.Parent = nil
                        UIPageLayout.Parent = Part.Items
                    end)
                else
                    UIPageLayout.Parent = nil
                    UIListLayout.Parent = Part.Items
                    TweenService:Create(Part.Items, ti["out"], {
                        Size = UDim2.new(1.214, 0, 0, 0)
                    }):Play()
                end
            end)
        end

        -- // Section
        function Tab:Section(settings)
            settings = settings or { Text = "Section" }

            local Section = Objects.Section:Clone()
            Section.Text      = settings.Text
            Section.Visible   = true
            Section.Parent    = TabContainer.Items

            -- Accent-colored section label
            Section.TextColor3 = Colors.AccentAlt
            Section.FontFace   = Font.new(
                "rbxasset://fonts/families/Montserrat.json",
                Enum.FontWeight.SemiBold,
                Enum.FontStyle.Normal
            )
        end

        return Tab
    end

    return Window
end

return riff

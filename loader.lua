-- ✅ Load Rayfield GUI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/VeneraScript/fullpower/main/uinterface.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Venerable HUB",
    LoadingTitle = "Initializing...",
    LoadingSubtitle = "by Gween & Nier",
    ConfigurationSaving = {
        Enabled = false
    }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ✅ Inisialisasi ESP
local ESP = {
    Players = false,
    Mobs = false,
    Objects = setmetatable({}, {__mode = "kv"}),
    Colors = {
        Players = Color3.fromRGB(0, 200, 255),
        Unicorn = Color3.fromRGB(255, 182, 193),
        Outlaw = Color3.fromRGB(255, 0, 0),
        Wolf = Color3.fromRGB(160, 160, 160),
        Werewolf = Color3.fromRGB(100, 100, 100),
        Vampire = Color3.fromRGB(128, 0, 128)
    }
}

-- ✅ Fungsi buat line ESP
local function CreateLine(color)
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Transparency = 1
    line.Color = color
    line.Visible = false
    return line
end

local function CreateText(color, size)
    local text = Drawing.new("Text")
    text.Size = size
    text.Color = color
    text.Center = true
    text.Outline = true
    text.Visible = false
    return text
end

-- ✅ Tracking objek
function ESP:TrackObject(obj, data)
    if not obj or not obj:IsA("Model") or self.Objects[obj] then return end
    local root = data.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local color = data.Color or self.Colors.Players

    local box = {
        Object = obj,
        PrimaryPart = root,
        Name = data.Name or obj.Name,
        IsPlayer = data.IsPlayer or false,
        Drawings = {
            TL = CreateLine(color),
            TR = CreateLine(color),
            BL = CreateLine(color),
            BR = CreateLine(color),
            Name = CreateText(color, 19),
            Distance = CreateText(color, 19)
        },
        Connections = {}
    }

    box.Connections.ancestry = obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil then self:UntrackObject(obj) end
    end)

    box.Connections.primary = root:GetPropertyChangedSignal("Parent"):Connect(function()
        if not root.Parent then self:UntrackObject(obj) end
    end)

    self.Objects[obj] = box
end

function ESP:UntrackObject(obj)
    local box = self.Objects[obj]
    if not box then return end

    for _, d in pairs(box.Drawings) do
        if typeof(d) == "Instance" or typeof(d) == "Drawing" then
            d:Remove()
        end
    end

    for _, conn in pairs(box.Connections) do
        conn:Disconnect()
    end

    self.Objects[obj] = nil
end

function ESP:UpdateAll()
    for obj, box in pairs(self.Objects) do
        if not obj or not box.PrimaryPart or not obj:IsDescendantOf(game) then
            self:UntrackObject(obj)
        end
    end
end

-- ✅ Loop render ESP
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    for obj, box in pairs(ESP.Objects) do
        local root = box.PrimaryPart
        if not root then continue end

        local pos, onScreen = cam:WorldToViewportPoint(root.Position)
        local show = (box.IsPlayer and ESP.Players) or (not box.IsPlayer and ESP.Mobs)

        if onScreen and show then
            local size = Vector3.new(4, 6, 0)
            local corners = {
                cam:WorldToViewportPoint((root.CFrame * CFrame.new(-2, -3, 0)).Position),
                cam:WorldToViewportPoint((root.CFrame * CFrame.new(2, -3, 0)).Position),
                cam:WorldToViewportPoint((root.CFrame * CFrame.new(-2, 3, 0)).Position),
                cam:WorldToViewportPoint((root.CFrame * CFrame.new(2, 3, 0)).Position)
            }

            box.Drawings.TL.From = Vector2.new(corners[1].X, corners[1].Y)
            box.Drawings.TL.To   = Vector2.new(corners[2].X, corners[2].Y)

            box.Drawings.BL.From = Vector2.new(corners[3].X, corners[3].Y)
            box.Drawings.BL.To   = Vector2.new(corners[4].X, corners[4].Y)

            box.Drawings.TR.From = Vector2.new(corners[1].X, corners[1].Y)
            box.Drawings.TR.To   = Vector2.new(corners[3].X, corners[3].Y)

            box.Drawings.BR.From = Vector2.new(corners[2].X, corners[2].Y)
            box.Drawings.BR.To   = Vector2.new(corners[4].X, corners[4].Y)

            for _, l in ipairs({box.Drawings.TL, box.Drawings.BL, box.Drawings.TR, box.Drawings.BR}) do
                l.Visible = true
            end

            box.Drawings.Name.Text = box.Name
            box.Drawings.Name.Position = Vector2.new(pos.X, pos.Y - 30)
            box.Drawings.Name.Visible = true

            local dist = LocalPlayer:FindFirstChild("Character") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = dist and (dist.Position - root.Position).Magnitude or 0

            box.Drawings.Distance.Text = string.format("%.1f m", distance)
            box.Drawings.Distance.Position = Vector2.new(pos.X, pos.Y - 10)
            box.Drawings.Distance.Visible = true
        else
            for _, d in pairs(box.Drawings) do
                d.Visible = false
            end
        end
    end
end)

-- ✅ Tracking Player
local function TrackPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        local root = char:WaitForChild("HumanoidRootPart", 3)
        if root then
            ESP:TrackObject(char, {
                IsPlayer = true,
                Name = p.DisplayName or p.Name,
                Color = ESP.Colors.Players,
                PrimaryPart = root
            })
        end
    end)
    if p.Character then
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if root then
            ESP:TrackObject(p.Character, {
                IsPlayer = true,
                Name = p.DisplayName or p.Name,
                Color = ESP.Colors.Players,
                PrimaryPart = root
            })
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do TrackPlayer(p) end
Players.PlayerAdded:Connect(TrackPlayer)

-- ✅ Tracking Mob
local mobTypes = {
    ["unicorn"] = ESP.Colors.Unicorn,
    ["outlaw"] = ESP.Colors.Outlaw,
    ["wolf"] = ESP.Colors.Wolf,
    ["werewolf"] = ESP.Colors.Werewolf,
    ["vampire"] = ESP.Colors.Vampire
}

local function TrackMob(mob)
    if not mob:IsA("Model") then return end
    if ESP.Objects[mob] then return end
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local root = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    for name, color in pairs(mobTypes) do
        if mob.Name:lower():find(name) then
            ESP:TrackObject(mob, {
                Name = mob.Name,
                Color = color,
                PrimaryPart = root
            })
            break
        end
    end
end

for _, mob in ipairs(workspace:GetDescendants()) do
    TrackMob(mob)
end

workspace.DescendantAdded:Connect(function(mob)
    task.wait(0.1)
    TrackMob(mob)
end)

-- ✅ UI Toggle
VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(val)
        ESP.Players = val
    end
})

VisualTab:CreateToggle({
    Name = "Mobs ESP",
    CurrentValue = false,
    Callback = function(val)
        ESP.Mobs = val
    end
})

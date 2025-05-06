-- ✅ Inisialisasi Rayfield GUI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/VeneraScript/fullpower/main/uinterface.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Venerable HUB",
    LoadingTitle = "Loading ESP...",
    LoadingSubtitle = "by Gween & Nier",
    ConfigurationSaving = {
        Enabled = false
    }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ✅ Drawing ESP Sistem Sederhana & Stabil
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPSettings = {
    Players = false,
    Mobs = false,
    Color = Color3.fromRGB(0, 255, 255),
    Tracked = {}
}

local function CreateESP(model, name, color)
    local text = Drawing.new("Text")
    text.Center = true
    text.Outline = true
    text.Size = 17
    text.Color = color or ESPSettings.Color
    text.Visible = false

    ESPSettings.Tracked[model] = {
        Drawing = text,
        Name = name
    }
end

local function RemoveESP(model)
    local tracked = ESPSettings.Tracked[model]
    if tracked then
        tracked.Drawing:Remove()
        ESPSettings.Tracked[model] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for model, info in pairs(ESPSettings.Tracked) do
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsDescendantOf(workspace) then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen and ((ESPSettings.Players and Players:GetPlayerFromCharacter(model)) or (ESPSettings.Mobs and not Players:GetPlayerFromCharacter(model))) then
                info.Drawing.Position = Vector2.new(pos.X, pos.Y - 15)
                info.Drawing.Text = info.Name
                info.Drawing.Visible = true
            else
                info.Drawing.Visible = false
            end
        else
            RemoveESP(model)
        end
    end
end)

-- ✅ Tracking Pemain
local function TrackPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            CreateESP(char, player.DisplayName or player.Name, Color3.fromRGB(0, 255, 255))
        end
    end)
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            CreateESP(player.Character, player.DisplayName or player.Name, Color3.fromRGB(0, 255, 255))
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    TrackPlayer(player)
end
Players.PlayerAdded:Connect(TrackPlayer)

-- ✅ Tracking Mobs Otomatis
local mobKeywords = {"unicorn", "wolf", "outlaw", "werewolf", "vampire"}
local function IsMob(model)
    local lower = model.Name:lower()
    for _, keyword in ipairs(mobKeywords) do
        if lower:find(keyword) then
            return true
        end
    end
    return false
end

local function TrackMobs()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not ESPSettings.Tracked[obj] then
            if not Players:GetPlayerFromCharacter(obj) and IsMob(obj) then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    CreateESP(obj, obj.Name, Color3.fromRGB(255, 100, 100))
                end
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
        if not Players:GetPlayerFromCharacter(obj) and IsMob(obj) then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then
                CreateESP(obj, obj.Name, Color3.fromRGB(255, 100, 100))
            end
        end
    end
end)

-- ✅ GUI Toggle
VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(state)
        ESPSettings.Players = state
    end,
})

VisualTab:CreateToggle({
    Name = "Mobs ESP",
    CurrentValue = false,
    Callback = function(state)
        ESPSettings.Mobs = state
        if state then
            TrackMobs()
        end
    end,
})

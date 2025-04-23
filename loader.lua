-- ✅ Inisialisasi Rayfield GUI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/VeneraScript/fullpower/main/uinterface.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Venera ESP GUI",
    LoadingTitle = "Initializing...",
    LoadingSubtitle = "by VeneraScript",
    ConfigurationSaving = {
        Enabled = false
    }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ✅ Sistem ESP yang Lebih Stabil
local ESP = {
    Players = false,
    Mobs = false,
    Objects = setmetatable({}, {__mode = "kv"}), -- Weak table untuk garbage collection
    Colors = {
        Players = Color3.fromRGB(0, 200, 255),
        Unicorn = Color3.fromRGB(255, 182, 193),
        Outlaw = Color3.fromRGB(255, 0, 0),
        Wolf = Color3.fromRGB(160, 160, 160),
        Werewolf = Color3.fromRGB(100, 100, 100),
        Vampire = Color3.fromRGB(128, 0, 128)
    }
}

-- Sistem Drawing yang Dioptimalkan
local drawings = {}
local function CreateDrawing(type, props)
    local drawing = Drawing.new(type)
    for prop, value in pairs(props) do
        drawing[prop] = value
    end
    table.insert(drawings, drawing)
    return drawing
end

-- Sistem ESP Object yang Lebih Kuat
function ESP:TrackObject(obj, options)
    if not obj or not obj.Parent then return end
    if self.Objects[obj] then return end -- Skip jika sudah ada
    
    local box = {
        Object = obj,
        Player = options.Player,
        PrimaryPart = options.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"),
        Name = options.Name or obj.Name,
        Color = options.Color or self.Colors.Players,
        Drawings = {
            Box = CreateDrawing("Quad", {
                Thickness = 2,
                Color = options.Color or self.Colors.Players,
                Transparency = 1,
                Filled = false,
                Visible = false
            }),
            Name = CreateDrawing("Text", {
                Text = options.Name or obj.Name,
                Color = options.Color or self.Colors.Players,
                Center = true,
                Outline = true,
                Size = 19,
                Visible = false
            }),
            Distance = CreateDrawing("Text", {
                Color = options.Color or self.Colors.Players,
                Center = true,
                Outline = true,
                Size = 19,
                Visible = false
            })
        },
        Connections = {}
    }
    
    if not box.PrimaryPart then
        for _, drawing in pairs(box.Drawings) do
            drawing:Remove()
        end
        return
    end
    
    -- Sistem tracking yang lebih baik
    box.Connections.ancestry = obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            self:UntrackObject(obj)
        end
    end)
    
    box.Connections.primaryPart = box.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
        if not box.PrimaryPart or not box.PrimaryPart.Parent then
            self:UntrackObject(obj)
        end
    end)
    
    self.Objects[obj] = box
    self:UpdateObjectVisibility(box)
    return box
end

function ESP:UntrackObject(obj)
    if not self.Objects[obj] then return end
    
    local box = self.Objects[obj]
    
    -- Hapus semua koneksi
    for _, conn in pairs(box.Connections) do
        conn:Disconnect()
    end
    
    -- Hapus semua drawing
    for _, drawing in pairs(box.Drawings) do
        drawing:Remove()
    end
    
    self.Objects[obj] = nil
end

function ESP:UpdateObjectVisibility(box)
    if not box or not box.Object or not box.PrimaryPart then return end
    
    local visible = (box.Player and self.Players) or (not box.Player and self.Mobs)
    
    for _, drawing in pairs(box.Drawings) do
        drawing.Visible = visible
    end
end

function ESP:UpdateAllVisibility()
    for obj, box in pairs(self.Objects) do
        if obj and obj.Parent and box.PrimaryPart and box.PrimaryPart.Parent then
            self:UpdateObjectVisibility(box)
        else
            self:UntrackObject(obj)
        end
    end
end

-- Player ESP dengan sistem yang lebih baik
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function TrackPlayer(player)
    if player == LocalPlayer then return end
    
    local function HandleCharacter(char)
        if not char then return end
        
        local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 2)
        if humanoidRootPart then
            ESP:TrackObject(char, {
                Player = player,
                Name = player.DisplayName or player.Name,
                Color = ESP.Colors.Players,
                PrimaryPart = humanoidRootPart
            })
        end
    end
    
    player.CharacterAdded:Connect(HandleCharacter)
    if player.Character then
        HandleCharacter(player.Character)
    end
end

-- Inisialisasi player
for _, player in ipairs(Players:GetPlayers()) do
    TrackPlayer(player)
end
Players.PlayerAdded:Connect(TrackPlayer)

-- Sistem Mobs ESP yang benar-benar stabil
local mobTypes = {
    ["unicorn"] = ESP.Colors.Unicorn,
    ["outlaw"] = ESP.Colors.Outlaw,
    ["wolf"] = ESP.Colors.Wolf,
    ["werewolf"] = ESP.Colors.Werewolf,
    ["vampire"] = ESP.Colors.Vampire
}

local mobCache = {}
local function TrackMob(mob)
    if not mob or not mob:IsA("Model") or mobCache[mob] then return end
    
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local name = mob.Name:lower()
    local color
    
    for mobType, mobColor in pairs(mobTypes) do
        if name:find(mobType) then
            color = mobColor
            break
        end
    end
    
    if color then
        local humanoidRootPart = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChildWhichIsA("BasePart")
        if humanoidRootPart then
            mobCache[mob] = true
            ESP:TrackObject(mob, {
                Name = mob.Name,
                Color = color,
                PrimaryPart = humanoidRootPart
            })
            
            mob.AncestryChanged:Connect(function(_, parent)
                if parent == nil then
                    mobCache[mob] = nil
                end
            end)
        end
    end
end

-- Fungsi untuk scan ulang semua mob di workspace
local function FullMobScan()
    for _, mob in ipairs(workspace:GetDescendants()) do
        TrackMob(mob)
    end
end

-- Scan awal untuk mob yang sudah ada
FullMobScan()

-- Deteksi mob baru dengan sistem yang lebih baik
workspace.DescendantAdded:Connect(function(mob)
    -- Tunggu sebentar untuk memastikan model terload sepenuhnya
    wait(0.1)
    TrackMob(mob)
end)

-- Render loop yang dioptimalkan
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat

-- Tambahkan sistem refresh periodik untuk memastikan tidak ada mob yang terlewat
local lastScanTime = 0
local scanInterval = 5 -- Detik

heartbeat:Connect(function(deltaTime)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Update semua ESP objects
    for obj, box in pairs(ESP.Objects) do
        if obj and obj.Parent and box.PrimaryPart and box.PrimaryPart.Parent then
            local position = box.PrimaryPart.Position
            local screenPosition, onScreen = camera:WorldToViewportPoint(position)
            
            if onScreen then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                    and (position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude 
                    or 0
                
                -- Update box
                if box.Drawings.Box then
                    local size = Vector3.new(4, 6, 0)
                    local corners = {
                        camera:WorldToViewportPoint((box.PrimaryPart.CFrame * CFrame.new(-size.X/2, -size.Y/2, 0)).p),
                        camera:WorldToViewportPoint((box.PrimaryPart.CFrame * CFrame.new(size.X/2, -size.Y/2, 0)).p),
                        camera:WorldToViewportPoint((box.PrimaryPart.CFrame * CFrame.new(size.X/2, size.Y/2, 0)).p),
                        camera:WorldToViewportPoint((box.PrimaryPart.CFrame * CFrame.new(-size.X/2, size.Y/2, 0)).p)
                    }
                    
                    if #corners == 4 then
                        box.Drawings.Box.PointA = Vector2.new(corners[1].X, corners[1].Y)
                        box.Drawings.Box.PointB = Vector2.new(corners[2].X, corners[2].Y)
                        box.Drawings.Box.PointC = Vector2.new(corners[3].X, corners[3].Y)
                        box.Drawings.Box.PointD = Vector2.new(corners[4].X, corners[4].Y)
                        box.Drawings.Box.Visible = (box.Player and ESP.Players) or (not box.Player and ESP.Mobs)
                    end
                end
                
                -- Update name dan distance
                if box.Drawings.Name then
                    box.Drawings.Name.Position = Vector2.new(screenPosition.X, screenPosition.Y - 30)
                    box.Drawings.Name.Text = box.Name
                    box.Drawings.Name.Visible = (box.Player and ESP.Players) or (not box.Player and ESP.Mobs)
                end
                
                if box.Drawings.Distance then
                    box.Drawings.Distance.Position = Vector2.new(screenPosition.X, screenPosition.Y - 10)
                    box.Drawings.Distance.Text = string.format("%.1f m", distance)
                    box.Drawings.Distance.Visible = (box.Player and ESP.Players) or (not box.Player and ESP.Mobs)
                end
            else
                if box.Drawings.Box then box.Drawings.Box.Visible = false end
                if box.Drawings.Name then box.Drawings.Name.Visible = false end
                if box.Drawings.Distance then box.Drawings.Distance.Visible = false end
            end
        else
            ESP:UntrackObject(obj)
        end
    end
    
    -- Lakukan scan ulang secara periodik
    lastScanTime = lastScanTime + deltaTime
    if lastScanTime >= scanInterval then
        lastScanTime = 0
        FullMobScan()
    end
end)

-- ✅ Toggle ESP
VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Players = Value
        ESP:UpdateAllVisibility()
    end,
})

VisualTab:CreateToggle({
    Name = "Mobs ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Mobs = Value
        ESP:UpdateAllVisibility()
        -- Lakukan scan ulang saat mengaktifkan mob ESP
        if Value then
            FullMobScan()
        end
    end,
})

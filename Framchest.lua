-- Script Auto Farm Chest (Ambil Semua Chest, Jauh/Dekat)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local function teleportAndLootChest(chest)
    -- Coba pakai Pathfinding dulu (agar tidak stuck)
    local path = game:GetService("PathfindingService"):CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
    path:ComputeAsync(HumanoidRootPart.Position, chest.Position)
    
    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in pairs(waypoints) do
            Humanoid:MoveTo(waypoint.Position)
            Humanoid.MoveToFinished:Wait()
        end
    else
        -- Jika pathfinding gagal, teleport langsung
        HumanoidRootPart.CFrame = chest.CFrame * CFrame.new(0, 3, 0)
    end
    
    -- Auto-klik chest
    if chest:FindFirstChild("ProximityPrompt") then
        fireproximityprompt(chest.ProximityPrompt)
    end
    task.wait(0.5) -- Delay biar tidak spam
end

-- Ambil SEMUA chest di map (termasuk yang jauh)
local function getAllChests()
    local chests = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name:lower():find("chest") or obj:FindFirstChild("ProximityPrompt")) and not table.find(chests, obj) then
            table.insert(chests, obj)
        end
    end
    return chests
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Main Loop (Ambil semua chest berulang)
while task.wait(1) do
    local allChests = getAllChests()
    if #allChests == 0 then
        warn("Tidak ada chest ditemukan! Menunggu...")
    else
        for _, chest in pairs(allChests) do
            teleportAndLootChest(chest)
            print("[+] Chest diambil:", chest.Name)
        end
        print("[✓] Semua chest diambil! Memulai lagi...")
    end
end

--!strict
-- Local firing logic for the demo carbine.

local tool = script.Parent :: Tool
local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fireEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("FireBullet")

local canFire = true
local fireCooldown = 0.1
local lastShot = 0

local function currentAmmoFolder()
  return player:WaitForChild("WeaponStats")
end

local function onActivated()
  if not canFire or tick() - lastShot < fireCooldown then
    return
  end

  local stats = currentAmmoFolder()
  local ammo = stats:FindFirstChild("Ammo") :: IntValue
  if ammo.Value <= 0 then
    return
  end

  ammo.Value -= 1
  lastShot = tick()

  local mouseRay = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
  local origin = mouseRay.Origin
  local direction = mouseRay.Direction

  fireEvent:FireServer(origin, direction, tool)
end

tool.Activated:Connect(onActivated)

UIS.InputBegan:Connect(function(input, processed)
  if processed then
    return
  end
  if input.KeyCode == Enum.KeyCode.R then
    local stats = currentAmmoFolder()
    local ammo = stats:FindFirstChild("Ammo") :: IntValue
    local reserve = stats:FindFirstChild("ReserveAmmo") :: IntValue
    local missing = 30 - ammo.Value
    local pulled = math.min(missing, reserve.Value)
    ammo.Value += pulled
    reserve.Value -= pulled
  end
end)

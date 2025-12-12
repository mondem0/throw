--!strict
-- Simple HUD for ammo and health.

local player = game:GetService("Players").LocalPlayer
local humanoid = player.CharacterAdded:Wait():WaitForChild("Humanoid") :: Humanoid
local stats = player:WaitForChild("WeaponStats")

local screenGui = script.Parent :: ScreenGui
local ammoLabel = screenGui:WaitForChild("AmmoLabel") :: TextLabel
local healthLabel = screenGui:WaitForChild("HealthLabel") :: TextLabel

local function updateAmmo()
  local ammo = stats:FindFirstChild("Ammo") :: IntValue
  local reserve = stats:FindFirstChild("ReserveAmmo") :: IntValue
  ammoLabel.Text = string.format("Ammo: %d / %d", ammo.Value, reserve.Value)
end

local function updateHealth()
  healthLabel.Text = string.format("Health: %d", math.floor(humanoid.Health))
end

stats.Ammo:GetPropertyChangedSignal("Value"):Connect(updateAmmo)
stats.ReserveAmmo:GetPropertyChangedSignal("Value"):Connect(updateAmmo)
humanoid.HealthChanged:Connect(function()
  updateHealth()
end)

updateAmmo()
updateHealth()

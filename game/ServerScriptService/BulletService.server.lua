--!strict
-- Server authority for bullet spawning and replication.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BulletPhysics = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BulletPhysics"))

local bulletManager = BulletPhysics.new()
bulletManager:connect()

local fireEvent = Instance.new("RemoteEvent")
fireEvent.Name = "FireBullet"
fireEvent.Parent = ReplicatedStorage:WaitForChild("Events")

local bulletTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Bullet") :: BasePart
local DEFAULT_DAMAGE = 25
local MUZZLE_VELOCITY = 300 -- studs/second
local MAX_BULLET_LIFE = 5

local function validateShooter(player: Player, tool: Tool?)
  if not tool then
    return false
  end
  local character = player.Character
  if not character then
    return false
  end
  return tool:IsDescendantOf(character)
end

fireEvent.OnServerEvent:Connect(function(player, origin: Vector3, direction: Vector3, tool: Tool?)
  if not validateShooter(player, tool) then
    return
  end

  local bullet = bulletTemplate:Clone()
  bullet:SetAttribute("Shooter", player.UserId)

  local velocity = direction.Unit * MUZZLE_VELOCITY
  bulletManager:spawn({
    Origin = origin,
    Velocity = velocity,
    Acceleration = Vector3.new(0, -workspace.Gravity, 0),
    MaxLife = MAX_BULLET_LIFE,
    Model = bullet,
    Shooter = player,
    Damage = DEFAULT_DAMAGE,
  })
end)

Players.PlayerAdded:Connect(function(player)
  local folder = Instance.new("Folder")
  folder.Name = "WeaponStats"
  folder.Parent = player

  local ammo = Instance.new("IntValue")
  ammo.Name = "Ammo"
  ammo.Value = 30
  ammo.Parent = folder

  local reserve = Instance.new("IntValue")
  reserve.Name = "ReserveAmmo"
  reserve.Value = 90
  reserve.Parent = folder
end)

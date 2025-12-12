--!strict
-- Handles bullet integration and collision helpers for the FPS example.
-- Assumes workspace.Gravity is set but allows override per bullet.

local RunService = game:GetService("RunService")

export type BulletParams = {
  Origin: Vector3,
  Velocity: Vector3,
  Acceleration: Vector3?,
  MaxLife: number,
  Model: BasePart,
  Shooter: Player,
  Damage: number,
}

export type BulletState = {
  part: BasePart,
  velocity: Vector3,
  acceleration: Vector3,
  life: number,
  maxLife: number,
  shooter: Player,
  damage: number,
}

local BulletPhysics = {}
BulletPhysics.__index = BulletPhysics

function BulletPhysics.new()
  return setmetatable({
    _active = {},
  }, BulletPhysics)
end

local function applyDamage(hit: BasePart, shooter: Player, damage: number)
  local character = hit:FindFirstAncestorWhichIsA("Model")
  local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
  if humanoid then
    humanoid:TakeDamage(damage)
  end
end

function BulletPhysics:spawn(params: BulletParams)
  local acceleration = params.Acceleration or Vector3.new(0, -workspace.Gravity, 0)
  local state: BulletState = {
    part = params.Model,
    velocity = params.Velocity,
    acceleration = acceleration,
    life = 0,
    maxLife = params.MaxLife,
    shooter = params.Shooter,
    damage = params.Damage,
  }
  state.part.CFrame = CFrame.new(params.Origin, params.Origin + params.Velocity)
  state.part.Anchored = true
  state.part.CanCollide = false
  state.part.Parent = workspace
  self._active[state.part] = state
end

function BulletPhysics:_step(dt: number)
  for part, state in pairs(self._active) do
    state.life += dt
    if state.life >= state.maxLife then
      part:Destroy()
      self._active[part] = nil
      continue
    end

    local lastPosition = part.Position
    state.velocity += state.acceleration * dt
    local newPosition = lastPosition + state.velocity * dt

    local direction = newPosition - lastPosition
    local result = workspace:Raycast(lastPosition, direction)
    if result then
      applyDamage(result.Instance, state.shooter, state.damage)
      part.CFrame = CFrame.new(result.Position)
      part:Destroy()
      self._active[part] = nil
    else
      part.CFrame = CFrame.new(newPosition, newPosition + state.velocity)
    end
  end
end

function BulletPhysics:connect()
  RunService.Heartbeat:Connect(function(dt)
    self:_step(dt)
  end)
end

return BulletPhysics

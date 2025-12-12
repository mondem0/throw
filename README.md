# Roblox FPS Starter (Luau)

This repository provides drop-in scripts and step-by-step instructions to assemble a Roblox first-person shooter prototype with physical bullets, gravity-based drop, collision damage, and a minimalist HUD for ammo and health.

## File map
- `game/ReplicatedStorage/Shared/BulletPhysics.lua` — tick-based bullet simulation with gravity, raycast collision, and damage.
- `game/ServerScriptService/BulletService.server.lua` — server authority for bullet spawning and player ammo values.
- `game/StarterPack/Carbine/CarbineTool.client.lua` — local tool script to fire the weapon and handle reloading.
- `game/StarterGui/FPSHud/AmmoHealthUI.client.lua` — UI controller that renders ammo/reserve and health text.
- `game/ReplicatedStorage/Assets/Bullet.placeholder.md` — guidance for the bullet Part you create in Studio.

## How to assemble the experience in Roblox Studio
1. **Import the folder layout**
   - In Studio, replicate the folder structure found in `game/` under the corresponding services (ServerScriptService, ReplicatedStorage, etc.).
   - Copy the Luau files into matching Script or LocalScript objects.

2. **Create the bullet model**
   - Under `ReplicatedStorage > Assets`, add a Part named **Bullet**.
   - Set size to roughly **0.2 x 0.2 x 1**, Anchored = true, CanCollide = false, CastShadow = false, Material = Neon (color of your choice). This Part is cloned per shot.

3. **Wire the remote event**
   - Under `ReplicatedStorage > Events`, create a **RemoteEvent** named **FireBullet** (the server script also creates it on start, but adding it in Studio helps previewing hierarchy).

4. **Server-side setup**
   - In **ServerScriptService**, add a Script named `BulletService` with the contents of `game/ServerScriptService/BulletService.server.lua`.
   - This script creates per-player `WeaponStats` (Ammo + ReserveAmmo), receives fire requests, and spawns physical bullets using the bullet template.

5. **Shared module**
   - In **ReplicatedStorage > Shared**, add a ModuleScript named `BulletPhysics` using `game/ReplicatedStorage/Shared/BulletPhysics.lua`.
   - The module handles gravity (`Acceleration` defaults to `Vector3.new(0, -workspace.Gravity, 0)`) and raycast hit detection each heartbeat.

6. **StarterPack weapon**
   - Add a Tool named `Carbine` to **StarterPack**.
   - Insert a LocalScript inside the Tool with the contents of `game/StarterPack/Carbine/CarbineTool.client.lua`.
   - Set the Tool's **Handle** and mesh as you prefer; the script only needs the Tool instance.
   - Firing uses center-screen aim (ViewportPointToRay). Hold left-click to shoot; press **R** to reload from ReserveAmmo.

7. **HUD**
   - In **StarterGui**, add a ScreenGui named `FPSHud` (ResetOnSpawn = false).
   - Add two TextLabels as children named `AmmoLabel` and `HealthLabel`.
   - Insert a LocalScript under the ScreenGui with the contents of `game/StarterGui/FPSHud/AmmoHealthUI.client.lua`.
   - The HUD listens for ammo/reserve changes and Humanoid health updates.

8. **Test the experience**
   - Play-test in Studio. When you fire, server-side bullets spawn, move with gravity, and raycast for collisions. On hit, Humanoids take damage.
   - Adjust `DEFAULT_DAMAGE`, `MUZZLE_VELOCITY`, `MAX_BULLET_LIFE` in `BulletService.server.lua` to tune feel.

## Bullet drop and collisions
- Bullets integrate velocity with acceleration each Heartbeat, so setting a higher gravity vector increases drop. You can also bias `Acceleration` to simulate wind or drag.
- Raycasting from the previous to the new bullet position ensures fast projectiles register hits even with low frame rates.
- Damage is applied to any Humanoid ancestor of the impacted part; extend `applyDamage` in `BulletPhysics.lua` for armor or hitboxes.

## Ammo + health UX
- `WeaponStats.Ammo` and `WeaponStats.ReserveAmmo` live on the player. The HUD shows `Ammo: <clip> / <reserve>`.
- Health text is derived from the local character's Humanoid, updating on `HealthChanged`.

## Extending
- Add muzzle flashes or tracers by attaching cosmetic parts to the bullet clone before `spawn`.
- Add server-side fire-rate throttling or raycast validation (e.g., magnitude checks on `origin`) for anti-exploit hardening.
- Consider swapping the bullet Part for a Beam-based tracer for visual flair while keeping the physical part hidden.

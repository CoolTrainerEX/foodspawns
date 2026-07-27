local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Entity = require(ReplicatedStorage.Shared.entities.Entity)

--[=[
	@class EntitySpawner

	Spawns [Entity] on an area.
]=]
local EntitySpawner = {}

EntitySpawner.__index = EntitySpawner

--[=[
	@prop _janitor Janitor
	@within EntitySpawner
	@external Janitor https://howmanysmall.github.io/Janitor/api/Janitor/
	@private
	@readonly

	[Janitor] used by the instance.
]=]

--[=[
	@prop _entities { Entity }
	@within EntitySpawner
	@private
	@readonly

	List of [Entity] to spawn.
]=]

--[=[
	@prop _size Vector2
	@within EntitySpawner
	@private
	@readonly

	Size of the spawner.
]=]

--[=[
	@prop _position Vector3
	@within EntitySpawner
	@private
	@readonly

	Position of the spawner.
]=]

--[=[
	@prop _rate number
	@within EntitySpawner
	@private
	@readonly

	Spawn rate (Hz).
]=]
export type EntitySpawner = typeof(setmetatable(
	{} :: {
		_janitor: Janitor.Janitor,
		_entities: { Entity.Entity },
		_size: Vector2,
		_position: Vector3,
		_rate: number,
	},
	EntitySpawner
))

local random = Random.new()

--[=[
	Creates a new [EntitySpawner].

	@param entities { Entity } -- List of [Entity] to spawn
	@param size Vector2 -- Size of the spawner
	@param position Vector3 -- Position of the spawner
	@param rate number -- Spawn rate (Hz)
	@return EntitySpawner -- Instance
]=]
function EntitySpawner.new(entities: { Entity.Entity }, size: Vector2, position: Vector3, rate: number): EntitySpawner
	local self = {}

	self._janitor = Janitor.new()
	self._entities = entities
	self._size = size
	self._position = position
	self._rate = rate

	return setmetatable(self, EntitySpawner)
end

--[=[
	Starts the spawning.

	@method start
	@within EntitySpawner
]=]
function EntitySpawner.start(self: EntitySpawner)
	self._janitor:Add(
		task.spawn(function()
			while true do
				local at = Vector3.new(
					random:NextNumber(self._position.X - self._size.X / 2, self._position.X + self._size.X / 2),
					self._position.Y,
					random:NextNumber(self._position.Z - self._size.Y / 2, self._position.Z + self._size.Y / 2)
				)

				self._janitor:Add(
					self._entities[random:NextInteger(1, #self._entities)]:spawn(
						CFrame.lookAt(at, at + random:NextUnitVector())
					)
				)

				task.wait(1 / self._rate)
			end
		end),
		nil,
		"spawn"
	)
end

--[=[
	Pauses the spawning.

	@method pause
	@within EntitySpawner
]=]
function EntitySpawner.pause(self: EntitySpawner)
	self._janitor:Remove("spawn")
end

--[=[
	Destroy instance and spawned [Entity].

	@method Destroy
	@within EntitySpawner
]=]
function EntitySpawner.Destroy(self: EntitySpawner)
	self._janitor:Destroy()
end

return EntitySpawner

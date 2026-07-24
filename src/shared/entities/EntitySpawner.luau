local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Entity = require(ReplicatedStorage.Shared.entities.Entity)

local Spawner = {}

Spawner.__index = Spawner

export type Spawner = typeof(setmetatable(
	{} :: {
		_janitor: Janitor.Janitor,
		_entities: { Entity.Entity },
		_size: Vector2,
		_position: Vector3,
		_rate: number,
	},
	Spawner
))

local random = Random.new()

function Spawner.new(entities: { Entity.Entity }, size: Vector2, position: Vector3, rate: number): Spawner
	local self = {}

	self._janitor = Janitor.new()
	self._entities = entities
	self._size = size
	self._position = position
	self._rate = rate

	return setmetatable(self, Spawner)
end

function Spawner.start(self: Spawner)
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

function Spawner.pause(self: Spawner)
	self._janitor:Remove("spawn")
end

function Spawner.Destroy(self: Spawner)
	self._janitor:Destroy()
end

return Spawner

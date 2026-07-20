local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Food = require(script.Parent.Food)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Spawner = {}

Spawner.__index = Spawner

export type Spawner = typeof(setmetatable(
	{} :: { _janitor: Janitor.Janitor, food: Food.Food, size: Vector2, position: Vector3, rate: number },
	Spawner
))

local random = Random.new()

function Spawner.new(food: Food.Food, size: Vector2, position: Vector3, rate: number): Spawner
	local self = {}

	self._janitor = Janitor.new()
	self.food = food
	self.size = size
	self.position = position
	self.rate = rate

	return setmetatable(self, Spawner)
end

function Spawner.start(self: Spawner)
	local spawnTask = task.spawn(function()
		while true do
			local model = self._janitor:Add(self.food:create())

			local at = Vector3.new(
				random:NextNumber(self.position.X - self.size.X / 2, self.position.X + self.size.X / 2),
				self.position.Y,
				random:NextNumber(self.position.Z - self.size.Y / 2, self.position.Z + self.size.Y / 2)
			)

			model:PivotTo(CFrame.lookAt(at, at + random:NextUnitVector()))
			model.Parent = Workspace
			task.wait(1 / self.rate)
		end
	end)

	self._janitor:Add(function()
		task.cancel(spawnTask)
	end, nil, "spawn")
end

function Spawner.pause(self: Spawner)
	self._janitor:Remove("spawn")
end

function Spawner.Destroy(self: Spawner)
	self._janitor:Destroy()
end

return Spawner

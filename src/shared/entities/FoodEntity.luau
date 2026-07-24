local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Entity = require(script.Parent.Entity)
local GoodSignal = require(ReplicatedStorage.Packages.GoodSignal)
local Currencies = require(ReplicatedStorage.Shared.Currencies)

local FoodEntity = {}

setmetatable(FoodEntity, { __index = Entity })
FoodEntity.__index = FoodEntity

export type FoodEntity =
	typeof(setmetatable(
		{} :: {
			Touched: GoodSignal.Signal<Player, { [Currencies.Currency]: number }>,
			_values: { [Currencies.Currency]: number },
		},
		FoodEntity
	))
	& Entity.Entity

function FoodEntity.new(model: Model, values: { [Currencies.Currency]: number }): FoodEntity
	local self = Entity.new(model)

	self.Touched = GoodSignal.new()
	self._values = values

	return setmetatable(self, FoodEntity)
end

function FoodEntity.spawn(self: FoodEntity, targetCFrame: CFrame)
	local clone = Entity.spawn(self, targetCFrame)
	local primaryPart = clone.PrimaryPart
	local debounce = false

	if primaryPart then
		primaryPart.Touched:Connect(function(otherPart: BasePart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)

			if not debounce and player then
				debounce = true
				self.Touched:Fire(player, self._values)
				clone:Destroy()
			end
		end)
	end

	return clone
end

return FoodEntity

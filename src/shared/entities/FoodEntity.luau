local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Entity = require(script.Parent.Entity)
local GoodSignal = require(ReplicatedStorage.Packages.GoodSignal)
local Currencies = require(ReplicatedStorage.Shared.Currencies)

--[=[
	@class FoodEntity

	[Entity] that can be collected by players to gain [Currency].
]=]
local FoodEntity = {}

setmetatable(FoodEntity, { __index = Entity })
FoodEntity.__index = FoodEntity

--[=[
	@prop _values { [Currency]: number }
	@within FoodEntity
	@private
	@readonly

	[Currency] value.
]=]

--[=[
	@prop Touched Signal<Player, { [Currency]: number }>
	@within FoodEntity
	@external Signal https://github.com/stravant/goodsignal
	@readonly

	Player touched [Signal].
]=]
export type FoodEntity =
	typeof(setmetatable(
		{} :: {
			_values: { [Currencies.Currency]: number },
			Touched: GoodSignal.Signal<Player, { [Currencies.Currency]: number }>,
		},
		FoodEntity
	))
	& Entity.Entity

--[=[
	Creates a new [FoodEntity].

	@param model Model -- [Model] to clone on spawn
	@param values { [Currency]: number } -- [Currency] value
	@return FoodEntity -- Instance
]=]
function FoodEntity.new(model: Model, values: { [Currencies.Currency]: number }): FoodEntity
	local self = Entity.new(model)

	self.Touched = GoodSignal.new()
	self._values = values

	return setmetatable(self, FoodEntity)
end

--[=[
	Clones the entity model to the target position.

	@method spawn
	@within FoodEntity
	@param targetCFrame CFrame -- Target position
	@return Model -- Reference to cloned [Model]
]=]
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

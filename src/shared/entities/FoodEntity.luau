local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Entity = require(script.Parent.Entity)
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

	[Currency] values.
]=]

export type FoodEntity =
	typeof(setmetatable(
		{} :: {
			_values: { [Currencies.Currency]: number },
		},
		FoodEntity
	))
	& Entity.Entity

--[=[
	@prop _registry { [Model]: FoodEntity }
	@within FoodEntity
	@private

	Registry of spawned [FoodEntity].
]=]
FoodEntity._registry = {} :: { [Model]: FoodEntity }

--[=[
	Creates a new [FoodEntity].

	@param model Model -- [Model] to clone on spawn
	@param values { [Currency]: number } -- [Currency] values
	@return FoodEntity -- Instance
]=]
function FoodEntity.new(model: Model, values: { [Currencies.Currency]: number }): FoodEntity
	local self = Entity.new(model)

	self._values = values

	return setmetatable(self, FoodEntity)
end

--[=[
	Consumes the [Model] and returns the [Currency] values.

	@param model Model -- Model to consume
	@return { [Currency]: number } -- Currency values
]=]
function FoodEntity.consume(model: Model): { [Currencies.Currency]: number }?
	local entity = FoodEntity._registry[model]

	if entity then
		model:Destroy()

		return entity._values
	end

	return
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

	FoodEntity._registry[clone] = self

	return clone
end

return FoodEntity

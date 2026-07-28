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
	Checks if the [Model] is in the registry and returns the [Currency] values and consume function.

	@param model Model -- Model to check
	@return { [Currencies.Currency]: number }? -- Currency values
	@return (() -> ())? -- Consume function
]=]
function FoodEntity.consume(model: Model): ({ [Currencies.Currency]: number }?, (() -> ())?)
	local entity = FoodEntity._registry[model]

	if entity then
		return entity._values, function()
			model:Destroy()
		end
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

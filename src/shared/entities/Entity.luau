--!strict
--[=[
	@class Entity

	Base class for spawnable entities with models.
]=]
local Entity = {}

Entity.__index = Entity

--[=[
	@prop _model Model
	@within Entity
	@private
	@readonly

	[Model] to clone on spawn.
]=]
export type Entity = typeof(setmetatable({} :: { _model: Model }, Entity))

--[=[
	Creates a new [Entity].

	@param model Model -- [Model] to clone on spawn
	@return Entity -- Instance
]=]
function Entity.new(model: Model): Entity
	local self = {}

	self._model = model

	return setmetatable(self, Entity)
end

--[=[
	Clones the entity model to the target position.

	@method spawn
	@within Entity
	@param targetCFrame CFrame -- Target position
	@return Model -- Reference to cloned [Model]
]=]
function Entity.spawn(self: Entity, targetCFrame: CFrame)
	local clone = self._model:Clone()

	clone:PivotTo(targetCFrame)
	clone.Parent = workspace

	return clone
end

return Entity

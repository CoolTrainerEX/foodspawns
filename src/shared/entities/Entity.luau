local Workspace = game:GetService("Workspace")
local Entity = {}

Entity.__index = Entity

export type Entity = typeof(setmetatable({} :: { _model: Model }, Entity))

function Entity.new(model: Model): Entity
	local self = {}

	self._model = model

	return setmetatable(self, Entity)
end

function Entity.spawn(self: Entity, targetCFrame: CFrame)
	local clone = self._model:Clone()

	clone:PivotTo(targetCFrame)
	clone.Parent = Workspace

	return clone
end

return Entity

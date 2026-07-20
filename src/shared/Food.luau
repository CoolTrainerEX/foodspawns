local Food = {}

Food.__index = Food

export type Food = typeof(setmetatable({} :: { model: Model, _hitbox: BasePart }, Food))

function Food.new(model: Model, hitbox: string): Food
	local self = {}

	self.model = model
	self._hitbox = self.model:FindFirstChild(hitbox)

	return setmetatable(self, Food)
end

function Food.touch(self: Food)
	self._hitbox.Touched:Connect(function(otherPart: BasePart) end)
end

return Food

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GoodSignal = require(ReplicatedStorage.Packages.GoodSignal)
local Food = {}

Food.__index = Food

export type Food = typeof(setmetatable(
	{} :: { model: Model, hitbox: string, Touched: GoodSignal.Signal<Player, number>, value: number },
	Food
))

function Food.new(model: Model, hitbox: string, value: number): Food
	local self = {}

	self.model = model
	self.hitbox = hitbox
	self.Touched = GoodSignal.new()
	self.value = value

	return setmetatable(self, Food)
end

function Food.create(self: Food)
	local clone = self.model:Clone()
	local hitbox = clone:FindFirstChild(self.hitbox)
	local debounce = false

	if hitbox:IsA("BasePart") then
		hitbox.Touched:Connect(function(otherPart: BasePart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)

			if not debounce and player then
				debounce = true
				self.Touched:Fire(player, self.value)
				clone:Destroy()
			end
		end)
	end

	return clone
end

return Food

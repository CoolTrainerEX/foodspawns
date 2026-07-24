local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Replica = require(ReplicatedStorage.Packages.Replica)
local Currencies = require(ReplicatedStorage.Shared.Currencies)

local ProfileData = {}

ProfileData.__index = ProfileData

export type Data = {
	currencies: { [Currencies.Currency]: number },
	upgrades: { [Upgrade]: number? },
}

export type ProfileData = typeof(setmetatable(
	{} :: {
		_player: Player,
		_data: Data,
		replica: typeof(Replica.New()),
	},
	ProfileData
))

type Stat = "SPEED"
type Upgrade = "BOOSTER"

ProfileData._baseStats = table.freeze({ ["SPEED"] = 40 } :: { [Stat]: number })

ProfileData.upgradesList = table.freeze({
	["BOOSTER"] = {
		{ stats = { ["SPEED"] = { operation = "ADD", value = 0.25 } }, cost = { ["MONEY"] = 1 } },
		{ stats = { ["SPEED"] = { operation = "MUL", value = 1.5 } }, cost = { ["FOOD"] = 1, ["MONEY"] = 1 } },
	},
} :: {
	[Upgrade]: {
		{
			stats: { [Stat]: { operation: "ADD" | "MUL", value: number } },
			cost: { [Currencies.Currency]: number },
		}
	},
})

function ProfileData.new(player: Player, data: Data): ProfileData
	local self = {}

	self._player = player
	self._data = data

	self.replica = Replica.New({
		Token = Replica.Token("ProfileData"),
		Data = { data = data, stats = table.clone(ProfileData._baseStats) },
	})

	self = setmetatable(self, ProfileData)

	self._player.CharacterAdded:Connect(function()
		self:applyStats()
	end)

	return self
end

function ProfileData.applyStats(self: ProfileData)
	local stats = table.clone(ProfileData._baseStats)
	local add = {}

	for upgrade, value in self._data.upgrades do
		if value then
			for stat, modifier in ProfileData.upgradesList[upgrade][value].stats do
				if modifier.operation == "MUL" then
					stats[stat] *= modifier.value
				elseif modifier.operation == "ADD" then
					if add[stat] then
						add[stat] += modifier.value
					else
						add[stat] = modifier.value
					end
				end
			end
		end
	end

	for stat, value in add do
		stats[stat] += value
	end

	-- Add any other stat changes here.

	for stat, value in stats do
		self.replica:Set({ "stats", stat }, value)
	end

	if self._player.Character then
		local humanoid = self._player.Character:WaitForChild("Humanoid")

		if humanoid:IsA("Humanoid") then
			humanoid.WalkSpeed = stats["SPEED"]
		end
	end
end

function ProfileData.addCurrency(self: ProfileData, currency: Currencies.Currency, value: number)
	self.replica:Set({ "data", "currencies", currency }, self._data.currencies[currency] + value)
	self:applyStats()
end

function ProfileData.upgrade(self: ProfileData, upgrade: Upgrade)
	local newValue = (self._data.upgrades[upgrade] or 0) + 1

	if newValue <= #ProfileData.upgradesList[upgrade] then
		local cost = ProfileData.upgradesList[upgrade][newValue].cost

		for currency, value in cost do
			if self._data.currencies[currency] < value then
				return
			end
		end

		self.replica:Set({ "data", "upgrades", upgrade }, newValue)

		for currency, value in cost do
			self.replica:Set({ "data", "currencies", currency }, self._data.currencies[currency] - value)
		end

		self:applyStats()
	end
end

function ProfileData.Destroy(self: ProfileData)
	local janitor = Janitor.new()

	janitor:Add(self.replica)
	janitor:Destroy()
end

return ProfileData

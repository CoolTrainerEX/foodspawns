local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Replica = require(ReplicatedStorage.Packages.Replica)
local Currencies = require(ReplicatedStorage.Shared.Currencies)
local FoodEntity = require(ReplicatedStorage.Shared.entities.FoodEntity)

--[=[
	@class ProfileData

	Class storing profile data.
]=]
local ProfileData = {}

ProfileData.__index = ProfileData

--[=[
	@interface Data
	@within ProfileData
	@field currencies { [Currency]: number } -- Player currencies
	@field upgrades { [Upgrade]: number? } -- Player upgrade levels
	
	Data stored in profile.
]=]
export type Data = {
	currencies: { [Currencies.Currency]: number },
	upgrades: { [Upgrade]: number? },
}

--[=[
	@prop _player Player
	@within ProfileData
	@private
	@readonly

	Reference to profile [Player].
]=]

--[=[
	@prop _data Data
	@within ProfileData
	@private

	Reference to profile [Data].
]=]

--[=[
	@prop replica Replica
	@within ProfileData
	@external Replica https://madstudioroblox.github.io/Replica/
	@server
	@readonly

	[Replica] used to sync data to the client.
]=]

--[=[
	@prop janitor Janitor
	@within ProfileData
	@external Janitor https://howmanysmall.github.io/Janitor/api/Janitor/
	@readonly

	[Janitor] used by the instance.
]=]
export type ProfileData = typeof(setmetatable(
	{} :: {
		_player: Player,
		_data: Data,
		replica: typeof(Replica.New()),
		janitor: Janitor.Janitor,
	},
	ProfileData
))

--[=[
	@type Stat "SPEED" | "PICKUP_RADIUS"
	@within ProfileData
	@private

	Player stat IDs.
]=]
type Stat = "SPEED" | "PICKUP_RADIUS"

--[=[
	@type Upgrade "BOOSTER"
	@within ProfileData
	@private

	Player upgrade IDs.
]=]
type Upgrade = "BOOSTER"

--[=[
	@prop _baseStats { [Stat]: number }
	@within ProfileData
	@private
	@readonly

	Player base stats.
]=]
ProfileData._baseStats = table.freeze({ ["SPEED"] = 16, ["PICKUP_RADIUS"] = 3 } :: { [Stat]: number })

--[=[
	@prop upgradesList { [Upgrade]: { {stats: { [Stat]: { operation: "ADD" | "MUL", value: number } },cost: { [Currency]: number } } } }
	@within ProfileData
	@readonly

	List of upgrade stats and costs in each level.
]=]
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

--[=[
	Creates a new [ProfileData] given the reference to the profile.

	@param player Player -- Reference to profile [Player]
	@param data Data -- Reference to profile [Data]
	@return ProfileData -- Instance
	@server
]=]
function ProfileData.new(player: Player, data: Data): ProfileData
	local self = {}

	self._player = player
	self._data = data
	self.janitor = Janitor.new()

	self.replica = self.janitor:Add(Replica.New({
		Token = Replica.Token("ProfileData"),
		Data = { data = data, stats = table.clone(ProfileData._baseStats) },
	}))

	self = setmetatable(self, ProfileData)

	self._player.CharacterAdded:Connect(function()
		self:applyStats()
	end)

	return self
end

--[=[
	Applies stats to the [Player].

	@method applyStats
	@within ProfileData
	@return { [Stat]: number } -- Player stats
]=]
function ProfileData.applyStats(self: ProfileData): { [Stat]: number }
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

		self.janitor:Add(
			RunService.Heartbeat:Connect(function()
				for _, basePart in
					workspace:GetPartBoundsInRadius(self._player.Character:GetPivot().Position, stats["PICKUP_RADIUS"])
				do
					if basePart.Parent:IsA("Model") then
						local values, consume = FoodEntity.consume(basePart.Parent)

						if values and consume then
							consume()

							for currency, value in values do
								self:addCurrency(currency, value)
							end
						end
					end
				end
			end),
			nil,
			"pickup"
		)
	end

	return stats
end

--[=[
	Adds to a player currency.

	@method addCurrency
	@within ProfileData
	@param currency Currency -- Currency to add
	@param value number -- Amount to add
]=]
function ProfileData.addCurrency(self: ProfileData, currency: Currencies.Currency, value: number)
	self.replica:Set({ "data", "currencies", currency }, self._data.currencies[currency] + value)
	self:applyStats()
end

--[=[
	Increment a player upgrade level.

	@method upgrade
	@within ProfileData
	@param upgrade Upgrade -- Upgrade to increment
]=]

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

--[=[
	Destroy instance.

	@method Destroy
	@within ProfileData
]=]
function ProfileData.Destroy(self: ProfileData)
	self.janitor:Destroy()
end

return ProfileData

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Replica = require(ReplicatedStorage.Packages.Replica)
local Currencies = require(ReplicatedStorage.Shared.Currencies)
local ProfileData = require(ReplicatedStorage.Shared.ProfileData)
local EntitySpawner = require(ReplicatedStorage.Shared.entities.EntitySpawner)
local FoodEntity = require(ReplicatedStorage.Shared.entities.FoodEntity)
local Upgrade = require(ReplicatedStorage.Shared.packets.Upgrade)
local ProfileStore = require(script.Parent.ServerPackages.ProfileStore)

local PlayerStore = ProfileStore.New(
	"PlayerStore",
	{ currencies = { ["FOOD"] = 10, ["MONEY"] = 10 }, upgrades = {} } :: ProfileData.Data
)

local PlayerData: {
	[Player]: {
		profile: typeof(PlayerStore:StartSessionAsync()),
		data: ProfileData.ProfileData,
		janitor: typeof(Janitor.new()),
	},
} =
	{}

local PlayerPromises: { [Player]: typeof(Promise.try()) } = {}

local function PlayerAdded(player)
	PlayerPromises[player] = Promise.try(function()
		return PlayerStore:StartSessionAsync(`{player.UserId}`, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})
	end)
		:andThen(function(profile)
			profile:AddUserId(player.UserId)
			profile:Reconcile()

			profile.OnSessionEnd:Connect(function()
				PlayerData[player] = nil
				player:Kick(`Profile session end - Please rejoin`)
			end)

			if player.Parent == Players then
				local janitor = Janitor.new()

				PlayerData[player] = {
					profile = janitor:Add(profile, "EndSession"),
					data = janitor:Add(ProfileData.new(player, profile.Data)),
					janitor = janitor,
				}

				print(`Profile loaded for {player.DisplayName}!`)

				return PlayerData[player]
			else
				profile:EndSession()
				return
			end
		end)
		:catch(function()
			player:Kick(`Profile load fail - Please rejoin`)
		end)
end

for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Replica.NewReadyPlayer:Connect(function(player: Player)
	local playerPromise = PlayerPromises[player]

	if playerPromise then
		playerPromise:andThen(function(playerData)
			playerData.data.replica:Subscribe(player)
		end)
	end
end)

Players.PlayerRemoving:Connect(function(player: Player)
	local playerData = PlayerData[player]

	if playerData then
		playerData.janitor:Cleanup()
	end
end)

local food = FoodEntity.new(ServerStorage:FindFirstChild("Food"), { ["FOOD"] = 5 })
local spawner = EntitySpawner.new({ food }, Vector2.new(100, 100), Vector3.new(0, 5, 0), 1)

food.Touched:Connect(function(player: Player, values: { [Currencies.Currency]: number })
	local data = PlayerData[player].data

	for currency, value in values do
		data:addCurrency(currency, value)
	end
end)

Upgrade.upgrade.listen(function(data: string, player: Player?)
	if player then
		PlayerData[player].data:upgrade(data)
	end
end)

spawner:start()

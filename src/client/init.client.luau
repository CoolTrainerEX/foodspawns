local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local App = require(script.App)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Replica = require(ReplicatedStorage.Packages.Replica)
local Food = require(ReplicatedStorage.Shared.states.currencies.Food)
local Money = require(ReplicatedStorage.Shared.states.currencies.Money)
local PickupRadius = require(ReplicatedStorage.Shared.states.stats.PickupRadius)
local Speed = require(ReplicatedStorage.Shared.states.stats.Speed)
local Booster = require(ReplicatedStorage.Shared.states.upgrades.Booster)

ReactRoblox.createRoot(Instance.new("Folder"))
	:render(ReactRoblox.createPortal(React.createElement(App), Players.LocalPlayer.PlayerGui))

Replica.OnNew("ProfileData", function(replica)
	Food:setState(replica.Data.data.currencies["FOOD"])
	Money:setState(replica.Data.data.currencies["MONEY"])
	Booster:setState(replica.Data.data.upgrades["BOOSTER"])
	Speed:setState(replica.Data.stats["SPEED"])
	PickupRadius:setState(replica.Data.stats["PICKUP_RADIUS"])

	replica:OnSet({ "data", "currencies", "FOOD" }, function(value)
		Food:setState(value)
	end)

	replica:OnSet({ "data", "currencies", "MONEY" }, function(value)
		Money:setState(value)
	end)

	replica:OnSet({ "data", "upgrades", "BOOSTER" }, function(value)
		Booster:setState(value)
	end)

	replica:OnSet({ "stats", "SPEED" }, function(value)
		Speed:setState(value)
	end)

	replica:OnSet({ "stats", "PICJUP_RADIUS" }, function(value)
		PickupRadius:setState(value)
	end)
end)

Replica.RequestData()

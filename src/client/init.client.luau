local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local App = require(script.App)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Replica = require(ReplicatedStorage.Packages.Replica)
local Food = require(ReplicatedStorage.Shared.states.Food)

ReactRoblox.createRoot(Instance.new("Folder"))
	:render(ReactRoblox.createPortal(React.createElement(App), Players.LocalPlayer.PlayerGui))

Replica.OnNew("ProfileData", function(replica)
	Food:setState(replica.Data.Food)

	replica:OnSet({ "Food" }, function(value)
		Food:setState(value)
	end)
end)

Replica.RequestData()

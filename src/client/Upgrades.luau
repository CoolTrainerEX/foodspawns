--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local React = require(ReplicatedStorage.Packages.React)
local Upgrade = require(ReplicatedStorage.Shared.packets.Upgrade)
local Booster = require(ReplicatedStorage.Shared.states.upgrades.Booster)

return function()
	local booster, setBooster = React.useState(Booster:getState())

	React.useEffect(function()
		local janitor = Janitor.new()

		janitor:Add(Booster:subscribe(setBooster))

		return function()
			janitor:Cleanup()
		end
	end, {})

	return React.createElement("Frame", {
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		Grid = React.createElement("UIGridLayout", {
			CellPadding = UDim2.fromOffset(5, 5),
			CellSize = UDim2.fromOffset(200, 40),
		}),
		Booster = React.createElement("TextButton", {
			Font = Enum.Font.Bodoni,
			TextColor3 = Color3.fromHSV(0.1, 1, 0.5),
			TextSize = 30,
			Text = `Booster: {booster or "--"}`,
			[React.Event.Activated] = function()
				Upgrade.upgrade.send("BOOSTER")
			end,
		}),
	})
end

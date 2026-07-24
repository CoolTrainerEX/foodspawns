local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local React = require(ReplicatedStorage.Packages.React)
local Speed = require(ReplicatedStorage.Shared.states.stats.Speed)

return function()
	local speed, setSpeed = React.useState(Speed:getState())

	React.useEffect(function()
		local janitor = Janitor.new()

		janitor:Add(Speed:subscribe(setSpeed))

		return function()
			janitor:Cleanup()
		end
	end, {})

	return React.createElement("Frame", {
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.one,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		React.createElement("UIGridLayout", {
			CellPadding = UDim2.fromOffset(5, 5),
			CellSize = UDim2.fromOffset(200, 40),
		}),
		React.createElement("TextLabel", {
			Font = Enum.Font.Bodoni,
			TextColor3 = Color3.fromHSV(0.1, 1, 0.5),
			TextSize = 30,
			Text = `Speed: {speed}`,
		}),
	})
end

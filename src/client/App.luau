local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local React = require(ReplicatedStorage.Packages.React)
local Food = require(ReplicatedStorage.Shared.states.Food)

return function()
	local food, setFood = React.useState(Food:getState())

	React.useEffect(function()
		local janitor = Janitor.new()

		janitor:Add(Food:subscribe(setFood))

		return function()
			janitor:Cleanup()
		end
	end, {})

	return React.createElement(
		"ScreenGui",
		{ ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets },
		React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		{
			React.createElement("TextLabel", {
				Size = UDim2.fromOffset(50, 25),
				Text = food,
			}),
		}
	)
end

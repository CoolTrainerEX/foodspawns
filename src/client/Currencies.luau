--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local React = require(ReplicatedStorage.Packages.React)
local Food = require(ReplicatedStorage.Shared.states.currencies.Food)
local Money = require(ReplicatedStorage.Shared.states.currencies.Money)

return function()
	local food, setFood = React.useState(Food:getState())
	local money, setMoney = React.useState(Money:getState())

	React.useEffect(function()
		local janitor = Janitor.new()

		janitor:Add(Food:subscribe(setFood))
		janitor:Add(Money:subscribe(setMoney))

		return function()
			janitor:Cleanup()
		end
	end, {})

	return React.createElement("ScreenGui", {
		ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets,
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		Grid = React.createElement("UIGridLayout", {
			CellPadding = UDim2.fromOffset(5, 5),
			CellSize = UDim2.fromOffset(200, 40),
		}),
		Food = React.createElement("TextLabel", {
			Font = Enum.Font.Bodoni,
			TextColor3 = Color3.fromHSV(0, 1, 0.5),
			TextSize = 30,
			Text = `Food: {food}`,
		}),
		Money = React.createElement("TextLabel", {
			Font = Enum.Font.Bodoni,
			TextColor3 = Color3.fromHSV(0.25, 1, 0.5),
			TextSize = 30,
			Text = `Money: {money}`,
		}),
	})
end

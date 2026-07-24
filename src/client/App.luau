local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Currencies = require(script.Parent.Currencies)
local Stats = require(script.Parent.Stats)
local Upgrades = require(script.Parent.Upgrades)
local React = require(ReplicatedStorage.Packages.React)

return function()
	return React.createElement("ScreenGui", { ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets }, {
		React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		React.createElement(Currencies),
		React.createElement(Stats),
		React.createElement(Upgrades),
	})
end

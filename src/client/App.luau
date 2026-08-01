--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Currencies = require(script.Parent.Currencies)
local Stats = require(script.Parent.Stats)
local Upgrades = require(script.Parent.Upgrades)
local React = require(ReplicatedStorage.Packages.React)

return function()
	return React.createElement("ScreenGui", { ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets }, {
		UIPadding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		Currencies = React.createElement(Currencies),
		Stats = React.createElement(Stats),
		Upgrades = React.createElement(Upgrades),
	})
end

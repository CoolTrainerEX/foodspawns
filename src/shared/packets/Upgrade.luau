local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return ByteNet.defineNamespace("upgrade", function()
	return { upgrade = ByteNet.definePacket({ value = ByteNet.string }) }
end)

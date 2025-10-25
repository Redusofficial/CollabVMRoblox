local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollabVM = ReplicatedStorage.CollabVM

local CollabVMClient = require(CollabVM.Protocol.CollabVMClient)

local Client = CollabVMClient.new("wss://computernewb.com/collab-vm/vm0")

Client:on("open", function()
	print("Connected to VM")
end)

Client.publicEmitter:onAny(function(...)
	print(...)
end)
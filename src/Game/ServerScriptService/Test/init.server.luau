local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")

local CollabVM = ReplicatedStorage.CollabVM
local ImagePart = script.Image

local Image = AssetService:CreateEditableImage({
	Size = Vector2.new(1024, 768)
})
ImagePart.Decal.TextureContent = Content.fromObject(Image)

local CollabVMClient = require(CollabVM.Protocol.CollabVMClient)

local Client = CollabVMClient.new("wss://computernewb.com/collab-vm/vm0")

Client:on("open", function()
	ImagePart.Parent = workspace
	print("Connected to VM")
end)

Client.publicEmitter:onAny(function(...)
	print(...)
end)

Client.imageDecoded:Connect(function(Position: Vector2, Size: Vector2, Pixels: buffer)
	Image:WritePixelsBuffer(Position, Size, Pixels)
end)
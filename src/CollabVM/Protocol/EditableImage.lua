local EditableImage = {}
EditableImage.__index = EditableImage

local function clamp(n, lo, hi)
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

-- parentInstance: GuiObject (Frame/ScreenGui) that will contain the pixel grid
-- width,height: dimensions in pixels
-- pixelSize: size of each pixel in pixels (UI size) — e.g. 2
function EditableImage.new(parentInstance, width, height, pixelSize)
    local self = setmetatable({}, EditableImage)
    self.parent = parentInstance
    self.width = width
    self.height = height
    self.pixelSize = pixelSize or 2
    self.container = Instance.new("Frame")
    self.container.Name = "EditableImageContainer"
    self.container.Size = UDim2.new(0, width * self.pixelSize, 0, height * self.pixelSize)
    self.container.BackgroundTransparency = 1
    self.container.Parent = parentInstance

    self.pixels = {} -- 2D table of frames
    for y = 1, height do
        self.pixels[y] = {}
        for x = 1, width do
            local p = Instance.new("Frame")
            p.Name = "px_" .. x .. "_" .. y
            p.Size = UDim2.new(0, self.pixelSize, 0, self.pixelSize)
            p.Position = UDim2.new(0, (x - 1) * self.pixelSize, 0, (y - 1) * self.pixelSize)
            p.BorderSizePixel = 0
            p.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            p.Parent = self.container
            self.pixels[y][x] = p
        end
    end

    -- staging buffer for batch updates
    self.buffer = {}

    return self
end

-- color components are 0-255 integers
function EditableImage:setPixel(x, y, r, g, b, a)
    x = clamp(math.floor(x), 1, self.width)
    y = clamp(math.floor(y), 1, self.height)
    r = clamp(math.floor(r or 0), 0, 255)
    g = clamp(math.floor(g or 0), 0, 255)
    b = clamp(math.floor(b or 0), 0, 255)
    -- a is ignored for now (no per-frame alpha support in this simple grid)
    self.buffer[#self.buffer + 1] = {x = x, y = y, r = r, g = g, b = b}
end

-- Apply buffered pixel updates immediately
function EditableImage:commit()
    for _, px in ipairs(self.buffer) do
        local x, y = px.x, px.y
        local frame = self.pixels[y] and self.pixels[y][x]
        if frame then
            frame.BackgroundColor3 = Color3.fromRGB(px.r, px.g, px.b)
        end
    end
    self.buffer = {}
end

function EditableImage:clear(r, g, b)
    r = r or 0; g = g or 0; b = b or 0
    for y = 1, self.height do
        for x = 1, self.width do
            local frame = self.pixels[y][x]
            if frame then
                frame.BackgroundColor3 = Color3.fromRGB(r, g, b)
            end
        end
    end
end

return EditableImage

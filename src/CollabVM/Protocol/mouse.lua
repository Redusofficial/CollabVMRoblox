export type MouseEventData = {
    buttons: number,
    offsetX: number,
    offsetY: number,
}

export type WheelEventData = {
    buttons: number,
    offsetX: number,
    offsetY: number,
    deltaY: number,
}

local function maskContains(mask: number, bit: number): boolean
    return bit32.band(mask, bit) == bit
end

local Mouse = {}
Mouse.__index = Mouse

export type Mouse = typeof(setmetatable({} :: {
    left: boolean,
    middle: boolean,
    right: boolean,
    scrollDown: boolean,
    scrollUp: boolean,
    x: number,
    y: number,
}, Mouse))

function Mouse.new(): Mouse
    local self = setmetatable({}, Mouse) :: Mouse

    self.left = false
    self.middle = false
    self.right = false
    self.scrollDown = false
    self.scrollUp = false
    self.x = 0
    self.y = 0

    return self
end

function Mouse:makeMask(): number
    local mask = 0
    if self.left then mask = bit32.bor(mask, 1) end
    if self.middle then mask = bit32.bor(mask, 2) end
    if self.right then mask = bit32.bor(mask, 4) end
    if self.scrollUp then mask = bit32.bor(mask, 8) end
    if self.scrollDown then mask = bit32.bor(mask, 16) end
    return mask
end

function Mouse:initFromMouseEvent(e: MouseEventData)
    self.left = maskContains(e.buttons, 1)
    self.right = maskContains(e.buttons, 2)
    self.middle = maskContains(e.buttons, 4)

    self.x = e.offsetX
    self.y = e.offsetY
    
    self.scrollUp = false
    self.scrollDown = false
end

function Mouse:initFromWheelEvent(ev: WheelEventData)
    self:initFromMouseEvent(ev)

    if ev.deltaY < 0 then
        self.scrollUp = true
    elseif ev.deltaY > 0 then
        self.scrollDown = true
    end
end

return Mouse
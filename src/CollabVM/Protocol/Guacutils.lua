local function decode(str: string): {string}?
    local pos: number = -1
    local sections: {string} = {}

    while true do
        local len: number = str:find('%.', pos + 2) or -1
        if len == -1 then
            break
        end

        local lengthStr: string = str:sub(pos + 2, len - 1)
        local length: number = tonumber(lengthStr) or -1

        if length == -1 then
            return nil
        end
        
        local nextPos: number = len + length

        if nextPos >= str:len() and nextPos ~= str:len() then
            return nil
        end

        local content: string = str:sub(len + 1, nextPos)
        table.insert(sections, content)
        
        pos = nextPos

        local separator: string = str:sub(pos + 1, pos + 1)

        if separator == ',' then
            continue
        elseif separator == ';' then
            break
        else
            return nil
        end
    end

    return sections
end

local function encode(...: string): string
    local strings: {string} = {...}
    local command: {string} = {}

    for i: number, current: string in ipairs(strings) do
        local currentLength: number = current:len()
        table.insert(command, currentLength .. '.')
        table.insert(command, current)
        
        if i < #strings then
            table.insert(command, ',')
        else
            table.insert(command, ';')
        end
    end
    
    return table.concat(command)
end

return {
    decode = decode,
    encode = encode
}
local function dupeTable(t1)
    local t2 = {}
    local toCopy = {}
    while #toCopy > 0 do
        for k, v in pairs(toCopy[1][1]) do
            if type(v) != "table" then
                toCopy[1][2][k] = toCopy[1][1][k]
            else
                local t3 = {}
                toCopy[1][2][k] = t3
                toCopy[#toCopy + 1] = {toCopy[1][1][k], t3}
            end
        end
    end
    return t2
end

do
    local old = _G.fs
    local permTables = {}
    local function dupeKey(k1)
        if not permTables[k] then
            error("Invalid key", 2)
        else
            local k2 = {}
            permTables[k2] = dupeTable(permTables[k])
            return k2
        end
    end
    local function getPermission(k, n)
        for k, v in pairs(permTables[k]) do
            if st
    local function setPermission(mainK, k, n, v)
        if not permTables[mainK] then
            error("Invalid main key", 2)
        elseif not permTables[k] then
            error("Invalid key", 2)
        elseif type(n) ~= "string" then
            error("Invalid permission", 2)
        elseif (v ~= true) and (v ~= false) and (v ~= nil) then
            error("Invalid permission value", 2)
        elseif not getPermission()

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
    local old = dupeTable(_G)
    local permTables = {}
    local function isValidPermission(s)
        --BIOS.lua disables changing string metatable - more secure than var "old" (still secure)
        return type(s) == "string" and s:gsub("%.%.+", "") == s and s:gsub("[^A-Za-z0-9_%-%.]") == s
    end
    local function normalizePermission(s)
        if not isValidPermission(s) then
            old.error("Invalid permission", 2)
        end
        if s:sub(1, 1) == "." then
            return s
        else
            return "." .. s
        end
    end
    local function dupeKey(k1)
        if not permTables[k1] then
            old.error("Invalid key", 2)
        else
            local k2 = {}
            permTables[k2] = dupeTable(permTables[k1])
            return k2
        end
    end
    local function getPermission(k, n)
        if not permTables[k] then
            old.error("Invalid key", 2)
        elseif not isValidPermission(n) then
            old.error("Invalid permission", 2)
        end
        if permTables[k][n] ~= nil then
            return permTables[k][n], true
        end
        n = normalizePermission(n)
        local lastFN, lastFV = ".", permTables[k]["."] or false
        for fn, fv in pairs(permTables[k]) do
            if #lastFN < #fn and #fn < #n and n:sub(1, #fn + 1) == (fn .. ".") then
                lastFN, lastFV = fn, fv
            end
        end
        return lastFV, false, lastFN
    end
    local function setPermission(mainK, k, n, v)
        if not permTables[mainK] then
            old.error("Invalid main key", 2)
        elseif not permTables[k] then
            old.error("Invalid key", 2)
        elseif not isValidPermission(n) then
            old.error("Invalid permission", 2)
        elseif (v ~= true) and (v ~= false) and (v ~= nil) then
            old.error("Invalid permission value", 2)
        elseif not getPermission(mainK, ".allowSettingPermissions")
            old.error("Cannot use main key to set permissions", 2)
        else
            n = normalizePermission(n)
            if v then
                local authorized, wasDirrect = getPermission(mainK, n)
                if not authorized or not (wasDirrect or getPermission(mainK, ".allowIndirrectPermissionAuthorization")) then
                    old.error("Unauthorized", 2)
                end
            elseif v == nil and permTables[k][n] == false and not getPermission(mainK, ".allowDisablingBlacklist") then
                old.error("Unauthorized to remove blacklist", 2)
            end
            permTables[k][n] = v
        end
    end
    local function getNewEnv()
        local newEnv = dupeTable(old)
        newEnv.perm = {
            getPermission = getPermission,
            setPermission = setPermission,
            dupeKey = dupeKey,

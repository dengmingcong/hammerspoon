-- 工具函数库
local M = {}

-- 检查数组中是否包含某个值
function M.arrayContains(arr, v)
    for _, x in ipairs(arr or {}) do
        if x == v then return true end
    end
    return false
end

-- 检查修饰键是否匹配
function M.modsMatch(flags, mods)
    for _, m in ipairs(mods) do
        if not flags[m] then return false end
    end
    for k, v in pairs(flags) do
        if v and not M.arrayContains(mods, k) then
            return false
        end
    end
    return true
end

-- 检查应用是否匹配规则
function M.appMatch(app, rule)
    local bid = app:bundleID() or ""
    if M.arrayContains(rule.bundleIDs, bid) then return true end

    local name = app:name() or ""
    for _, p in ipairs(rule.namePatterns or {}) do
        if name:match(p) then return true end
    end
    return false
end

return M

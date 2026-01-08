-- 应用快捷键规则配置
local M = {}

M.APP_HOTKEY_RULES = {
    -- ==================== VS Code ====================
    {
        app = {
            bundleIDs = {
                "com.microsoft.VSCode",
                "com.microsoft.VSCodeInsiders",
            },
            namePatterns = { "^Code" },
        },
        hotkeys = {
            { key = "p", mods = { "cmd", "shift" } },   -- Command Palette
            { key = "g", mods = { "ctrl", "shift" } },  -- Source Control
            { key = "j", mods = { "cmd" } },            -- Toggle Panel
        },
    },

    -- ==================== Chrome & Safari ====================
    {
        app = {
            bundleIDs = {
                "com.google.Chrome",
                "com.google.Chrome.canary",
                "com.apple.Safari",
            },
            namePatterns = { "^Google Chrome", "^Safari" },
        },
        hotkeys = {
            { key = "t", mods = { "cmd" } },            -- New Tab
        },
    },

    -- ==================== DingTalk ====================
    {
        app = {
            bundleIDs = {
                "com.alibaba.DingTalkMac",
            },
            namePatterns = { "^DingTalk", "^钉钉" },
        },
        hotkeys = {
            { key = "f", mods = { "cmd" } },            -- Search
        },
    },

    -- ==================== Other App ====================
}

return M

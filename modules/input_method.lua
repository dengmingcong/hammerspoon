-- 输入法模块：智能切换输入法
local constants = require("config.constants")
local rules = require("config.rules")
local utils = require("modules.utils")

local M = {}

-- 模块内部状态
local inputMethodSwitcher = nil
local wakeWatcher = nil
local keepaliveTimer = nil

-- 初始化输入法监听
function M.init()
    -- 创建键盘事件监听
    inputMethodSwitcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local app = hs.application.frontmostApplication()
        if not app then return false end

        local key = event:getCharacters(true)
        if not key then return false end
        key = key:lower()

        local flags = event:getFlags()

        for _, rule in ipairs(rules.APP_HOTKEY_RULES) do
            if utils.appMatch(app, rule.app) then
                for _, hk in ipairs(rule.hotkeys) do
                    if key == hk.key and utils.modsMatch(flags, hk.mods) then
                        if hs.keycodes.currentSourceID() ~= constants.EN_SOURCE_ID then
                            -- 使用系统快捷键切换，避免 macOS CJKV 输入法 bug
                            -- 参考: https://github.com/tekezo/Karabiner/issues/308
                            -- 异步执行避免阻塞主线程
                            hs.timer.doAfter(constants.INPUT_METHOD_SWITCH_DELAY, function()
                                hs.eventtap.keyStroke({"ctrl", "alt"}, "space", 0)
                            end)
                        end
                        return false
                    end
                end
            end
        end
        return false
    end)

    -- 启动事件监听
    inputMethodSwitcher:start()

    -- 系统唤醒后重新启动事件监听
    wakeWatcher = hs.caffeinate.watcher.new(function(event)
        if event == hs.caffeinate.watcher.systemDidWake then
            if inputMethodSwitcher then
                inputMethodSwitcher:stop()
                inputMethodSwitcher:start()
            end
        end
    end)
    wakeWatcher:start()

    -- 守护定时器，若监听被意外停用则重启
    keepaliveTimer = hs.timer.doEvery(constants.KEEPALIVE_INTERVAL, function()
        if inputMethodSwitcher and not inputMethodSwitcher:isEnabled() then
            inputMethodSwitcher:stop()
            inputMethodSwitcher:start()
        end
    end)
end

-- 停止输入法监听
function M.stop()
    if wakeWatcher then
        wakeWatcher:stop()
        wakeWatcher = nil
    end
    if keepaliveTimer then
        keepaliveTimer:stop()
        keepaliveTimer = nil
    end
    if inputMethodSwitcher then
        inputMethodSwitcher:stop()
        inputMethodSwitcher = nil
    end
end

-- 重新加载模块（Hammerspoon 配置重载时调用）
function M.reload()
    M.stop()
    M.init()
end

return M

-- ============================================
-- Hammerspoon 主入口配置文件
-- ============================================

-- 加载功能模块
local inputMethod = require("modules.input_method")
local airpodsVolume = require("modules.airpods_volume")

-- ============================================
-- 初始化所有模块
-- ============================================

inputMethod.init()
airpodsVolume.init()

-- ============================================
-- Hammerspoon 重载时的清理和重新初始化
-- ============================================

-- 添加测试热键
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    -- 重新加载配置
    hs.reload()
end)

-- 添加手动测试热键：按 Cmd+Alt+Ctrl+A 来手动测试 AirPods 音量设置
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", function()
    airpodsVolume.setVolume(25)
end)

function reloadConfig()
    inputMethod.reload()
    airpodsVolume.reload()
end
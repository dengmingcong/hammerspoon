-- ============================================
-- AirPods 音量自动设置模块
-- 在 AirPods 连接时自动设置为指定音量
-- ============================================

local M = {}

-- 配置
local config = {
    -- AirPods 设备名称（子字符串匹配）
    deviceNames = {
        "AirPods"
    },
    -- 连接时自动设置的音量 (0-100)
    targetVolume = 20,
    -- 是否显示通知
    showAlert = true
}

-- 记录上一个连接的设备名称，避免重复触发
local lastDeviceName = ""
local watcherStarted = false

-- 检查设备名称是否匹配 AirPods
local function isAirPods(deviceName)
    if not deviceName then return false end
    
    for _, airpodsName in ipairs(config.deviceNames) do
        if string.find(deviceName, airpodsName, 1, true) then
            return true
        end
    end
    return false
end

-- 音频设备变化回调函数
local function audioDeviceChanged()
    local current = hs.audiodevice.defaultOutputDevice()
    
    if not current then return end
    
    local deviceName = current:name()
    
    -- 设备名称改变时才执行
    if deviceName ~= lastDeviceName then
        lastDeviceName = deviceName
        
        -- 如果是 AirPods，设置音量
        if isAirPods(deviceName) then
            -- 第一次设置：连接后 0.5 秒
            hs.timer.doAfter(0.5, function()
                current:setVolume(config.targetVolume)
            end)
            
            -- 第二次设置：连接后 1.5 秒（确保覆盖系统自动调整）
            hs.timer.doAfter(1.5, function()
                current:setVolume(config.targetVolume)
                hs.alert.show(deviceName .. " 已连接\n音量设置为: " .. config.targetVolume .. "%", 2)
            end)
        end
    end
end

-- 初始化函数
function M.init()
    if watcherStarted then
        return
    end
    
    -- 立即检查当前设备
    local current = hs.audiodevice.defaultOutputDevice()
    if current then
        lastDeviceName = current:name()
    end
    
    -- 设置音频设备变化监听
    hs.audiodevice.watcher.setCallback(audioDeviceChanged)
    hs.audiodevice.watcher:start()
    watcherStarted = true
    
    hs.alert.show("AirPods 音量管理已启用\n目标音量: " .. config.targetVolume .. "%", 2)
end

-- 重载函数
function M.reload()
    watcherStarted = false
    M.init()
end

-- 配置更新函数（供外部调用）
function M.setConfig(options)
    if options.targetVolume then
        config.targetVolume = options.targetVolume
    end
    if options.deviceNames then
        config.deviceNames = options.deviceNames
    end
    if options.showAlert ~= nil then
        config.showAlert = options.showAlert
    end
end

-- 手动设置 AirPods 音量（用于快速调整）
function M.setVolume(volume)
    local current = hs.audiodevice.defaultOutputDevice()
    if current and isAirPods(current:name()) then
        current:setVolume(volume)
        hs.alert.show("音量设置为: " .. volume .. "%", 1)
    else
        hs.alert.show("未找到 AirPods 连接", 1)
    end
end

-- 返回配置（用于查看当前配置）
function M.getConfig()
    return config
end

return M

local L = LibStub("AceLocale-3.0"):NewLocale(..., "zhCN")
if not L then return end

L = L or {}
-- MessageClassifier
L["DISABLE_TIPS"] = "公共频道/世界频道消息去重：已停用"
L["ENABLE_TIPS"] = "公共频道/世界频道消息去重：已启用，可用 /msgdd 命令进行开关。"
L["ENABLE_TIPS_WITH_BIGFOOT"] = "公共频道/世界频道消息去重：已启用，可在小地图大脚按键包中关闭"
L["RESET_TIPS"] = "公共频道/世界频道消息去重：过滤器已重置"

-- Options
L["CONFIG_PAGE_TITLE"] = "聊天消息去重"
L["OPTION_ENABLED"] = "启用重复消息过滤"
L["OPTION_ENABLED_TOOLTIP"] = "不显示公共频道/世界频道中重复的消息"
L["OPTION_MIN_DUP_INTERVAL"] = "允许重复消息出现的最短间隔秒数，设为0始终禁止重复消息"
L["OPTION_PASS_PLAYER_SELF"] = "不过滤自己发送的消息"
L["OPTION_PASS_PLAYER_SELF_TOOLTIP"] = "不过滤玩家自己发送的消息（备注：即使不选中该选项，重复消息也会被发出去，只是不会在聊天窗口显示）"
L["OPTION_RESET"] = "重置过滤器"
L["OPTION_RESET_TOOLTIP"] = "清除重复消息记录，允许重复消息再次显示"

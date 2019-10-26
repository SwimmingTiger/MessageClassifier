local L = LibStub("AceLocale-3.0"):NewLocale(..., "zhTW")
if not L then return end

L = L or {}
-- MessageClassifier
L["DISABLE_TIPS"] = "Public channel/World channel message deduplication: Disabled"
L["ENABLE_TIPS"] = "Public channel/World channel message deduplication: Enabled. You can toggle it with command /msgdd"
L["ENABLE_TIPS_WITH_BIGFOOT"] = "Public channel/World channel message deduplication: Enabled. You can turn it off in the minimap BigFoot button package."
L["RESET_TIPS"] = "Public channel/World channel message deduplication: Filter has been reset"

-- Options
L["CONFIG_PAGE_TITLE"] = "聊天消息去重"
L["OPTION_ENABLED"] = "啓用重複消息過濾"
L["OPTION_ENABLED_TOOLTIP"] = "不顯示公共頻道/世界頻道中重複的消息"
L["OPTION_MIN_DUP_INTERVAL"] = "允許重復消息出現的最短間隔秒數，設為0始終禁止重複消息"
L["OPTION_RESET"] = "重置過濾器"
L["OPTION_RESET_TOOLTIP"] = "清除重復消息記錄，允許重復消息再次顯示"

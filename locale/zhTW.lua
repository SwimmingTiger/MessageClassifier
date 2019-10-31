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

-- Channels
L["CHAN_FULLNAME_GUILD"]="公會"
L["CHAN_FULLNAME_RAID"]="團隊"
L["CHAN_FULLNAME_PARTY"]="小隊"
L["CHAN_FULLNAME_GENERAL"]="綜合"
L["CHAN_FULLNAME_TRADE"]="交易"
L["CHAN_FULLNAME_WORLDDEFENSE"]="世界防務"
L["CHAN_FULLNAME_LOCALDEFENSE"]="本地防務"
L["CHAN_FULLNAME_LFGCHANNEL"]="尋求組隊"
L["CHAN_FULLNAME_BATTLEGROUND"]="戰場"
L["CHAN_FULLNAME_YELL"]="喊道"
L["CHAN_FULLNAME_SAY"]="說"
L["CHAN_FULLNAME_WHISPERTO"]="發送給"
L["CHAN_FULLNAME_WHISPERFROM"]="悄悄地說"
L["CHAN_FULLNAME_BIGFOOTCHANNEL"] = "大腳世界頻道"
L["CHAN_SHORTNAME_GUILD"]="公"
L["CHAN_SHORTNAME_RAID"]="團"
L["CHAN_SHORTNAME_PARTY"]="隊"
L["CHAN_SHORTNAME_YELL"]="喊"
L["CHAN_SHORTNAME_BATTLEGROUND"]="戰"
L["CHAN_SHORTNAME_OFFICER"]="官"
L["CHAN_SHORTNAME_BIGFOOT"]="世";
L["CHAN_SHORTNAME_WHISPERTO"]="密"
L["CHAN_SHORTNAME_WHISPERFROM"]="密"
L["CHAN_SHORTNAME_GENERAL"]="綜"
L["CHAN_SHORTNAME_TRADE"]="交"
L["CHAN_SHORTNAME_LOCALDEFENSE"]="本"
L["CHAN_SHORTNAME_LFGCHANNEL"]="尋"
L["CHAN_SHORTNAME_WORLDDEFENSE"]="世"

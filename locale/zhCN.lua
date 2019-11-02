local L = LibStub("AceLocale-3.0"):NewLocale(..., "zhCN")
if not L then return end

L = L or {}
-- Browser
L["BROWSER_CLASSIFIED_BY_AUTHOR"] = "玩家列表/%s"
L["BROWSER_CLASSIFIED_BY_CHANNEL"] = "频道列表/%s"
L["BROWSER_CLASSIFIED_ALL_MESSAGES"] = "全部发言"
L["BROWSER_STATUS_BAR"] = "共 %d 消息, 唯一 %d, 重复 %d, 重复率 %0.2f%%"
L["BROWSER_TITLE"] = "消息浏览器"

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
L["OPTION_RESET"] = "重置过滤器"
L["OPTION_RESET_TOOLTIP"] = "清除重复消息记录，允许重复消息再次显示"
L["OPTION_OPEN_MESSAGE_BROWSER"] = "打开消息浏览器"
L["OPTION_RULE_SETS_TITLE"] = "消息分类规则"
L["OPTION_ADD_RULE_SET"] = "添加规则"
L["OPTION_EDIT_RULE_SET"] = "编辑"
L["OPTION_REMOVE_RULE_SET"] = "移除"
L["OPTION_RULE_SETS"] = "自定义规则"
L["OPTION_DEFAULT_RULE_SETS"] = "默认规则"
L["OPTION_RULE_LOGIC"] = "达成条件"
L["OPTION_RULE_LOGIC_OR"] = "任一"
L["OPTION_RULE_LOGIC_AND"] = "全部"

-- Localized class variable
L["author"] = "作者"
L["channel"] = "频道"
L["content"] = "内容"

-- Rule Operators
L["unconditional"] = "无条件"
L["equal"] = "等于"
L["not equal"] = "不等于"
L["contain"] = "包含"
L["not contain"] = "不包含"
L["match"] = "匹配"
L["not match"] = "不匹配"

-- Channels
L["CHAN_FULLNAME_GUILD"]="公会"
L["CHAN_FULLNAME_RAID"]="团队"
L["CHAN_FULLNAME_PARTY"]="小队"
L["CHAN_FULLNAME_GENERAL"]="综合"
L["CHAN_FULLNAME_TRADE"]="交易"
L["CHAN_FULLNAME_WORLDDEFENSE"]="世界防务"
L["CHAN_FULLNAME_LOCALDEFENSE"]="本地防务"
L["CHAN_FULLNAME_LFGCHANNEL"]="寻求组队"
L["CHAN_FULLNAME_BATTLEGROUND"]="战场"
L["CHAN_FULLNAME_YELL"]="喊道"
L["CHAN_FULLNAME_SAY"]="说"
L["CHAN_FULLNAME_WHISPERTO"]="发送给"
L["CHAN_FULLNAME_WHISPERFROM"]="悄悄地说"
L["CHAN_FULLNAME_BIGFOOTCHANNEL"] = "大脚世界频道"
L["CHAN_SHORTNAME_GUILD"]="公"
L["CHAN_SHORTNAME_RAID"]="团"
L["CHAN_SHORTNAME_PARTY"]="队"
L["CHAN_SHORTNAME_YELL"]="喊"
L["CHAN_SHORTNAME_BATTLEGROUND"]="战"
L["CHAN_SHORTNAME_OFFICER"]="官"
L["CHAN_SHORTNAME_BIGFOOT"]="世"
L["CHAN_SHORTNAME_WHISPERTO"]="密"
L["CHAN_SHORTNAME_WHISPERFROM"]="密"
L["CHAN_SHORTNAME_GENERAL"]="综"
L["CHAN_SHORTNAME_TRADE"]="交"
L["CHAN_SHORTNAME_LOCALDEFENSE"]="本"
L["CHAN_SHORTNAME_LFGCHANNEL"]="寻"
L["CHAN_SHORTNAME_WORLDDEFENSE"]="世"

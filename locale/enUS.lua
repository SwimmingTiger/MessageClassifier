local L = LibStub("AceLocale-3.0"):NewLocale(..., "enUS", true, nil)
if not L then return end

L = L or {}
-- MessageClassifier
L["DISABLE_TIPS"] = "Public channel/World channel message deduplication: Disabled"
L["ENABLE_TIPS"] = "Public channel/World channel message deduplication: Enabled. You can toggle it with command /msgdd"
L["ENABLE_TIPS_WITH_BIGFOOT"] = "Public channel/World channel message deduplication: Enabled. You can turn it off in the minimap BigFoot button package."
L["RESET_TIPS"] = "Public channel/World channel message deduplication: Filter has been reset"

-- Options
L["CONFIG_PAGE_TITLE"] = "Message Deduplication"
L["OPTION_ENABLED"] = "Enable duplicate message filter"
L["OPTION_ENABLED_TOOLTIP"] = "Do not display duplicate messages in public channel/world channels"
L["OPTION_MIN_DUP_INTERVAL"] = "Min seconds for duplicate messages appear, 0 to always hide"
L["OPTION_PASS_PLAYER_SELF"] = "Do not filter messages sent by yourself"
L["OPTION_PASS_PLAYER_SELF_TOOLTIP"] = "Do not filter the messages sent by the player self (Note: even if this option is not enabled, the duplicate message will be sent, but will not be displayed in the chat window)"
L["OPTION_RESET"] = "Reset filter"
L["OPTION_RESET_TOOLTIP"] = "Clear duplicate message records, allowing duplicate messages to be displayed again"

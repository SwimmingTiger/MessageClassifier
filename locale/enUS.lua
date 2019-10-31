local L = LibStub("AceLocale-3.0"):NewLocale(..., "enUS", true, nil)
if not L then return end

L = L or {}
-- Browser
L["BROWSER_CLASSIFIED_BY_AUTHOR"] = "By Author/%s"
L["BROWSER_CLASSIFIED_BY_CHANNEL"] = "By Channel/%s"
L["BROWSER_CLASSIFIED_ALL_MESSAGES"] = "All Messages"
L["BROWSER_STATUS_BAR"] = "All messages %d, unique %d, duplicate %d, duplicate rate %0.2f%%"
L["BROWSER_TITLE"] = "Message Browser"

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
L["OPTION_RESET"] = "Reset filter"
L["OPTION_RESET_TOOLTIP"] = "Clear duplicate message records, allowing duplicate messages to be displayed again"

-- Channels
L["CHAN_FULLNAME_Guild"] = true
L["CHAN_FULLNAME_Raid"] = true
L["CHAN_FULLNAME_Party"] = true
L["CHAN_FULLNAME_General"] = true
L["CHAN_FULLNAME_Trade"] = true
L["CHAN_FULLNAME_WorldDefense"] = true
L["CHAN_FULLNAME_LocalDefense"] = true
L["CHAN_FULLNAME_LFGChannel"] = true
L["CHAN_FULLNAME_BattleGround"] = true
L["CHAN_FULLNAME_Yell"] = true
L["CHAN_FULLNAME_Say"] = true
L["CHAN_FULLNAME_WhisperTo"] = true
L["CHAN_FULLNAME_WhisperFrom"] = true
L["CHAN_FULLNAME_BigFootChannel"] = true
L["CHAN_SHORTNAME_Guild"] = true
L["CHAN_SHORTNAME_Raid"] = true
L["CHAN_SHORTNAME_Party"] = true
L["CHAN_SHORTNAME_Yell"] = true
L["CHAN_SHORTNAME_BattleGround"] = true
L["CHAN_SHORTNAME_Officer"] = true
L["CHAN_SHORTNAME_BigFoot"] = true
L["CHAN_SHORTNAME_WhisperTo"] = true
L["CHAN_SHORTNAME_WhisperFrom"] = true
L["CHAN_SHORTNAME_General"] = true
L["CHAN_SHORTNAME_Trade"] = true
L["CHAN_SHORTNAME_LocalDefense"] = true
L["CHAN_SHORTNAME_LFGChannel"] = true
L["CHAN_SHORTNAME_WorldDefense"] = true

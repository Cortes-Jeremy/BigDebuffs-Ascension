-- [[ Constants ]]

-- Expension
WOW_PROJECT_ASCENSION = 0	 			-- ASCENSION
WOW_PROJECT_MAINLINE = 1	 			-- Retail
WOW_PROJECT_CLASSIC = 2					-- Classic
WOW_PROJECT_WOWLABS = 3					-- Plunderstorm
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5 --Burning Crusade Classic
WOW_PROJECT_WRATH_CLASSIC = 11	 		-- Wrath
WOW_PROJECT_CATACLYSM_CLASSIC = 14		-- Cataclysm Classic
WOW_PROJECT_MISTS_CLASSIC = 19			-- Mists of Pandaria Classic
WOW_PROJECT_ID = WOW_PROJECT_WRATH_CLASSIC

-- GlobalString (enUS)
BUFF_STACKS_OVERFLOW = "*"

-- [[ Show Raid Frames for BD:Test() ]]

local saved

function ShowRaidFrames(show)
    if show then
        if not saved then
            saved = { CompactRaidFrameManager:IsShown(), CompactRaidFrameContainer:IsShown() }
        end
        CompactRaidFrameManager:Show()
        CompactRaidFrameContainer:Show()
        CompactRaidFrameContainer:TryUpdate()
    elseif saved then
        if saved[1] then
            CompactRaidFrameManager:Show()
        else
            CompactRaidFrameManager:Hide()
        end
        if saved[2] then
            CompactRaidFrameContainer:Show()
        else
            CompactRaidFrameContainer:Hide()
        end
        CompactRaidFrameContainer:TryUpdate()
        saved = nil
    end
end

-- [[ C_Spell ]]

local GetSpellTexture = GetSpellTexture
local GetSpellInfo = GetSpellInfo
function C_GetSpellTexture(ID, BookType)
	local _, Icon
	if ( BookType ) then
		Icon = GetSpellTexture(ID, BookType)
	else
		_, _, Icon = GetSpellInfo(ID)
	end
	return Icon, Icon
end

-- [[ Unit ]]

local UnitChannelInfo = UnitChannelInfo
function C_UnitChannelInfo(Unit)
	local Name, Rank, Text, Texture, StartTime, EndTime, IsTradeskill, Interruptable, SpellID = UnitChannelInfo(Unit)
	return Name, Text, Texture, StartTime, EndTime, IsTradeskill, Interruptable, SpellID
end

-- [[ Aura ]]

local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo
local UnitAffectingCombat = UnitAffectingCombat
local _, CLASS_PLAYER = UnitClass("player")
local AURA

function SpellIsSelfBuff(SpellID)
    if ( SpellID ) then
        local SpellName = GetSpellInfo(SpellID)
        local Info = (SpellName) and AURA[SpellName]

        if ( Info ) then
            return Info.SelfOnly, Info.CanApply
        end
    end
end

function SpellGetVisibilityInfo(SpellID, Type)
    if ( SpellID and Type ) then
        local SpellName = GetSpellInfo(SpellID)
        local Info = (SpellName) and AURA[SpellName]

        if ( Info ) then
            local ShowMine, ShowSpec
            if ( Type == "RAID_INCOMBAT" ) then
                ShowMine = Info.ShowMine_INCOMBAT
                ShowSpec = Info.ShowSpec_INCOMBAT
            elseif ( Type == "RAID_OUTOFCOMBAT" ) then
                ShowMine = Info.ShowMine_OUTCOMBAT
                ShowSpec = Info.ShowSpec_OUTCOMBAT
            end

            return (ShowMine ~= nil or ShowSpec ~= nil), ShowMine, ShowSpec
        end
    end
end

--[[ Aura Information ]]

local function Aura(SpellID, CanApply, SelfOnly, ShowMine_INCOMBAT, ShowMine_OUTCOMBAT, ShowSpec_INCOMBAT, ShowSpec_OUTCOMBAT)
    AURA = AURA or {}

    AURA[GetSpellInfo(SpellID)] = {
        CanApply = CanApply, -- Player can cast it.
        SelfOnly = SelfOnly, -- Spell is not usable on others.

       --[[
            Combat State Information: RAID_INCOMBAT, RAID_OUTOFCOMBAT
                ShowMine: whether to show the spell if cast by the player/player's pet/vehicle (e.g. the Paladin Forbearance debuff)
                ShowSpec: whether to show the spell for the current specialization of the player, it will override all others if set.
        ]]
        ShowMine_INCOMBAT = ShowMine_INCOMBAT,
        ShowMine_OUTCOMBAT = ShowMine_OUTCOMBAT,

        ShowSpec_INCOMBAT = ShowSpec_INCOMBAT,
        ShowSpec_OUTCOMBAT = ShowSpec_OUTCOMBAT,
    }
end

if ( CLASS_PLAYER == "DEATHKNIGHT" ) then
    Aura(1148265, true, true) -- Unholy Presence
    Aura(1148263, true, true) -- Frost Presence
    Aura(1148266, true, true) -- Blood Presence
    Aura(1145529, true, true) -- Blood Tap
    Aura(1149016, true, false) -- Hysteria
    Aura(1157330, true, false) -- Horn of Winter
    Aura(1149028, true, false) -- Dancing Rune Weapon

    Aura(3714, true, false, false, true) -- Path of Frost
elseif ( CLASS_PLAYER == "DRUID" ) then
    Aura(1129166, true, false) -- Innervate
    Aura(1109634, true, true) -- Dire Bear Form
    Aura(1100768, true, true) -- Cat Form
    Aura(1148451, true, false) -- Lifebloom
    Aura(1148441, true, false) -- Rejuvenation
    Aura(1148443, true, false) -- Regrowth
    Aura(1153251, true, false) -- Wild Growth
    Aura(1161336, true, true) -- Survival Instincts
    Aura(1150334, true, true) -- Berserk
    Aura(1105229, true, true) -- Enrage
    Aura(1122812, true, true) -- Barkskin
    Aura(1153312, true, true) -- Nature's Grasp
    Aura(1122842, true, true) -- Frenzied Regeneration
    Aura(1102893, true, false) -- Abolish Poison

    Aura(2304509, true, false) -- Stampeding Roar
    Aura(1186384, true, false) -- Efflorescence
    Aura(1567851, true, false) -- Stonebark

    Aura(1100467, true, false, false, true) -- Thorns
    Aura(1101126, true, false, false, true) -- Mark of the Wild
    Aura(1121849, true, false, false, true) -- Gift of the Wild
elseif ( CLASS_PLAYER == "HUNTER" ) then
    Aura(1105384, true, true) -- Feign Death
    Aura(1103045, true, true) -- Rapid Fire
    Aura(1153480, true, false) -- Roar of Sacrifice
    Aura(1153271, true, false) -- Master's Call
    Aura(1153476, true, false) -- Intervene

    Aura(1119506, true, false, false, true) -- Trueshot Aura
elseif ( CLASS_PLAYER == "MAGE" ) then
    Aura(1143039, true, true) -- Ice Barrier
    Aura(1145438, true, true) -- Ice Block
    Aura(1143012, true, true) -- Frost Ward
    Aura(1143008, true, true) -- Ice Armor
    Aura(1107301, true, true) -- Frost Armor
    Aura(1112472, true, true) -- Icy Veins
    Aura(1143010, true, true) -- Fire Ward
    Aura(1143046, true, true) -- Molten Armor
    Aura(1143020, true, true) -- Mana Shield
    Aura(1143024, true, true) -- Mage Armor
    Aura(1100066, true, true) -- Invisibility
    Aura(1100130, true, false) -- Slow Fall
    Aura(1111213, true, true) -- Arcane Concentration
    Aura(1112043, true, true) -- Presence of Mind
    Aura(1112042, true, true) -- Arcane Power
    Aura(1131579, true, true) -- Arcane Empowerment

    Aura(1161024, true, false, false, true) -- Dalaran Intellect
    Aura(1161316, true, false, false, true) -- Dalaran Brilliance
    Aura(1142995, true, false, false, true) -- Arcane Intellect
    Aura(1143002, true, false, false, true) -- Arcane Brilliance
    Aura(1143015, true, false, false, true) -- Dampen Magic
    Aura(1154646, true, false, false, true) -- Focus Magic
elseif ( CLASS_PLAYER == "PALADIN" ) then
    Aura(1153601, true, false) -- Sacred Shield
    Aura(1153563, true, false) -- Beacon of Light
    Aura(1106940, true, false) -- Hand of Sacrifice
    Aura(1164205, true, false) -- Divine Sacrifice
    Aura(1131821, true, true) -- Aura Mastery
    Aura(1100642, true, true) -- Divine Shield
    Aura(1101022, true, false) -- Hand of Protection
    Aura(1101044, true, false) -- Hand of Freedom
    Aura(1154428, true, true) -- Divine Plea
    Aura(1148952, true, true) -- Holy Shield
    Aura(1148942, true, true) -- Devotion Aura
    Aura(1154043, true, true) -- Retribution Aura
    Aura(1119746, true, true) -- Concentration Aura
    Aura(1148943, true, true) -- Shadow Resistance Aura
    Aura(1148945, true, true) -- Frost Resistance Aura
    Aura(1148947, true, true) -- Fire Resistance Aura
    Aura(1132223, true, true) -- Crusader Aura
    Aura(1131884, true, true) -- Avenging Wrath
    Aura(1154203, true, false) -- Sheath of Light
    Aura(1120053, true, true) -- Vengeance
    Aura(1159578, true, true) -- The Art of War

    Aura(1101038, true, false) -- Hand of Salvation
    Aura(1554912, true, false) -- Word of Glory HoT

    Aura(1120217, true, false, false, true) -- Blessing of Kings
    Aura(1125898, true, false, false, true) -- Greater Blessing of Kings
    Aura(1148936, true, false, false, true) -- Blessing of Wisdom
    Aura(1148938, true, false, false, true) -- Greater Blessing of Wisdom
    Aura(1148932, true, false, false, true) -- Blessing of Might
    Aura(1148934, true, false, false, true) -- Greater Blessing of Might
    Aura(1125899, true, false, false, true) -- Greater Blessing of Sanctuary
    Aura(1120911, true, false, false, true) -- Blessing of Sanctuary
elseif ( CLASS_PLAYER == "PRIEST" ) then
    Aura(1148111, true, false) -- Prayer of Mending
    Aura(1133206, true, false) -- Pain Suppression
    Aura(1148068, true, false) -- Renew
    Aura(1148066, true, false) -- Power Word: Shield
    Aura(72418, true, true) -- Chilling Knowledge
    Aura(1147930, false, false) -- Grace
    Aura(1110060, true, false) -- Power Infusion
    Aura(1100586, true, true) -- Fade
    Aura(1148168, true, true) -- Inner Fire
    Aura(1114751, true, true) -- Inner Focus
    Aura(1106346, true, false) -- Fear Ward
    Aura(1164901, true, false) -- Hymn of Hope
    Aura(1101706, true, false) -- Levitate
    Aura(1164843, false, false) -- Divine Hymn
    Aura(1159891, false, false) -- Borrowed Time
    Aura(1100552, true, false) -- Abolish Disease
    Aura(1115473, true, true) -- Shadowform
    Aura(1115286, true, true) -- Vampiric Embrace
    Aura(1149694, true, true) -- Improved Spirit Tap
    Aura(1147788, true, false) -- Guardian Spirit
    Aura(1133151, true, true) -- Surge of Light
    Aura(1133151, true, true) -- Inspiration
    Aura(1107001, true, false) -- Lightwell Renew
    Aura(1127827, true, true) -- Spirit of Redemption
    Aura(1163734, true, true) -- Serendipity
    Aura(1165081, true, false) -- Body and Soul
    Aura(1163944, false, false) -- Renewed Hope

    Aura(2305014, false, false) -- Halo

    Aura(1148073, true, false, false, true) -- Divine Spirit
    Aura(1148074, true, false, false, true) -- Prayer of Spirit
    Aura(1148169, true, false, false, true) -- Shadow Protection
    Aura(1148170, true, false, false, true) -- Prayer of Shadow Protection
    Aura(1148162, true, false, false, true) -- Prayer of Fortitude
    Aura(1148161, true, false, false, true) -- Power Word: Fortitude
elseif ( CLASS_PLAYER == "ROGUE" ) then
    Aura(1101784, true, true) -- Stealth
    Aura(1131665, true, true) -- Master of Subtlety
    Aura(1126669, true, true) -- Evasion
    Aura(1111305, true, true) -- Sprint
    Aura(1126888, true, true) -- Vanish
    Aura(1136554, true, true) -- Shadowstep
    Aura(1148659, true, true) -- Feint
    Aura(1131224, true, true) -- Clock of Shadow
    Aura(1151713, true, true) -- Shadow dance
    Aura(1114177, true, true) -- Cold Blood
    Aura(1157934, true, false) -- Tricks of the Trade
elseif ( CLASS_PLAYER == "SHAMAN" ) then
    Aura(1149284, true, false) -- Earth Shield
    Aura(1108515, false, false) -- Windfury Totem
    Aura(1108178, true, false) -- Grounding Totem
    Aura(1132182, true, false) -- Heroism
    Aura(1102825, true, false) -- Bloodlust
    Aura(1161301, true, false) -- Riptide
    Aura(1151466, true, false) -- Elemental Oath

    Aura(1116237, true, false) -- Ancestral Fortitude
    Aura(1151997, true, false) -- Earthliving
elseif ( CLASS_PLAYER == "WARLOCK" ) then
    Aura(1102947, true, false) -- Fire Shield
    Aura(1100132, true, false) -- Detect Invisibility
    Aura(1119028, true, false) -- Soul Link
    Aura(1154424, true, false) -- Fel Intelligence
elseif ( CLASS_PLAYER == "WARRIOR" ) then
    Aura(1102687, true, true) -- Bloodrage
    Aura(1118499, true, true) -- Berserker Rage
    Aura(1112328, true, true) -- Sweeping Strikes
    Aura(1123920, true, true) -- Spell Reflection
    Aura(1100871, true, true) -- Shield Wall
    Aura(1102565, true, true) -- Shield Block
    Aura(1155694, true, true) -- Enraged Regeneration
    Aura(1101719, true, true) -- Recklessness
    Aura(1157522, true, true) -- Enrage
    Aura(1120230, true, true) -- Retaliation
    Aura(1146924, true, true) -- Bladestorm
    Aura(1147440, true, false) -- Commanding Shout
    Aura(1147436, true, false) -- Battle Shout
    Aura(1146913, true, true) -- Bloodsurge
    Aura(1112292, true, true) -- Death Wish
    Aura(1116492, true, true) -- Blood Craze
    Aura(1165156, true, true) -- Juggernaut
    Aura(1103411, true, false) -- Intervene
    Aura(1150720, true, false) -- Vigilance

    Aura(1150720, true, false, false, true) -- Vigilance
end

--[[ Global Auras ]]

Aura(69127, nil, nil, nil, nil, false, true) -- Chill of the Throne
Aura(26013, nil, nil, nil, nil, false, true) -- Deserter
Aura(31694, nil, nil, nil, nil, false, false) -- Strange Feeling
Aura(70013, nil, nil, nil, nil, false, false) -- Quel'Delar's Compulsion

--[[ UNITAURA / UNITBUFF / UNITDEBUFF Modern payload ]]

function C_UnitAura(...)
    local Name, Rank, Icon, Count, Type, Duration, Expire, Caster, Steal, Consolidate, ID = UnitAura(...)
    local Aura = AURA[Name]
    return Name, Icon, Count, Type, Duration, Expire, Caster, Steal, Consolidate, ID, (Aura and Aura.CanApply)
end
function C_UnitBuff(...)
    local Name, Rank, Icon, Count, Type, Duration, Expire, Caster, Steal, Consolidate, ID = UnitBuff(...)
    local Aura = AURA[Name]
    return Name, Icon, Count, Type, Duration, Expire, Caster, Steal, Consolidate, ID, (Aura and Aura.CanApply)
end
function C_UnitDebuff(...)
    local Name, Rank, Icon, Count, Type, Duration, Expire, Caster, Steal, Consolidate, ID = UnitDebuff(...)
    return Name, Icon, Count, Type, Duration, Expire, Caster, Steal, Consolidate, ID
end

--[[ CompactUnitFrame_UtilShouldDisplayDebuff Note: Support if CompactRaidFrames not installed. ]]

local SpellGetVisibilityInfo = SpellGetVisibilityInfo
function CompactUnitFrame_UtilShouldDisplayDebuff(...)
    local _, _, _, _, _, _, _, Caster, _, _, SpellID = UnitDebuff(...)
    if ( SpellID ) then
        local HasCustom, AlwaysShowMine, ShowForMySpec = SpellGetVisibilityInfo(SpellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if ( HasCustom ) then
            return ShowForMySpec or (AlwaysShowMine and (Caster == "player" or Caster == "pet" or Caster == "vehicle"))
        end
        return true
    end
end

--[[ Masque 9.1.1 (3.3.5 backport) icon problems handling ]]

local _MasqueUFState = {}
function OnMasqueUnitFrameCallback(Group, SkinID, Backdrop, Shadow, Gloss, Colors, Disabled)

    local state = _MasqueUFState[Group]
    if not state then
        _MasqueUFState[Group] = { SkinID = SkinID, Disabled = Disabled }
        return
    end

    if state.SkinID == SkinID and state.Disabled == Disabled then return end

    state.SkinID = SkinID
    state.Disabled = Disabled

    if Disabled then
        DEFAULT_CHAT_FRAME:AddMessage( "|cffffcc00BigDebuffs:|r Masque Disabled for ".. Group ..". Please reload your interface (/reload) to avoid issues.")
    end

end

local _MasqueNPState = {}
function OnMasqueNamePlateCallback(Group, SkinID, Backdrop, Shadow, Gloss, Colors, Disabled)

    local state = _MasqueNPState[Group]
    if not state then
        _MasqueNPState[Group] = { SkinID = SkinID, Disabled = Disabled }
        return
    end

    if state.SkinID == SkinID and state.Disabled == Disabled then return end

    state.SkinID = SkinID
    state.Disabled = Disabled

    if Disabled then
        DEFAULT_CHAT_FRAME:AddMessage( "|cffffcc00BigDebuffs:|r Masque Disabled for ".. Group ..". Please reload your interface (/reload) to avoid issues.")
    end
end

function RestoreIconLayout(frame, isUnitFrame)
    if not frame then return end
    if not frame.icon then return end

    local icon = frame.icon
    icon:ClearAllPoints()
    icon:SetAllPoints(frame)

    if isUnitFrame then
        -- frame.icon:SetDrawLayer("BACKGROUND", 7)
        frame.icon:SetDrawLayer("BORDER", 7)
    end
end

--[[ Ascension missing functions ]]

function CompactUnitFrame_UtilIsBossAura(unit, index, filter, checkAsBuff)
    -- make sure you are using the correct index here!  allAurasIndex ~= debuffIndex
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura;
    if (checkAsBuff) then
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitBuff(unit, index, filter);
    else
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter);
    end
    return isBossAura;
end

function CompactUnitFrame_UtilIsPriorityDebuff(unit, index, filter)  -- USe AuraUtil_IsPriorityDebuff for now its the same bassically
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter)

	local _, classFilename = UnitClass("player");
	if ( classFilename == "PALADIN" ) then
		if ( spellId == 25771 ) then	--Forbearance
			return true
		end
	elseif ( classFilename == "PRIEST" ) then
		if ( spellId == 6788 ) then	--Weakened Soul
			return true
		end
	end

	return false
end

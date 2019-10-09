-- GettingThingsHealed-Classic (GTH)
-- Forked and updated for WoW Classic by Neffer of Razorgore (EU)
-- Originally GettingThingsHealed (GTH) By Dagma of Argent Dawn (US)
-- Some code based on code from Heal Organizer 2.2 by Progman and Ackis

-- globals

GTHversion = "v0.1.0"

--colors
local gthcolor = {
    dragborder = { r=0.5 , g=0.5 , b=0.5 , a=1 },
    dragback = { r=0 , g=0 , b=0 , a=0.3 },
    draghighlight = { r=1 , g=1 , b=0 , a=1 },
    assignpoolborder = { r=0.5 , g=0.5 , b=0.5 , a=1 }
 }
 
-- textures
local texdialogborder = "Interface\\DialogFrame\\UI-DialogBox-Border"
local textooltipborder = "Interface\\Tooltips\\UI-Tooltip-Border"
local texdragborder = "Interface\\GLUES\\COMMON\\TextPanel-Border"
local texdisconnect = "Interface\\CHARACTERFRAME\\Disconnect-Icon"
local texwhiteback = "Interface\\Buttons\\WHITE8X8"
local texreplines = "Interface\\PaperDollInfoFrame\\UI-Character-ReputationLines"

-- other globals
local unitids = {};

local menusstartx = 165
local menusstartxOrig = 165
local menusstarty = -40
local menusstartyOrig = -40
local rowheight = 28
local tankpoolrowheight = 23
local colwidth = 130
local phasewidth = 130
local dragwidthstd = 100
local gthwinheight = 330

GTHdebug = false;

GTHmostrecentpresetload = GTHL["new preset"];

local customtarget = nil;

local maxassignments = 8;

local GTHnameflag = nil; -- used to decide the function of naming edit box at runtime

GTHframes = {}; -- global frames

GTHdeathQueue = {}
GTHofflineList = {}
GTHSoRlist = { ["nobody"]=true }
GTHsor_name = GetSpellInfo( 20711 );

-- healer list and class list; these are defaults before a raid is formed, unless there is a saved roster
GTHhealerList = {
    ["CoHPriest1"] = { ["class"]="PRIEST" , ["talents"]={14,57,0} },
    ["Druid1"] = { ["class"]="DRUID" , ["talents"]={11,0,50} },
    ["Druid2"] = { ["class"]="DRUID" , ["talents"]={11,0,50} },
    ["Pally1"] = { ["class"]="PALADIN" , ["talents"]={42,19,0} },
    ["Shaman1"] = { ["class"]="SHAMAN" , ["talents"]={11,0,50} },
    ["Shaman2"] = { ["class"]="SHAMAN" , ["talents"]={11,0,50} },
    ["Pally2"] = { ["class"]="PALADIN" , ["talents"]={41,20,0} },
    ["CoHPriest2"] = { ["class"]="PRIEST" , ["talents"]={14,57,0} },
    ["DiscPriest1"] = { ["class"]="PRIEST" , ["talents"]={57,14,0} },
    ["ShadowPriest"] = { ["class"]="PRIEST" , ["talents"]={13,0,58} },
    ["ProtPally"] = { ["class"]="PALADIN" , ["talents"]={13,48,0} },
    ["Boomkin"] = { ["class"]="DRUID" , ["talents"]={51,0,10} },
    ["Feral"] = { ["class"]="DRUID" , ["talents"]={0,51,10} },
    ["Mental"] = { ["class"]="SHAMAN" , ["talents"]={51,0,10} },
    ["Enhance"] = { ["class"]="SHAMAN" , ["talents"]={0,51,10} },
    ["Retnoob"] = { ["class"]="PALADIN" , ["talents"]={5,5,51} },
    ["UnknownShaman"] = { ["class"]="SHAMAN" }
}
GTHhealerListDefault = nil
GTHhealerRows = 3

-- tank list
-- tank classes are: WARRIOR, DRUID, PALADIN, DEATHKNIGHT
-- this list contains all members of those classes and filters by spec, like healer list
GTHtankList = {
    ["Druid1"] = { ["class"]="DRUID" , ["talents"]={11,0,50} },
    ["Druid2"] = { ["class"]="DRUID" , ["talents"]={11,0,50} },
    ["Pally1"] = { ["class"]="PALADIN" , ["talents"]={42,19,0} },
    ["Pally2"] = { ["class"]="PALADIN" , ["talents"]={41,20,0} },
    ["ProtPally"] = { ["class"]="PALADIN" , ["talents"]={13,48,0} },
    ["Boomkin"] = { ["class"]="DRUID" , ["talents"]={51,0,10} },
    ["Feral"] = { ["class"]="DRUID" , ["talents"]={0,51,10} },
    ["Retnoob"] = { ["class"]="PALADIN" , ["talents"]={5,5,51} },
    ["ProtWarrior"] = { ["class"]="WARRIOR" , ["talents"]={5,5,51} },
    ["FuryWarrior"] = { ["class"]="WARRIOR" , ["talents"]={5,51,5} }
}
GTHtankListDefault = nil
GTHtankRows = 2

GTHassignment = {
    [GTHL["Phase"].." 1"] = {
    	["xtagsx"] = { ["order"]=1 , ["aorder"]={ [GTHL["New assignment"]]=1 } },
        [GTHL["New assignment"]] = { }
    }
}; -- the current assignment

GTHassignmentPrev = nil; -- keeps most recent assignment scheme, doesn't save; allows for an "undo"

GTHdisplayphase = GTHL["phase"].." 1";

GTHpresets = {
    [GTHL["New"]] = {
        [GTHL["Phase"].." 1"] = {
    		["xtagsx"] = { ["order"]=1 , ["aorder"]={ [GTHL["New assignment"]]=1 } },
        	[GTHL["New assignment"]] = { }
    	}
    } -- end blank
}

-- spec icons
-- GTHspecicons = {
--     ["DRUID"] = {
--         [1] = "Spell_Nature_ForceOfNature",
--         [2] = "Ability_Racial_BearForm",
--         [3] = "Ability_Druid_TreeofLife"
--     },
--     ["PRIEST"] = {
--         [1] = "Spell_Holy_Penance",
--         [2] = "Spell_Holy_CircleOfRenewal",
--         [3] = "Spell_Shadow_Shadowform"
--     },
--     ["SHAMAN"] = {
--         [1] = "Spell_Shaman_ThunderStorm",
--         [2] = "Spell_Shaman_ImprovedStormstrike",
--         [3] = "Spell_Shaman_TidalWaves"
--     },
--     ["PALADIN"] = {
--         [1] = "Ability_Paladin_BeaconofLight",
--         [2] = "Spell_Holy_AvengersShield",
--         [3] = "Ability_Paladin_DivineStorm"
--     },
--     -- tank classes
--     ["WARRIOR"] = {
--         [1] = "Ability_Warrior_SavageBlow",
--         [2] = "Ability_Warrior_Rampage",
--         [3] = "Ability_Warrior_DefensiveStance"
--     },
--     ["DEATHKNIGHT"] = {
--         [1] = "Spell_Deathknight_BloodPresence",
--         [2] = "Spell_Deathknight_FrostPresence",
--         [3] = "Spell_Deathknight_UnholyPresence"
--     }
-- }

-- raid target icons in Interface\\TARGETINGFRAME\\
GTHluckycharms = {
    [1] = "UI-RaidTargetingIcon_1", -- star
    [2] = "UI-RaidTargetingIcon_2", -- circle
    [3] = "UI-RAIDTARGETINGICON_3", -- diamond
    [4] = "UI-RaidTargetingIcon_4", -- triangle
    [5] = "UI-RaidTargetingIcon_5", -- moon
    [6] = "UI-RaidTargetingIcon_6", -- square
    [7] = "UI-RaidTargetingIcon_7", -- cross (X)
    [8] = "UI-RaidTargetingIcon_8", -- skull
}

-- saved variables, per character
GTHData = {
	announceDeaths = false,     -- announce healer deaths to channel
	announceOffline = false,    -- announce disconnects
	verbose = true,	       -- verbose message formats
    announcechannel = "RAID",      -- custom announce channel
    assignment = nil,          -- saved current assignment
    gthversion = GTHversion,     -- version mark for pref updating
    displayphase = nil,        -- currently displayed phase
    playerPresets = {}         -- saved player presets
}

GTHDataDefaults = {
	announceDeaths = false,     -- announce healer deaths to channel
	announceOffline = false,    -- announce disconnects
	verbose = true,	       -- verbose message formats
    announcechannel = "RAID",      -- custom announce channel
    assignment = nil,          -- saved current assignment
    gthversion = GTHversion,     -- version mark for pref updating
    displayphase = nil,        -- currently displayed phase
    playerPresets = {}         -- saved player presets
}

-- saved roster
GTHDataRoster = {
    ["GTHhealerList"] = nil,
    ["GTHtankList"] = nil
}
GTHFlagRealRoster = false

GTHBroadcastHeader = GTHL["Healing assignments:"]
GTHBroadcastPhaseHeader = "{"..GTHL["Star"].."}"..GTHL["Phase"]..": %P"
GTHBroadcastLine = "    %A: %H"
GTHBroadcastFooter = "( '/w "..UnitName("player").." heal!' "..GTHL["to repeat"]..". )"

-- session-only flags that control social behavior of the add-on
GTHsessionflags = {
	announcements = false -- toggled true on own broadcast, toggled off on another's broadcast. this stops death spam from multiple people, and no spam until you broadcast yourself.
}

-- Initialize

function GTH_OnLoad(self)

    gthprint('GTH-Trace: GTH_OnLoad');

    -- register events
    --- initialization events
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("VARIABLES_LOADED");
    
    -- catch whispers, for sending assignments back to healers who request
    self:RegisterEvent("CHAT_MSG_WHISPER");
    
    -- catch addon messages
    self:RegisterEvent("CHAT_MSG_ADDON");
    
    -- raid composition events
    self:RegisterEvent("GROUP_ROSTER_UPDATE");
    self:RegisterEvent("RAID_ROSTER_UPDATE");
    
    -- combat log event, so we can detect healer deaths and notify
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    
    -- disconnect events
    self:RegisterEvent("PARTY_MEMBER_DISABLE")
    self:RegisterEvent("PARTY_MEMBER_ENABLE")
    
    -- Raid target icon changes
    self:RegisterEvent("RAID_TARGET_UPDATE")
    
    -- Detect dual-spec talent swaps
    -- self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    -- talent inspect event
    -- this fires after a successful NotifyInspect("unit")
    -- this:RegisterEvent("INSPECT_TALENT_READY");
	
	-- slash init
	SlashCmdList["GTHslash"] = GTH_Options;
	SLASH_GTHslash1 = "/gth";

end

function GTHtf(flag)
    if flag then return 1 else return 0 end
end

-- slash handler
function GTH_Options(msg)
    
    local param,omsg;
    omsg = msg;
    msg,param = strsplit(" ",msg,2);
    
    if msg == "help" then
        -- print full help
        gthprint("Getting Things Healed option commands:");
        gthprint("    /gth: Show the config dialog");
        gthprint("    /gth scan: Force rescan of healers in raid");
    elseif msg == "pollroles" then
        -- dump all raid member roles to main output
        for i = 1,GetNumGroupMembers() do
            local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("raid"..i)
            local name = GetRaidRosterInfo(i)
            gthprint( name.." T:"..GTHtf(canBeTank).." H:"..GTHtf(canBeHealer).." DPS:"..GTHtf(canBeDamager) )
        end
    elseif msg == "broadcast" then
    	-- parse any phase parameters passed
    	local paramlist;
    	if param then
    		paramlist = { strsplit(",",param) }
    	else
    		paramlist = {}
    	end
    	if #(paramlist) > 0 then
    		-- there are phase names in the command
    		local dpsave = GTHdisplayphase;
    		for i,p in ipairs( paramlist ) do
				--gthprint(p)
				GTHdisplayphase = p
				GTH_Broadcast( true )
    		end
    		GTHdisplayphase = dpsave
    	else
    		-- no phase names passed, so just broadcast the entire assignment list
    		GTH_Broadcast( false );
    	end
    elseif msg == "scan" then
        -- force rescan of raid and rebuild of inspect queue
        GTH_FindHealers();
    elseif msg == "debug" then
        -- toggle debug text
        GTHdebug = not GTHdebug;
    elseif msg == "reset" then
        -- reset saved variables and assignment
        -- replace saved data with default values
        for k,v in pairs( GTHDataDefaults ) do
            GTHData[k] = v
        end
        GTHData.assignment = GTH_assignment_copy( GTHpresets[GTHL["New"]] )
        GTHassignment = GTH_assignment_copy( GTHData.assignment )
        GTHdisplayphase = GTHL["Phase"].." 1"
        GTHData.displayphase = GTHL["Phase"].." 1"
        GTHframes.frame:Hide()
    else
        -- no command caught, so toggle frame
        if GTHframes.frame:IsShown() then
            GTHData.assignment = GTH_assignment_copy( GTHassignment ); -- save assignment
            GTHData.displayphase = GTHdisplayphase; -- save displayed phase
            GTHframes.frame:Hide();
            -- save/merge tanks and healers into rosters
            if GTHFlagRealRoster or GTHDataRoster["GTHhealerList"] then
                if GTHDataRoster["GTHhealerList"] then
                    -- merge
                    GTHDataRoster["GTHhealerList"] = GTH_merge_healer_tables( GTHDataRoster["GTHhealerList"] , GTHhealerList )
                    GTHDataRoster["GTHtankList"] = GTH_merge_healer_tables( GTHDataRoster["GTHtankList"] , GTHtankList )
                else
                    -- save for first time
                    GTHDataRoster["GTHhealerList"] = GTH_copy_healer_table( GTHhealerList )
                    GTHDataRoster["GTHtankList"] = GTH_copy_healer_table( GTHtankList )
                end
            end
        else
            if GTHData.assignment ~= nil then
                GTHassignment = GTH_assignment_copy( GTHData.assignment ); -- fetch saved assignment
            end
            
            -- pull up a phase
            local aphase = "";
            if GTHData.displayphase == nil then
                for k,v in pairs( GTHassignment ) do
                   aphase = k;
                   break
                end
            else
                aphase = GTHData.displayphase; -- saved current phase
            end
            
            GTH_RefreshDropMenus( aphase );
            GTHdisplayphase = aphase;
            GTHframes.frame:Show();
        end
    end

end

function gthprint(x)
    if x then DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..x) end
end

-- event handler
function GTH_OnEvent(self,event,...)

    local arg1,arg2
    arg1,arg2 = select(1,...)

    if event == "PLAYER_ENTERING_WORLD" then

        -- nothing here yet
    elseif event == "PARTY_MEMBER_DISABLE" then
    
        --gthprint( "event" )
    	GTH_ScanDisconnects()
    	
    elseif event == "CHAT_MSG_ADDON" then
        
    	GTH_ChatMsgAddon(...)
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    
    	GTH_CombatLogEvent(...)
    
    elseif event == "CHAT_MSG_WHISPER" then
        
        -- handle whispers
        GTH_CHAT_MSG_WHISPER(arg1,arg2);
        
    elseif ( event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" ) then
       
        -- scan for healers
        GTH_FindHealers();

    elseif event == "RAID_TARGET_UPDATE" then
        -- redraw all the healer boxes
        GTH_RefreshPopulatePool()
        GTH_RefreshDropMenus( GTHdisplayphase )
    
    elseif event == "VARIABLES_LOADED" then
    
        -- hook NotifyInspect so we can tell when another add-on calls it and messes up our inspects
        --hooksecurefunc("NotifyInspect", function(self,arg1) return GTH_NotifyInspect(self,arg1) end);
    
        --gthprint("variables loaded")
    
        -- check version of saved variables, in case of previous version
        
        
        -- check if presets exist
        if GTHData.playerPresets == nil then
            GTHData.playerPresets = {};
        end
        
        -- added in 1.2
        if GTHData.announceDeaths == nil then
        	GTHData.announceDeaths = true
        end
        
        -- added in 1.4
        if GTHData.verbose == nil then
        	GTHData.verbose = false -- default is short messages
        end
        
        if GTHData.announceOffline == nil then
        	GTHData.announceOffline = true
        end
        
        -- initialize
        
        if GTHData.assignment == nil then
            GTHData.assignment = GTH_assignment_copy( GTHpresets[GTHL["New"]] )
        end
        
        -- update saved preset format for v2.0.4+
        for pn,pv in pairs( GTHData.assignment ) do
            if not pv["xtagsx"]["aorder"] then
                -- not up to 2.0.4 format, so erase
                GTHData.assignment = GTH_assignment_copy( GTHpresets[GTHL["New"]] )
                break
            end
        end
        
        if GTHData.assignment ~= nil then
            -- fetch saved assignment
            GTHassignment = GTH_assignment_copy( GTHData.assignment );
        end
        
        
        if ( GTHData.gthversion == nil or GTHData.gthversion ~= GTHversion ) then
            GTHData.gthversion = GTHversion
            GTHData.announceDeaths = false
            GTHData.announceOffline = false
            GTHData.verbose = true
            -- should exit with current version stamp
        end
        
        GTH_CreateFrames();
        
        GTHhealerListDefault = GTH_copy_healer_table( GTHhealerList )
        GTHtankListDefault = GTH_copy_healer_table( GTHtankList )
        -- load any saved rosters
        if GTHDataRoster["GTHhealerList"] then
            GTHhealerList = GTH_copy_healer_table( GTHDataRoster["GTHhealerList"] )
            GTHtankList = GTH_copy_healer_table( GTHDataRoster["GTHtankList"] )
        end
    end

end

function GTH_copy_healer_table( sourcetab )
    -- copies a table of healers/tanks
    local newtab = {}
    for name,v in pairs( sourcetab ) do
        newtab[name] = {}
        for kk,vv in pairs( v ) do
            newtab[name][kk] = vv
        end
    end
    return newtab
end

function GTH_merge_healer_tables( tab1 , tab2 )
    -- merges together two healer/tank lists
    local newtab = {}
    for name,v in pairs( tab1 ) do
        newtab[name] = {}
        for kk,vv in pairs( v ) do
            newtab[name][kk] = vv
        end
    end
    for name,v in pairs( tab2 ) do
        newtab[name] = {}
        for kk,vv in pairs( v ) do
            newtab[name][kk] = vv
        end
    end
    return newtab
end

-- make the frames from stored settings
function GTH_CreateFrames()

    -- make frames
    
    -- config frame
    GTHframes.frame = CreateFrame("Frame", "GTHFrame", UIParent );
	GTHframes.frame:Hide();
	GTHframes.frame:EnableMouse(true)
	GTHframes.frame:SetFrameStrata("MEDIUM")
	GTHframes.frame:SetMovable(true)
	GTHframes.frame:SetToplevel(true)
	GTHframes.frame:SetWidth(540)
	GTHframes.frame:SetHeight(400)
	GTHframes.frame:SetBackdrop( { 
		bgFile = "Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = false, tileSize = 16, edgeSize = 24, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	GTHframes.frame:ClearAllPoints()
	GTHframes.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	GTHframes.frame:SetClampedToScreen(true)
	GTHframes.frame:SetScript("OnMouseDown",function(self,arg1)
		if ( arg1 == "LeftButton" ) then
			self:StartMoving()
		end
	end)
	GTHframes.frame:SetScript("OnMouseUp",function(self,arg1)
		if ( arg1 == "LeftButton" ) then
			self:StopMovingOrSizing()
			--RaidBuffStatus:SaveFramePosition()
		end
	end)
	GTHframes.frame:SetScript("OnHide",function(self) self:StopMovingOrSizing() end)
	-- set colors
	--GTHframes.frame:SetBackdropBorderColor(0, 0, 0, 1)
	--GTHframes.frame:SetBackdropColor(0,0,0,0.7)
    
	
	-- PHASE selection frames
	-- up to eight 
	GTHframes.phasedrag = {}
	for i = 1,8 do
	   GTHframes.phasedrag[ i ] = CreateFrame( "Frame" , "GTHFramePhaseDrag"..i , GTHframes.frame )
	   GTH_PhaseDragInitialize( GTHframes.phasedrag[ i ] )
	   GTHframes.phasedrag[ i ].label:SetText( GTH_rgbToHexColor(1,1,1).."xphasex"..i )
	   GTHframes.phasedrag[ i ]:ClearAllPoints()
	   GTHframes.phasedrag[ i ]:SetPoint( "CENTER" , GTHframes.frame , "TOPLEFT" , 85 , -3 + menusstarty - (i)*23 )
	   GTHframes.phasedrag[ i ]:Hide()
	end
	-- phases label
    GTHframes.phaseslabel = GTHframes.frame:CreateFontString()
    GTHframes.phaseslabel:SetFontObject("GameFontNormal")
    GTHframes.phaseslabel:SetPoint("CENTER" , GTHframes.phasedrag[ 1 ] , "CENTER" , -15 , 20 )
    GTHframes.phaseslabel:SetText( GTHL["Phases"] )
    
    -- add phase button
    GTHframes.newphasebutton = CreateFrame( "Frame" , "GTHFrameNewPhaseButton" , GTHframes.frame )
    GTHframes.newphasebutton:EnableMouse(true)
    GTHframes.newphasebutton:SetWidth(24)
	GTHframes.newphasebutton:SetHeight(24)
	GTHframes.newphasebutton.texup = GTHframes.newphasebutton:CreateTexture( nil , "ARTWORK" )
	GTHframes.newphasebutton.texup:SetBlendMode("BLEND")
	GTHframes.newphasebutton.texup:SetWidth(24)
	GTHframes.newphasebutton.texup:SetHeight(24)
	GTHframes.newphasebutton.texup:SetPoint("CENTER",GTHframes.newphasebutton,"CENTER",0,0)
	GTHframes.newphasebutton.texup:SetTexture( "Interface\\Minimap\\UI-Minimap-ZoomInButton-Up" )
	GTHframes.newphasebutton.texhi = GTHframes.newphasebutton:CreateTexture( nil , "HIGHLIGHT" )
	GTHframes.newphasebutton.texhi:SetBlendMode("ADD")
	GTHframes.newphasebutton.texhi:SetWidth(24)
	GTHframes.newphasebutton.texhi:SetHeight(24)
	GTHframes.newphasebutton.texhi:SetPoint("CENTER",GTHframes.newphasebutton,"CENTER",0,0)
	GTHframes.newphasebutton.texhi:SetTexture( nil )
	GTHframes.newphasebutton:SetScript( "OnMouseDown" , 
	   function()
	       GTHframes.newphasebutton.texup:SetTexture( "Interface\\Minimap\\UI-Minimap-ZoomInButton-Down" )
	   end
	)
	GTHframes.newphasebutton:SetScript( "OnMouseUp" , 
	   function(self)
	       GTHframes.newphasebutton.texup:SetTexture( "Interface\\Minimap\\UI-Minimap-ZoomInButton-Up" )
	       -- new phase empty phase
            local n = GTH_CountPhases( GTHassignment )
            if n < 8 and MouseIsOver(self) then
                n = n + 1
                local nl = 1
                while GTHassignment[GTHL["Right-click to rename"].." "..nl] do
                    nl = nl + 1
                end
                GTHassignment[GTHL["Right-click to rename"].." "..nl] = { ["xtagsx"]={ ["order"]=n , ["aorder"]={[ GTHL["new assignment"].." 1" ]=1} } , [ GTHL["new assignment"].." 1" ] = {} }
                GTHdisplayphase = GTHL["Right-click to rename"].." "..nl
                GTH_RefreshDropMenus( GTHdisplayphase )
            end
            GTHframes.newphasebutton.texhi:SetTexture( nil )
	   end
	)
	GTHframes.newphasebutton:SetScript( "OnEnter" ,
	   function()
	       -- UI-Minimap-ZoomButton-Highlight
	       GTHframes.newphasebutton.texhi:SetTexture( "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight" )
	   end
	)
	GTHframes.newphasebutton:SetScript( "OnLeave" ,
	   function()
	       GTHframes.newphasebutton.texhi:SetTexture( nil )
	   end
	)
	
	-- phase connection line
	GTHframes.plines = {}
	GTHframes.plines[1] = GTH_RepLinesInitialize( 20 , 2 )
	GTHframes.plines[1]:Hide()
	GTHframes.plines[2] = GTH_RepLinesInitialize( 2 , 20 )
	GTHframes.plines[2]:Hide()
	GTHframes.plines[3] = GTH_RepLinesInitialize( 20 , 2 )
	GTHframes.plines[3]:Hide()
	GTHframes.plines[4] = GTH_RepLinesInitialize( 20 , 2 )
	GTHframes.plines[4]:Hide()
	
	-- assigned healer pools
	-- these hold the drag-able healer name frames
	GTHframes.assignedpool = {}
	for i = 1,8 do
	   GTHframes.assignedpool[ i ] = CreateFrame("Frame", "GTHFramePool"..i, GTHframes.frame )
	   GTH_AssignedPoolInitialize( GTHframes.assignedpool[ i ] )
	   GTHframes.assignedpool[ i ]:Hide()
	end
	
	-- make the max number of healer drag frames
	-- we need 25 for the populate list, in case the whole raid is healers
	-- we need 8 for each of 8 assignments (64)
	
	-- populate pool (the visual image of GTHhealerList)
	GTHframes.dragPopulate = {}
	GTHframes.dragPopulateLabel = {}
	for i = 1,25 do
	   GTHframes.dragPopulate[ i ] = CreateFrame("Frame", "GTHFrameDragPopulate"..i, GTHframes.frame )
	   GTHframes.dragPopulateLabel[ i ] = GTHframes.dragPopulate[ i ]:CreateFontString()
	   GTH_DragInitialize( GTHframes.dragPopulate[ i ] , GTHframes.dragPopulateLabel[ i ] , "h"..i , "PRIEST" , "populate" )
	   -- position
       GTHframes.dragPopulate[ i ]:ClearAllPoints()
       GTHframes.dragPopulate[ i ]:SetPoint( "RIGHT" , GTHframes.frame , "TOPRIGHT" , -19 , -100 - 21*(i-1) )
	end
	
	-- assigned (listed) healer frames
	GTHframes.dragListed = {}
	GTHframes.dragListedLabel = {}
	for i = 1,8 do
	   GTHframes.dragListed[ i ] = {}
	   GTHframes.dragListedLabel[ i ] = {}
	   for j = 1,8 do
           GTHframes.dragListed[ i ][ j ] = CreateFrame("Frame", "GTHFrameDragListed"..i..j, GTHframes.frame )
           GTHframes.dragListedLabel[ i ][ j ] = GTHframes.dragListed[ i ][ j ]:CreateFontString()
           GTH_DragInitialize( GTHframes.dragListed[ i ][ j ] , GTHframes.dragListedLabel[ i ][ j ] , "h"..i..j , "PRIEST" , "relocate" )
        end
	end
	
	-- assignment name boxes (can be relocated or deleted)
	GTHframes.dragAssignment = {}
	for i = 1,8 do
	   GTHframes.dragAssignment[ i ] = CreateFrame("Frame", "GTHFrameDragAssignment"..i, GTHframes.frame )
	   GTHframes.dragAssignment[i].label = GTHframes.dragAssignment[ i ]:CreateFontString()
	   GTHframes.dragAssignment[i]:EnableMouse(true)
        GTHframes.dragAssignment[i]:SetScript( "OnMouseUp" , function( self , button ) 
            GTH_AssignmentDrag_OnMouseUp( self , button )
        end )
        GTHframes.dragAssignment[i]:SetScript( "OnMouseDown" , function(self) 
            local c = gthcolor.draghighlight
            self:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
        end )
        
	   GTH_DragInitialize( GTHframes.dragAssignment[ i ] , GTHframes.dragAssignment[ i ].label , "a"..i , "PRIEST" , "assignmentrelocate" )
	   GTHframes.dragAssignment[i]:SetWidth(119)
	   GTHframes.dragAssignment[i]:SetHeight(23)
	end
	
	-- drag ghost frame
	GTHframes.dragGhost = CreateFrame("Frame", "GTHFrameDragGhost", GTHframes.frame )
    GTHframes.dragGhostLabel = GTHframes.dragGhost:CreateFontString()
    GTH_DragInitialize( GTHframes.dragGhost , GTHframes.dragGhostLabel , "xxxx" , "PRIEST" , "ghost" )
    GTHframes.dragGhost:SetMovable(true)
    GTHframes.dragGhost:SetAlpha( 1 )
    GTHframes.dragGhost:EnableMouse(false)
    GTHframes.dragGhost:SetFrameLevel(GTHframes.frame:GetFrameLevel() + 30)
	
	-- tank populate pool (the visual image of GTHtankList)
	GTHframes.dragTankPopulate = {}
	for i = 1,25 do
	   GTHframes.dragTankPopulate[ i ] = CreateFrame("Frame", "GTHFrameDragTankPopulate"..i, GTHframes.frame )
	   GTHframes.dragTankPopulate[ i ].label = GTHframes.dragTankPopulate[ i ]:CreateFontString()
	   GTH_DragInitialize( GTHframes.dragTankPopulate[ i ] , GTHframes.dragTankPopulate[ i ].label , "t"..i , "WARRIOR" , "assignmentpopulate" )
	   -- position
       GTHframes.dragTankPopulate[ i ]:ClearAllPoints()
       GTHframes.dragTankPopulate[ i ]:SetPoint( "RIGHT" , GTHframes.frame , "TOPRIGHT" , -19 , -100 - 21*(i-1) )
	end
	
	-- assignment name boxes
	GTHframes.assignmentpool = {}
	for i = 1,8 do
	   GTHframes.assignmentpool[ i ] = CreateFrame("Frame", "GTHFrameAssignmentPool"..i, GTHframes.frame )
	   GTH_AssignmentPoolInitialize( GTHframes.assignmentpool[ i ] )
	   GTHframes.assignmentpool[ i ]:SetBackdrop( { 
            bgFile = texwhiteback, 
            edgeFile = texdialogborder,  
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
        })
        GTHframes.assignmentpool[ i ]:SetBackdropColor(0,0,0, 0.5 )
        local c = gthcolor.assignpoolborder
        GTHframes.assignmentpool[ i ]:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
	   GTHframes.assignmentpool[ i ]:Hide()
	end
	
		-- pool labels
	-- healers label
    GTHframes.hpoolLabel = GTHframes.frame:CreateFontString()
    GTHframes.hpoolLabel:SetFontObject("GameFontNormalSmall")
    GTHframes.hpoolLabel:SetPoint("TOP" , GTHframes.dragPopulate[ 1 ] , "BOTTOMRIGHT" , 0 , 0 )
    GTHframes.hpoolLabel:SetText( "Available Healers" )
    -- assignments (tanks) label
    GTHframes.apoolLabel = GTHframes.frame:CreateFontString()
    GTHframes.apoolLabel:SetFontObject("GameFontNormalSmall")
    GTHframes.apoolLabel:SetPoint("TOP" , GTHframes.dragTankPopulate[ 1 ] , "BOTTOMRIGHT" , 0 , 0 )
    GTHframes.apoolLabel:SetText( "Available Assignments/Tanks" )
	
	-- dwarf spirit healer texture
	GTHframes.dagangel = GTHframes.frame:CreateTexture(nil,"ARTWORK")
    GTHframes.dagangel:SetBlendMode("ADD")
    GTHframes.dagangel:SetWidth(200)
    GTHframes.dagangel:SetHeight(200)
    GTHframes.dagangel:SetPoint("BOTTOMLEFT",GTHframes.frame,"BOTTOMLEFT", -15 , 80 )
    GTHframes.dagangel:SetTexture("Interface\\AddOns\\GettingThingsHealed\\dagangel.tga")
    GTHframes.dagangel:SetAlpha(0.7)
    GTHframes.dagangel:Hide()
	
	-- okay button
	-- saves assignment to player variables
	GTHframes.okaybutton = CreateFrame("Button", "GTHframeOKbutton", GTHframes.frame , "OptionsButtonTemplate" );
	GTHframes.okaybutton:ClearAllPoints();
	GTHframes.okaybutton:SetPoint("BOTTOMRIGHT" , GTHframes.frame , "BOTTOMRIGHT" , -14 , 12);
	GTHframes.okaybutton:SetText("Close");
	GTHframes.okaybutton:SetWidth(65);
	--GTHframes.okaybutton:SetScript("OnClick", function() GTHData.assignment = GTH_assignment_copy(GTHassignment); GTHData.announcechannel = GTHframes.channeledit:GetText(); GTHData.displayphase = GTHdisplayphase; GTHframes.frame:Hide(); end)
	GTHframes.okaybutton:SetScript("OnClick", function() GTHData.assignment = GTH_assignment_copy(GTHassignment); GTHData.displayphase = GTHdisplayphase; GTHframes.frame:Hide(); end)
	GTHframes.okaybutton:Show();
	
	-- cancel button
	-- closes window but doesn't save current assignment
	-- instead copies saved assignment to current assignment
	GTHframes.cancelbutton = CreateFrame("Button", "GTHframeOKbutton", GTHframes.frame , "OptionsButtonTemplate" );
	GTHframes.cancelbutton:ClearAllPoints();
	GTHframes.cancelbutton:SetPoint("BOTTOMRIGHT" , GTHframes.frame , "BOTTOMRIGHT" , -80 , 12);
	GTHframes.cancelbutton:SetText("x");
	GTHframes.cancelbutton:SetWidth(20);
	GTHframes.cancelbutton:SetScript("OnClick", function() GTHassignment = GTH_assignment_copy(GTHData.assignment); GTHframes.frame:Hide(); end)
	GTHframes.cancelbutton:Hide();
	
	-- custom assignment text entry frame
    GTHframes.custom = CreateFrame("Frame", "GTHcustomassignment", UIParent);
	GTHframes.custom:Hide();
	GTHframes.custom:EnableMouse(true)
	GTHframes.custom:SetFrameStrata("HIGH")
	GTHframes.custom:SetToplevel(true)
	GTHframes.custom:SetWidth(200)
	GTHframes.custom:SetHeight(100)
	GTHframes.custom:SetBackdrop( { 
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	GTHframes.custom:ClearAllPoints()
	GTHframes.custom:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	GTHframes.custom:SetClampedToScreen(true)
	-- set colors
	GTHframes.custom:SetBackdropBorderColor(0, 0, 0, 1)
	GTHframes.custom:SetBackdropColor(0, 0, 0, 0.9)
	
	-- okay button for custom dialog
	GTHframes.custombutton = CreateFrame("Button", "GTHcustomassignmentOK", GTHcustomassignment , "OptionsButtonTemplate" );
	GTHframes.custombutton:ClearAllPoints();
	GTHframes.custombutton:SetPoint("BOTTOMRIGHT",GTHcustomassignment,"BOTTOMRIGHT",-6,6);
	GTHframes.custombutton:SetText("Okay");
	GTHframes.custombutton:SetWidth(45);
	GTHframes.custombutton:SetScript("OnClick", 
	function() 
	   local theassign = GTHframes.customedit:GetText(); 
	   --UIDropDownMenu_SetText( customtarget , theassign );  
	   local temp = GTH_assignedhealers_copy( GTHassignment[customtarget.phase][ customtarget.assignment ] ); 
	   GTHassignment[customtarget.phase][ customtarget.assignment ] = nil; 
	   GTHassignment[customtarget.phase][ theassign ] = temp;
	   -- rename the aorder entry, too
	   local aorder = GTHassignment[customtarget.phase]["xtagsx"]["aorder"][ customtarget.assignment ]
	   GTHassignment[customtarget.phase]["xtagsx"]["aorder"][ customtarget.assignment ] = nil
	   GTHassignment[customtarget.phase]["xtagsx"]["aorder"][ theassign ] = aorder
	   -- finalize
	   customtarget.assignment = theassign;
	   --GTHframes.dropHealers[customtarget.myindex].assignment = theassign; 
	   GTHframes.custom:Hide();
	   -- refresh
	   GTH_RefreshDropMenus( GTHdisplayphase )
    end)
	GTHframes.custombutton:Show();
	
	-- cancel custom button
	GTHframes.customCancel = CreateFrame("Button", "GTHcustomCancel", GTHcustomassignment , "OptionsButtonTemplate" );
	GTHframes.customCancel:ClearAllPoints();
	GTHframes.customCancel:SetPoint("BOTTOMLEFT",GTHcustomassignment,"BOTTOMLEFT",6,6);
	GTHframes.customCancel:SetText("Cancel");
	GTHframes.customCancel:SetWidth(45);
	GTHframes.customCancel:SetScript("OnClick", function() GTHframes.custom:Hide(); end)
	GTHframes.customCancel:Show();
	
	-- edit box for custom dialog
	GTHframes.customedit = CreateFrame("EditBox", "GTHcustomassignmentEdit", GTHcustomassignment );
	GTHframes.customedit:ClearAllPoints();
	GTHframes.customedit:SetPoint("CENTER",GTHframes.custom,"CENTER",0,0);
	GTHframes.customedit:SetText( GTHL["Custom..."] );
	GTHframes.customedit:SetWidth(170);
    GTHframes.customedit:SetHeight(24);
    GTHframes.customedit:SetFontObject(GameFontNormal)
    GTHframes.customedit:SetTextColor(.8,.8,.8)
    GTHframes.customedit:SetTextInsets(8,8,8,8)
    GTHframes.customedit:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    GTHframes.customedit:SetBackdropColor(.1,.1,.1,.3)
    GTHframes.customedit:SetBackdropBorderColor(.5,.5,.5)
    GTHframes.customedit:SetMultiLine(false)
    GTHframes.customedit:SetAutoFocus(true)
    GTHframes.customedit:SetScript( "OnEnterPressed" , function() GTHframes.custombutton:Click() end )
	GTHframes.customedit:Show();
	
	-- DELETE PRESET FRAMES
	
	-- dialog
    GTHframes.deletepreset = CreateFrame("Frame", "GTHdeletepreset", UIParent);
	GTHframes.deletepreset:Hide();
	GTHframes.deletepreset:EnableMouse(true)
	GTHframes.deletepreset:SetFrameStrata("HIGH")
	GTHframes.deletepreset:SetToplevel(true)
	GTHframes.deletepreset:SetWidth(200)
	GTHframes.deletepreset:SetHeight(100)
	GTHframes.deletepreset:SetBackdrop( { 
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	GTHframes.deletepreset:ClearAllPoints()
	GTHframes.deletepreset:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	GTHframes.deletepreset:SetClampedToScreen(true)
	-- set colors
	GTHframes.deletepreset:SetBackdropBorderColor(0, 0, 0, 1)
	GTHframes.deletepreset:SetBackdropColor(0, 0, 0, 0.99)
	
	-- delete button
	GTHframes.deleteOkay = CreateFrame("Button", "GTHdeleteOK", GTHdeletepreset , "OptionsButtonTemplate" );
	GTHframes.deleteOkay:ClearAllPoints();
	GTHframes.deleteOkay:SetPoint("BOTTOMRIGHT",GTHdeletepreset,"BOTTOMRIGHT",-6,6);
	GTHframes.deleteOkay:SetText(GTHL["Delete"]);
	GTHframes.deleteOkay:SetWidth(45);
	GTHframes.deleteOkay:SetScript("OnClick", function() local deletetarget = UIDropDownMenu_GetText( GTHframes.dropDeletePresets ); if deletetarget ~= "" then GTHData.playerPresets[deletetarget] = nil; end; GTHframes.deletepreset:Hide(); end)
	GTHframes.deleteOkay:Show();
	
	
	-- cancel delete button
	GTHframes.deleteCancel = CreateFrame("Button", "GTHdeleteCancel", GTHdeletepreset , "OptionsButtonTemplate" );
	GTHframes.deleteCancel:ClearAllPoints();
	GTHframes.deleteCancel:SetPoint("BOTTOMLEFT",GTHdeletepreset,"BOTTOMLEFT",6,6);
	GTHframes.deleteCancel:SetText("Cancel");
	GTHframes.deleteCancel:SetWidth(45);
	-- script branches to handle phase renaming and preset naming
	GTHframes.deleteCancel:SetScript("OnClick", function() GTHframes.deletepreset:Hide(); end)
	GTHframes.deleteCancel:Show();
	
	-- delete presets popupmenu
	GTHframes.dropDeletePresets = CreateFrame("Frame", "GTHdropDeletePreset" , GTHdeletepreset , "UIDropDownMenuTemplate");
	GTHframes.dropDeletePresets:ClearAllPoints()
    GTHframes.dropDeletePresets:SetPoint("CENTER", GTHdeletepreset , "CENTER" , -50 , 0 );
    UIDropDownMenu_Initialize( GTHframes.dropDeletePresets , GTHdropDeletePresets_Initialise);
    
    -- dropDeletePresets text string
    GTHframes.labelDeletePresets = GTHframes.dropDeletePresets:CreateFontString();
	GTHframes.labelDeletePresets:SetFontObject("GameFontNormal");
	GTHframes.labelDeletePresets:SetPoint("BOTTOMLEFT" , GTHframes.dropDeletePresets , "TOPRIGHT" , 0, 0);
	GTHframes.labelDeletePresets:SetText(GTHL["Player Presets"]);
	
	-- RENAME PHASE FRAMES
	
	-- dialog
    GTHframes.renamephase = CreateFrame("Frame", "GTHrenamephase", UIParent);
	GTHframes.renamephase:Hide();
	GTHframes.renamephase:EnableMouse(true)
	GTHframes.renamephase:SetFrameStrata("HIGH")
	GTHframes.renamephase:SetToplevel(true)
	GTHframes.renamephase:SetWidth(200)
	GTHframes.renamephase:SetHeight(100)
	GTHframes.renamephase:SetBackdrop( { 
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	GTHframes.renamephase:ClearAllPoints()
	GTHframes.renamephase:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	GTHframes.renamephase:SetClampedToScreen(true)
	-- set colors
	GTHframes.renamephase:SetBackdropBorderColor(0, 0, 0, 1)
	GTHframes.renamephase:SetBackdropColor(0, 0, 0, 0.9)
	
	-- okay button for renamephase dialog
	GTHframes.renamephasebutton = CreateFrame("Button", "GTHrenamephaseOK", GTHrenamephase , "OptionsButtonTemplate" );
	GTHframes.renamephasebutton:ClearAllPoints();
	GTHframes.renamephasebutton:SetPoint("BOTTOMRIGHT",GTHframes.renamephase,"BOTTOMRIGHT",-6,6);
	GTHframes.renamephasebutton:SetText("Okay");
	GTHframes.renamephasebutton:SetWidth(45);
	-- script branches to handle phase renaming and preset naming
	GTHframes.renamephasebutton:SetScript("OnClick", function() if GTHnameflag == "renamephase" then local thephase = GTHframes.renamephaseedit:GetText(); UIDropDownMenu_SetText( GTHdropNew , thephase ); local temp = GTH_phase_copy( GTHassignment[ GTHrenametarget ] ); GTHassignment[ GTHrenametarget ] = nil; GTHdropNew.phase = thephase; GTHassignment[ thephase ] = temp; UIDropDownMenu_SetSelectedName( GTHdropNew , thephase ); GTHdisplayphase = thephase; GTH_RefreshDropMenus( thephase ); end if GTHnameflag == "savepreset" then local thenewpreset = GTH_assignment_copy( GTHassignment ); GTHData.playerPresets[ GTHframes.renamephaseedit:GetText() ] = thenewpreset; end GTHframes.renamephase:Hide(); end)
	GTHframes.renamephasebutton:Show();
	
	-- cancel rename/save button
	GTHframes.renamephaseCancel = CreateFrame("Button", "GTHrenamephaseCancel", GTHrenamephase , "OptionsButtonTemplate" );
	GTHframes.renamephaseCancel:ClearAllPoints();
	GTHframes.renamephaseCancel:SetPoint("BOTTOMLEFT",GTHframes.renamephase,"BOTTOMLEFT",6,6);
	GTHframes.renamephaseCancel:SetText("Cancel");
	GTHframes.renamephaseCancel:SetWidth(45);
	GTHframes.renamephaseCancel:SetScript("OnClick", function() GTHframes.renamephase:Hide(); end)
	GTHframes.renamephaseCancel:Show();
	
	--  UIDropDownMenu_SetSelectedName( this.owner, this.owner.phase );
    --  GTH_RefreshDropMenus( this.owner.phase );
	
	-- edit box for renamephase dialog
	GTHframes.renamephaseedit = CreateFrame("EditBox", "GTHrenamephaseEdit", GTHrenamephase );
	GTHframes.renamephaseedit:ClearAllPoints();
	GTHframes.renamephaseedit:SetPoint("CENTER",GTHframes.renamephase,"CENTER",0,0);
	GTHframes.renamephaseedit:SetText("Custom");
	GTHframes.renamephaseedit:SetWidth(170);
    GTHframes.renamephaseedit:SetHeight(24);
    GTHframes.renamephaseedit:SetFontObject(GameFontNormal)
    GTHframes.renamephaseedit:SetTextColor(.8,.8,.8)
    GTHframes.renamephaseedit:SetTextInsets(8,8,8,8)
    GTHframes.renamephaseedit:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    GTHframes.renamephaseedit:SetBackdropColor(.1,.1,.1,.3)
    GTHframes.renamephaseedit:SetBackdropBorderColor(.5,.5,.5)
    GTHframes.renamephaseedit:SetMultiLine(false)
    GTHframes.renamephaseedit:SetAutoFocus(true)
    GTHframes.renamephaseedit:SetScript( "OnEnterPressed" , function() GTHframes.renamephasebutton:Click() end )
	GTHframes.renamephaseedit:Show();
	
	-- pull up a phase
	local aphase = "";
	if GTHData.displayphase == nil then
        for k,v in pairs( GTHassignment ) do
           aphase = k;
           break
        end
    else
        aphase = GTHData.displayphase;
    end
    GTHdisplayphase = aphase;
	
	-- phase menu
    GTHframes.dropNew = GTH_CreatePhaseDropMenu( "GTHdropNew" , 1 , aphase );
    UIDropDownMenu_SetSelectedValue( GTHframes.dropNew , 1 ); -- select first phase
    GTHframes.dropNew:Hide()
    
    -- font strings
	GTHframes.labelP = GTHdropNew:CreateFontString();
	GTHframes.labelP:SetFontObject("GameFontNormal");
	GTHframes.labelP:SetPoint("BOTTOMLEFT" , GTHdropNew , "TOPRIGHT" , 0, 0);
	GTHframes.labelP:SetText(GTHL["Phase"]);
	
	GTHframes.labelT = GTHframes.frame:CreateFontString();
	GTHframes.labelT:SetFontObject("GameFontNormalLarge");
	GTHframes.labelT:SetPoint("TOPLEFT" , GTHframes.frame , "TOPLEFT" , 28, -10);
	GTHframes.labelT:SetText("Getting Things Healed");
	
	GTH_RefreshDropMenus( aphase );
	
	-- make presets menu
	GTHframes.dropPreset = CreateFrame("Frame", "GTHdropPreset" , GTHframes.frame, "UIDropDownMenuTemplate");
	GTHframes.dropPreset:ClearAllPoints()
    GTHframes.dropPreset:SetPoint("BOTTOMRIGHT", GTHframes.frame, "BOTTOMRIGHT" , -200 , 7 );
    UIDropDownMenu_SetButtonWidth( GTHframes.dropPreset , 50 )
    UIDropDownMenu_Initialize(GTHframes.dropPreset, GTHdropPresets_Initialise);
    
    GTHframes.labelPresets = GTHframes.dropPreset:CreateFontString();
	GTHframes.labelPresets:SetFontObject("GameFontNormal");
	GTHframes.labelPresets:SetPoint("BOTTOMLEFT" , GTHframes.dropPreset , "TOPRIGHT" , 0, 0);
	GTHframes.labelPresets:SetText( GTHL["Presets"] );
	
	-- make broadcast menu
	GTHframes.dropBroadcast = CreateFrame("Frame", "GTHdropBroadcast" , GTHframes.frame, "UIDropDownMenuTemplate");
	GTHframes.dropBroadcast:ClearAllPoints()
    GTHframes.dropBroadcast:SetPoint("BOTTOMLEFT", GTHframes.frame, "BOTTOMLEFT" , 0 , 6 );
    UIDropDownMenu_SetButtonWidth( GTHframes.dropBroadcast , 20 )
    UIDropDownMenu_Initialize(GTHframes.dropBroadcast, GTHdropBroadcast_Initialise);
    
    GTHframes.labelBroadcast = GTHframes.dropBroadcast:CreateFontString();
	GTHframes.labelBroadcast:SetFontObject("GameFontNormal");
	GTHframes.labelBroadcast:SetPoint("BOTTOMLEFT" , GTHframes.dropBroadcast , "TOPRIGHT" , 0, 0);
	GTHframes.labelBroadcast:SetText( GTHL["Broadcast healing assignments"] );
	
	-- raid broadcast button
	GTHframes.raidbutton = CreateFrame("Button", "GTHframeRaidButton", GTHframes.frame , "OptionsButtonTemplate" );
	GTHframes.raidbutton:ClearAllPoints();
	GTHframes.raidbutton:SetPoint("LEFT" , GTHframes.dropBroadcast , "RIGHT" , 112 , 0);
	GTHframes.raidbutton:SetText( GTHL["Broadcast"] );
	GTHframes.raidbutton:SetWidth(95);
	
	GTHframes.raidbutton:SetScript( "OnUpdate" , function() local t=""; if IsShiftKeyDown() then t=GTHL["Phase"] elseif IsControlKeyDown() then t=GTHL["Share"] else t=GTHL["Broadcast"] end GTHframes.raidbutton:SetText( t ) end )
	
	GTHframes.raidbutton:SetScript("OnClick", 
	function()
		if IsControlKeyDown() then
			GTH_SharePreset( GTHassignment )
		else 
			GTH_Broadcast( IsShiftKeyDown() )
		end
	end )
	GTHframes.raidbutton:Show();
	
	-- options menu
	GTHframes.optionmenu = CreateFrame("Frame", "GTHframeOptionsMenu" , GTHframes.frame )
	GTHframes.optionmenu:ClearAllPoints()
	GTHframes.optionmenu:SetPoint("BOTTOMRIGHT" , GTHframes.frame , "BOTTOMRIGHT" , -230 , 14 )
	GTHframes.optionmenu.label = GTHframes.optionmenu:CreateFontString()
	GTHframes.optionmenu.label:SetFontObject("GameFontNormalSmall")
	GTHframes.optionmenu.label:SetPoint( "RIGHT" , GTHframes.optionmenu , "RIGHT" , 0, 0)
	GTHframes.optionmenu.label:SetText( GTHL["Options"] )
	GTHframes.optionmenu:SetWidth(60)
	GTHframes.optionmenu:SetHeight(16)
	
	GTHframes.optionmenu.up = GTHframes.optionmenu:CreateTexture( nil , "ARTWORK" )
	GTHframes.optionmenu.up:SetWidth(16)
	GTHframes.optionmenu.up:SetHeight(16)
	GTHframes.optionmenu.up:SetPoint( "LEFT" , GTHframes.optionmenu , "LEFT" , 0 , 0 )
	GTHframes.optionmenu.up:SetTexture( "Interface\\GossipFrame\\BinderGossipIcon.blp" )
	
	GTHframes.optionmenu.hi = GTHframes.optionmenu:CreateTexture( nil , "ARTWORK" )
	GTHframes.optionmenu.hi:SetWidth(60)
	GTHframes.optionmenu.hi:SetHeight(16)
	GTHframes.optionmenu.hi:SetBlendMode("ADD")
	GTHframes.optionmenu.hi:SetPoint( "CENTER" , GTHframes.optionmenu , "CENTER" , 0 , 0 )
	GTHframes.optionmenu.hi:SetTexture( "Interface\\BUTTONS\\UI-Common-MouseHilight" )
	GTHframes.optionmenu.hi:Hide()
	
	GTHframes.optionmenu:EnableMouse(true)
	GTHframes.optionmenu:SetScript( "OnMouseDown" , 
	   function()
	       GTHframes.optionmenu.up:SetWidth(14)
	       GTHframes.optionmenu.up:SetHeight(14)
	   end
    )
    GTHframes.optionmenu:SetScript( "OnMouseUp" , 
	   function()
	       GTHframes.optionmenu.up:SetWidth(16)
	       GTHframes.optionmenu.up:SetHeight(16)
	       ToggleDropDownMenu(1, nil, GTHframes.optionmenudrop, GTHframes.optionmenu, 0, 0)
	   end
    )
    GTHframes.optionmenu:SetScript( "OnEnter" ,
        function()
            GTHframes.optionmenu.hi:Show()
        end
    )
	GTHframes.optionmenu:SetScript( "OnLeave" ,
        function()
            GTHframes.optionmenu.hi:Hide()
        end
    )
	
	
	GTHframes.optionmenudrop = CreateFrame("Frame", "GTHdropOptions" , GTHframes.frame, "UIDropDownMenuTemplate");
	UIDropDownMenu_Initialize(GTHframes.optionmenudrop, GTHdropOptions_Initialise);
	--GTHframes.optionmenu:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, GTHframes.optionmenudrop, GTHframes.optionmenu, 0, 0); end)
	GTHframes.optionmenu:Show();
	
	
	
	-- set broadcast menu to saved channel
	if GTHData.announcechannel ~= "" then
	   UIDropDownMenu_SetSelectedValue( GTHframes.dropBroadcast , GTHData.announcechannel );
	   UIDropDownMenu_SetText( GTHframes.dropBroadcast , GTHData.announcechannel );
	end
    
    -- finally show the pool of healer names
    GTH_RefreshPopulatePool()
    
end

function GTH_RefreshPopulatePool()
    -- redraw the pool of drag-able healer names
    -- GTHframes.dragPopulate
    -- GTHhealerList
    local n = 0
    local hlist = {}
    for h,v in pairs( GTHhealerList ) do
        table.insert( hlist , h )
        n = n + 1
    end
    table.sort( hlist )
    
    local cols = 3
    local rows = 3
    -- n+1 boxes to position in three columns
    rows = ceil( (n+1)/cols )
    
    for i = 1,25 do
        local col = ceil( i / rows )
        local row = i - (col-1)*rows
        if i > n then
            if i == n+1 then
                -- 'All Remaining' box
                GTHframes.dragPopulate[ i ].phase = "x"
                GTHframes.dragPopulate[ i ].assignment = "x"
                -- show
                GTH_DragSetHealer( GTHframes.dragPopulate[ i ] , GTHL["All remaining"] , nil , "populate" )
                GTHframes.dragPopulate[ i ]:ClearAllPoints()
                GTHframes.dragPopulate[ i ]:SetPoint( "LEFT" , GTHframes.frame , "BOTTOMLEFT" , 60+menusstartx + (col-1)*100 , 70 + (row-1)*20 )
                GTHframes.dragPopulate[ i ]:Show()
            else
                -- hide
                GTHframes.dragPopulate[ i ]:Hide()
            end
        else
            GTHframes.dragPopulate[ i ].phase = "x"
            GTHframes.dragPopulate[ i ].assignment = "x"
            -- show
            local tooltip = nil
            GTH_DragSetHealer( GTHframes.dragPopulate[ i ] , hlist[ i ] , GTH_GetClass( hlist[i] ) , "populate" , nil , nil , tooltip )
            
            -- check if healer is assigned in this phase already
            local assignedalready = false
            for k,a in pairs( GTHassignment[ GTHdisplayphase ] ) do
                for h,v in pairs( a ) do
                    if h == hlist[ i ] then
                        assignedalready = true
                    end
                end
            end
            if assignedalready then
                GTHframes.dragPopulate[ i ]:SetAlpha(0.4)
            else
                GTHframes.dragPopulate[ i ]:SetAlpha(1)
            end 
            
            GTHframes.dragPopulate[ i ]:ClearAllPoints()
            GTHframes.dragPopulate[ i ]:SetPoint( "LEFT" , GTHframes.frame , "BOTTOMLEFT" , 60+menusstartx + (col-1)*100 , 70 + (row-1)*20 )
            GTHframes.dragPopulate[ i ]:Show()
        end
    end
    
    GTHhealerRows = rows
    GTHframes.hpoolLabel:ClearAllPoints()
    GTHframes.hpoolLabel:SetPoint( "CENTER" , GTHframes.frame , "BOTTOMLEFT" , 60+menusstartx + (2.5-1)*100 , 70 + (rows)*20 )
    
    -- now refresh tank pool
    -- GTHtankList
    n = 0
    local tlist = {}
    for t,v in pairs( GTHtankList ) do
        table.insert( tlist , t )
        n = n + 1
    end
    table.sort( tlist )
    
    cols = 2
    -- n+1 boxes to position in three columns
    rows = ceil( (n+3)/cols )
    
    for i = 1,25 do
        local col = ceil( i / rows )
        local row = i - (col-1)*rows
        if i > n then
            if i < n+4 then
                -- 'Raid healing', 'Custom' and '%MT1' boxes
                GTHframes.dragTankPopulate[ i ].phase = GTHdisplayphase
                if i == n+1 then
                    GTHframes.dragTankPopulate[ i ].assignment = GTHL["Raid healing"]
                elseif i == n+2 then
                    GTHframes.dragTankPopulate[ i ].assignment = GTHL["Custom..."]
                else
                    GTHframes.dragTankPopulate[ i ].assignment = "%MT1"
                end
                -- show
                GTH_DragSetHealer( GTHframes.dragTankPopulate[ i ] , GTHframes.dragTankPopulate[ i ].assignment , nil , "assignmentpopulate" )
                GTHframes.dragTankPopulate[ i ]:ClearAllPoints()
                GTHframes.dragTankPopulate[ i ]:SetPoint( "LEFT" , GTHframes.frame , "BOTTOMLEFT" , 15 + (col-1)*100 , 70 + (row-1)*20 )
                local assignedalready = GTH_alreadyassigned( GTHframes.dragTankPopulate[ i ].assignment )
                if assignedalready then
                    GTHframes.dragTankPopulate[ i ]:SetAlpha(0.4)
                else
                    GTHframes.dragTankPopulate[ i ]:SetAlpha(1)
                end
                GTHframes.dragTankPopulate[ i ]:Show()
            else
                -- hide
                GTHframes.dragTankPopulate[ i ]:Hide()
            end
        else
            GTHframes.dragTankPopulate[ i ].phase = GTHdisplayphase
            GTHframes.dragTankPopulate[ i ].assignment = tlist[ i ]
            -- show
            local tooltip = nil
            GTH_DragSetHealer( GTHframes.dragTankPopulate[ i ] , tlist[ i ] , GTH_GetClass( tlist[i] ) , "assignmentpopulate" , nil , nil , tooltip )
            
            -- check if tank is assigned in this phase already
            local assignedalready = GTH_alreadyassigned( tlist[ i ] )
            if assignedalready then
                GTHframes.dragTankPopulate[ i ]:SetAlpha(0.4)
            else
                GTHframes.dragTankPopulate[ i ]:SetAlpha(1)
            end
            
            GTHframes.dragTankPopulate[ i ]:ClearAllPoints()
            GTHframes.dragTankPopulate[ i ]:SetPoint( "LEFT" , GTHframes.frame , "BOTTOMLEFT" , 15 + (col-1)*100 , 70 + (row-1)*20 )
            GTHframes.dragTankPopulate[ i ]:Show()
        end
    end
    
    GTHtankRows = rows
    
    GTHframes.apoolLabel:ClearAllPoints()
    GTHframes.apoolLabel:SetPoint( "CENTER" , GTHframes.frame , "BOTTOMLEFT" , 15 + (2-1)*100 , 70 + (rows)*20 )
    
end

function GTH_DragSetHealer( frame , name , class , dragtype , tankname , tanknum , tooltip )
    
    -- really sets more than healer drags...also handles assignments and phases
    
    --if not GTHhealerList[ name ] and name ~= GTHL["All remaining"] then return end
    
    frame.healername = name
    frame.healerclass = class
    frame.tankname = tankname
    frame.tanknum = tanknum
    frame.dragtype = dragtype
    frame.tooltip = tooltip
    
    if name == GTHL["All remaining"] then
        frame.healerclass = "ALLREMAINING"
    end
    
    local colorclass = frame.healerclass
    if not colorclass then
        colorclass = "ALLREMAINING"
    end
    
    frame.labelframe:SetText( GTH_HexClassColor( colorclass )..name )
    
    -- PA: Would be talent icon
    frame.icon:SetTexture( nil )
    
    if frame.healername ~= GTHL["All remaining"] and dragtype ~= "phase" then
        frame.icon:SetTexture( "Interface\\GossipFrame\\ActiveQuestIcon.blp" )
        if not tankname and dragtype == "assignmentrelocate" then
            -- this is an assignment drag in a pool, and not tied to a named tank, so no talent icon display
            -- i.e. it's just an arbitrary assignment, not a unit
            frame.icon:SetTexture( nil )
        end
    end
    
    if frame.healername == GTHL["All remaining"] then
        frame.icon:SetTexture( nil )
        frame.iconL:SetTexture(nil)
    else
        -- check for raid target icon
        local unitID = GTH_GetUnitByName( name )
        if unitID then
            local iconindex = GetRaidTargetIndex( unitID )
            if iconindex then
                frame.iconL:SetTexture( "Interface\\TARGETINGFRAME\\" ..GTHluckycharms[ iconindex ] )
                --frame.iconL:SetTexture( "Interface\\GossipFrame\\ActiveQuestIcon.blp" )
            else
                frame.iconL:SetTexture(nil)
            end
        end
    end
    
    if colorclass == "ALLREMAINING" then
        -- phase drag box
        frame.icon:SetTexture( nil )
    end
    
    if GTHofflineList[ name ] then
        -- this player is offline, so make with lightning icon
        frame.iconL:SetTexture( texdisconnect )
    end
    
end

function GTH_RepLinesInitialize( w , h )
    -- creates and returns a frame that just draws those connecting lines
    local frame = CreateFrame("Frame", nil , GTHframes.frame );
	frame:SetWidth(w)
	frame:SetHeight(h)
	frame:SetBackdrop( { 
		bgFile = texreplines,
		edgeFile = nil, tile = true, tileSize = 2, edgeSize = 0, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
    return frame
end

function GTH_PhaseDragInitialize( frame )
    -- init phase drag-able box, reusing healer drag code
    frame.label = frame:CreateFontString()
    frame:EnableMouse(true)
    frame:SetScript( "OnMouseUp" , function( self , button ) 
        GTH_PhaseDrag_OnMouseUp( self , button )
    end )
    frame:SetScript( "OnMouseDown" , function(self) 
        local c = gthcolor.draghighlight
        self:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
    end )
    frame.tooltip = GTH_rgbToHexColor(1,1,1).."Right-click to rename"
    GTH_DragInitialize( frame , frame.label , nil , nil , "phase" )
end

function GTH_AssignmentDrag_OnMouseUp( frame , button )
    -- this phase selected
    local c = gthcolor.dragborder
    frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
    
    if button == "LeftButton" then
        -- nothing yet
        --gthprint( frame.assignment )
    elseif button == "RightButton" then
        -- rename
        customtarget = frame
        GTHframes.customedit:SetText( frame.assignment )
        -- store the assignment
        GTHframes.custom:ClearAllPoints()
        GTHframes.custom:SetPoint("CENTER", frame, "CENTER", 0, 0)
        GTHcustomassignment:Show()
        GTHframes.customedit:HighlightText()
    end
end

GTHrenametarget = nil
function GTH_PhaseDrag_OnMouseUp( frame , button )
    -- this phase selected
    local c = gthcolor.dragborder
    frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
    
    if button == "LeftButton" then
        -- select as displayed phase
        GTH_RefreshDropMenus( frame.phase )
    elseif button == "RightButton" then
        -- rename
        GTHnameflag = "renamephase"
        GTHrenametarget = frame.phase
        GTHframes.renamephaseedit:SetText( frame.phase )
        -- store the phase
        GTHframes.renamephase:ClearAllPoints()
        GTHframes.renamephase:SetPoint("CENTER", frame, "CENTER", 0, 0)
        GTHrenamephase:Show()
        GTHframes.renamephaseedit:HighlightText()
    end
end

function GTHPopulateDropInit(self, level)
    
	level = level or 1
	local info = UIDropDownMenu_CreateInfo()
	
	--local tooltip = GTH_rgbToHexColor(1,1,1)..t[1].."/"..t[2].."/"..t[3].." ("..t2[1].."/"..t2[2].."/"..t2[3]..")"
	info.text = "TITLE"
    info.isTitle = true
    info.value = -1
    info.func = GTHPopulateDDClick
    info.owner = self
    info.checked = nil
    info.icon = nil
    --UIDropDownMenu_AddButton(info, level)
    
    info.isTitle = nil
    info.disabled = nil
    
    if GetNumGroupMembers() == 0 then
        local itemname = "Remove from roster"
        info.text = itemname
        info.value = itemname
        info.func = GTHPopulateDDClick
        info.owner = self
        info.checked = false
        info.icon = nil
        UIDropDownMenu_AddButton(info, level)
    else
        -- PA: Leave this for now until you understand it better
        local itemname = "Rescan talents"
        info.text = itemname
        info.value = itemname
        info.func = GTHPopulateDDClick
        info.owner = self
        info.checked = false
        info.icon = nil
        UIDropDownMenu_AddButton(info, level)
    end
    
end

function GTHPopulateDDClick(self)
    --print(this.value)
    --print(GTHPopDropped)
    if self.value == "Remove from roster" then
        if GTHDataRoster and GTHPopDropped then
            GTHDataRoster["GTHtankList"][GTHPopDropped] = nil
            GTHDataRoster["GTHhealerList"][GTHPopDropped] = nil
            if GTHDataRoster["GTHhealerList"] then
                GTHhealerList = GTH_copy_healer_table( GTHDataRoster["GTHhealerList"] )
                GTHtankList = GTH_copy_healer_table( GTHDataRoster["GTHtankList"] )
            end
            GTH_RefreshPopulatePool()
        end
    end
end

GTHPopulateDropdown = CreateFrame( "Frame", "GTHPopulateDropdownFrame", nil, "UIDropDownMenuTemplate" )
GTHPopDropped = ""
function GTH_DragInitialize( frame , textframe , healername , healerclass , dragtype )
    frame:EnableMouse(true)
	frame:SetWidth(100)
	frame:SetHeight(22)
	if dragtype == "assignmentpopulate" or dragtype == "assignmentrelocate" then
        frame:SetBackdrop( { 
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = texdialogborder,
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 3, bottom = 3 }
        })
	else
	   frame:SetBackdrop( { 
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = texdragborder,
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 3, bottom = 3 }
        })
	end
	local c = gthcolor.dragback
	frame:SetBackdropColor( c.r , c.g , c.b , c.a )
	c = gthcolor.dragborder
	frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", GTHframes.frame, "CENTER", 0, 0)
	frame:SetFrameLevel(GTHframes.frame:GetFrameLevel() + 2)
	
	frame:RegisterForDrag("LeftButton")
	
	if dragtype == "assignmentpopulate" or dragtype == "populate" then
	   -- add right-click menu
	   frame:SetScript("OnMouseUp",
	       function(self) 
	           if arg1=="RightButton" then 
	               -- dropdown menu
	               --GameTooltip:Hide()
	               if self.healerclass then
                        if self.healerclass ~= "ALLREMAINING" then
                           GTHPopDropped = self.healername
                            UIDropDownMenu_Initialize( GTHPopulateDropdown, GTHPopulateDropInit, "MENU" )
                             ToggleDropDownMenu( 1, nil, GTHPopulateDropdown, frame, 0, 0)
                         end
			         end
	           end 
	       end
	   )
	end
	
	frame:SetScript( "OnDragStart" , function(self) GTH_DragStart( self ) end )
	frame:SetScript( "OnDragStop" , function(self) GTH_DragStop( self ) end )
	
	frame:SetScript( "OnEnter" , function(self) 
        self.highlight:SetTexture( "Interface\\BUTTONS\\UI-Common-MouseHilight" )
        if self.tooltip then
            -- set show tooltip timer
            GTHtooltarget = self
            GTHtooltimer = 0
        end
    end )
    frame:SetScript( "OnLeave" , function(self) 
        self.highlight:SetTexture( nil )
        local c = gthcolor.dragborder
        self:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
        GameTooltip:Hide()
        GTHtooltarget = nil
    end )
	
	frame.healername = healername
	frame.healerclass = healerclass
	frame.labelframe = textframe
	frame.dragtype = dragtype -- populate or relocate
	frame:Hide()
	-- text string
	textframe:SetFontObject("GameFontNormalSmall")
	textframe:SetPoint("CENTER" , frame , "CENTER" , 0, 0)
	if dragtype ~= "phase" then
	   textframe:SetText( GTH_HexClassColor(healerclass)..healername )
    end
	-- right icon
	frame.icon = frame:CreateTexture(nil,"ARTWORK")
	frame.icon:SetBlendMode("BLEND")
	frame.icon:SetWidth(16)
	frame.icon:SetHeight(16)
	frame.icon:SetPoint("RIGHT",frame,"RIGHT",-2,0);
    frame.icon:SetTexture(nil)
    -- left icon
	frame.iconL = frame:CreateTexture(nil,"ARTWORK")
	frame.iconL:SetBlendMode("BLEND")
	frame.iconL:SetWidth(16)
	frame.iconL:SetHeight(16)
	frame.iconL:SetPoint("LEFT",frame,"LEFT",2,0);
    frame.iconL:SetTexture(nil)
    -- highlight
    frame.highlight = frame:CreateTexture(nil,"ARTWORK")
    frame.highlight:SetBlendMode("ADD")
    --frame.highlight:SetWidth(140)
    --frame.highlight:SetHeight(30)
    --frame.highlight:SetPoint( "LEFT" , frame , "LEFT" , -4 , -4 )
    frame.highlight:SetAllPoints( frame )
    frame.highlight:SetAlpha(0.7)
    frame.highlight:SetTexture(nil)
	
end

function GTH_AssignmentPoolInitialize( frame )
    -- just initializes the pool target
    -- other functions position and update it
    frame:SetWidth(120 + 4)
	frame:SetHeight(24 + 4)
	frame:SetBackdrop( { 
		bgFile = "Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame:SetBackdropColor(0,0,0, 0.5 )
	local c = gthcolor.assignpoolborder
	frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", GTHframes.frame, "CENTER", 0, 0)
	frame:Hide()
	frame.assignment = nil
	frame.rows = 1
	frame:SetFrameLevel(GTHframes.frame:GetFrameLevel()+1)
end

function GTH_AssignedPoolInitialize( frame )
    -- just initializes the pool target
    -- other functions position and update it
    frame:SetWidth(100*2 + 4)
	frame:SetHeight(24 + 4)
	frame:SetBackdrop( { 
		bgFile = "Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame:SetBackdropColor(0,0,0, 0.5 )
	local c = gthcolor.assignpoolborder
	frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", GTHframes.frame, "CENTER", 0, 0)
	frame:Hide()
	frame.assignment = nil
	frame.rows = 1
	frame:SetFrameLevel(GTHframes.frame:GetFrameLevel()+1)
end

function GTH_AssignedPoolPosition( frame , row , height , dropframe )
    -- moves the pool to the right place on the screen
    if frame then
        frame:ClearAllPoints()
        frame:SetHeight(24*height+4)
        frame:SetPoint("TOPLEFT" , GTHframes.frame , "TOPLEFT" , menusstartx + colwidth + 18 , menusstarty - rowheight*(row-1) - 12 )
    end
    -- also position corresponding assignment drop pool
    if dropframe then
        dropframe:ClearAllPoints()
        dropframe:SetPoint("TOPLEFT" , GTHframes.frame , "TOPLEFT" , menusstartx + 18 , menusstarty - rowheight*(row-1) - 12 )
    end
    
end

function GTH_alreadyassigned( assignmentstring )
    local isassigned = false
    for aname,adata in pairs( GTHassignment[ GTHdisplayphase ] ) do
        if aname == assignmentstring then
            isassigned = true
        end
    end
    return isassigned
end

GTHcurrentdrag = nil
function GTH_DragStart( frame )

    --gthprint( frame:GetName().." : "..frame.dragtype..tostring(frame.assignment) )

    -- attach ghost drag to cursor
    local cursorX, cursorY = GetCursorPosition()
    cursorX = cursorX / UIParent:GetEffectiveScale()
    cursorY = cursorY / UIParent:GetEffectiveScale()
    --local pt , relFrame , relPt , startX, startY = frame:GetPoint()
    local name = frame.healername
    if not name then name = "noname" end
    --GTHframes.dragGhostLabel:SetText( name )
    
    --gthprint( table.concat( { name , frame.healerclass } , "," ) )
    
    -- check for assignment populate that is already assigned in this phase
    if frame.dragtype == "assignmentpopulate" and GTH_alreadyassigned( frame.assignment ) then
        return -- no drag!
    end
    
    if frame.dragtype == "phase" then
        GTH_DragSetHealer( GTHframes.dragGhost , frame.phase , "PRIEST" , "phase" )
        GTHframes.dragGhost:SetWidth( phasewidth )
    elseif frame.dragtype == "assignmentpopulate" then
        GTH_DragSetHealer( GTHframes.dragGhost , name , frame.healerclass , "assignmentpopulate" )
        GTHframes.dragGhost:SetWidth( dragwidthstd )
    elseif frame.dragtype == "assignmentrelocate" then
        GTH_DragSetHealer( GTHframes.dragGhost , name , frame.healerclass , "assignmentrelocate" )
        GTHframes.dragGhost:SetWidth( dragwidthstd )
    else
        GTH_DragSetHealer( GTHframes.dragGhost , name , frame.healerclass )
        GTHframes.dragGhost:SetWidth( dragwidthstd )
    end
    
    GTHframes.dragGhost:ClearAllPoints()
	GTHframes.dragGhost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX , cursorY )
    GTHframes.dragGhost:Show()
    if frame.dragtype == "populate" then
        -- healer template box
        local c = gthcolor.draghighlight
        frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
        GTHframes.dragGhost:SetAlpha(1)
        GTHcurrentdrag = frame
    elseif frame.dragtype == "phase" then
        -- phase box
        frame:SetAlpha(0)
        GTHcurrentdrag = frame
        GTHframes.dragGhost:SetAlpha(1)
        local c = gthcolor.draghighlight
        GTHframes.dragGhost:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
    else
        -- assigned healer box, so just pick it up
        frame:SetAlpha(0.1)
        GTHcurrentdrag = GTHframes.dragGhost
        GTHframes.dragGhost:SetAlpha(1)
    end
    GTHframes.dragGhost:StartMoving()
    --gthprint( "Drag start: "..frame:GetName().."/"..frame.phase.."/"..frame.assignment.." / "..frame.healername )
end

function GTH_DragStop( frame )

    if frame.dragtype == "assignmentpopulate" and GTH_alreadyassigned(frame.assignment) then
        return -- no drag! so no stop
    end

    -- hide ghost drag
    GTHframes.dragGhost:StopMovingOrSizing()
    if frame.dragtype == "populate" then
        local c = gthcolor.dragborder
        frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
    else
        frame:SetAlpha(1)
    end
    GTHcurrentdrag = nil
    GTHframes.dragGhost:Hide()
    
    -- check for drop target
    
    --gthprint( "drop "..frame.dragtype )
    
    -- dragtypes POPULATE and RELOCATE
    if frame.dragtype == "populate" or frame.dragtype == "relocate" then
        for i = 1,8 do
            local pool = GTHframes.assignedpool[i]
            if MouseIsOver(pool) and pool:IsVisible() then
                local c = gthcolor.assignpoolborder
                pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                --gthprint( "Drop target: "..pool:GetName().."/"..pool.phase.."/"..pool.assignment.."/"..frame.healername )
                --gthprint( "          "..frame.phase.."/"..frame.assignment )
                -- check if relocate and landed on home
                if frame.dragtype == "relocate" then
                    -- also remove from source
                    GTH_UnAssignHealer( frame.healername , frame.phase , frame.assignment )
                end
                if frame.healername == GTHL["All remaining"] then
                    GTHassignment[ pool.phase ][ pool.assignment ] = { [GTHL["All remaining"]]={ ["class"]="ALLREMAINING" } }
                else
                    GTH_UnAssignHealer( GTHL["All remaining"] , pool.phase , pool.assignment )
                    --GTH_AssignHealer( frame.healername , pool.phase , pool.assignment )
                    GTHassignment[ pool.phase ][ pool.assignment ][ frame.healername ] = { ["class"]=frame.healerclass , ["talents"] = frame.talents }
                end
                -- redraw
                GTH_RefreshDropMenus( GTHdisplayphase )
                return
            end
        end
        -- check for dumping an assigned healer dropped outside a pool
        if MouseIsOver( GTHframes.frame ) and frame.dragtype == "relocate" then
            -- assigned healer dragged and dropped in open frame space, so unassign
            GTH_UnAssignHealer( frame.healername , frame.phase , frame.assignment )
            GTH_RefreshDropMenus( GTHdisplayphase )
        end
    end -- dragtypes POPULATE and RELOCATE
    
    -- dragtypes ASSIGNMENTPOPULATE and ASSIGNMENTRELOCATE
    if frame.dragtype == "assignmentpopulate" or frame.dragtype == "assignmentrelocate" then
        for i = 1,8 do
            local pool = GTHframes.assignmentpool[i]
            if MouseIsOver(pool) and pool:IsVisible() then
                local c = gthcolor.assignpoolborder
                pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                --gthprint( "Drop target: "..pool:GetName().."/"..pool.phase.."/"..pool.assignment.."/"..frame.healername )
                --gthprint( "          "..frame.phase.."/"..frame.assignment )
                -- check if relocate and landed on home
                if frame.dragtype == "assignmentrelocate" then
                    -- assignment name dragged to new slot
                    -- so swap source and target positions
                    if pool.assignment then
                        -- we didn't land on the "new" box
                        local targetorder = GTHassignment[GTHdisplayphase]["xtagsx"]["aorder"][pool.assignment]
                        GTHassignment[GTHdisplayphase]["xtagsx"]["aorder"][pool.assignment] = GTHassignment[GTHdisplayphase]["xtagsx"]["aorder"][frame.assignment]
                        GTHassignment[GTHdisplayphase]["xtagsx"]["aorder"][frame.assignment] = targetorder
                    end
                else
                    -- populate from assignment type pool (tank pool)
                    -- so replace target assignment with drag assignment
                    -- first destroy any assignment already in target
                    if pool.assignment then
                        local copy = GTH_assignedhealers_copy( GTHassignment[ pool.phase ][ pool.assignment ] )
                        GTHassignment[ pool.phase ][ pool.assignment ] = nil
                        -- make new assignment (with new name) and slot the old assigned healers into it
                        GTHassignment[ pool.phase ][ frame.assignment ] = copy
                        -- preserve order of old name
                        local pos = GTHassignment[ pool.phase ]["xtagsx"]["aorder"][pool.assignment]
                        GTHassignment[ pool.phase ]["xtagsx"]["aorder"][pool.assignment] = nil
                        GTHassignment[ pool.phase ]["xtagsx"]["aorder"][frame.assignment] = pos
                    else
                        -- must be the new assignment drag box
                        -- so make it a new assignment
                        GTHassignment[ pool.phase ][ frame.assignment ] = {}
                        -- give it an order
                        local nth = GTH_CountAssignmentsinPhase( GTHassignment[GTHdisplayphase] )
                        GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "aorder" ][ frame.assignment ] = nth
                    end
                    -- finally check if custom assignment. if so, open rename box.
                    if frame.assignment == GTHL["Custom..."] then
                        GTH_RefreshDropMenus( GTHdisplayphase )
                        for i = 1,8 do
                            if GTHframes.dragAssignment[i].assignment == GTHL["Custom..."] then
                                customtarget = GTHframes.dragAssignment[i]
                            end
                        end
                        GTHframes.customedit:SetText( GTHL["Custom..."] )
                        -- store the assignment
                        GTHframes.custom:ClearAllPoints()
                        GTHframes.custom:SetPoint("CENTER", customtarget, "CENTER", 0, 0)
                        GTHcustomassignment:Show()
                        GTHframes.customedit:HighlightText()
                    end
                end
                
                -- redraw
                GTH_RefreshDropMenus( GTHdisplayphase )
                return
            end
        end
        -- check for dumping an assigned healer dropped outside a pool
        if MouseIsOver( GTHframes.frame ) and frame.dragtype == "assignmentrelocate" then
            -- assignment dragged and dropped in open frame space, so delete this assignment
            -- GTH_UnAssignHealer( frame.healername , frame.phase , frame.assignment )
            GTHassignment[ GTHdisplayphase ][ frame.assignment ] = nil
            local oldpos = GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "aorder" ][ frame.assignment ]
            GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "aorder" ][ frame.assignment ] = nil
            -- reorder remaining assignments
            for a,o in pairs( GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "aorder" ] ) do
                if o > oldpos then
                    -- move assignments that were above the deleted one down one position
                    GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "aorder" ][a] = o-1
                end
            end
            
            GTH_RefreshDropMenus( GTHdisplayphase )
        end
    end -- dragtypes ASSIGNMENTPOPULATE and ASSIGNMENTRELOCATE
    
    -- dragtype PHASE
    if frame.dragtype == "phase" then
        local c = gthcolor.dragborder
        frame:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
        
        for i = 1,8 do
            local pool = GTHframes.phasedrag[i]
            if MouseIsOver(pool) and pool:IsVisible() and pool ~= frame then
                -- swap orders: dragged phase with dragged-to phase
                -- FRAME is the dragged phase
                -- POOL is the target phase
                local source_order_orig = GTHassignment[ frame.phase ][ "xtagsx" ][ "order" ]
                local dest_order_orig = GTHassignment[ pool.phase ][ "xtagsx" ][ "order" ]
                GTHassignment[ frame.phase ][ "xtagsx" ][ "order" ] = dest_order_orig
                GTHassignment[ pool.phase ][ "xtagsx" ][ "order" ] = source_order_orig
                frame:SetAlpha(1)
                pool:SetAlpha(1)
                GTH_RefreshDropMenus( GTHdisplayphase )
                return
            end
        end
        
        -- check for dumping a phase outside the phase list to delete it
        if MouseIsOver( GTHframes.frame ) and frame.dragtype == "phase" and not MouseIsOver( frame ) then
            if GTH_CountPhases( GTHassignment ) > 1 then
                -- delete phase
                local n = GTH_CountPhases( GTHassignment )
                local oldpos = GTHassignment[ frame.phase ][ "xtagsx" ][ "order" ]
                GTHassignment[ frame.phase ] = nil
                -- renumber the phases
                for k,v in pairs( GTHassignment ) do
                    local pos = v["xtagsx"]["order"]
                    if pos > oldpos then
                        -- phases that were higher in number than the deleted one need to be moved down one
                        v["xtagsx"]["order"] = pos - 1
                    end
                end
                -- select a new display phase
                for k,v in pairs( GTHassignment ) do
                    GTHdisplayphase = k
                    break
                end
                GTH_RefreshDropMenus( GTHdisplayphase )
            end
        end
        
    end -- dragtype PHASE
    
end

function GTH_RefreshPhaseDrags( displayphase )
    -- refreshes display of phase boxes on left
    
    local numphases = GTH_CountPhases( GTHassignment )
    local sortedphases = GTH_sort_phases( GTHassignment )
    local activebox = nil
    
    for i = 1,8 do
        if i > numphases then
            GTHframes.phasedrag[i]:Hide()
            GTHframes.phasedrag[i].phase = nil
        else
            local phase = sortedphases[i]
            GTHframes.phasedrag[i].phase = phase
            GTHframes.phasedrag[i].label:SetText( GTH_rgbToHexColor(1,1,1)..phase )
            if displayphase == phase then
                GTHframes.phasedrag[i]:SetHeight( 24 )
                GTHframes.phasedrag[i]:SetWidth( phasewidth + 10 )
                GTHframes.phasedrag[i].icon:SetTexture( "Interface\\BUTTONS\\UI-CheckBox-Check" )
                activebox = i
            else
                GTHframes.phasedrag[i]:SetHeight( 22 )
                GTHframes.phasedrag[i]:SetWidth( phasewidth )
                GTHframes.phasedrag[i].icon:SetTexture( nil )
            end
            --local numicon = "Interface\\AddOns\\GettingThingsHealed\\glassnumbers"
            --GTHframes.phasedrag[i].iconL:SetTexture(numicon..i..".tga")
            -- update position of phase boxes
            GTHframes.phasedrag[i]:ClearAllPoints()
            GTHframes.phasedrag[i]:SetPoint( "CENTER" , GTHframes.frame , "TOPLEFT" , 85 , -3 + menusstarty - (i)*23 )
            GTHframes.phasedrag[i]:Show()
        end
    end
    
    -- position the new phase button
    -- GTHframes.newphasebutton
    GTHframes.newphasebutton:ClearAllPoints()
    GTHframes.newphasebutton:SetPoint( "CENTER" , GTHframes.frame , "TOPLEFT" , 85 , -3 + menusstarty - (numphases+1)*23 )
    
    local n = GTH_CountPhases( GTHassignment )
    if n < 8 then
        GTHframes.newphasebutton:Show()
    else
        GTHframes.newphasebutton:Hide()
    end
    
    -- finally position and show the connection lines
    GTHframes.plines[1]:ClearAllPoints()
    GTHframes.plines[1]:SetPoint( "LEFT" , GTHframes.phasedrag[activebox] , "RIGHT" , 0 , 0 )
    GTHframes.plines[1]:SetWidth(20)
    GTHframes.plines[1]:Show()
    
    local dotheight = GTH_CountAssignmentsinPhase( GTHassignment[GTHdisplayphase] ) * rowheight
    dotheight = max( 23*( activebox ) - 11 , dotheight )
    GTHframes.plines[2]:ClearAllPoints()
    GTHframes.plines[2]:SetPoint( "TOP" , GTHframes.phasedrag[1] , "CENTER" , 91 , 12 )
    GTHframes.plines[2]:SetHeight( dotheight )
    GTHframes.plines[2]:Show()
    
end

function GTH_RefreshDropMenus( displayphase )
    -- creates dropdownmenus for assignments, and healer names
    
    GTHdisplayphase = displayphase
    
    GTH_RefreshPhaseDrags( displayphase )
    GTH_RefreshPopulatePool()
    
    -- first check if we made the frames already
    local createframes = false;
    if GTHframes.dropAssign == nil then
        createframes = true;
        GTHframes.dropAssign = {};
        GTHframes.dropHealers = {};
    end
    
    if createframes then
    
        --gthprint( "GTH> Create Frames" )
        
        -- create rows of paired assignment/healer menus
        for i = 1 , maxassignments do
            GTHframes.dropAssign[i] = GTH_CreateAssignmentDropMenu( "GTHdropA"..i , 1 + i , displayphase , "x" , i );
            GTHframes.dropHealers[i] = GTH_CreateHealerDropMenu( "GTHdropH"..i , 1 + i , displayphase , "x" , i );
        end
        
        -- assignments label
        GTHframes.labelA = GTHframes.frame:CreateFontString();
        GTHframes.labelA:SetFontObject("GameFontNormal");
        GTHframes.labelA:SetPoint("BOTTOMLEFT" , GTHframes.assignmentpool[1] , "TOPLEFT" , 20, 0);
        GTHframes.labelA:SetText(GTHL["Assignments"]);
        
        -- healer lists label
        GTHframes.labelH = GTHframes.frame:CreateFontString();
        GTHframes.labelH:SetFontObject("GameFontNormal");
        GTHframes.labelH:SetPoint("BOTTOMLEFT" , GTHframes.assignmentpool[1] , "TOPLEFT" , 130 + 20, 0);
        GTHframes.labelH:SetText(GTHL["Healers"]);
    end
    
    -- hide all the frames before we display the needed ones
    for i = 1 , maxassignments do
        GTHframes.dropAssign[i]:Hide()
        GTHframes.dropHealers[i]:Hide()
        GTHframes.assignedpool[ i ]:Hide()
        GTHframes.assignmentpool[ i ]:Hide()
        GTHframes.dragAssignment[ i ]:Hide()
        for j = 1,8 do
            GTHframes.dragListed[ i ][ j ]:Hide()
        end
    end
        
    -- now feed them correct info
    
    -- get the phase
    --gthprint( displayphase );
    local GTHphase = GTHassignment[displayphase];
    
    local assigncount = 0;
    
    -- get sorted list of assignments in the phase
    -- this ensures we display assignments in alphabetical order
    --local sassignments = GTH_sort_keys( GTHphase );
    local sassignments = GTH_sortAssignmentsByOrder( GTHphase )
    
    --gthprint( table.concat( sassignments , " , " ) )
    
    --for anAssignment,aHealerList in pairs( GTHphase ) do
    local showrow = 1
    for i = 1 , #( sassignments ) do
    
        local anAssignment = sassignments[i];
        local aHealerList = GTHphase[anAssignment];
    	
    	if anAssignment ~= "xtagsx" then
    	
			assigncount = assigncount + 1;
			
			local nhealers = GTH_CountHealersInAssignment( displayphase , anAssignment )
			local poolheight = ceil( nhealers / 2 ) -- 1,2=1 ; 3,4=2 ; etc
			poolheight = max(1,poolheight)
			
			--GTHframes.dropAssign[assigncount].phase = displayphase;
			--GTHframes.dropAssign[assigncount].assignment = anAssignment;
			
			-- select assignment
			UIDropDownMenu_SetText( GTHframes.dropAssign[assigncount] , anAssignment );
			
			-- healer target pools (for dragging to/from)
			GTH_AssignedPoolPosition( GTHframes.assignedpool[ assigncount ] , showrow , poolheight , GTHframes.assignmentpool[ assigncount ] )
			showrow = showrow + poolheight
			
			-- assigned healer drag targets
			GTHframes.assignedpool[ assigncount ].assignment = anAssignment
			GTHframes.assignedpool[ assigncount ].phase = displayphase
			
			-- assignment name drag targets
			GTHframes.assignmentpool[ assigncount ].assignment = anAssignment
			GTHframes.assignmentpool[ assigncount ].phase = displayphase
			
			-- healer menus
			GTHframes.dropHealers[assigncount].phase = displayphase;
			GTHframes.dropHealers[assigncount].assignment = anAssignment;
			
			-- remove selections
			GTHframes.dropHealers[assigncount].selectedValue = nil;
			GTHframes.dropAssign[assigncount].selectedValue = nil;
			GTHframes.dropAssign[assigncount].selectedName = anAssignment;
			
			-- set summary text on healer menu
			local buttonstring = ""
            buttonstring = GTH_FormatHealersMenuText( displayphase , anAssignment )
			--UIDropDownMenu_SetText( GTHframes.dropHealers[assigncount] , buttonstring );
			
			-- finally make visible
			--GTHframes.dropHealers[assigncount]:Show()
			GTHframes.dropHealers[assigncount]:Hide()
			--GTHframes.dropAssign[assigncount]:Show()
			GTHframes.dropAssign[assigncount]:Hide()
			GTHframes.assignedpool[ assigncount ]:Show()
			GTHframes.assignmentpool[ assigncount ]:SetAlpha(1)
			GTHframes.assignmentpool[ assigncount ]:Show()
			
			-- show assignment box
			GTH_RefreshAssignmentInPool( GTHframes.assignmentpool[ assigncount ] , assigncount )
			
			-- show healer boxes
			GTH_RefreshHealersInPool( GTHframes.assignedpool[ assigncount ] , assigncount )
        
        end -- not xtagsx
    end
    
    -- show the bottom blank assignment drag target, for making a new assignment
    local na = #( sassignments )
    if na < 8 then
        GTHframes.assignmentpool[ na+1 ].assignment = nil
        GTHframes.assignmentpool[ na+1 ].phase = displayphase
        
        GTH_AssignedPoolPosition( nil , showrow , poolheight , GTHframes.assignmentpool[ na+1 ] )
        
        GTHframes.assignmentpool[ na+1 ]:SetAlpha(0.5)
        GTHframes.assignmentpool[ na+1 ]:Show()
    end
    
    -- check if we need to expand the height of the frame
    
    --gthprint( GTHtankRows)
    --gthprint( GTHhealerRows)
    
    -- expand for pools
    
    local poolrows = max( GTHtankRows , GTHhealerRows )
    showrow = max( showrow , GTH_CountPhases( GTHassignment )*0.9 )
    
    local currHeight = GTHframes.frame:GetHeight()
    
    local slack = 8 - poolrows - showrow
    
    if slack <= 0 then
        -- expand height of frame
        GTHframes.frame:SetHeight( gthwinheight + tankpoolrowheight*( abs(slack) ) )
    else
        -- set the default height
        GTHframes.frame:SetHeight( gthwinheight )
    end
    
    
    -- finally make sure phase menu shows current phase
    UIDropDownMenu_SetText( GTHdropNew , displayphase );
    UIDropDownMenu_SetSelectedName( GTHdropNew , displayphase );
    
    GTHdisplayphase = displayphase;
    
    GTH_RefreshPopulatePool()
    
    --gthprint("refresh done");
end

function GTH_RefreshAssignmentInPool( frame , index )
    -- show the currently slotted assignment in this assignment pool
    local assignment = frame.assignment
    local phase = frame.phase
    
    local class = nil
    
    local displayname , tanknum , tankname = GTH_FormatAssignmentString( assignment )
    
    if tankname then
        -- formatted assignment string replaced a tank name, so we need to color it right and pull talents
        if GTHtankList[ tankname ] then
            class = GTH_GetClass( tankname )
        end
    elseif GTHtankList[ displayname ] then
        -- if full assignment name is just the name of a tank, do the same
        class = GTH_GetClass( displayname )
    end
    
    GTH_DragSetHealer( GTHframes.dragAssignment[index] , displayname , class , "assignmentrelocate" , tankname , tanknum )
    
    GTHframes.dragAssignment[index].phase = phase
    GTHframes.dragAssignment[index].assignment = assignment
    
    GTHframes.dragAssignment[ index ].tooltip = GTH_rgbToHexColor(1,1,1).."Right-click to rename"
    
    GTHframes.dragAssignment[index]:ClearAllPoints()
    GTHframes.dragAssignment[index]:SetPoint( "CENTER" , frame , "CENTER" , 0 , 0 )
    GTHframes.dragAssignment[index]:Show()
end

function GTH_RefreshHealersInPool( frame , index )
    -- show/hide individual healer boxes in an assigned pool
    local assignment = frame.assignment
    local phase = frame.phase
    local hlist = GTH_sort_keys( GTHassignment[phase][assignment] )
    local nh = #( hlist )
    
    local col = 0
    local row = 1
    for i = 1,8 do
        local healerframe = GTHframes.dragListed[index][i]
        if i > nh then
            -- not this many healers, so hide
            healerframe:Hide()
        else
            -- position and show
            healerframe.phase = phase
            healerframe.assignment = assignment
            local name = hlist[i]
            local class
            class = GTHassignment[phase][assignment][ name ][ "class" ]
                
            GTH_DragSetHealer( healerframe , name , class , "relocate" )
            col = col + 1
            if col > 2 then
                col = 1
                row = row + 1
            end
            healerframe:ClearAllPoints()
            healerframe:SetPoint( "TOPLEFT" , frame , "TOPLEFT" , 3 + (col-1)*98 , -4 - (row-1)*23 )
            healerframe:Show()
        end
    end
            
end

local GTHabbrevtab = {
	[2] = 6,
	[3] = 4,
	[4] = 3,
	[5] = 2,
	[6] = 1
}
function GTH_FormatHealersMenuText( phase , assignment )
	local hn = GTH_CountHealersInAssignment( phase , assignment );
	local buttonstring = ""
	local abbrevlen = GTHabbrevtab[hn]
	if hn > 6 then abbrevlen = 1 end
	if hn > 1 then
		buttonstring = "("..hn..")";
		for h,v in pairs( GTHassignment[phase][assignment] ) do
			buttonstring = buttonstring.." "..GTH_HexClassColor( v["class"] )..string.sub(h,1,abbrevlen)
		end
	else
		for h,v in pairs( GTHassignment[phase][assignment] ) do
			buttonstring = GTH_HexClassColor( v["class"] )..h
		end
	end
	return buttonstring
end

function GTH_sort_keys( set )
    -- takes a table and returns a sorted list of the keys
    local sortedset = {};
    for k,v in pairs( set ) do
        table.insert( sortedset , k )
    end
    table.sort( sortedset )
    return sortedset;
end

function GTH_CreateAssignmentDropMenu( name , row , phase , assignment , myindex )
    local thenewframe = CreateFrame("Frame", name , GTHframes.frame, "UIDropDownMenuTemplate");
	thenewframe:ClearAllPoints()
    thenewframe:SetPoint("LEFT", GTHframes.frame, "TOPLEFT" , menusstartx , menusstarty - rowheight*(row-1) );
    thenewframe.phase = phase;
    thenewframe.assignment = assignment;
    thenewframe.droptype = "assignment";
    thenewframe.myindex = myindex;
    UIDropDownMenu_Initialize(thenewframe, GTHdrop1_Initialise);
    return thenewframe;
end

function GTH_CreateHealerDropMenu( name , row , phase , assignment , myindex )
    local thenewframe = CreateFrame("Frame", name , GTHframes.frame, "UIDropDownMenuTemplate");
	thenewframe:ClearAllPoints()
    thenewframe:SetPoint("LEFT", GTHframes.frame, "TOPLEFT" , menusstartx + colwidth + 15 , menusstarty - rowheight*(row-1) );
    thenewframe.phase = phase;
    thenewframe.assignment = assignment;
    thenewframe.droptype = "healerlist";
    thenewframe.myindex = myindex;
    UIDropDownMenu_Initialize(thenewframe, GTHdropH1_Initialise);
    return thenewframe;
end

function GTH_CreatePhaseDropMenu( name , row , phase )
    local thenewframe = CreateFrame("Frame", name , GTHframes.frame, "UIDropDownMenuTemplate");
	thenewframe:ClearAllPoints()
    thenewframe:SetPoint("LEFT", GTHframes.frame, "TOPLEFT" , menusstartx , menusstarty - rowheight*(row-1) + 24 );
    thenewframe.phase = phase;
    UIDropDownMenu_Initialize(thenewframe, GTHdropNew_Initialise);
    return thenewframe;
end

function GTH_AssignmentExists( assignment , phase )
    for k,v in pairs( GTHassignment[phase] ) do
        if ( k == assignment ) then return true; end
    end
    return nil;
end

function GTHdropDeletePresets_Initialise(self)
    level = 1;
    local info = UIDropDownMenu_CreateInfo();
    
    for k,v in pairs( GTHData.playerPresets ) do
        --gthprint( k );
        info.text = k;
        info.value = k;
        info.func = GTHdropmenu_OnClick 
        info.owner = self
        info.checked = nil; 
        info.icon = nil;
        UIDropDownMenu_AddButton(info, level);
    end
    
end

function GTHdropOptions_Initialise(self)
	level = 1;
    local info = UIDropDownMenu_CreateInfo();
    
    -- OPTIONS
    
    info.text = "GTH "..GTHversion.." "..GTHL["Options"];
    info.isTitle = true;
    info.value = -1;
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end; 
    info.owner = self
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.isTitle = nil
    info.disabled = nil
    
    info.text = GTHL["Broadcast deaths"];
    info.value = "Broadcast deaths";
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end; 
    info.owner = self
    info.checked = GTHData.announceDeaths; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    -- announceOffline
    
    info.text = GTHL["Broadcast disconnects"];
    info.value = "Broadcast disconnects";
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end; 
    info.owner = self
    info.checked = GTHData.announceOffline; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["Verbose broadcasts"];
    info.value = "Verbose";
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end; 
    info.owner = self
    info.checked = GTHData.verbose; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    -- COMMANDS
    
    info.text = GTHL["Commands"];
    info.isTitle = true;
    info.value = -1;
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end; 
    info.owner = self
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.isTitle = nil
    info.disabled = nil
    
    -- roster reset
    info.text = "Reset saved roster";
    info.value = "ResetRoster";
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end;
    info.owner = self
    info.icon = nil;
    info.checked = nil;
    info.colorCode = GTH_rgbToHexColor( 1 , 1 , 1 );
    info.keepShownOnClick = nil;
    UIDropDownMenu_AddButton(info, level);
    
    -- GTH_SharePreset( preset )
    
    info.text = GTHL["Share current assignments"];
    info.value = "Share";
    info.func = function(self) GTHdropmenu_OptionsOnClick(self) end;
    info.owner = self
    info.icon = nil;
    info.checked = nil;
    info.colorCode = GTH_rgbToHexColor( 1 , 1 , 1 );
    info.keepShownOnClick = nil;
    UIDropDownMenu_AddButton(info, level);
    
end

function GTHdropBroadcast_Initialise(self)
    level = 1;
    local info = UIDropDownMenu_CreateInfo();
    
    info.text = GTHL["Raid"];
    info.value = "RAID";
    info.func = GTHdropmenu_OnClick
    info.owner = self
    info.checked = nil;
    info.icon = nil;
    -- get the chat window color for this channel
    local chatinfo = ChatTypeInfo[ "RAID" ];
    info.colorCode = GTH_rgbToHexColor( chatinfo.r , chatinfo.g , chatinfo.b );
    UIDropDownMenu_AddButton(info, level);
    
    -- add channels
    local chanList = { GetChannelList() };
    local serverChannels1 = { EnumerateServerChannels() } -- list of server channels, so we can filter them out
    local serverChannels = {}
    for i,c in ipairs( serverChannels1 ) do -- make keyed table to server channels
    	serverChannels[ c ] = c
    end
    local numChan = #chanList / 2;
    -- PA: Fix this channel search
    -- for i = 1,numChan do
    --     local chanNumberIndex = (i-1)*2 + 1; -- 1 is 1; 2 is 3; 3 is 5; etc.
    --     if not serverChannels[ chanList[chanNumberIndex + 1] ] then
    --         -- not a server channel, so add to menu
    --         info.text = chanList[chanNumberIndex + 1];
    --         info.value = chanList[chanNumberIndex + 1];
    --         info.func = GTHdropmenu_OnClick 
    --         info.owner = self
    --         info.checked = nil; 
    --         info.icon = nil;
            
    --         -- get the chat window color for this channel
    --         local chatinfo = ChatTypeInfo[ "CHANNEL"..chanList[chanNumberIndex] ];
    --         info.colorCode = GTH_rgbToHexColor( chatinfo.r , chatinfo.g , chatinfo.b );
            
    --         UIDropDownMenu_AddButton(info, level);
    --     end
    -- end
    
    info.text = GTHL["Whisper"];
    info.value = "WHISPER";
    info.func = GTHdropmenu_OnClick 
    info.owner = self
    info.checked = nil;
    info.icon = nil;
    -- get the chat window color for this channel
    local chatinfo = ChatTypeInfo[ "WHISPER" ];
    info.colorCode = GTH_rgbToHexColor( chatinfo.r , chatinfo.g , chatinfo.b );
    UIDropDownMenu_AddButton(info, level);
    
end

-- called when presets menu is opened
function GTHdropPresets_Initialise(self)

    level = 1;
    local info = UIDropDownMenu_CreateInfo();
    local countplayerpresets = 0;
    
    -- add player presets
    for k,v in pairs( GTHData.playerPresets ) do
        countplayerpresets = countplayerpresets + 1;
    end
    
    if countplayerpresets > 0 then
    
        local sortedPresetNames = GTH_sort_keys( GTHData.playerPresets )
    
        info.text = GTHL["Player presets"];
        info.isTitle = true;
        info.value = -1;
        info.func = function(self) GTHdropmenu_OnClick(self) end; 
        info.owner = self
        info.checked = nil; 
        info.icon = nil;
        UIDropDownMenu_AddButton(info, level);
        
        info.isTitle = nil;
        info.disabled = nil;
        
        if IsShiftKeyDown() then
            -- prune out preset names that don't contain current zone name
            local thiszone = GetRealZoneText()
            local newtab = {}
            for i,k in ipairs( sortedPresetNames ) do
                if string.find( k , thiszone ) then
                    table.insert( newtab , k )
                end
            end
            sortedPresetNames = newtab
            if #sortedPresetNames == 0 then
                -- note empty
                info.text = "-- No presets containing zone name '"..GetRealZoneText().."'";
                info.isTitle = true;
                info.value = -1;
                info.func = function(self) GTHdropmenu_OnClick(self) end; 
                info.owner = self
                info.checked = nil; 
                info.icon = nil;
                UIDropDownMenu_AddButton(info, level);
                
                info.isTitle = nil;
                info.disabled = nil;
            end
        else
            -- note about shift-click for only those that match current zone
            local zone = GetRealZoneText()
            if not zone then zone = "_" end
            info.text = "Shift-click for zone matches only ("..zone..")";
            info.isTitle = true;
            info.value = -1;
            info.func = function(self) GTHdropmenu_OnClick(self) end; 
            info.owner = self
            info.checked = nil; 
            info.icon = nil;
            UIDropDownMenu_AddButton(info, level);
            
            info.isTitle = nil;
            info.disabled = nil;
        end
    
        for i,k in ipairs( sortedPresetNames ) do
            --gthprint( k );
            info.text = k;
            info.value = k;
            info.func = function(self) GTHdropmenu_OnClick(self) end; 
            info.owner = self
            info.checked = nil; 
            info.icon = nil;
            UIDropDownMenu_AddButton(info, level);
        end
        
        info.text = GTHL["Built-in presets"];
        info.isTitle = true;
        info.value = -1;
        info.func = function(self) GTHdropmenu_OnClick(self) end; 
        info.owner = self
        info.checked = nil; 
        info.icon = nil;
        UIDropDownMenu_AddButton(info, level);
        
        info.isTitle = nil;
        info.disabled = nil;
    end
    
    -- add built-in presets
    local presets = GTH_sort_keys( GTHpresets )
    for i = 1,#(presets) do
    --for k,v in pairs( GTHpresets ) do
        --gthprint( k );
        local k = presets[i]
        info.text = k;
        info.value = k;
        info.func = function(self) GTHdropmenu_OnClick(self) end; 
        info.owner = self
        info.checked = nil; 
        info.icon = nil;
        UIDropDownMenu_AddButton(info, level);
    end
    
    info.text = GTHL["Commands"];
    info.isTitle = true;
    info.value = -1;
    info.func = function(self) GTHdropmenu_OnClick(self) end; 
    info.owner = self
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.isTitle = nil;
    info.disabled = nil;
    
    -- add "Undo" to most recent assignment, before a preset load
    if GTHassignmentPrev ~= nil then
    	info.disabled = nil
    else
    	info.disabled = true
    end
	info.text = GTHL["Previous preset"];
	info.value = "PREVIOUS";
	info.func = function(self) GTHdropmenu_OnClick(self) end; 
	info.owner = self
	info.checked = nil; 
	info.icon = nil;
	UIDropDownMenu_AddButton(info, level);
    
    info.disabled = nil
    info.text = GTHL["Save as"].."...";
    info.value = 99;
    info.func = function(self) GTHdropmenu_OnClick(self) end; 
    info.owner = self
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    if countplayerpresets > 0 then
    	info.disabled = nil
    else
    	info.disabled = true
    end
	info.text = GTHL["Delete"].."...";
	info.value = 100;
	info.func = function(self) GTHdropmenu_OnClick(self) end; 
	info.owner = self
	info.checked = nil; 
	info.icon = nil;
	UIDropDownMenu_AddButton(info, level);
    
end


function GTH_sort_phases( set )
	-- returns sorted list of phase names, sorted by xorderx field.
	local sortedset = {};
	local numphases = 0;
	
	-- count phases
	for k,v in pairs( set ) do
		numphases = numphases + 1
	end
	
	-- pull out phases in order
	local i = 0
    for k,v in pairs( set ) do
    	i = i + 1
    	if v["xtagsx"] then
    		if v["xtagsx"]["order"] then
    			sortedset[ v["xtagsx"]["order"] ] = k
    		else
    			-- must be an old preset with no order keys
    			sortedset[ i ] = k
    		end
    	else
    		-- must be an old preset with no order keys
    		sortedset[ i ] = k
    	end
    end
    
    return sortedset;
end

function GTH_HexClassColor( class )
    -- takes a class name and return string that is hex raid color
    
    if class == "ALLREMAINING" or not class then
    	return GTH_rgbToHexColor( 1 , 1 , 0.5 )
    end
    
    local r,g,b;
    r = RAID_CLASS_COLORS[class].r;
    g = RAID_CLASS_COLORS[class].g;
    b = RAID_CLASS_COLORS[class].b;
    
    return GTH_rgbToHexColor( r , g , b );
end

function GTH_rgbToHexColor( r , g , b )
    -- convert decimals colors to hex
    r = string.format( "%02x" , r * 255 );
    g = string.format( "%02x" , g * 255 );
    b = string.format( "%02x" , b * 255 );
    
    return "|cff"..r..g..b;
end

function GTHdropmenu_OptionsOnClick(self)
	if self.value == "Broadcast deaths" then
		-- toggle without changing the selected channel
		GTHData.announceDeaths = not GTHData.announceDeaths
	elseif self.value == "Verbose" then
		-- toggle verbose message formats
		GTHData.verbose = not GTHData.verbose
	elseif self.value == "Broadcast disconnects" then
		GTHData.announceOffline = not GTHData.announceOffline
	elseif self.value == "Share" then
		GTH_SharePreset( GTHassignment )
    elseif self.value == "ResetRoster" then
        GTHDataRoster["GTHhealerList"] = nil
        GTHDataRoster["GTHtankList"] = nil
        GTHhealerList = GTH_copy_healer_table( GTHhealerListDefault )
        GTHtankList = GTH_copy_healer_table( GTHtankListDefault )
	end
end

function GTHdropmenu_OnClick(self)

-- this function handles all dropdownmenu clicks

    -- handler for broadcast menu
    if ( self.owner == GTHframes.dropBroadcast ) then
    
    	if self.value == "Broadcast Deaths" then
    		-- toggle without changing the selected channel
    		GTHData.announceDeaths = not GTHData.announceDeaths
    	else    
			UIDropDownMenu_SetSelectedValue(self.owner, self.value);
			GTHData.announcechannel = self.value;
		end
        return;
    end
    
    -- handler for delete presets menu
    if ( self.owner == GTHframes.dropDeletePresets ) then
        -- all we really need to do is highlight the selected item
        -- the "Delete" button in the dialog does the real work
        UIDropDownMenu_SetSelectedValue(self.owner, self.value);
        return;
    end
    
    -- handler for presets menu
    if ( self.owner == GTHdropPreset ) then
    
    
        if self.value == 99 then
            -- save as...
            GTHnameflag = "savepreset";
            GTHframes.renamephaseedit:SetText( GTHmostrecentpresetload );
            GTHrenamephase:Show();
            GTHframes.renamephaseedit:HighlightText();
            return
        elseif self.value == 100 then
            -- delete
            UIDropDownMenu_SetSelectedValue(GTHframes.dropDeletePresets, nil);
            UIDropDownMenu_SetText( GTHframes.dropDeletePresets , "" );
            GTHdeletepreset:Show();
            return
        elseif self.value == "PREVIOUS" then
            -- load previous preset and save current one for "Undo"
            local tempassign = GTH_assignment_copy( GTHassignment );
            GTHassignment = GTH_FilterPreset( GTH_assignment_copy( GTHassignmentPrev ) );
            GTHassignmentPrev = tempassign;
            -- refresh the menus
            local aphase = "";
            for k,v in pairs( GTHassignment ) do
                if v[ "xtagsx" ][ "order" ] == 1 then
                    aphase = k
                end
            end
            GTH_RefreshDropMenus( aphase );
            return
        end
    
        -- fetch the clicked preset and populate current assignment with
        
        -- is it a player preset or built-in?
        local thepreset = {};
        if GTHData.playerPresets[ self.value ] then
            thepreset = GTH_FilterPreset( GTH_assignment_copy( GTHData.playerPresets[self.value] ) )
        else
            thepreset = GTH_FilterPreset( GTH_assignment_copy( GTHpresets[self.value] ) )
        end
        
        -- store name of loaded preset, so we can use it as save default later
        GTHmostrecentpresetload = self.value;
        
        -- save current assignment, so we can "Undo" to it after the load
        GTHassignmentPrev = GTH_assignment_copy( GTHassignment );
        
        GTHassignment = thepreset;
        
        -- refresh the menus
        local aphase = "";
        for k,v in pairs( GTHassignment ) do
            aphase = k;
            break
        end
        GTH_RefreshDropMenus( aphase );
        
    end
    
    -- handler for assignment menu
    if ( self.owner.droptype == "assignment" ) then
        
        local thephase = self.owner.phase;
        local theassign = self.owner.assignment;
        
        -- make sure healer chooser is enabled now
        --UIDropDownMenu_EnableDropDown( getglobal("GTHdropH"..this.owner.myindex) );
        
        if ( self.value == 99 ) then
            -- custom assignment, so we need to set the text for it
            customtarget = self.owner;
            self.value = GTHL["Custom..."];
            GTHcustomassignment:Show();
            GTHframes.customedit:HighlightText();
            
        elseif ( self.value == 100 ) then
            -- delete assignment
            -- check if only assignment row
            local assigncount = 0;
            for k,v in pairs( GTHassignment[ thephase ] ) do
                assigncount = assigncount + 1;
            end
            if assigncount > 1 then
                -- can delete
                GTHassignment[ thephase ][ theassign ] = nil;
                GTH_RefreshDropMenus( thephase );
            else
                -- only assignment, so don't delete
                
            end
            
            return
        elseif ( self.value == 101 ) then
            -- new assignment
            -- need to (1) make a new assignment entry in phase, (2) refresh menu display
            -- find empty number in "new assignment" sequence
            local newnum = 1;
            local fLoop = true;
            while fLoop do
                local foundx = false;
                for k,v in pairs( GTHassignment[ thephase ] ) do
                    if ( string.find( k , GTHL["new assignment"] ) == 1 and string.len( k ) == (string.len( GTHL["new assignment"] ) + 2) ) then
                        -- check the number on it
                        if tonumber(strsub( k , -1 , -1 )) == newnum then
                            foundx = true;
                            break
                        end
                    end
                end
                if foundx then
                    newnum = newnum + 1;
                else
                    fLoop = false;
                end
            end
            -- make new assignment entry
            GTHassignment[thephase][GTHL["new assignment"].." "..newnum] = {}; -- new empty assignment
            -- now refresh menus
            GTH_RefreshDropMenus( thephase );
            return
        end
        
        -- set new value
        
        local oldassign = theassign;
        local newassign = self.value;
        
        UIDropDownMenu_SetSelectedName( self.owner, newassign);
        UIDropDownMenu_SetText( self.owner , GTH_FormatAssignmentString(newassign) );
        
        --gthprint( oldassign );
        --gthprint( newassign );
        
        if oldassign ~= newassign then
            -- new assignment name
            -- so change keys in GTHassignment to match new name
            
            -- copy the assignment table, so we can slot it in under new name later
            local assigncopy = GTHassignment[thephase][oldassign];
            -- remove the old keyed table
            GTHassignment[thephase][oldassign] = nil;
            -- reinsert under new key
            GTHassignment[thephase][newassign] = assigncopy;
            -- now change .assignment values in healer name menu for this row
            getglobal("GTHdropH"..self.owner.myindex).assignment = newassign;
            -- finally change own assignment reference
            self.owner.assignment = newassign;
            
            GTH_RefreshDropMenus( GTHdisplayphase )
        end
    end -- assignment menu
    
    -- handler for healername menu
    if ( self.owner.droptype == "healerlist" ) then
        local buttonstring = "";
        local thephase = self.owner.phase;
        local theassign = self.owner.assignment;
        
        -- review list and make sure any recommendation strings are cleared
        -- recommendation strings start with ':' and come from the presets
        for h,v in pairs( GTHassignment[thephase][theassign] ) do
            if strsub( h , 1 , 1 ) == ":" then
                GTHassignment[thephase][theassign][h] = nil
                --table.remove( GTHassignment[thephase][theassign] , i );
            end
        end
        
        -- healer assigner
        if self.value == 98 then
            -- all others, so clear the assigned list and replace with remaining
            GTHassignment[thephase][theassign] = { [GTHL["All remaining"]]={ ["class"]="ALLREMAINING" } };
            buttonstring = GTHL["All remaining"];
            UIDropDownMenu_SetSelectedValue(self.owner, self.value);
        elseif self.value == 99 then
            -- clear the list
            GTHassignment[thephase][theassign] = {};
            buttonstring = "";
            UIDropDownMenu_SetSelectedValue(self.owner, nil);
        elseif self.value == 100 then -- PA: What is this?
            -- force rescan of talents
            GTH_FindHealers();

        else
            -- assign a named healer
            if not GTH_HealerAssigned( self.value , thephase , theassign ) then
                GTH_AssignHealer( self.value , thephase , theassign );
                GTH_UnAssignHealer( GTHL["All remaining"] , thephase , theassign );
            else
                GTH_UnAssignHealer( self.value , thephase , theassign );
                GTH_UnAssignHealer( GTHL["All remaining"] , thephase , theassign );
            end
            
            -- clear "All remaining", if checked
            self.owner.selectedValue = nil;
            -- hide the "All remaining" checkmark, to make sure
            local button, checkImage;
            for i = 1,UIDROPDOWNMENU_MAXBUTTONS do
                button = getglobal("DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i);
                --gthprint(i.." / "..button:GetText());
                if button:GetText() == GTHL["All remaining"] then
                    checkImage = getglobal("DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check");
                    button:UnlockHighlight();
                    checkImage:Hide();
                end
            end
            
            buttonstring = GTH_FormatHealersMenuText( thephase , theassign )
            
        end
        
        if self.value ~= 99 then
            --UIDropDownMenu_SetSelectedValue(this.owner, this.value);
            --this.value = nil;
        else
            --this.value = nil;
        end
        UIDropDownMenu_SetText( self.owner , buttonstring );
    end
    
    -- handler for phase menu
    if ( self.owner == GTHdropNew ) then
        if ( self.value == 100 ) then
            -- rename phase
            GTHnameflag = "renamephase";
            GTHframes.renamephaseedit:SetText( GTHdisplayphase );
            -- store the phase
            GTHrenamephase:Show();
            GTHframes.renamephaseedit:HighlightText();
        elseif self.value == "MOVEUP" then
        	-- move displayed phase up
        	local dpos = GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "order" ]
        	if dpos > 1 then
        		local abovephase = GTH_GetPhaseByPosition( dpos - 1 ) -- phase just above
        		GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "order" ] = dpos - 1
        		GTHassignment[ abovephase ][ "xtagsx" ][ "order" ] = dpos
        	end
        elseif self.value == "MOVEDOWN" then
        	-- move displayed phase down
        	local numphases = GTH_CountPhases( GTHassignment )
        	local dpos = GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "order" ]
        	if dpos < numphases then
        		local belowphase = GTH_GetPhaseByPosition( dpos + 1 ) -- phase just above
        		GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "order" ] = dpos + 1
        		GTHassignment[ belowphase ][ "xtagsx" ][ "order" ] = dpos
        	end
        elseif ( self.value == 101 ) then
            -- new phase empty phase
            local n = GTH_CountPhases( GTHassignment )
            n = n + 1
            nl = n
            while GTHassignment[GTHL["new phase"].." "..nl] do
            	nl = nl + 1
            end
			GTHassignment[GTHL["new phase"].." "..nl] = { ["xtagsx"]={ ["order"]=n } , [ GTHL["new assignment"].." 1" ] = {} };
			UIDropDownMenu_SetText( self.owner , GTHL["new phase"].." "..nl );
			self.owner.phase = GTHL["new phase"].." "..nl;
			GTH_RefreshDropMenus( GTHL["new phase"].." "..nl );
        elseif ( self.value == 102 ) then
            -- delete phase
            local n = GTH_CountPhases( GTHassignment )
            local oldpos = GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "order" ]
            GTHassignment[ GTHdisplayphase ] = nil;
            UIDropDownMenu_SetSelectedValue( self.owner, 1 );
            -- renumber the phases
            for k,v in pairs( GTHassignment ) do
            	local pos = v["xtagsx"]["order"]
            	if pos > oldpos then
            		-- phases that were higher in number than the deleted one need to be moved down one
            		v["xtagsx"]["order"] = pos - 1
            	end
            end
            -- select a new display phase
            for k,v in pairs( GTHassignment ) do
                self.owner.phase = k;
                break
            end
            GTH_RefreshDropMenus( self.owner.phase  );
            UIDropDownMenu_SetText( self.owner , self.owner.phase );
        else
            -- phase selected, so refresh frames
            UIDropDownMenu_SetSelectedValue(self.owner, self.value);
            self.owner.phase = self:GetText();
            GTH_RefreshDropMenus( self:GetText() );
        end
    end -- end phase menu
    
    
end

function GTH_CountPhases( set )
	local n = 0
	for k,v in pairs( set ) do
		n = n + 1
	end
	return n
end

function GTH_sortAssignmentsByOrder( phasetable )
    local slist = {}
    local aorder = phasetable["xtagsx"]["aorder"]
    for i = 1,GTH_CountAssignmentsinPhase( phasetable ) do
        for aname,order in pairs( aorder ) do
            if order == i then
                table.insert( slist , aname )
            end
        end
    end
    return slist
end

function GTH_CountAssignmentsinPhase( phasetable )
    local n = 0
    for a,v in pairs( phasetable ) do
        if a ~= "xtagsx" then
            n = n + 1
        end
    end
    return n
end

function GTH_GetPhaseByPosition( p )
	for k,v in pairs( GTHassignment ) do
		if v["xtagsx"] then
			if v["xtagsx"]["order"] then
				if v["xtagsx"]["order"] == p then return k end
			end
		end
	end
	return nil
end

function GTH_CountHealersInAssignment( aPhase , anAssignment )
    local n = 0;
    for h,v in pairs( GTHassignment[aPhase][anAssignment] ) do
        if h ~= GTHL["All remaining"] then n = n + 1 end
    end
    return n
end

function GTH_HealerAssignedAnywhere( healername )
    -- check if healer is assigned to anything explicitly
    -- also catches 'All remaining'
    local assigned = false
    local firstassignment = nil
    
    for kp,vp in pairs( GTHassignment ) do
        for ka,va in pairs( vp ) do
            if va[ healername ] then
                assigned = true
                firstassignment = ka
                return assigned, firstassignment
            elseif va[ GTHL["All remaining"] ] then
                assigned = true
                firstassignment = ka
                -- don't return right now; keep scanning for an explicit assignment
            end
        end
    end
    
    return assigned, firstassignment
end

-- check if healername is already in assignment in phase
function GTH_HealerAssigned(healername,phase,assignment)

    -- loop over assignments in 'phase' and 'assignment'
    
    if assignment == nil then return end;

    for h,v in pairs( GTHassignment[phase][assignment] ) do
        if h == healername then
            -- healer is checked
            return true
        end
    end
    
    return nil
end

-- insert healername into 'assignment' in 'phase'
function GTH_AssignHealer(healername,phase,assignment)
    if not GTH_HealerAssigned(healername,phase,assignment) then
        GTHassignment[phase][assignment][healername] = GTHhealerList[healername]
    end
end

-- remove healername from 'assignment' in 'phase'
function GTH_UnAssignHealer(healername,phase,assignment)

    GTHassignment[phase][assignment][healername] = nil;

end

function GTH_FindHealers()

    local newhlist = {}
    local newtlist = {}

    for i=1, MAX_RAID_MEMBERS do
        if not UnitExists("raid"..i) then
            -- kein mitglied, also auch kein heiler
        else
            -- prüfen ob er ein heiler ist
            local class,engClass = UnitClass("raid"..i)
            local unitname = UnitName("raid"..i)
            if engClass == "DRUID" or engClass == "PRIEST" or
                    engClass == "PALADIN" or engClass == "SHAMAN" then
                -- is a healer, add to healers list
                newhlist[unitname] = { ["class"]=engClass , ["talents"]=nil }
            end
            -- check for tank class
            if engClass == "WARRIOR" or engClass == "DRUID" or engClass == "PALADIN" or engClass == 
            "DEATHKNIGHT" then
                newtlist[unitname] = { ["class"]=engClass , ["talents"]=nil }
            end
        end
    end -- loop over raid members
    
    if newhlist ~= {} then
        GTHhealerList = newhlist;
        GTH_RefreshPopulatePool()
        GTHFlagRealRoster = true
    end
    
    if newtlist ~= {} then
        GTHtankList = newtlist
        GTH_RefreshPopulatePool()
        GTHFlagRealRoster = true
    end
    
end

function GTH_BuildUnitIDs() -- {{{
    unitids = {}
    for i=1, MAX_RAID_MEMBERS do
        if UnitExists("raid"..i) then
            unitids[UnitName("raid"..i)] = "raid"..i
        end
    end
end -- }}}

function GTH_GetUnitByName( aname ) -- {{{
    if not aname then
        return nil
    end
    
    if UnitName("player") == aname then return "player" end
    
    for i=1, MAX_RAID_MEMBERS do
        if UnitExists("raid"..i) then
            -- exists, so might be our "aname"
            if UnitName("raid"..i) == aname then
                return "raid"..i
            end
        end
    end
    return nil
end -- }}}

function GTH_GetMainTank(i)
    local s = "";
    
    -- check for oRA; use it's tanks, if present
    if oRA and oRA.maintanktable then
        if oRA.maintanktable[i] and
            UnitExists(GTH_GetUnitByName(oRA.maintanktable[i])) and
            UnitName(GTH_GetUnitByName(oRA.maintanktable[i])) == oRA.maintanktable[i]
            then
            s = "("..oRA.maintanktable[i]..")"
        end
    else
        -- check for default UI maintanks
        local numRaidMembers = GetNumGroupMembers();
        local mtcount = 0;
        for j = 1 , numRaidMembers do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot = GetRaidRosterInfo(j);
            if role == "MAINTANK" then
                mtcount = mtcount + 1;
                if mtcount == i then
                    -- same number as number we want to fetch, so return this name
                    s = "("..name..")";
                end
            end
        end
    end
    
    return s;
end

function GTH_FormatAssignmentString( raw )
    local sout = raw
    local mtnum = nil
    local mtname = nil
    local tanknum
    local tankname
    -- does any preformatting for assignment output
    
    -- wildcarding
    local pstart,pend = string.find( sout , "%%MT" )
    
    while pstart do
    
    --if ( pstart ) then
        -- get the tank number
        tanknum = strsub( sout , pend + 1 , pend + 1 )
        tankname = GTH_GetMainTank( tonumber( tanknum ) )
        -- insert into the raw string
        if tankname ~= "" then
            sout = string.gsub( sout , "%%MT"..tanknum , tankname )
            mtnum = tanknum
            mtname = tankname
            
            pstart,pend = string.find( sout , "%%MT" )
        else
            pstart = nil
        end
        
    end
    
    return sout , mtnum , mtname
end

function GTH_FormatBroadcastString( raw , phasename , assignmentname , healerlist )
    -- search and replace broadcast wildcards
    -- %P : phase name
    -- %A : assignment name
    -- %H : healer list
    local sout = raw
    -- phase name
    if phasename then
        local pstart,pend = string.find( sout , "%%P" )
        while pstart do
            sout = string.gsub( sout , "%%P" , phasename )
            pstart,pend = string.find( sout , "%%P" )
        end
    end
    -- assignment name
    if assignmentname then
        local pstart,pend = string.find( sout , "%%A" )
        while pstart do
            sout = string.gsub( sout , "%%A" , assignmentname )
            pstart,pend = string.find( sout , "%%A" )
        end
    end
    -- healer list
    if healerlist then
        local pstart,pend = string.find( sout , "%%H" )
        while pstart do
            sout = string.gsub( sout , "%%H" , healerlist )
            pstart,pend = string.find( sout , "%%H" )
        end
    end
    
    return sout
end

function GTH_MakeMessages( justthisphase , ahealer , classcolor )
    local m = {};
    local s = "";
    local counter = 0;
    local prespace = "    "
    if not GTHData.verbose then prespace = " " end
    
    -- header
    if GTHData.verbose and not ahealer then
    	table.insert( m , GTHBroadcastHeader );
    end
    
    -- make sorted list of phases
    local sphases = GTH_sort_phases( GTHassignment );
    
    -- count phases
    local numphases = #( sphases );
    
    -- loop over phases
    local foundanyassignment = false
    if not ahealer then foundanyassignment = true end
    for i = 1 , numphases do
    --for kphase,vphase in pairs( GTHassignment ) do
    
        local kphase = sphases[i];
        local vphase = GTHassignment[kphase];
    
        -- if more than one phase, add phase name to message table
        if numphases > 1 then
            if ( not justthisphase or GTHdisplayphase == kphase ) then
                table.insert( m , GTH_FormatBroadcastString( GTHBroadcastPhaseHeader , kphase ) );
            end
        end
        
        -- make sorted list of assignments in this phase
        local sassignments = GTH_sortAssignmentsByOrder( vphase );
        local numassigns = #( sassignments );
        
        -- loop over assignments in phase
        for j = 1 , numassigns do
        --for kassignment,vassignment in pairs( vphase ) do
        
            local kassignment = sassignments[j];
            local vassignment = vphase[ kassignment ];
            
            -- loop over healers in assignment and build list of names
            s = "";
            counter = 0;
            if kassignment ~= "xtagsx" then
            
                local foundnamedhealer = false
                if not ahealer then foundnamedhealer = true end
            
				for h,v in pairs( vassignment ) do
					counter = counter + 1
				    if h == ahealer then foundnamedhealer = true end
				    if h == GTHL["All remaining"] then foundnamedhealer = true end
				    -- class coloring for tooltip
				    local hcol = ""
				    if classcolor and foundnamedhealer and v.class then
				        hcol = GTH_HexClassColor( v.class )
				    end
					if counter > 1 then
						s = s..", "..hcol..h;
					else
						s = s..hcol..h; -- first name, so no comma
					end
				end -- healers
				
				if foundnamedhealer then foundanyassignment = true end
				
				-- add assignment name to front of healer list
				if not ahealer then
				    s = GTH_FormatBroadcastString( GTHBroadcastLine , kphase , GTH_FormatAssignmentString(kassignment) , s )
				else
				    -- building personal messages, so just need assignment name
				    s = GTH_FormatBroadcastString( "%A" , kphase , GTH_FormatAssignmentString(kassignment) , nil )
				end
				
				-- add assignment line to table of messages
				if ( not justthisphase or GTHdisplayphase == kphase ) then
				    if foundnamedhealer then
					   table.insert( m , s )
				    end
				end
            
            end -- not xtagsx
            
        end -- assignments
    
    end -- phases
    
    if not foundanyassignment and ahealer then
        table.insert( m , GTHL["No healing assignments for "]..ahealer )
    end
    
    return m
    
end

function GTH_Broadcast_SingleLine( raw )
    local messages = { table.concat( raw , "{"..GTHL["Diamond"].."}" ) }
    if string.len( messages[1] ) > 254 then
       messages = GTH_ChunkSplit( messages[1] , 250 , "" , "" )
    end
    return messages
end

function GTH_Broadcast( justthisphase )

	GTHsessionflags.announcements = true
	
    -- PA: Uncomment
    -- send out addon message for other clients
	--SendAddonMessage( "GTH", "BROADCAST", "RAID" )
	
	-- make messages
	local messages = GTH_MakeMessages( justthisphase )
    
    -- add whisper instructions to end
    if GTHData.verbose then
    	table.insert( messages , GTHBroadcastFooter )
    else
    	-- condense the messages into one line
    	messages = GTH_Broadcast_SingleLine( messages )
   	end

    -- get the channel and call the right function
    if GTHData.announcechannel == "RAID" then
        GTH_BroadcastRaid( justthisphase , messages );
        return;
    elseif GTHData.announcechannel == "WHISPER" then
        -- whisper code
        -- go through list of healers and whisper assignment to each
        for h,v in pairs(GTHhealerList) do
            if h ~= UnitName("player") then
                -- check talents
                if GTH_HealerAssignedAnywhere( h ) then
                    -- send whisper reply, as if we just got a whisper "heal!"
                    GTH_CHAT_MSG_WHISPER( "heal!" , h , justthisphase , true );
                end
            end
        end -- loop over healers
        
    else
        -- custom channel
        GTH_BroadcastChan( justthisphase , messages );
    end
    
end

function GTH_BroadcastChan( justthisphase , messages ) --{{{

    --if GetNumRaidMembers() == 0 then
    --    return;
    --end
    local id, name = GetChannelName( GTHData.announcechannel );
    if id == 0 then
        -- not in the channel anymore
        return;
    end
        
    for _, message in pairs(messages) do
        ChatThrottleLib:SendChatMessage("NORMAL", "GTH", message, "CHANNEL", nil, id)
    end

end -- }}}

function GTH_BroadcastRaid( justthisphase , messages ) -- {{{

    if GetNumGroupMembers() == 0 then
        -- not in a raid
        return;
    end
        
    for _, message in pairs(messages) do
        ChatThrottleLib:SendChatMessage("NORMAL", "GTH", message, "RAID")
    end
    
end -- }}}

function GTH_CHAT_MSG_WHISPER( msg , user , justthisphase , spam ) -- {{{
    --if GetNumRaidMembers() == 0 then
     --   return
    --end

    if msg == "heal!" then
        -- just user's assignments
        local reply = GTH_MakeMessages( justthisphase , user )
        
        -- shadowpriest catch
        -- local isinlist, class, talents = GTH_InHealerList( user )
        -- if class == "PRIEST" and talents then
        --     if talents[3] > 30 then
        --         -- has shadowform, so...
        --         table.insert( reply , "Just melt faces." );
        --     end
        -- end
        
        -- add whisper instructions to end
        if GTHData.verbose and not spam then
        	table.insert( reply , GTHBroadcastFooter );
        else
        	-- condense if brief messages set or we have the 'spam' flag for a whisper broadcast
        	reply = GTH_Broadcast_SingleLine( reply )
        end
        
        for _, reply in pairs(reply) do
            ChatThrottleLib:SendChatMessage("NORMAL", "GTH", reply, "WHISPER" , nil , user)
        end
    elseif msg == "heal! all" then
        -- everyone's assignments
        local reply = GTH_MakeMessages( justthisphase );

        if not GTHData.verbose then
            -- condense the messages into one line
            reply = GTH_Broadcast_SingleLine( reply )
        end
        
        for _, reply in pairs(reply) do
            ChatThrottleLib:SendChatMessage("NORMAL", "GTH", reply, "WHISPER" , nil , user)
        end
    elseif msg == "transmit" then
    	-- send the current preset, so it can be shared to another GTH user
    	
    end
    
end -- }}}

function GTH_TableToString(t)
	local out = ""
	
	if type(t) == "table" then
		local itemcount = 0
		for k,v in pairs( t ) do
			itemcount = itemcount + 1
			if itemcount > 1 then out = out..", " end
			local temp = GTH_TableToString( v )
			if string.sub( temp , 1 , 1 ) == "[" then
                if tonumber(k) then
                    out = out..'['..k..'] = { '..temp.." } "
                else
				    out = out..'["'..k..'"] = { '..temp.." } "
				end
			else
                if tonumber(k) then
                    out = out..'['..k..'] = '..temp
                else
				    out = out..'["'..k..'"] = '..temp
				end
			end
		end
	else
		if type(t) == "string" then
			out = out..'"'..tostring(t)..'"'
		else
			out = out..tostring(t)
		end
	end -- is table
	
	return out
end

-- this function splits up a long preset string so it can be sent via addon messaging
function GTH_ChunkSplit(string, length, endChars , startChars )
    if not string then
        return {}
    end
    -- Sanity check: make sure length is an integer.
    if not length then
        length = 200
    end
    length = floor(tonumber(length))
    if not endChars then
        endChars = "MWISHO"
    end
    if not startChars then
        startChars = "MWANZO"
    end
    local Table = { startChars }
    for i=1, strlen(string), length do
        table.insert(Table, strsub(string, i, i + length - 1 ) )
    end
    table.insert( Table , endChars ) -- message that signals end of chunks
    return Table
end

function GTH_MakePresetShareString( preset )
	-- makes a preset table into a string that can be sent via addon chat message
	-- receiver can pick up the preset with assert(loadstring( string ))()
	local sharestring = "GTHassignment={"..GTH_TableToString( preset ).."}"
	return sharestring
end

function GTH_SharePreset( preset )

    -- PA: Cut this off from other clients, 
    --return

	-- send preset to other clients in RAID
	-- the other clients pick preset up as their current preset
	
	local m = GTH_ChunkSplit( GTH_MakePresetShareString(preset) )
	
	--ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype, target, queueName)
	for _, chunk in pairs(m) do
	   --gthprint( chunk )
       -- PA: This line was uncommented 
       --ChatThrottleLib:SendAddonMessage("NORMAL", "GTHchunk", chunk, "RAID" )
        
        --ChatThrottleLib:SendAddonMessage("NORMAL", "GTHchunk", chunk, "WHISPER" , "Pembroke" )
		--ChatThrottleLib:SendChatMessage("NORMAL", "GTHchunk", chunk, "CHANNEL", 2)
	end
	
	gthprint("GTH> Assignment structure sent to other GTH users in raid.")
	
end

function GTH_InHealerList( aname )
    -- checks if the named unit is in the healer list
    -- if so, returns class and talents (if scanned)
    local inlist = false;
    local aclass = nil;
    
    if GTHhealerList[aname] then
        inlist = true;
        aclass = GTHhealerList[aname]["class"];
    end
    
    return inlist, aclass;
end

function GTH_GetClass( name )
    if GTHhealerList[name] then
        return GTHhealerList[name]["class"]
    elseif GTHtankList[name] then
        return GTHtankList[name]["class"]
    end
    return nil
end

function GTH_assignment_copy( orig )
    -- copy a preset table
    local newtable = {};
    
    for kphase,vphase in pairs( orig ) do
        newtable[kphase] = {};
        for kassignment,vassignment in pairs( vphase ) do
            newtable[kphase][kassignment] = {};
            for h,v in pairs( vassignment ) do
                if type(v) == "table" then
                    newtable[kphase][kassignment][h] = {}
                    for k,v2 in pairs( v ) do
                        newtable[kphase][kassignment][h][k] = v2
                    end
                else
                    newtable[kphase][kassignment][h] = v
                end
            end
        end
    end
    
    return newtable;
end

function GTH_assignedhealers_copy( orig )
    local newtable = {}
    
    for kassignment,vassignment in pairs( orig ) do
        newtable[kassignment] = {}
        for h,v in pairs( vassignment ) do
            newtable[kassignment][h] = v
        end
    end
    
    return newtable;
end

function GTH_phase_copy( orig )
    local newtable = {};
    
	for kassignment,vassignment in pairs( orig ) do
		newtable[kassignment] = {};
		for h,v in pairs( vassignment ) do
			newtable[kassignment][h] = v
		end
	end
    
    return newtable;
end

function GTH_FilterPreset( aPreset )

    -- PA: review later
    --return 

    -- filters a preset, with saved healer names, through the currently available healer list
    -- 1) match all available healers to any saved assignments with their name
    -- 2) for remaining assignments, match class/spec with saved healer
    -- 3) for any remaining, assign at random
    
    -- copy the preset
    local newp = GTH_assignment_copy( aPreset )
    -- clean out the assignments, so we can populate them as we go
    local phasecount = 0
    for phaseN,phase in pairs( newp ) do
    	phasecount = phasecount + 1
    	local foundTags = false
        for assignmentN,assignment in pairs( phase ) do
        	if assignmentN ~= "xtagsx" then -- keep existing tags
            	phase[assignmentN] = { }
            else
            	foundTags = true
            end
        end -- assignments
        if not foundTags then
        	-- didn't see an xtagsx assignment, so must be a pre-1.3.0 preset
        	-- add default tags
        	phase["xtagsx"] = { ["order"] = phasecount }
        end
        if not phase["xtagsx"]["aorder"] then
        	phase["xtagsx"]["aorder"] = {}
        	local n = 1
        	for assignmentN,assignment in pairs( phase ) do
                if assignmentN ~= "xtagsx" then
                    phase["xtagsx"]["aorder"][assignmentN] = n
                    n = n + 1
                end
            end
        end
    end -- phases
    
    -- copy the currently available healers, so we can track them as we use them
    local availablehealers = {}
    for h,v in pairs( GTHhealerList ) do
        availablehealers[h] = v
    end
    
    -- 1
    -- scan over healers in the preset, and remove matching ones from available list
    local replacelist = {};
    local presentlist = {};
    for phaseN,phase in pairs( aPreset ) do
        for assignmentN,assignment in pairs( phase ) do
        	if  assignmentN ~= "xtagsx" then
				for h,v in pairs( assignment ) do
					if availablehealers[h] then
						-- add to present list, so we don't use them to do replacements later
						presentlist[h] = v
					else
						-- saved healer not present right now, so mark for replacement
						replacelist[h] = v
					end
				end -- healers
            end -- not xorderx
        end -- assignments
    end -- phases
    -- remove present healers from available
    -- we'll use remaining names for replacements
    for h,v in pairs( presentlist ) do
        availablehealers[h] = nil
    end
    
    -- 2
    -- assign replacements
    -- loop over names to replace, and assign individual replacements from available
    
    -- first pass for matching class only
    for h,v in pairs( replacelist ) do
        if h ~= GTHL["All remaining"] then
        	if not v["replacement"] then
				-- find an available healer with the same class
				for h2,v2 in pairs( availablehealers ) do
					-- if class is in the preset class list
					if string.find( v["class"] , v2["class"] ) then
					--if v2["class"] == v["class"] then
						replacelist[h]["replacement"] = h2
						availablehealers[h2] = nil -- remove so we don't use again
						gthprint("GTH> Substitution: "..h.."("..v["class"]..") --> "..h2)
						break
					end
				end
			end -- not replacement already
        end -- not all remaining
    end
    
    -- second pass for any replacement
    for h,v in pairs( replacelist ) do
        if h ~= GTHL["All remaining"] then
            if not v["replacement"] then
                -- didn't find a replacement with the same class,
                -- so match to any now
                for h2,v2 in pairs( availablehealers ) do
                    replacelist[h]["replacement"] = h2
                    availablehealers[h2] = nil
                    gthprint("GTH> Substitution: "..h.."("..v["class"]..") --> "..h2)
                    break
                end
            end
        end -- not all remaining
    end
    
    -- loop over assignments and make replacements
    for phaseN,phase in pairs( aPreset ) do
        for assignmentN,assignment in pairs( phase ) do
        	if assignmentN ~= "xtagsx" then
				for h,v in pairs( assignment ) do
					if ( h ~= GTHL["All remaining"] and replacelist[h] ) then
						if replacelist[h]["replacement"] then
							local areplacement = replacelist[h]["replacement"]
							newp[phaseN][assignmentN][ areplacement ] = GTHhealerList[ areplacement ]
						else
							-- no replacement named
							gthprint("GTH> No replacement for "..h)
						end
					elseif h == GTHL["All remaining"] then
						-- make sure "All remaining" gets copied to filtered preset
						newp[phaseN][assignmentN][ GTHL["All remaining"] ] = { ["class"]="ALLREMAINING" }
					elseif presentlist[h] then
						-- this named healer is present, so copy assignment
						newp[phaseN][assignmentN][h] = v
					end
				end -- healers
			else
				-- is the tags 'assignment', so copy it
				
            end -- not xtagsx
        end -- assignments
    end -- phases
    
    return newp
end

local GTHtankclasses = { ["WARRIOR"]=true , ["DRUID"]=true , ["PALADIN"]=true , ["DEATHKNIGHT"]=true }
local GTHhealclasses = { ["PRIEST"]=true , ["DRUID"]=true , ["PALADIN"]=true , ["SHAMAN"]=true }

local GTHdisconnecttimer = 0;
local GTHdeathTimer = 0;
local GTHpulsetimer = 0
local GTHpulsedir = 1
local GTHphaseSwapSave = nil
GTHtooltimer = 0
GTHtooltarget = nil
function GTH_OnUpdate(self,elapsed)

    if GTHtooltarget then
        GTHtooltimer = GTHtooltimer + elapsed
        if GTHtooltimer > 1 then
            GameTooltip:SetOwner( GTHtooltarget , "ANCHOR_RIGHT" )
            GameTooltip:SetText( GTHtooltarget.tooltip )
        end
    end
    
    GTHdisconnecttimer = GTHdisconnecttimer + elapsed;
    if GTHdisconnecttimer > 2 then -- 2 second delay between attempts
        GTHdisconnecttimer = 0
        -- scan for disconnects and reconnects
        GTH_ScanDisconnects()
    end
    
    -- priest spirit of redemption timer, to delay death check
    if #(GTHdeathQueue) > 0 then
    	GTHdeathTimer = GTHdeathTimer + elapsed
    	if GTHdeathTimer > 1 then
    		GTHdeathTimer = 0
    		GTH_DeathAnnounce( GTHdeathQueue[1] )
    		table.remove( GTHdeathQueue , 1 )
    	end
    else
    	GTHdeathTimer = 0
    end
    
    if GTHframes.frame:IsVisible() then
        if GTHcurrentdrag then
            -- highlight drag source
            
            if GTHcurrentdrag.dragtype == "phase" then
                
                -- check possible phase landings (the other visible phases)
                local overAnotherPhase = false
                for i = 1,8 do
                    local pool = GTHframes.phasedrag[i]
                    if pool:IsVisible() then
                        if MouseIsOver(pool) and pool ~= GTHcurrentdrag then
                            -- show source as destination, to simulate swap
                            GTHcurrentdrag.labelframe:SetText( GTH_rgbToHexColor( 1,1,1 )..pool.phase )
                            GTHcurrentdrag:SetAlpha(1)
                            -- show destination as source
                            --pool.labelframe:SetText( GTH_rgbToHexColor( 1,1,1 )..GTHcurrentdrag.phase )
                            pool:SetAlpha(0)
                            overAnotherPhase = true
                        else
                            -- set text to real phase
                            --pool.labelframe:SetText( GTH_rgbToHexColor( 1,1,1 )..pool.phase )
                            pool:SetAlpha(1)
                        end
                    end
                end
                if not overAnotherPhase then
                    -- make sure source text is set to original state and dim out again
                    GTHcurrentdrag.labelframe:SetText( GTH_rgbToHexColor( 1,1,1 )..GTHcurrentdrag.phase )
                    GTHcurrentdrag:SetAlpha(0)
                    -- if not over self, then set pending delete icon (X)
                    if not MouseIsOver( GTHcurrentdrag ) then
                        GTHframes.dragGhost.icon:SetTexture( "Interface\\TARGETINGFRAME\\"..GTHluckycharms[7] )
                    else
                        GTHframes.dragGhost.icon:SetTexture( nil )
                    end
                else
                    -- make sure delete icon is cleared
                    GTHframes.dragGhost.icon:SetTexture( nil )
                end
            
            elseif GTHcurrentdrag.dragtype == "assignmentpopulate" then
                -- highlight assignment name pools
                for i = 1,GTH_CountAssignmentsinPhase( GTHassignment[GTHdisplayphase] )+1 do
                    local pool = GTHframes.assignmentpool[ i ]
                    if pool:IsVisible() then
                        if MouseIsOver(pool) then
                            local c = gthcolor.draghighlight
                            pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                        else
                            local c = gthcolor.assignpoolborder
                            pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                        end
                    end -- is visible
                end
            elseif GTHcurrentdrag.dragtype == "assignmentrelocate" then
                -- highlight assignment name pools
                for i = 1,GTH_CountAssignmentsinPhase( GTHassignment[GTHdisplayphase] ) do
                    local pool = GTHframes.assignmentpool[ i ]
                    if pool:IsVisible() then
                        if MouseIsOver(pool) then
                            local c = gthcolor.draghighlight
                            pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                        else
                            local c = gthcolor.assignpoolborder
                            pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                        end
                    end -- is visible
                end
            else
                -- not PHASE drag
                intensity = 1
                if GTHcurrentdrag ~= GTHframes.dragGhost then
                    GTHcurrentdrag:SetBackdropBorderColor(intensity,intensity,0,1)
                end
                
                -- highlight any possible target hover
                for i = 1,8 do
                    local pool = GTHframes.assignedpool[i]
                    if MouseIsOver(pool) and pool:IsVisible() then
                        local c = gthcolor.draghighlight
                        pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                    else
                        local c = gthcolor.assignpoolborder
                        pool:SetBackdropBorderColor( c.r , c.g , c.b , c.a )
                    end
                end
                
            end
        end -- currentdrag
    end -- isvisible 
end

function gthfindsor()
	for i = 1,50000 do
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange 
= GetSpellInfo(i)
		if name then
			--gthprint(i.." "..name)
			if name == "Spirit of Redemption" then gthprint(i..name) end
		else
			--
		end
	end
end

function GTH_HasSpiritRedemption( aname )
	local unitid = GTH_GetUnitByName( aname )
	if not unitid then return false end
	local hasSoR = false
	local name, rank, iconTexture = UnitBuff( unitid, GTHsor_name )
	if name then
        hasSoR = true
    end
	return hasSoR
end

local GTHchunks = ""
function GTH_ChatMsgAddon( ... )
	-- is from GTH?
	local prefix,msg,disttype,sender = select(1, ...)
	--gthprint(msg)
	if prefix == "GTH" then
		if msg == "BROADCAST" then
			-- another client sent out a broadcast, so suppress our messages for rest of this session
            --gthprint( sender )
            if sender ~= UnitName( "player" ) then
			     GTHsessionflags.announcements = false
			 end
		end
	elseif prefix == "GTHchunk" then
		-- chunk of a shared preset
		if msg == "MWANZO" then
			-- first chunk
			GTHchunks = ""
		elseif msg == "MWISHO" then
			-- last chunk
			-- save current preset
			gthprint(GTHchunks)
			GTHassignmentPrev = GTH_assignment_copy( GTHassignment );
			-- execute joined chunks as a script, replacing current preset with shared one
			--GTHchunks = 'GTHassignment={["Phase 1"] = { ["xtagsx"] = { ["order"] = 1, ["aorder"] = { ["ProtWarrior"] = 1 }  } , ["ProtWarrior"] = { ["Druid1"] = { ["class"] = "DRUID", ["talents"] = { [1] = 11, [2] = 0, [3] = 50 }  }  }  } }'
			if not GTHframes.frame:IsShown() then
                assert(loadstring( GTHchunks ))();
                GTHData.assignment = GTH_assignment_copy( GTHassignment )
                gthprint("GTH> Assignment structure received from another GTH user.")
            else
                gthprint("GTH> Assignment structure sent from another GTH user, but GTH was open, so the assignment wasn't processed. Close GTH and ask the user to resend the assignments.")
            end
		else
			-- must be a true chunk of text
			GTHchunks = GTHchunks..msg
		end
	end
end

function GTH_CombatLogEvent( ... )

	if not GTHData.announceDeaths then return end
	if not GTHsessionflags.announcements then return end
    
	local timestamp, msg, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = select(1, ...)
	
	if msg == "UNIT_DIED" then
	   --gthprint( "UNIT_DIED" )
		-- unit death
		-- check if healer
		local isHealer, _ = GTH_InHealerList( destName )
		local isAssigned = GTH_HealerAssignedAnywhere( destName )
		if isHealer and isAssigned then
				
            -- if dead healer is a PRIEST, we need to delay the death announcement a moment, to check for Spirit of Redemption
            -- we use OnUpdate event for this
            if GTH_GetClass( destName ) == "PRIEST" then
                table.insert( GTHdeathQueue , destName ) -- add this priest to the announce queue
            else
                -- not a PRIEST, so just announce
                GTH_DeathAnnounce( destName )
            end
				
		end -- inhealerlist
	end -- UNIT_DIED
	
end

function GTH_DeathAnnounce( destName , disconnect )
	-- fetch assignments
	local m = GTH_MakeMessages( false , destName )
	local m1 = "{"..GTHL["Skull"].."}"..destName.." "..GTHL["dead"].."!"
	if disconnect then m1 = "{"..GTHL["Cross"].."}"..destName.." "..GTHL["offline"].."!" end
	
	if ( GTH_GetClass( destName ) == "PRIEST" and not disconnect ) then
		if GTH_HasSpiritRedemption( destName ) then
			m1 = m1.." ("..GTHsor_name.." "..GTHL["active"]..")"
			GTHSoRlist[ destName ] = true -- flag so we don't broadcast assignments on final death
		elseif GTHSoRlist then
			if GTHSoRlist[ destName ] then
				GTHSoRlist[ destName ] = nil
				m = {} -- no assignment strings on second death
				m1 = "{"..GTHL["Skull"].."}"..destName.." "..GTHL["is really dead now"].." ("..GTHsor_name.." "..GTHL["expired"]..")."
			end
		end
	end
	
	-- join header and messages
	if not GTHData.verbose then m1 = m1.." (" end
	local newm = { m1 }
	for i,s in ipairs( m ) do
		table.insert( newm , s )
	end
	if not GTHData.verbose then table.insert( newm , ")" ) end
	m = newm
	
	if not GTHData.verbose then
		m = { table.concat( m , " " ) }
	end
	
	-- now broadcast to usual channel
	if GTHData.announcechannel == "RAID" then
		for _, message in pairs(m) do
			ChatThrottleLib:SendChatMessage("NORMAL", "GTH", message, "RAID")
		end
	elseif GTHData.announcechannel == "WHISPER" then
		-- go through list of healers and whisper message to each
        for h,v in pairs( GTHhealerList ) do
            if h ~= UnitName("player") then
                for _, message in pairs(m) do
                    ChatThrottleLib:SendChatMessage("NORMAL", "GTH", message, "WHISPER" , nil , h )
                end
            end
        end -- loop over healers
	else
		local id, chname = GetChannelName( GTHData.announcechannel );
		if id == 0 then return end
		for _, message in pairs(m) do
			ChatThrottleLib:SendChatMessage("NORMAL", "GTH", message, "CHANNEL", nil, id)
		end
	end
	
end

function GTH_ScanDisconnects()
	local foundnewX = false
	local newX = ""
	for i = 1,MAX_RAID_MEMBERS do
		local name, rank, subgroup, level, class, fileName, 
  			zone, online, isDead, role, isML = GetRaidRosterInfo(i)
  		--if name then gthprint( tostring(name)..tostring( online )..tostring( zone ) ) end
  		if name and GTHhealerList[name] then
  			if not online then
  				-- got an offline member
  				if not GTHofflineList[ name ] then
  					foundnewX = true
  					newX = name
  				end
  				GTHofflineList[ name ] = true
  			else
  				GTHofflineList[ name ] = nil
  			end
  		end
  	end
  	if foundnewX and GTHData.announceOffline then
  		if not GTHsessionflags.announcements then return end
  		if not GTH_HealerAssignedAnywhere( newX ) then return end
  		GTH_DeathAnnounce( newX , true )
  	end
end
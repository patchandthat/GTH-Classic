local f = CreateFrame"Frame"
local dropdown = CreateFrame( "Frame", "GTHBrokerDD", nil, "UIDropDownMenuTemplate" )
local player, tipshown = UnitName"player"
local tipshown, config, days, chars, classes, f1, f2, f3
local t, sorted, defaultClass = {}, {}, { r=1, g=.8, b=0 }
local ByValue = function(a,b) return a.money > b.money end
local ByName = function(a,b) return a.name < b.name end
local othersMoney, session, today = 0

local block = LibStub("LibDataBroker-1.1"):NewDataObject("GettingThingsHealed", {
	type = "data source",
	icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02",
	OnLeave = function()
		--GameTooltipTextLeft1:SetFont( f1, f2, f3 )
		--GameTooltipTextRight1:SetFont( f1, f2, f3 )
		tipshown = nil
		return GameTooltip:Hide()
	end,
	OnClick = function(self, button)
		if button == "RightButton" then
			GameTooltip:Hide()
			UIDropDownMenu_Initialize( dropdown, GTHdropOptions_Initialise, "MENU" )
			return ToggleDropDownMenu( 1, nil, dropdown, self, 0, 0)
        elseif button == "LeftButton" then
            if IsShiftKeyDown() then
                -- broadcast
                GTH_Broadcast( false )
            else
                -- open config dialog
                GTH_Options("")
            end
            GameTooltip:Hide()
		end
	end
})


block.OnEnter = function(self)
	tipshown = self
	local showBelow = select(2, self:GetCenter()) > UIParent:GetHeight()/2
	GameTooltip:SetOwner( self, "ANCHOR_NONE" )
	GameTooltip:SetPoint( showBelow and "TOP" or "BOTTOM", self, showBelow and "BOTTOM" or "TOP" )

	GameTooltip:AddLine( "Getting Things Healed" )
	GameTooltip:AddLine( "|cFFFFFF66Left-click: Assignment window" )
	GameTooltip:AddLine( "|cFFFFFF66Right-click: Options menu" )
	GameTooltip:AddLine( "|cFFFFFF66Shift-Left-click: Broadcast (@"..GTHData.announcechannel..")" )
	
	-- add current assignments
	GameTooltip:AddLine(" ")
	local messages = GTH_MakeMessages( false , nil , true )
	for k,v in pairs(messages) do
	   if string.sub(v,1,1) == "{" then
	       -- phase line
	       local pstring = string.sub(v,7) -- all but the {Star}
	       GameTooltip:AddLine( "|cFFFFFFFF"..pstring )
	       GameTooltip:AddTexture( "Interface\\Calendar\\MoreArrow" )
	   else
	       -- assignment line
	       --local left,right = strsplit( ":" , v , 2 )
	       --GameTooltip:AddDoubleLine( left , right )
	       GameTooltip:AddLine( v )
	   end
	end

	--f1, f2, f3 = GameTooltipTextLeft1:GetFont()
	--GameTooltipTextLeft1:SetFont( GameTooltipTextLeft2:GetFont() )
	--GameTooltipTextRight1:SetFont( GameTooltipTextLeft2:GetFont() )
	return GameTooltip:Show()
end

local function OnEvent(self, event, addon)
	block.text = "GTH"
	--return IsLoggedIn() and OnEvent(nil, "")
end

f:SetScript( "OnEvent", OnEvent )

f:RegisterEvent"ADDON_LOADED"
f:RegisterEvent"PLAYER_LOGIN"


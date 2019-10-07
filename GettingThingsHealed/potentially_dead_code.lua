-- called when phase menu is opened
--[[function GTHdropNew_Initialise()

    level = 1;
    local info = UIDropDownMenu_CreateInfo();
    
    info.text = GTHL["Phases"];
    info.isTitle = true;
    info.value = -1;
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.isTitle = nil;
    info.disabled = nil;
    
    -- add existing phases to menu
    
    -- first make sorted list of phase names
    local sphases = GTH_sort_phases( GTHassignment );
    
    local phasecount = #( sphases ); -- number of phases
    
    for i = 1 , phasecount do
        local k = sphases[i];
        info.text = k;
        info.value = i;
        info.func = function() GTHdropmenu_OnClick() end; 
        info.owner = this:GetParent();
        info.icon = nil;
        info.checked = nil;
        UIDropDownMenu_AddButton(info, level);
    end
    
    info.text = GTHL["Commands"];
    info.isTitle = true;
    info.value = -1;
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.isTitle = nil;
    info.disabled = nil;
    
    info.text = GTHL["Move up"];
    info.value = "MOVEUP";
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    local numphases = GTH_CountPhases( GTHassignment )
    local dpos = GTHassignment[ GTHdisplayphase ][ "xtagsx" ][ "order" ]
    if dpos == 1 then
    	info.disabled = true
    end
    UIDropDownMenu_AddButton(info, level);
    
    info.disabled = nil;
    info.text = GTHL["Move down"];
    info.value = "MOVEDOWN";
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    if dpos == numphases then
    	info.disabled = true
    end
    UIDropDownMenu_AddButton(info, level);
    
    info.disabled = nil;
    info.text = GTHL["Rename phase"].."...";
    info.value = 100;
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    info.tooltipTitle = GTHL["Rename phase"].."...";
    info.tooltipText = GTHL["Change the name of this phase."];
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["New phase"];
    info.value = 101;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    info.tooltipTitle = GTHL["New phase"];
    info.tooltipText = GTHL["Add another block of assignment rows."];
    UIDropDownMenu_AddButton(info, level);
    
    -- decide whether to enable delete
    local phasecount = 0;
    local deleteDisable = true;
    for k,v in pairs( GTHassignment ) do
        phasecount = phasecount + 1;
    end
    if phasecount > 1 then deleteDisable = nil; end
    info.text = GTHL["Delete this phase"];
    info.value = 102;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    info.disabled = deleteDisable;
    info.tooltipTitle = GTHL["Delete this phase"];
    info.tooltipText = GTHL["Remove this block of assignment rows."];
    UIDropDownMenu_AddButton(info, level);
    
end]]


-- called when healer list menu is opened
--[[function GTHdropH1_Initialise()
    level = 1;
    local info = UIDropDownMenu_CreateInfo();
    
    -- populate healer list
    for ahealer,adetails in pairs( GTHhealerList ) do
        local atalents = adetails["talents"];
        local aclass = adetails["class"];
        
        info.text = ahealer;
        info.value = ahealer;
        info.isTitle = nil;
        info.disabled = nil;
        info.func = function() GTHdropmenu_OnClick() end; 
        info.owner = this:GetParent();
        
        info.icon = nil;
        if info.owner ~= nil then
            -- show checkmark, because already in this assignment?
            info.checked = GTH_HealerAssigned( ahealer, info.owner.phase, info.owner.assignment );
            
            -- icons for different healer specs
            if adetails["talents"] then
            	-- talents scanned
            	if adetails["class"] == "PRIEST" then
            		if adetails["talents"][1] > 22 then
            			info.icon = "Interface\\Icons\\Spell_Holy_DivineSpirit.blp";
            		elseif adetails["talents"][2] > 40 then
            			info.icon = "Interface\\Icons\\Spell_Holy_CircleOfRenewal.blp";
            		end
            	end
            end
            
            -- check all the other assignments now and show '!' icon if in any of them
            for anAssignment,aHealerList in pairs( GTHassignment[ info.owner.phase ] ) do
                for h,d in pairs( aHealerList ) do
                    if ( h == ahealer and anAssignment ~= info.owner.assignment ) then
                        -- assigned to a different assignment already
                        info.icon = "Interface\\GossipFrame\\AvailableQuestIcon.blp";
                        break
                    end
                end
            end
        else
            info.checked = nil;
        end
        
        -- keep menu open after selection
        info.keepShownOnClick = 1;
        
        -- check for talent info and add it to tooltip if we have it
        if atalents then
            info.tooltipTitle = ahealer;
            info.tooltipText = GTHL["Talents"]..": "..atalents[1].."/"..atalents[2].."/"..atalents[3];
        else
            info.tooltipTitle = nil;
            info.tooltipText = nil;
        end
        
        info.colorCode = GTH_HexClassColor( aclass );
        
        -- check talents
        if GTH_IsHealerFromTalents( ahealer ) then
            UIDropDownMenu_AddButton( info , level );
        end
    end
    
    info.text = GTHL["All remaining"];
    info.value = 98;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.icon = nil;
    info.checked = nil;
    info.colorCode = GTH_rgbToHexColor( 1 , 1 , 1 );
    info.tooltipTitle = nil;
    info.tooltipText = nil;
    info.keepShownOnClick = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["Commands"];
    info.isTitle = true;
    info.value = -1;
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.isTitle = nil;
    info.disabled = nil;
    
    info.text = GTHL["Clear selections"];
    info.value = 99;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.icon = nil;
    info.checked = nil;
    info.colorCode = GTH_rgbToHexColor( 1 , 1 , 1 );
    info.keepShownOnClick = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["Rescan talents"];
    info.value = 100;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.icon = nil;
    info.checked = nil;
    info.colorCode = GTH_rgbToHexColor( 1 , 1 , 1 );
    info.keepShownOnClick = nil;
    UIDropDownMenu_AddButton(info, level);
    
end]]


--[[ called when assignment menu is opened
function GTHdrop1_Initialise()
    level = 1;
    local info = UIDropDownMenu_CreateInfo();
    
    info.text = GTHL["Assignments"];
    info.isTitle = true;
    info.value = -1;
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTH_FormatAssignmentString("%MT1");
    info.isTitle = nil;
    info.disabled = nil;
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = "%MT1";
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTH_FormatAssignmentString("%MT2");
    info.disabled = nil;
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = "%MT2";
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTH_FormatAssignmentString("%MT3");
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = "%MT3";
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTH_FormatAssignmentString("%MT4");
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = "%MT4";
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTH_FormatAssignmentString("%MT5");
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = "%MT5";
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["All tanks"];
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = GTHL["All tanks"];
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["Raid healing"];
    if this:GetParent() ~= nil then
        info.disabled = GTH_AssignmentExists( info.text , this:GetParent().phase );
    end
    info.value = GTHL["Raid healing"];
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["Commands"];
    info.isTitle = true;
    info.value = -1;
    info.func = function() GTHdropmenu_OnClick() end; 
    info.owner = this:GetParent();
    info.checked = nil; 
    info.icon = nil;
    UIDropDownMenu_AddButton(info, level);
    
    info.text = GTHL["Custom..."];
    info.value = 99;
    info.isTitle = nil;
    info.disabled = nil;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    info.tooltipTitle = GTHL["Custom..."];
    info.tooltipText = GTHL["Enter a custom name for this healing assignment."];
    UIDropDownMenu_AddButton(info, level);
    
    -- decide whether to enable delete command
    local deleteDisabled = true;
    local assigncount = 0;
    if this:GetParent() ~= nil then
        for k,v in pairs( GTHassignment[ this:GetParent().phase ] ) do
        	if k ~= "xtagsx" then assigncount = assigncount + 1 end
        end
    end
    if assigncount > 1 then deleteDisabled = nil end
    
    info.text = GTHL["Delete"].."...";
    info.value = 100;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    info.disabled = deleteDisabled;
    info.tooltipTitle = GTHL["Delete"].."...";
    info.tooltipText = GTHL["Remove this healing assignment."];
    UIDropDownMenu_AddButton(info, level);
    
    -- decide whether to enable new assignment command
    deleteDisabled = true;
    if ( assigncount < maxassignments ) then deleteDisabled = nil; end
    if this:GetParent() ~= nil then
        local patstart,patend = string.find( this:GetParent().assignment , GTHL["new assignment"] );
        if patstart == 1 then
            -- is a "new assignment" named assignment
            --deleteDisabled = true;
        end
    end
    info.text = GTHL["New"].."...";
    info.value = 101;
    info.func = function() GTHdropmenu_OnClick() end;
    info.owner = this:GetParent();
    info.checked = nil;
    info.icon = nil;
    info.disabled = deleteDisabled;
    info.tooltipTitle = GTHL["New assignment"];
    info.tooltipText = GTHL["Add a fresh new healing assignment."];
    UIDropDownMenu_AddButton(info, level);
    
    --UIDropDownMenu_SetText( "(Choose assignment)" , GTHdrop1 )
end]]

function GTH_IsHealerFromTalents( name )
    -- checks for talents and returns false if no healing specced
    -- if talents don't exist yet, assumes is a healer (true)
    
    local check2nd = false
    
    if not GTHData.checkspecs then return true end
    
    local class = GTH_GetClass( name )
    local htalents, htalents2 = GTH_GetTalents( name )
    local showthishealer = false
    if htalents then
        --print(htalents[1])
        if not htalents[1] then htalents = {0,0,0} end
        if not htalents2 then htalents2 = {0,0,0} end
        if class == "PRIEST" then
            -- must have 31+ in holy or discipline
            if htalents[1] > 30 or (htalents2[1] > 30 and check2nd) then showthishealer = true; end
            if htalents[2] > 30 or (htalents2[2] > 30 and check2nd) then showthishealer = true; end
        elseif class == "DRUID" then
            -- must have 31 or more in Resto
            if htalents[3] > 30 or (htalents2[3] > 30 and check2nd) then showthishealer = true; end
        elseif class == "SHAMAN" then
            -- must have 31 or more in Resto
            if htalents[3] > 30 or (htalents2[3] > 30 and check2nd) then showthishealer = true; end
        elseif class == "PALADIN" then
            -- must have 31 or more in Holy
            if htalents[1] > 30 or (htalents2[1] > 30 and check2nd) then showthishealer = true; end
        end
    else
        showthishealer = true
    end
    return showthishealer
end

function GTH_IsTankFromTalents( name )
    
    if not GTHData.checkspecs then return true end
    
    local check2nd = false
    
    local class = GTH_GetClass( name )
    local htalents, htalents2 = GTH_GetTalents( name )
    local showthistank = false
    if htalents then
        if not htalents[1] then htalents = {0,0,0} end
        if not htalents2 then htalents2 = {0,0,0} end
        if class == "WARRIOR" then
            -- must not have more than 30 points in prot tree
            if htalents[3] > 30 or (htalents2[3] > 30 and check2nd) then showthistank = true; end
        elseif class == "DRUID" then
            -- must have 31 or more in Feral
            if htalents[2] > 30 or (htalents2[2] > 30 and check2nd) then showthistank = true; end
        elseif class == "DEATHKNIGHT" then
            -- always show deathknight
            showthistank = true
        elseif class == "PALADIN" then
            -- must have 31 or more in Prot
            if htalents[2] > 30 or (htalents2[2] > 30 and check2nd) then showthistank = true; end
        end
    else
        showthistank = true
    end
    return showthistank
end

function GTH_GetTalents( name )
    local t1,t2 = nil,nil
    if GTHinspectedList[ name ] then
        t1,t2 = GTHinspectedList[ name ], GTHinspectedList2[ name ]
    else
        if GTHhealerList[ name ] then
            if GTHhealerList[ name ][ "talents" ] then
                t1,t2 = GTHhealerList[ name ][ "talents" ], nil
            end
        elseif GTHtankList[name] then
            if GTHtankList[name]["talents"] then
                t1,t2 = GTHtankList[name]["talents"], nil
            end
        end
    end
    if t1 then
        if not t1[1] then t1=nil end
    end
    return t1, t2
end

function GTH_UpdateInspectQueue()
    --GTHinspectQueue = {};
    -- for i,unit in ipairs( GTHhealerList ) do
    for unit,v in pairs( GTHhealerList ) do
        local inqueue = false;
        for i,h in ipairs( GTHinspectQueue ) do
            if h == unit then
                -- already in queue
                inqueue = true;
            end
        end
        for h,t in pairs( GTHinspectedList ) do
            if h == unit then
                -- already inspected today
                inqueue = true;
            end
        end
        -- if not in queue already, add to end of stack
        if ( not inqueue ) then 
            table.insert( GTHinspectQueue , unit );
        end
    end
    -- now check tanks
    for unit,v in pairs( GTHtankList ) do
        local inqueue = false;
        for i,h in ipairs( GTHinspectQueue ) do
            if h == unit then
                -- already in queue
                inqueue = true;
            end
        end
        for h,t in pairs( GTHinspectedList ) do
            if h == unit then
                -- already inspected today
                inqueue = true;
            end
        end
        -- if not in queue already, add to end of stack
        if ( not inqueue ) then 
            table.insert( GTHinspectQueue , unit );
        end
    end
end

function GTH_NotifyInspect(self,unitid)
	if unitid ~= GTHinspectTarget then
	   -- another add-on fired NotifyInspect, so discard any queued inspect so it will reload
		--self:UnregisterEvent("INSPECT_TALENT_READY");
		--GTHinspectTarget = nil;
		return
	end
end

function GTH_TalentsSame( talents1 , talents2 )
	-- test if two talent lists are the same
	local same = true;
	if ( not talents1 or not talents2 ) then return false end
	if talents1[1] ~= talents2[1] then same = false end
	if talents1[2] ~= talents2[2] then same = false end
	if talents1[3] ~= talents2[3] then same = false end
	return same
end

function GTH_StartInspect(self)
    
    -- not in a raid, so no scanning please
    if GetNumGroupMembers() == 0 then 
        GTHinspectQueue = {};
        self:UnregisterEvent("INSPECT_TALENT_READY");
		GTHinspectTarget = nil;
        return 
    end 

    --gthprint("GTH> StartInspect");

    -- if no inspect ongoing, start one
    --if GTHinspectTarget == nil then
    if true then
    
        -- pull first name off stack and convert to raid ID
        if #(GTHinspectQueue) > 0 then
            GTHinspectName = GTHinspectQueue[1];
            GTHinspectTarget = GTH_GetUnitByName( GTHinspectName ); 
        else
            return -- queue is empty
        end
        
        -- fire up an inspection
        
        if ( GTHinspectTarget == "otherUnit" or GTHinspectTarget == "raid41" ) then
            -- lost unit from raid or such
            -- so rescan
            GTHinspectTarget = nil;
            table.remove( GTHinspectQueue , 1 );
            GTH_FindHealers();
            GTH_UpdateInspectQueue();
            return;
        end
        
        if UnitIsUnit("player", GTHinspectTarget) then
        
            -- remove player from queue
            GTH_GetRaidMemberTalents( false ); -- player inspect
            table.remove( GTHinspectQueue , 1 );
            GTHinspectTarget = nil;
            return;
            
        else
            if ( CheckInteractDistance(GTHinspectTarget, 1) and UnitPlayerControlled(GTHinspectTarget) ) then
                -- valid inspect target, is in range
                NotifyInspect( GTHinspectTarget );
                self:RegisterEvent("INSPECT_TALENT_READY");
            else
                --gthprint("GTH> pushing "..GTHinspectName.." to end of queue.");
                -- out of range, so move to end of queue
                table.remove( GTHinspectQueue , 1 );
                table.insert( GTHinspectQueue , GTHinspectName );
                GTHinspectName = nil;
                GTHinspectTarget = nil; -- new first name will get pulled off on next refresh
            end -- interact distance
        end -- player controlled
        
    end
end

function GTH_GetRaidMemberTalents( self , inspect )
    -- an INSPECT_TALENT_READY event has fired
    
    --gthprint("GTH> GetRaidMemberTalents");

    if GetNumGroupMembers() == 0 then 
        GTHinspectQueue = {};
        self:UnregisterEvent("INSPECT_TALENT_READY");
		GTHinspectTarget = nil;
        return 
    end 
    
    if GTHinspectTarget ~= nil then
        local talents = {}
        local talents2 = {0,0,0} -- secondary spec
        local groupNum = GetActiveTalentGroup( inspect , false )
        local numTalentGroups = GetNumTalentGroups( inspect , false )
        for i = 1 , GetNumTalentTabs( inspect ) do
            local _, _, _, _, spent = GetTalentTabInfo(i, inspect , false , groupNum)
            talents[i] = spent
            if numTalentGroups > 1 then
                local offGroup = 2
                if groupNum == 2 then offGroup = 1 end
                local _, _, _, _, spent = GetTalentTabInfo(i, inspect , false , offGroup)
                talents2[i] = spent
            end
        end
        -- save spent totals x/y/z
        GTHinspectedList[ GTHinspectName ] = talents
        GTHinspectedList2[ GTHinspectName ] = talents2
        
        local _,class = UnitClass( GTHinspectTarget )
        if GTHhealclasses[ class ] then
            GTHhealerList[ GTHinspectName ]["talents"] = talents
        end
        if GTHtankclasses[ class ] then
            GTHtankList[ GTHinspectName ]["talents"] = talents
        end
        
        if GTHdebug then
            gthprint( "GTH> Talents saved for "..GTHinspectName..": ("..talents[1].."/"..talents[2].."/"..talents[3]..")" );
        end
        
        -- clear the inspection
        GTHinspectTarget = nil;
        -- remove from queue
        table.remove( GTHinspectQueue , 1 );
        
        -- refresh
        GTH_RefreshPopulatePool()
        
        if GTHdebug then
            gthprint( "GTH> Inspect Queue contains "..#(GTHinspectQueue).." names now." );
        end
    end
    
end

GTHinspectTarget = nil; -- current unitID for NotifyInspect()
GTHinspectName = nil; -- unit name of inspect target
GTHinspectQueue = {}; -- list of units still to inspect

GTHinspectedList = {}; -- session-only list of units successfully inspected, with their talents
GTHinspectedList2 = {} -- secondary specs, if any
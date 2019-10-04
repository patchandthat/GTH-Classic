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
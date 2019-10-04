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
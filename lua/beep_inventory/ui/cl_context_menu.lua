for i = 1, 45 do
    BUi:CreateFont("BCORE.Inventory." .. i, "Montserrat", i, 500)
    BUi:CreateFont("BCORE.Inventorys." .. i, "Montserrat", i, 600)
    BUi:CreateFont("BCORE.Inventoryb." .. i, "Montserrat", i, 1024)
end

hook.Add("OnContextMenuOpen","[BCORE][INVENTORY[CONTEXTMENU]",function()
    if IsValid(BCORE.Inventory.Context) then 
        BCORE.Inventory.Context:SetVisible(true) 
    else
        BCORE.Inventory.Context = BUi.Create("EditablePanel")
        BCORE.Inventory.Context:SetTall(BUi:Scale(380))
        BCORE.Inventory.Context:Stick(BOTTOM, 0, 515, 0, 515, 10)
        BCORE.Inventory.Context:ClearPaint():Background(BCORE.F4.colors.light, 10):On("Paint", function(s, w, h)
            draw.RoundedBox(10, 1, 1, w - 2, h - 2, BCORE.F4.colors.bg)
        end)
        
        BCORE.Inventory.Context.NavBar = BUi.Create("EditablePanel", BCORE.Inventory.Context)
        BCORE.Inventory.Context.NavBar:SetTall(BUi:Scale(40))
        BCORE.Inventory.Context.NavBar:Stick(TOP, 10)
        BCORE.Inventory.Context.NavBar:ClearPaint():Background(BCORE.F4.colors.light, 6):On("Paint", function(s, w, h)
            draw.RoundedBox(6, 1, 1, w - 2, h - 2, BCORE.F4.colors.sec)
        end)

        BCORE.Inventory.upgradesbool = true

        BCORE.Inventory.Context.NavBar.Upgrades = BUi.Create("DButton", BCORE.Inventory.Context.NavBar)
        BCORE.Inventory.Context.NavBar.Upgrades:Stick(RIGHT,5)
        BCORE.Inventory.Context.NavBar.Upgrades:SetWide( BCORE.Inventory.Context.NavBar:GetWide() * .1)
        BCORE.Inventory.Context.NavBar.Upgrades:SetText("")
        BCORE.Inventory.Context.NavBar.Upgrades:FadeHover(Color(BCORE.F4.colors.light.r, BCORE.F4.colors.light.g, BCORE.F4.colors.light.b, 90),6,8)  
        BCORE.Inventory.Context.NavBar.Upgrades:ClearPaint():Background(BCORE.F4.colors.light, 6):On("Paint", function(s, w, h)
            draw.RoundedBox(6, 1, 1, w - 2, h - 2, BCORE.F4.colors.sec)
            draw.SimpleText(BCORE.Inventory.upgradesbool and "Upgrades" or "Inventory", "BCORE.Inventorys.20", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end)
        
        BCORE.Inventory.Context.NavBar.nameLabel = BUi.Create("DLabel", BCORE.Inventory.Context.NavBar)
        BCORE.Inventory.Context.NavBar.nameLabel:SetText(BUi.Truncate(LocalPlayer():Nick(), 20) .. "'s Inventory")
        BCORE.Inventory.Context.NavBar.nameLabel:SetFont("BCORE.F4s.25")
        BCORE.Inventory.Context.NavBar.nameLabel:SetTextColor(color_white)
        BCORE.Inventory.Context.NavBar.nameLabel:Stick(LEFT, 0, 10)
        BCORE.Inventory.Context.NavBar.nameLabel:SizeToContents()
        
        BCORE.Inventory.Context.GridHolder = BUi.Create("EditablePanel", BCORE.Inventory.Context)
        BCORE.Inventory.Context.GridHolder:SetTall(BUi:Scale(430))
        BCORE.Inventory.Context.GridHolder:Stick(TOP, 0, 10, 0, 0, 10)
        BCORE.Inventory.Context.GridHolder:ClearPaint()
        
        BCORE.Inventory.Context.Inventory = BUi.Create("[BCORE][UI][INVENTORY_GRID]", BCORE.Inventory.Context.GridHolder)
        BCORE.Inventory.Context.Inventory:Stick(FILL)
        BCORE.Inventory.Context.Inventory:Load()
        BCORE.Inventory.Context.NavBar.Upgrades.DoClick = function(s)
            if not BCORE.Inventory.upgradesbool then 
                BCORE.Inventory.Context.Inventory:Load(LocalPlayer().BCORE_Inventory)
            else
                BCORE.Inventory.Context.Inventory:Load(LocalPlayer().BCORE_Inventory_Modifiers)
            
            end
            BCORE.Inventory.upgradesbool = not BCORE.Inventory.upgradesbool
        end
        
        BCORE.Inventory.Context.Inventory:SetGridSpaceX(10)
        BCORE.Inventory.Context.Inventory:SetGridSpaceY(10)
        BCORE.Inventory.Context.Inventory:UpdateGrid()        
        
    end
end)

hook.Add("OnContextMenuClose","[BCORE][INVENTORY[CONTEXTMENU][Close]",function()
   
    if IsValid(BCORE.Inventory.Context) and IsValid(BCORE.Inventory.Context.slotgem) then
        BCORE.Inventory.Context:SetVisible(true)
    else
        BCORE.Inventory.Context:Remove() 
    end

end)
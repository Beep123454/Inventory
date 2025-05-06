local PANEL = {}

AccessorFunc(PANEL, "panelWidth", "PanelWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "panelHeight", "PanelHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "modelPanelWidth", "ModelPanelWidth", FORCE_NUMBER)

function PANEL:Init()

    self:SetPanelWidth(500)
    self:SetPanelHeight(300)
    self:SetModelPanelWidth(100)
    self:BUi():FadeIn(0.5)
    self.sockets = self.sockets or {}
end



function PANEL:SetItemInfo(data)
    self.Item = data

    if not self.Item then return end

    local wep_base = self.Item.itemType == "Modifier" and nil or weapons.Get(self.Item.className)
    self.basestats = self.Item.itemType == "Modifier" and {} or {
        Damage = wep_base.Primary and wep_base.Primary.Damage or 50,   
        Accuracy = wep_base.Primary and wep_base.Primary.IronAccuracy or 85,  
        Recoil = wep_base.Primary and wep_base.Primary.Recoil or wep_base.Primary.KickUp or 1.2, 
        ClipSize = wep_base.Primary and wep_base.Primary.ClipSize or 30,  
        Spread = wep_base.Primary and wep_base.Primary.Spread or 0.05,  
        RPM = wep_base.Primary and wep_base.Primary.RPM or 600,  
        Shots = wep_base.Primary and wep_base.Primary.NumShots or NumberofShots or 1
    }

    self.infoholder = vgui.Create("DPanel", self)
    self.infoholder:Dock(TOP)
    self.infoholder:DockMargin(10, 10, 10, 10)
    self.infoholder:SetTall(100)
    self.infoholder:BUi():ClearPaint()

    self.mhold = vgui.Create("DPanel", self.infoholder)
    self.mhold:Dock(LEFT)
    self.mhold:SetWide(BUi:Scale(self:GetModelPanelWidth()))
    self.mhold:BUi():ClearPaint():FadeIn(0.2):Background(BCORE.F4.colors.light, 5):On("Paint", function(s, w, h)
            local rotation = (CurTime() * 50) % 360 
            local siner = (math.sin(CurTime() * 2.5) + 2 ) * .3

            local rclr = Color(0,0,0,0)
            if self.Item.rarity == BCORE.Inventory:GetHighestRarity() then 
                rclr = HSVToColor(CurTime()* 10  % 360,1,1) 
            else
                rclr = BCORE.Inventory.config.Rarities[self.Item.rarity].color
            end

            draw.RoundedBox(6, 0, 0, w, h, BCORE.F4.colors.light)
  
            
            BUi.masks.Start()
    
            surface.SetAlphaMultiplier(siner)
            surface.SetDrawColor(rclr)
            surface.SetMaterial(BUi.Grad["Down"])

            surface.DrawTexturedRectRotated(w/2, h/2, w, h*2,rotation)
            BUi.masks.Source()
            draw.RoundedBox(6, 0, 0, w, h, rclr)
            BUi.masks.End()
            surface.SetAlphaMultiplier(1)
            draw.RoundedBox(6, 1, 1, w - 2, h - 2, BCORE.F4.colors.sec)
            surface.SetAlphaMultiplier(siner)
            BUi.masks.Start()
            surface.SetDrawColor(rclr)
            surface.SetMaterial(BUi.Grad["Down"])
            surface.DrawTexturedRect(1, h / 4 - 1, w- 2, h / 1.3)
            BUi.masks.Source()
            draw.RoundedBox(6, 1, 1, w - 2, h - 2, BCORE.F4.colors.sec)
            BUi.masks.End()
            surface.SetAlphaMultiplier(1)

    end)

    self.ModelPanel = self.mhold:Add("DModelPanel")
    self.ModelPanel:Dock(FILL)
    self.ModelPanel:SetModel(self.Item.model)
    self.ModelPanel:BUi():FadeIn(0.2)
    function self.ModelPanel:LayoutEntity() return end
    local mn, mx = self.ModelPanel.Entity:GetRenderBounds()
    local size = math.max(
        math.abs(mn.x) + math.abs(mx.x),
        math.abs(mn.y) + math.abs(mx.y),
        math.abs(mn.z) + math.abs(mx.z)
    )
    self.ModelPanel:SetFOV(40)
    self.ModelPanel:SetCamPos(Vector(size, size, size))
    self.ModelPanel:SetLookAt((mn + mx) * 0.5)

    self.navbar = vgui.Create("DPanel", self.infoholder)
    self.navbar:Dock(TOP)
    self.navbar:DockMargin(10, 0, 0, 0)
    self.navbar:SetTall(40)
    self.navbar:BUi():ClearPaint():Background(Color(56, 56, 56,200), 5):FadeIn(0.5):On("Paint", function(s, w, h)
            local rclr = Color(0,0,0,0)
            if self.Item.rarity == BCORE.Inventory:GetHighestRarity() then 
                rclr = HSVToColor(CurTime()* 10  % 360,1,1) 
            else
                rclr = BCORE.Inventory.config.Rarities[self.Item.rarity].color
            end
        local siner = (math.sin(CurTime() * 2.5) + 2 ) * .3
        local rotation = (CurTime() * 30) % 360 
        surface.SetAlphaMultiplier(siner)
        BUi.masks.Start()
        surface.SetMaterial(BUi.Grad["Right"])
        surface.SetDrawColor(rclr)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetMaterial(BUi.Grad["Left"])
        surface.SetDrawColor(rclr)
        surface.DrawTexturedRect(0, 0, w/2, h)
        surface.DrawTexturedRectRotated(w/2, h/2, w, h*2 ,rotation)
        BUi.masks.Source()
        draw.RoundedBox(5, 0, 0, w, h, BCORE.F4.colors.tert)
        BUi.masks.End()
        surface.SetAlphaMultiplier(1)
        draw.RoundedBox(5, 1, 1, w - 2, h - 2,  BCORE.F4.colors.accent)
        
        draw.SimpleText(self.Item.name, "BCORE.Inventoryb.30", w / 2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

    self.modifireholderscroller = vgui.Create("DScrollPanel", self)
    self.modifireholderscroller:Dock(LEFT)
    self.modifireholderscroller:DockMargin(10, 15, 10, 10)
    self.modifireholderscroller:SetWide( self.mhold:GetWide())
    self.modifireholderscroller:BUi():ClearPaint():HideVBar()

    self.modifireholder = vgui.Create("DIconLayout",  self.modifireholderscroller)
    self.modifireholder:Dock(FILL)
    self.modifireholder:SetSpaceX(10)
    self.modifireholder:SetSpaceY(10)
    self.modifireholder:BUi():ClearPaint()


    if  BCORE.Inventory.config.Rarities[self.Item.rarity].weight > 4 and self.Item.itemType == "UpgradableWeapon" then
        for i = 1, BCORE.Inventory.config.Rarities[self.Item.rarity].sockets do
            local socket = BUi.Create("DPanel",self.modifireholder)
            socket:SetSize(45,45)
            socket:BUi():ClearPaint():On("Paint", function(s, width, height)
                draw.RoundedBox(6, 0, 0, width, height, BCORE.F4.colors.light)
                draw.RoundedBox(6, 1, 1, width - 2, height - 2, BCORE.F4.colors.sec)
            end)
            
            self.sockets[i] = {
                socket = socket,
                HasItem = false
            }
        end
        if self.Item.customData.Modifiers then
        for k,v in pairs(self.Item.customData.Modifiers) do
            local modifier = BUi.Create("[BCORE][UI][ITEM_PANEL]", self.sockets[k].socket)
            modifier:Dock(FILL)
            modifier:SetItem(v)
            modifier:Text("")
            self.sockets[k].HasItem = true
        end
    end
    end

end

function PANEL:Paint(w, h)
    if not self.Item then return end
    self:BUi():ClearPaint():Background(Color(56, 56, 56), 5):On("Paint", function(s, w, h)
        local rclr = Color(0,0,0,0)
        if self.Item.rarity == BCORE.Inventory:GetHighestRarity() then 
            rclr = HSVToColor(CurTime()* 10  % 360,1,1) 
        else
            rclr = BCORE.Inventory.config.Rarities[self.Item.rarity].color
        end
        local siner = (math.sin(CurTime() * 2.5) + 2 ) * .3
        draw.RoundedBox(5, 1, 1, w - 2, h - 2, Color(28, 28, 28))
        surface.SetAlphaMultiplier(siner)
        BUi.masks.Start()
        BUi.DrawImgur(0,0,w,h, "8CLv24q", rclr)
        surface.SetMaterial(BUi.Grad["Down"])
        surface.SetDrawColor(rclr)
        surface.DrawTexturedRect(0, 0, w, h)
        BUi.masks.Source()
        draw.RoundedBox(8, 0, 0, w, h, BCORE.F4.colors.tert)
        BUi.masks.End()
        surface.SetAlphaMultiplier(1)

        local textX = self.navbar:GetWide() * 0.83
        draw.SimpleText(self.Item.rarity, "BCORE.Inventoryb.30", textX, 50,rclr, TEXT_ALIGN_CENTER)

        if  not table.IsEmpty(self.Item.customData) then
            local pos = 55
            for k, v in SortedPairs(self.Item.customData) do
                if k == "Modifiers" then continue end
                if k == "Type" then continue end
                pos = pos + 30
                local val = isstring(v) and v or math.Round( v,2 )
                local offsetx, _ = surface.GetTextSize(k .. ": " .. val .. " ")

                if self.Item.itemType == "Modifier" then 
                    draw.SimpleText(k .. ": " .. val .. " ", "BCORE.Inventorys.25", self.navbar:GetWide() * .33, pos, color_white, TEXT_ALIGN_LEFT)
                    draw.SimpleText("+" .. val * 10 .. "%", "BCORE.Inventorys.25", self.navbar:GetWide() * .33 + offsetx, pos, Color(28,208,28), TEXT_ALIGN_LEFT)
                else
                    local base = self.basestats[k]
                    local diff = val - base
                    local percent_change = base ~= 0 and (diff / base) * 100 or 0
                    
                    if math.abs(percent_change) > 1000 then
                        percent_change = (percent_change / math.abs(percent_change)) * 200
                    end
                    
                    local substat = (diff < 0 and string.format("%.2f%%", percent_change)) or ("+" .. string.format("%.2f%%", percent_change))
                    local redorgreen = string.StartsWith(substat, "+") and Color(28, 208, 28) or Color(255, 0, 0)
                    
                    draw.SimpleText(k .. ": " .. val .. " ", "BCORE.Inventorys.25", self.navbar:GetWide() * .33, pos, color_white, TEXT_ALIGN_LEFT)
                    draw.SimpleText(substat, "BCORE.Inventorys.25", self.navbar:GetWide() * .33 + offsetx, pos, redorgreen, TEXT_ALIGN_LEFT)
                    
                                                    
                end
            end
        end


        draw.SimpleText("Modifiers", "BCORE.Inventorys.25", 10, 110, color_white, TEXT_ALIGN_LEFT)
    end)
end

function PANEL:PerformLayout()
    self:BUi():FadeIn(0.5)
    self:SetSize(BUi:Scale(self:GetPanelWidth()), BUi:Scale(self:GetPanelHeight()))
    self:MakePopup()
end

vgui.Register("[BCORE][UI][ITEM_HOVER]", PANEL, "DPanel")

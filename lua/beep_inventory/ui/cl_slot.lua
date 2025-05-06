local PANEL = {}


local currentMenu = nil

function PANEL:SetItem(data)
    self.Item = data
    if not self.Item then
        if IsValid(self.ModelPanel) then
            self.ModelPanel:Remove()
        end
        return
    end

    if IsValid(self.ModelPanel) then
        self.ModelPanel:Remove()
    end

    self.ModelPanel = self:Add("DModelPanel")
    self.ModelPanel:Dock(FILL)
    self.ModelPanel.LayoutEntity = function() return end
    self.ModelPanel:SetModel(self.Item.model)

    local mn, mx = self.ModelPanel.Entity:GetRenderBounds()
    local size = math.max(
        math.abs(mn.x) + math.abs(mx.x),
        math.abs(mn.y) + math.abs(mx.y),
        math.abs(mn.z) + math.abs(mx.z)
    )

    self.ModelPanel:SetFOV(40)
    self.ModelPanel:SetCamPos(Vector(size, size, size))
    self.ModelPanel:SetLookAt((mn + mx) * 0.5)

    if not self.ModelPanel.NoDrag then
        self.ModelPanel:SetDragParent(self)
    end
end

function PANEL:Paint(w, h)
    self:BUi():ClearPaint():On("Paint", function(s, w ,h)
       
        if self.Item then

            local rotation = (CurTime() * 50) % 360 
            local rclr = Color(0,0,0,0)
            local siner = (math.sin(CurTime() * 2.5) + 2 ) * .3
            if self.Item.rarity == BCORE.Inventory:GetHighestRarity() then 
                rclr = HSVToColor(CurTime()* 10  % 360,1,1) 
            else
                rclr = BCORE.Inventory.config.Rarities[self.Item.rarity].color
            end
            draw.RoundedBox(6, 0, 0, w, h, BCORE.F4.colors.light)
  
            
            BUi.masks.Start()
    
            surface.SetDrawColor(rclr)
            surface.SetMaterial(BUi.Grad["Down"])

            surface.DrawTexturedRectRotated(w/2, h/2, w, h*2,rotation)
            BUi.masks.Source()
            draw.RoundedBox(6, 0, 0, w, h, rclr)
            BUi.masks.End()
            draw.RoundedBox(6, 1, 1, w - 2, h - 2, BCORE.F4.colors.sec)

            BUi.masks.Start()
            surface.SetAlphaMultiplier(siner)
            BUi.DrawImgur(0,0,w,h, "HX2VcKu", rclr)
            surface.SetDrawColor(rclr)
            surface.SetMaterial(BUi.Grad["Down"])
            surface.DrawTexturedRect(1, h / 4 - 1, w- 2, h / 1.3)
            BUi.masks.Source()
            draw.RoundedBox(6, 1, 1, w - 2, h - 2, BCORE.F4.colors.sec)
            BUi.masks.End()
            surface.SetAlphaMultiplier(1)

        end
   
    end)
end

function PANEL:GetItem()
    return self.Item
end

function PANEL:Think()

    self.ModelPanel.DoClick = function(s)
        if IsValid(currentMenu) then
            currentMenu:Close()
        end
    end

    self.ModelPanel.DoRightClick = function(s)
        self:RemoveTooltip()
        
        if IsValid(currentMenu) then
            currentMenu:Close()
        end

        local menu = BUi.Create("BUi.DMenu", self)
        currentMenu = menu  
        menu:SetSize(110)

        for k,v in pairs(self.Item.onAction) do
           
            menu:AddOption(v, function()
                BCORE.Inventory:RequestAction(self.Item.id, v)
                if v == "Socket" then
                    if BCORE.Inventory.config.Rarities[self.Item.rarity].weight < 4 then return end
                    BCORE.Inventory.Context.slotgem = BUi.Create("[BCORE][UI][SLOT_GEM]")
                    BCORE.Inventory.Context.slotgem:SetItemInfo(self.Item)
                end
             
            end)
        end
        menu:Open()
    end

    if not self.Item or not self:IsVisible() then
        self:RemoveTooltip()
        return
    end

    local isHovered = self.ModelPanel and self.ModelPanel:IsHovered()
    if isHovered then
        local mouseX, mouseY = input.GetCursorPos()
        self:UpdateTooltip(mouseX + 20, mouseY - 240)
    else
        self:RemoveTooltip()
    end
end

function PANEL:UpdateTooltip(x, y)
    if not self.tip then
        self.tip = vgui.Create("[BCORE][UI][ITEM_HOVER]")
        self.tip:SetItemInfo(self.Item)
    end
    self.tip:SetPos(x, y)
end

function PANEL:RemoveTooltip()
    if IsValid(self.tip) then
        self.tip:Remove()
        self.tip = nil
    end
end

function PANEL:OnRemove()
    if IsValid(self.tip) then
        self.tip:Remove()
    end
end

vgui.Register("[BCORE][UI][ITEM_PANEL]", PANEL, "DButton")

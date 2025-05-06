hook.Add("PostDrawTranslucentRenderables", "BCORE.Inventory.ItemOverhead", function()
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetNWBool("IsItem") then
            local verticleoffset = 10
            local tick = false

            if ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < 4500 then
                verticleoffset = 20
                tick = true
            else
                verticleoffset = 10
            end

            local min, max = ent:GetCollisionBounds()
            local height = max.z - min.z
            local targetOffset = Vector(0, 0, height + verticleoffset)

            ent.smoothedOffset = ent.smoothedOffset or targetOffset
            ent.smoothedOffset = LerpVector(FrameTime() * 10, ent.smoothedOffset, targetOffset)

            local mypos = ent:GetPos()
            local tw, _ = surface.GetTextSize(ent:GetNWString("ItemName") or "Unknown")
            local rclr = Color(0, 0, 0, 0)

            if ent:GetNWString("ItemRarity") == "Primordial" then
                rclr = HSVToColor(CurTime() * 10 % 360, 1, 1)
            else
                rclr = BCORE.Inventory.config.Rarities[ent:GetNWString("ItemRarity")].color
            end

            if (LocalPlayer():GetPos():Distance(mypos) >= 1000) then return end
            local pos = mypos + ent.smoothedOffset
            local ang = Angle(0, EyeAngles().y - 90, 90)
            local siner = (math.sin(CurTime() * 2.5) + 2) * .3

            local x, y, w = -400, 0, 800
            local customDataCount = 0

            for i = 1, 100 do
                local customDataValue = ent:GetNWString("Custom_" .. i, "Unknown")
                if customDataValue ~= "Unknown" then
                    customDataCount = customDataCount + 1
                end
            end

            local targetBoxHeight = 120 + (customDataCount * 85)
            ent.boxHeight = ent.boxHeight or 120
            ent.boxHeight = Lerp(FrameTime() * 10, ent.boxHeight, tick and targetBoxHeight or 120)

            ent.textOffset = ent.textOffset or 150
            ent.textOffset = Lerp(FrameTime() * 6, ent.textOffset, tick and 150 or 75)

            cam.Start3D2D(pos, ang, 0.03)
                local namex, namey, namew, nameh = (x + w * .5 - tw * .5) - 100, y - 160, tw + 200, 150
                surface.SetAlphaMultiplier(siner)
                draw.RoundedBox(32, namex, namey, namew, nameh, rclr)
                surface.SetAlphaMultiplier(1)

                draw.RoundedBox(32, namex + 5, namey + 5, namew - 12, nameh - 12, BCORE.F4.colors.bg)

                surface.SetAlphaMultiplier(siner)
                draw.RoundedBox(32, x, y, w, ent.boxHeight, rclr)
                surface.SetAlphaMultiplier(1)
                draw.RoundedBox(32, x + 5, y + 5, w - 12, ent.boxHeight - 12, BCORE.F4.colors.bg)

                draw.RoundedBoxEx(32, x + 5, y + 5, w - 12, 110, tick and BCORE.F4.colors.accent or Color(0, 0, 0, 0), true, true, false, false)

                if tick then
                    local alpha = ent.alpha or 0
                    ent.alpha = Lerp(FrameTime() /4, alpha, 255)
                    ent.alpha = math.Clamp(ent.alpha, 0, 255)
                else
                    ent.alpha = 0
                end

                surface.SetAlphaMultiplier(siner)
                draw.RoundedBox(0, x + 5, y + 220 * .5, w - 12, 5, tick and rclr or Color(0, 0, 0, 0))
                local lineoffset = 390
                
                for i = 1, customDataCount - 1 do
                    draw.RoundedBox(0, x + 5, lineoffset * .5, w - 12, 5, Color(rclr.r,rclr.g,rclr.b,ent.alpha))
                    lineoffset = lineoffset + 170
                end

                surface.SetAlphaMultiplier(1)
                local textoffset = ent.textOffset
             
                for i = 1, customDataCount do
                    local customDataKey = "Custom_" .. i
                    local customDataValue = ent:GetNWString(customDataKey, "Unknown")
                    if customDataValue == "Unknown" then continue end
                    local split = string.Split(customDataValue, " ")
                    local val = tonumber(split[2]) and math.Round(tonumber(split[2]), 2) or split[2]
                    draw.SimpleText(split[1] .. " " ..val, "BCORE.Inventorys.75", x + 20, textoffset, Color(255,255,255,ent.alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    textoffset = textoffset + 85
                end

                draw.SimpleText(ent:GetNWString("ItemRarity", "Unknown Item"), "BCORE.Inventoryb.110", x + w * .5, y + 100 * .5, rclr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(ent:GetNWString("ItemName", "Unknown Item"), "BCORE.Inventoryb.110", x + w * .5, y - 170 * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end)
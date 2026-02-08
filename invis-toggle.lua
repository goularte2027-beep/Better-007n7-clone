-- Invisible Upon Cloning - Toggleable Module (corrigido: só ativa no momento real do clone)
-- Agora com threshold alto ( >= 0.8 ) pra evitar ativar cedo
-- Só reage quando o jogo aplica transparência alta na skill de clone

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local running = false
local animTrack = nil
local connection = nil

local ANIMATION_ID = "rbxassetid://75804462760596"

local function setInvisibility(enabled)
    if enabled then
        if running then return end
        running = true
        
        print("[Invis Toggle] Modo ON ativado - esperando clone real...")
        
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not running then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if not root then return end
            
            -- Threshold alto: só ativa quando transparência é muito alta (clone real)
            -- No Forsaken, invis/clone chega a \~0.925 ou 1.0
            if root.Transparency >= 0.8 then
                if not animTrack or not animTrack.IsPlaying then
                    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                    
                    local animation = Instance.new("Animation")
                    animation.AnimationId = ANIMATION_ID
                    
                    animTrack = animator:LoadAnimation(animation)
                    animTrack.Looped = true
                    animTrack:Play()
                    animTrack:AdjustSpeed(0)
                    
                    root.Transparency = 0.4  -- Mantém visível pra você
                    print("[Invis Toggle] Clone detectado! Pose freeze ativada.")
                end
            else
                -- Desativa quando transparência volta ao normal
                if animTrack and animTrack.IsPlaying then
                    animTrack:Stop()
                    animTrack = nil
                    root.Transparency = 1
                    print("[Invis Toggle] Clone acabou! Pose desativada.")
                end
            end
        end)
    else
        running = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if animTrack and animTrack.IsPlaying then
            animTrack:Stop()
            animTrack = nil
        end
        
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if root then
                root.Transparency = 1
            end
        end
        print("[Invis Toggle] Modo OFF - tudo resetado.")
    end
end

getgenv().ToggleInvisibleCloning = function(enabled)
    setInvisibility(enabled)
end

LocalPlayer.CharacterAdded:Connect(function()
    if running then
        setInvisibility(false)
        print("[Invis Toggle] Reset ao respawn.")
    end
end)

print("[Invisible Cloning Toggle] Carregado! Só ativa quando transparência >= 0.8 (clone real).")

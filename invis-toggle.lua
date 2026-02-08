-- Invisible Upon Cloning - Toggleable Module (versão corrigida: só ativa no momento do clone)
-- Agora só reage quando o clone realmente acontece (transparência alta + verificação extra)

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
        
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not running then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if not root then return end
            
            -- Só ativa se transparência for ALTA (indicando clone real, não bug ou efeito normal)
            -- No Forsaken, clones costumam setar Transparency = 1 ou próximo disso
            if root.Transparency >= 0.8 then  -- Aumentei o threshold pra evitar ativar cedo
                if not animTrack or not animTrack.IsPlaying then
                    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                    
                    local animation = Instance.new("Animation")
                    animation.AnimationId = ANIMATION_ID
                    
                    animTrack = animator:LoadAnimation(animation)
                    animTrack.Looped = true
                    animTrack:Play()
                    animTrack:AdjustSpeed(0)
                    
                    root.Transparency = 0.4  -- Mantém visível pro player, mas "invis" pro jogo
                    print("[Invis Toggle] Clone detectado! Pose ativada.")
                end
            else
                -- Desativa quando o clone acaba (transparência volta a 0 ou baixa)
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
    end
end

getgenv().ToggleInvisibleCloning = function(enabled)
    setInvisibility(enabled)
end

LocalPlayer.CharacterAdded:Connect(function()
    if running then
        setInvisibility(false)  -- Reset ao respawn
    end
end)

print("[Invisible Cloning Toggle] Carregado! Agora só ativa no momento do clone real.")

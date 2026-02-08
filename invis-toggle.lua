-- Invisible upon Cloning - com animação de "dentro do chão" corrigida (sem glitch)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local running = false
local animTrack = nil
local connection = nil

local ANIMATION_ID = "rbxassetid://75804462760596"

local function handleToggle(enabled)
    running = enabled
    
    if enabled then
        print("[Invis Under Ground] LIGADO - monitorando clone continuamente...")
        
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not running then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
            
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            local root = character:FindFirstChild("HumanoidRootPart")
            
            if torso and torso.Transparency > 0 then  -- Clone ativo
                if not animTrack or not animTrack.IsPlaying then
                    local animation = Instance.new("Animation")
                    animation.AnimationId = ANIMATION_ID
                    
                    animTrack = animator:LoadAnimation(animation)
                    animTrack.Looped = true
                    animTrack.Priority = Enum.AnimationPriority.Action4  -- Prioridade alta
                    
                    animTrack:Play()
                    animTrack:AdjustSpeed(0.001)  -- Speed quase zero, mas evita glitch
                    
                    if root then
                        root.Transparency = 0.4  -- Invisível pro jogo, visível pra você
                    end
                    print("[Invis Under Ground] Clone detectado - entrando no chão!")
                end
            else
                if animTrack and animTrack.IsPlaying then
                    animTrack:Stop()
                    animTrack = nil
                    if root then
                        root.Transparency = 1
                    end
                    print("[Invis Under Ground] Clone acabou - saindo do chão.")
                end
            end
        end)
    else
        print("[Invis Under Ground] DESLIGADO")
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        if animTrack and animTrack.IsPlaying then
            animTrack:Stop()
            animTrack = nil
        end
        
        local character = LocalPlayer.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Transparency = 1
            end
        end
    end
end

getgenv().ToggleInvisibleCloning = function(enabled)
    handleToggle(enabled)
end

-- Reset ao respawn (mantém ligado se estava ON)
LocalPlayer.CharacterAdded:Connect(function()
    if running then
        local character = LocalPlayer.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Transparency = 1
            end
        end
        print("[Invis Under Ground] Respawn - resetado, monitoramento continua.")
    end
end)

print("[Invis Under Ground] Carregado! Monitora continuamente enquanto ligado.")

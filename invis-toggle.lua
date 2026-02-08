-- Invisible upon Cloning - Adaptado pro Gubby Gui (com animação de entrar no chão)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local running = false
local animTrack = nil

-- Função principal (ON/OFF)
local function handleToggle(enabled)
    running = enabled
    
    if enabled then
        print("[Invis Clone] LIGADO - procurando clone...")
        
        spawn(function()
            while running do
                local character = LocalPlayer.Character
                if not character then task.wait(0.5) continue end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then task.wait(0.5) continue end
                
                local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                
                local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                local root = character:FindFirstChild("HumanoidRootPart")
                
                if torso and torso.Transparency \~= 0 then
                    if not animTrack or not animTrack.IsPlaying then
                        local animation = Instance.new("Animation")
                        animation.AnimationId = "rbxassetid://75804462760596"
                        animTrack = animator:LoadAnimation(animation)
                        animTrack.Looped = true
                        animTrack:Play()
                        animTrack:AdjustSpeed(0.001)  -- Evita o loop glitchado
                        
                        if root then
                            root.Transparency = 0.4
                        end
                        print("[Invis Clone] CLONE DETECTADO! Entrando no chão...")
                    end
                else
                    if animTrack and animTrack.IsPlaying then
                        animTrack:Stop()
                        animTrack = nil
                        if root then
                            root.Transparency = 1
                        end
                        print("[Invis Clone] Clone acabou - saindo do chão.")
                    end
                end
                
                task.wait(0.5)  -- Delay do original
            end
        end)
    else
        print("[Invis Clone] DESLIGADO")
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

-- Função global pro Gubby Gui chamar
getgenv().ToggleInvisibleCloning = function(enabled)
    handleToggle(enabled)
end

-- Reset ao respawn
LocalPlayer.CharacterAdded:Connect(function()
    if running then
        local character = LocalPlayer.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Transparency = 1
            end
        end
        print("[Invis Clone] Respawn - resetado, continua ligado.")
    end
end)

print("[Invis Clone] Carregado! Monitora enquanto ligado.")

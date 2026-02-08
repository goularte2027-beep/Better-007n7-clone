-- Invisible Upon Cloning - Toggleable Module for Gubby Gui
-- Esse script fica no GitHub e é carregado via loadstring
-- Função global: getgenv().ToggleInvisibleCloning(true/false)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local running = false
local animTrack = nil
local connection = nil

local ANIMATION_ID = "rbxassetid://75804462760596"  -- Animação de pose freeze para simular invis

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
            
            local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
            
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if not root then return end
            
            -- Se o root já está transparente (clonado/invis), ativa pose freeze + transparência extra
            if root.Transparency > 0.1 then
                if not animTrack or not animTrack.IsPlaying then
                    local animation = Instance.new("Animation")
                    animation.AnimationId = ANIMATION_ID
                    
                    animTrack = animator:LoadAnimation(animation)
                    animTrack.Looped = true
                    animTrack:Play()
                    animTrack:AdjustSpeed(0)  -- Freeze na pose
                    
                    root.Transparency = 0.4  -- Deixa mais visível pro player, mas ainda "invis" pro jogo
                end
            else
                -- Desativa quando volta ao normal
                if animTrack and animTrack.IsPlaying then
                    animTrack:Stop()
                    animTrack = nil
                    root.Transparency = 1
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

-- Função global que o Gubby Gui chama
getgenv().ToggleInvisibleCloning = function(enabled)
    setInvisibility(enabled)
end

-- Reseta ao respawn (boa prática)
LocalPlayer.CharacterAdded:Connect(function()
    if running then
        setInvisibility(false)
    end
end)

print("[Invisible Cloning Toggle] Carregado! Use ToggleInvisibleCloning(true/false)")

-- Invis Clone com "debaixo do chão" por 5 segundos após clone
-- Detecta transparência alta → abaixa pro chão → espera 5s → volta pra cima

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local connection = nil
local isCloned = false

local function setMode(active)
    enabled = active
    
    if active then
        print("[Invis Under Ground] Modo ON - esperando uso do clone...")
    else
        print("[Invis Under Ground] Modo OFF")
        if connection then
            connection:Disconnect()
            connection = nil
        end
        isCloned = false
        -- Garante que volta pra posição normal ao desligar
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)  -- força subir um pouco
        end
    end
end

getgenv().ToggleUnderGroundClone = function(active)
    setMode(active)
end

-- Loop de detecção
local function startDetection()
    connection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Detecta o momento do clone (transparência alta)
        if root.Transparency >= 0.75 and not isCloned then
            isCloned = true
            print("[Invis Under Ground] Clone detectado! Abaixando pro chão...")
            
            -- Abaixa pro chão (loop pra ficar "debaixo do solo")
            task.spawn(function()
                local downOffset = Vector3.new(0, -4.5, 0)  -- quanto abaixar (ajuste se precisar mais ou menos)
                local startTime = tick()
                
                while tick() - startTime < 5.1 and isCloned and enabled do
                    if char and root and root.Parent then
                        root.CFrame = root.CFrame + downOffset * 0.05  -- movimento suave pra baixo
                    end
                    task.wait(0.03)
                end
                
                -- Após 5 segundos, volta pra cima
                if isCloned and enabled then
                    print("[Invis Under Ground] 5 segundos acabaram! Voltando pra cima...")
                    if char and root and root.Parent then
                        root.CFrame = root.CFrame + Vector3.new(0, 5, 0)  -- sobe de volta
                    end
                    isCloned = false
                end
            end)
        end
        
        -- Se transparência voltar ao normal antes dos 5s (clone cancelado), reseta
        if root.Transparency < 0.5 and isCloned then
            isCloned = false
            print("[Invis Under Ground] Clone cancelado antes dos 5s - resetando.")
        end
    end)
end

-- Inicia detecção quando toggle liga
local oldEnabled = false
RunService.Heartbeat:Connect(function()
    if enabled \~= oldEnabled then
        oldEnabled = enabled
        if enabled then
            startDetection()
        else
            if connection then connection:Disconnect() connection = nil end
        end
    end
end)

-- Reset ao respawn
LocalPlayer.CharacterAdded:Connect(function()
    isCloned = false
    if enabled then
        print("[Invis Under Ground] Respawn detectado - resetando estado.")
    end
end)

print("[Invis Under Ground] Carregado! Ativa só quando clone usado → abaixa 5s → volta.")

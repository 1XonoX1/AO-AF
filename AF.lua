local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishEventRemote = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FishEvent")
local ToolActionRemote = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("ToolAction")

local CompleteListener = nil
local FishEventListener = nil

local LastCatch = nil

local function GetEquippedRod ()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    return Character and Character:FindFirstChildOfClass("Tool")
end

local function CastAgain ()
    
    local EquippedRod = GetEquippedRod()
    
    if not EquippedRod then
        ShouldReel = false
        print("🎣 No rod equipped")
        return
    end
    
    if not AutoFishEnabled then
        return
    end

    print("🎣 Casting rod again")
    ToolActionRemote:FireServer(EquippedRod)
end

local function StopReeling ()
    ShouldReel = false
    
    if CompleteListener then
        CompleteListener:Disconnect()
        CompleteListener = nil
    end
    
    print("🎣 Stopped reeling, waiting", SecondsWaitForReelAgain, "seconds")
    wait(SecondsWaitForReelAgain)
    
    CastAgain()
end

local function StartReeling (Item)
    print("🎣 Reeling in:", tostring(Item))

    if CompleteListener then
        CompleteListener:Disconnect()
        CompleteListener = nil
    end
    
    CompleteListener = FishEventRemote.OnClientEvent:Connect(
        function (Player, Action, _)
            if tostring(Player) == tostring(LocalPlayer) and tostring(Action) == "Complete" then
                print("🎣 Caught. Stopping reel")
                
                if LastCatch then
                    WindUI:Notify({
                        Title = "Caught " .. LastCatch,
                        Duration = 5
                    })
                end
                
                StopReeling()
            end
        end    
    )

    while ShouldReel do
        local EquippedRod = GetEquippedRod()
    
        if not EquippedRod then
            ShouldReel = false
            print("🎣 No rod equipped")
            StopReeling()
            break
        end
        
        ToolActionRemote:FireServer(EquippedRod)
        
        local MinCPS = ReelSpeedValue - ReelSpeedRandomnessValue
        local MaxCPS = ReelSpeedValue + ReelSpeedRandomnessValue
        local ActualCPS = MinCPS + math.random() * (MaxCPS - MinCPS)
        
        if ActualCPS == 0 or ActualCPS < 0.01 then
            ActualCPS = 0.01
        end
        
        local RandomReelClickWait = 1.0 / ActualCPS
        
        print("🎣 Waiting:", string.format("%.2f", RandomReelClickWait), "seconds")
        wait(RandomReelClickWait)
    end
end

local function StartLogging ()
    print("🎣 Listening to FishEvent")
    
    FishEventListener = FishEventRemote.OnClientEvent:Connect(
        function (Player, Action, Item, Data)
            if tostring(Player) == tostring(LocalPlayer) then
                print("🎣 FishEvent:\n - Action:", tostring(Action), "\n - Item:", tostring(Item), "\n")
            end
            
            if tostring(Player) == tostring(LocalPlayer) and tostring(Action) == "Bite" then
                if not ShouldReel then
                    print("🎣 Your fish bite detected. Item:", tostring(Item))
                    LastCatch = tostring(Item)
                    ShouldReel = true
                    coroutine.wrap(
                        function ()
                            StartReeling(Item)
                        end
                    )()
                end
            end
        end
    )
end

local function StopAll ()
    print("🎣 Stopping All")
    ShouldReel = false
    
    if CompleteListener then
        CompleteListener:Disconnect()
        CompleteListener = nil
    end
    
    if FishEventListener then
        FishEventListener:Disconnect()
        FishEventListener = nil
    end
end

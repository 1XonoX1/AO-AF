local ShouldReel = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local FishEventRemote = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FishEvent")
local NotificationRemote = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("UI"):WaitForChild("Notification")
local ToolActionRemote = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("ToolAction")

local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

local Map = workspace:WaitForChild("Map")

local CompleteListener = nil
local NotificationListener = nil
local FishEventListener = nil

getgenv().GetMapPlaces = function ()
    local Names = {}

    for _, Folder in ipairs(Map:GetChildren()) do
        if Folder:IsA("Folder") and Folder:FindFirstChild("Center") then
            table.insert(Names, Folder.Name)
        end
    end

    return Names
end

getgenv().TPToIsland = function (Name, Wait)
    local Center = Map[Name]:WaitForChild("Center")
    local WaitUntil = false

    local WaitListener = Map[Name].OnChildAdded:Connect(
        function ()
            WaitUntil = true
        end
    )

    repeat
        task.wait()
        LocalPlayer.Character.PrimaryPart.CFrame = Center.CFrame + Vector3.new(0,275,0)
    until
        WaitUntil or not Wait

    WaitUntil = false
    WaitListener:Disconnect()
    WaitListener = nil
end

local function GetRootPart ()
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    return Character:FindFirstChild("HumanoidRootPart")
end

local function FreezeCharacter ()
	local RootPart = GetRootPart()
	if RootPart then
		RootPart.Anchored = true
	end

    print("AutoFish | Freezed character in place")
end

local function UnfreezeCharacter ()
	local RootPart = GetRootPart()
	if RootPart then
		RootPart.Anchored = false
	end

    print("AutoFish | Unfreezed character")
end

local function GetEquippedRod ()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    return Character and Character:FindFirstChildOfClass("Tool")
end

local function CastAgain ()
    local EquippedRod = GetEquippedRod()

    if not EquippedRod then
        ShouldReel = false
        print("AutoFish | No rod equipped")
        return
    end

    if not getgenv().AutoFishToggle.Value then
        return
    end

    print("AutoFish | Casting rod again")
    ToolActionRemote:FireServer(EquippedRod)
end

local function CheckAutoEat ()
    local AmountLabel = PlayerGui
        :WaitForChild("MainGui")
        :WaitForChild("UI")
        :WaitForChild("HUD")
        :WaitForChild("Anchor")
        :WaitForChild("HungerBar")
        :WaitForChild("Back")
        :WaitForChild("Amount")

    local ParsedAmount = tonumber(AmountLabel.Text)

    local PreviousRod = GetEquippedRod()

    if ParsedAmount <= tonumber(getgenv().AutoEatLevelSlider.Value.Default) then
        getgenv().EatDish()
    end

    -- getgenv().StopAll()

    task.wait(1)

    print("AutoFish | Equipping rod again")
    LocalPlayer.Character.Humanoid:EquipTool(PreviousRod)
end

local function StopReeling ()
    ShouldReel = false

    if CompleteListener then
        CompleteListener:Disconnect()
        CompleteListener = nil
    end

    if NotificationListener then
        NotificationListener:Disconnect()
        NotificationListener = nil
    end

    for i, v in pairs(getgenv().LastCatch) do
        print(i, v)
    end

    coroutine.wrap(
        function ()
            getgenv().SendWebhook()
            getgenv().WindUI:Notify({
                Title = "Caught " .. (getgenv().LastCatch and (getgenv().LastCatch.Alt .. " ") or "") .. getgenv().LastCatch.Name,
                Duration = 5
            })
        end
    )()

    if getgenv().AutoEatToggle.Value then
        CheckAutoEat()
        task.wait()
    end

    print("AutoFish | Stopped reeling, waiting", getgenv().CastAgainWaitSlider.Value.Default, "seconds")
    task.wait(getgenv().CastAgainWaitSlider.Value.Default)

    CastAgain()
end

local function StartReeling (Item)
    print("AutoFish | Reeling in:", tostring(Item))

    if CompleteListener then
        CompleteListener:Disconnect()
        CompleteListener = nil
    end

    CompleteListener = FishEventRemote.OnClientEvent:Connect(
        function (Player, Action, _)
            if tostring(Player) == tostring(LocalPlayer) and tostring(Action) == "Complete" then
                ShouldReel = false
            end

            if NotificationListener then
                NotificationListener:Disconnect()
                NotificationListener = nil
            end

            NotificationListener = NotificationRemote.OnClientEvent:Connect(
                function (Data, Title, Description)
                    if string.find(Title, "Caught") then
                        print("AutoFish | Caught. Stopping reel")

                        local ParsedJSON = HttpService:JSONDecode(Data)

                        if ParsedJSON then
                            getgenv().LastCatch = ParsedJSON
                        end

                        StopReeling()
                    end
                end
            )
        end
    )

    while ShouldReel do
        local EquippedRod = GetEquippedRod()

        if not EquippedRod then
            ShouldReel = false
            print("AutoFish | No rod equipped")
            StopReeling()
            break
        end

        ToolActionRemote:FireServer(EquippedRod)

        -- Why is default the actual value?
        local MinCPS = getgenv().ReelSpeedSlider.Value.Default - getgenv().ReelSpeedRandomnessSlider.Value.Default
        local MaxCPS = getgenv().ReelSpeedSlider.Value.Default + getgenv().ReelSpeedRandomnessSlider.Value.Default
        local ActualCPS = MinCPS + math.random() * (MaxCPS - MinCPS)

        if ActualCPS == 0 or ActualCPS < 0.01 then
            ActualCPS = 0.01
        end

        local RandomReelClickWait = 1.0 / ActualCPS

        print("AutoFish | Waiting", string.format("%.2f", RandomReelClickWait), "seconds", "(" .. ActualCPS .. " CPS)")
        task.wait(RandomReelClickWait)
    end
end

getgenv().StartLogging = function ()
    FreezeCharacter()
    print("AutoFish | Listening to FishEvent")

    FishEventListener = FishEventRemote.OnClientEvent:Connect(
        function (Player, Action, Item, Data)
            if tostring(Player) == tostring(LocalPlayer) then
                print("AutoFish | FishEvent:\n - Action:", tostring(Action), "\n - Item:", tostring(Item), "\n")
            end

            if tostring(Player) == tostring(LocalPlayer) and tostring(Action) == "Bite" then
                if not ShouldReel then
                    print("AutoFish | Your fish bite detected. Item:", tostring(Item))
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

getgenv().StopAll = function ()
    UnfreezeCharacter()
    print("AutoFish | Stopping all")
    ShouldReel = false

    if CompleteListener then
        CompleteListener:Disconnect()
        CompleteListener = nil
    end

    if NotificationListener then
        NotificationListener:Disconnect()
        NotificationListener = nil
    end

    if FishEventListener then
        FishEventListener:Disconnect()
        FishEventListener = nil
    end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local RunService = game:GetService("RunService")

local WHITE = Color3.new(1, 1, 1)

local FarColor = Color3.fromRGB(0, 255, 0)
local MidColor = Color3.fromRGB(255, 255, 0)
local NearColor = Color3.fromRGB(255, 0, 0)

local ESPRunning = false
local ESPFolder = nil
local Connections = {}

local function CreateNameTag ()
	local TagGui = Instance.new("BillboardGui")

	TagGui.Name = "ESPNameTag"
	TagGui.Size = UDim2.new(0, 200, 0, 50)
	TagGui.AlwaysOnTop = true
	TagGui.StudsOffset = Vector3.new(0, 1.8, 0)

	local Tag = Instance.new("TextLabel", TagGui)

	Tag.Name = "Tag"
	Tag.BackgroundTransparency = 1
	Tag.Position = UDim2.new(0, -50, 0, 0)
	Tag.Size = UDim2.new(0, 300, 0, 20)
	Tag.Font = Enum.Font.SourceSansBold
	Tag.TextSize = 15
	Tag.TextColor3 = WHITE
	Tag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	Tag.TextStrokeTransparency = 0.4
	Tag.TextScaled = false

	local Distance = Instance.new("TextLabel", TagGui)

	Distance.Name = "Distance"
	Distance.BackgroundTransparency = 1
	Distance.Position = UDim2.new(0, -50, 0, 18)
	Distance.Size = UDim2.new(0, 300, 0, 20)
	Distance.Font = Enum.Font.SourceSans
	Distance.TextSize = 14
	Distance.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	Distance.TextStrokeTransparency = 0.5
	Distance.TextScaled = false

	return TagGui
end

local function GetDistanceColor (Distance)
	if Distance < 1000 then
		return NearColor
	elseif Distance < 5000 then
		return MidColor
	else
		return FarColor
	end
end

local function UpdateNameTag (NameTag, PlayerName, Distance)
	local Tag = NameTag:FindFirstChild("Tag")
	local Dist = NameTag:FindFirstChild("Distance")

	if Tag then Tag.Text = PlayerName end
	if Dist then
		Dist.Text = string.format("%.0f studs", Distance)
		Dist.TextColor3 = GetDistanceColor(Distance)
	end
end

local function LoadCharacter (Player, Holder)
	if not ESPRunning then return end

	repeat
	    task.wait()
	until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

	Holder:ClearAllChildren()

	local Char = Player.Character
	local Head = Char:FindFirstChild("Head")

	if not Head then
	    return
	end

	local TagGui = CreateNameTag()
	TagGui.Adornee = Head
	TagGui.Parent = Holder

	local Conn = nil

	Conn = RunService.RenderStepped:Connect(
        function()
            if not ESPRunning or not Char or not Char:FindFirstChild("HumanoidRootPart") then
                Conn:Disconnect()
                return
            end

            local HRP = Char.HumanoidRootPart
            local LocalChar = LocalPlayer.Character

            if not LocalChar or not LocalChar:FindFirstChild("HumanoidRootPart") then
                return
            end

            local Dist = (LocalChar.HumanoidRootPart.Position - HRP.Position).Magnitude
            UpdateNameTag(TagGui, Player.Name, Dist)
        end
    )

	table.insert(Connections, Conn)
end

local function ESPLoadPlayer (Player)
	if not ESPRunning then
        return
    end

	local Holder = Instance.new("Folder")
	Holder.Name = Player.Name
	Holder.Parent = ESPFolder

	local function OnCharacterAdded ()
		LoadCharacter(Player, Holder)
	end

	local function OnCharacterRemoving ()
		Holder:ClearAllChildren()
	end

	table.insert(Connections, Player.CharacterAdded:Connect(OnCharacterAdded))
	table.insert(Connections, Player.CharacterRemoving:Connect(OnCharacterRemoving))

	OnCharacterAdded()
end

local function ESPUnloadPlayer (Player)
	local Holder = ESPFolder:FindFirstChild(Player.Name)

	if Holder then
	    Holder:Destroy()
	end
end

getgenv().ESPEnable = function ()
	if ESPRunning then
	    return
	end

	ESPRunning = true

	ESPFolder = Instance.new("Folder", game.CoreGui)
	ESPFolder.Name = "ESP"

	-- Load existing players
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer then
			ESPLoadPlayer(Player)
		end
	end

	table.insert(
	    Connections,
	    Players.PlayerAdded:Connect(
    	    function(Player)
        		if Player ~= LocalPlayer then
        			ESPLoadPlayer(Player)
        		end
    	    end
        )
    )

	table.insert(
	    Connections,
	    Players.PlayerRemoving:Connect(
	        function(player)
		        ESPUnloadPlayer(player)
	        end
	    )
    )
end

getgenv().ESPDisable = function ()
	if not ESPRunning then
	    return
	end

	ESPRunning = false

	for _, Player in pairs(Players:GetPlayers()) do
		ESPUnloadPlayer(Player)
	end

	for _, Conn in ipairs(Connections) do
		pcall(
		    function()
		        Conn:Disconnect()
		    end
		)
	end

	Connections = {}

	if ESPFolder then
	    ESPFolder:Destroy()
	end

	ESPFolder = nil
end

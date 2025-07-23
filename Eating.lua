local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolActionRemote = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("ToolAction")

local HungerUpdateListener = nil

local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
local Backpack = LocalPlayer:FindFirstChild("Backpack")
local BackpackScript = require(LocalPlayer.PlayerScripts.Backpack.BackpackScript)

local AmountLabel = PlayerGui
    :WaitForChild("MainGui")
    :WaitForChild("UI")
    :WaitForChild("HUD")
    :WaitForChild("Anchor")
    :WaitForChild("HungerBar")
    :WaitForChild("Back")
    :WaitForChild("Amount")

local NotAcceptableDishColor = Color3.fromRGB(124, 92, 70)

local function OpenAndGetInventory ()
    local Inventory = PlayerGui and PlayerGui:FindFirstChild("Backpack"):FindFirstChild("Backpack"):FindFirstChild("Inventory")

    Inventory.Visible = false
    task.wait()
    if Inventory and not Inventory.Visible then
        BackpackScript:OpenClose()
        task.wait()
    end

    return Inventory
end

local function CloseInventory (Inventory)
    if Inventory.Visible then
        BackpackScript:OpenClose()
    end
end

local OnlyFishFood = false

local function FindDishes ()
    local Dishes = {}
    local Inventory = OpenAndGetInventory()

    if Inventory then
        local UIGridFrame = Inventory:FindFirstChild("ScrollingFrame"):FindFirstChild("UIGridFrame")

        for _, Item in ipairs(UIGridFrame:GetChildren()) do
            if Item then
                local SubTypeMatch = false
                local ColorMatch = false

                -- Check ISubType
                local ISubType = Item:FindFirstChild("ISubType")
                if ISubType and ISubType:IsA("StringValue") then
                    if ISubType.Value == "Meal" then
                        SubTypeMatch = true
                    end
                end

                -- Check View.Figure.Part0.Color
                local View = Item:FindFirstChild("View")
                if View then
                    local Figure = View:FindFirstChild("Figure")
                    if Figure then
                        local Part0 = Figure:FindFirstChild("Part0")
                        if Part0 and Part0:IsA("BasePart") then
                            if Part0.Color ~= NotAcceptableDishColor then
                                ColorMatch = true
                            end
                        end
                    end
                end

                if SubTypeMatch and ColorMatch then
                    local ItemName = Item:FindFirstChild("ToolName") and Item.ToolName.Text

                    if ItemName and (not OnlyFishFood or string.find(ItemName, "Fish")) then
                        print("Dish found:", ItemName)
                        local ToolEquivalent = Backpack and Backpack:FindFirstChild(ItemName)
                        if ToolEquivalent and ToolEquivalent:IsA("Tool") then
                            table.insert(Dishes, ToolEquivalent)
                        end
                    end
                end
            end
        end
    end

    task.wait()
    CloseInventory(Inventory)
    task.wait()

    return Dishes
end

local function EquipFirstDish ()
    local Dishes = FindDishes()
    local FirstDish = Dishes[1]
    LocalPlayer.Character.Humanoid:EquipTool(FirstDish)
    task.wait()

    return FirstDish
end

getgenv().EatDish = function ()
    if HungerUpdateListener then
        HungerUpdateListener:Disconnect()
        HungerUpdateListener = nil
    end

    local DishName = EquipFirstDish().Name
    print("Eating:", DishName)

    local HungerUpdated = false
    HungerUpdateListener = AmountLabel:GetPropertyChangedSignal("Text"):Connect(
        function()
            print("Hunger updated:", AmountLabel.Text)
            HungerUpdated = true
            HungerUpdateListener:Disconnect()
            HungerUpdateListener = nil
        end
    )

    local DishItem = LocalPlayer.Character:WaitForChild(DishName)

    ToolActionRemote:FireServer(DishItem)

    repeat
        task.wait()
    until
        HungerUpdated

    local ParsedAmount = tonumber(AmountLabel.Text)

    if ParsedAmount < 100 then
        task.wait()
        getgenv().EatDish()
    end
end

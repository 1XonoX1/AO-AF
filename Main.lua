-- Setup
getgenv().WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--- Last catch global variable
getgenv().LastCatch = nil

--- GUI global variables
getgenv().AutoFishToggle = nil
getgenv().ReelSpeedSlider = nil
getgenv().ReelSpeedRandomnessSlider = nil
getgenv().DiscordWebhookToggle = nil
getgenv().DiscordWebhookTokenInput = nil

getgenv().LoadDropdown = nil

local HttpService = game:GetService("HttpService")

-- Discord Code

loadstring(game:HttpGet("https://raw.githubusercontent.com/1XonoX1/AO-AF/refs/heads/main/Discord.lua"))

-- Main Code

loadstring(game:HttpGet("https://raw.githubusercontent.com/1XonoX1/AO-AF/refs/heads/main/Fishing.lua"))

-- ESP Code

loadstring(game:HttpGet("https://raw.githubusercontent.com/1XonoX1/AO-AF/refs/heads/main/ESP.lua"))

-- UI Code

local Window = getgenv().WindUI:CreateWindow({
    Title = "Auto Fish | By XonoX",
    Icon = "ship",
    Author = "For Arcane Odyssey",
    Folder = "AutoFishAO",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    User = {
        Enabled = true,
        Anonymous = false
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

Window:SetToggleKey(Enum.KeyCode.Y)

-- Buttons
Window:CreateTopbarButton(
    "Credits",
    "heart-handshake",
    function ()
        Window:Dialog({
            Icon = "heart-handshake",
            Title = "Credits",
            Content = "WindUI by Footagesus",
            Buttons = {
                {
                    Title = "Copy Github",
                    Callback = function ()
                        setclipboard("https://github.com/Footagesus")
                        getgenv().WindUI:Notify({
                            Title = "Copied link to clipboard",
                            Duration = 5,
                        })
                    end,
                    Variant = "Primary"
                },
                {
                    Title = "Close",
                    Variant = "Secondary"
                }
            }
        })
    end,
    0
)

-- Welcome Tab
local WelcomeTab = Window:Tab({
    Title = "Welcome",
    Icon = "heart"
})

WelcomeTab:Paragraph({
    Title = "Welcome",
    Desc = [[
Thank you for using the Auto Fish script.

❣ If you are going to reuse this script, please credit me and the UI library.

🛠 Feel free to join the Discord server if you are experiencing issues, need support,
or have suggestions for new features.
    ]],
    Image = "ship-wheel"
})

--- Automatic Section
local AutomaticSection = Window:Section({
    Title = "Automatic",
    Opened = true
})

-- Auto Fish Tab
local AutoFishTab = AutomaticSection:Tab({
    Title = "Auto Fish",
    Icon = "fish"
})

local AutoFishToggleOnce = false
getgenv().AutoFishToggle = AutoFishTab:Toggle({
    Title = "Enable",
    Desc = "Toggles automatic fishing.",
    Icon = "check",
    Type = "Toggle",
    Callback = function (state)
        if not AutoFishToggleOnce then
            AutoFishToggleOnce = true
            return
        end

        if state and getgenv().StartLogging then
            getgenv().StartLogging()

            getgenv().WindUI:Notify({
                Title = "Enabled Auto Fish",
                Desc = "Position yourself and throw the bobber once",
                Duration = 5,
            })
        else
            getgenv().StopAll()

            getgenv().WindUI:Notify({
                Title = "Disabled Auto Fish",
                Duration = 5,
            })
        end
    end
})

local AutoFishReelingSection = AutoFishTab:Section({
    Title = "Reeling",
    TextXAlignment = "Left",
    TextSize = 17
})

getgenv().ReelSpeedSlider = AutoFishTab:Slider({
    Title = "Reel Speed",
    Desc = [[
Controls the CPS (Clicks Per Second) that will be sent to reel in the catch.

Not recommended to modify.
]],
    Step = 0.01,
    Value = {
        Min = 1,
        Max = 20,
        Default = 8,
    }
})


getgenv().ReelSpeedRandomnessSlider = AutoFishTab:Slider({
    Title = "Reel Speed Randomness",
    Desc = [[
Controls how much the CPS can vary randomly.

For example, if the speed is set to 8 and randomness is 0.5, the actual CPS will vary randomly between 7.5 and 8.5.
]],
    Step = 0.01,
    Value = {
        Min = 0,
        Max = 5,
        Default = 0.5,
    }
})

local AutoFishWaitSection = AutoFishTab:Section({
    Title = "Waiting",
    TextXAlignment = "Left",
    TextSize = 17
})

getgenv().CastAgainWaitSlider = AutoFishTab:Slider({
    Title = "Cast Again Wait",
    Desc = [[
Controls how many seconds to wait before casting the rod again.
]],
    Step = 1,
    Value = {
        Min = 1,
        Max = 60,
        Default = 8,
    }
})

-- Auto Eat Tab
local AutoEatTab = AutomaticSection:Tab({
    Title = "Auto Eat",
    Icon = "utensils"
})

local AutoEatToggle = AutoEatTab:Toggle({
    Title = "Enable",
    Desc = [[
Toggles auto eating when the hunger reaches a certain level.

Automatically selects the first dish it can find and consumes it. DOES NOT LOOK FOR DISHES THAT NEED TO BE PLACED.

Only works if Auto Fish is enabled.
]],
    Icon = "check",
    Type = "Toggle",
    Callback = function (state)
        -- Set on/off
    end
})

-- Misc Section
local MiscSection = Window:Section({
    Title = "Misc",
    Opened = true
})

-- ESP Tab
local ESPTab = MiscSection:Tab({
    Title = "ESP",
    Icon = "radar"
})

local ESPToggleOnce = false
local ESPToggle = ESPTab:Toggle({
    Title = "Enable",
    Desc = [[
Toggles the ESP.
]],
    Icon = "check",
    Type = "Toggle",
    Callback = function (state)
        if not ESPToggleOnce then
            ESPToggleOnce = true
            return
        end

        if state then
            getgenv().ESPEnable()

            getgenv().WindUI:Notify({
                Title = "Enabled ESP",
                Duration = 5
            })
        else
            getgenv().ESPDisable()

            getgenv().WindUI:Notify({
                Title = "Disabled ESP",
                Duration = 5
            })
        end
    end
})

local TPTab = MiscSection:Tab({
    Title = "TP",
    Icon = "move"
})

local MapPlaces = getgenv().GetMapPlaces()
local TPDropdown = TPTab:Dropdown({
    Title = "Islands",
    Values = MapPlaces,
    AllowNone = false
})

local TPWaitToggle = TPTab:Toggle({
    Title = "Wait Load",
    Desc = "Waits for the island to load when teleporting",
    Type = "Toggle",
    Icon = "check",
    Default = true
})

local TPButton = TPTab:Button({
    Title = "Teleport",
    Desc = "Teleports the player to the selected island",
    Callback = function ()
        if TPDropdown.Value == nil then
            return
        end

        getgenv().TPToIsland(TPDropdown.Value, TPWaitToggle.Value)
    end
})

-- Discord Tab
local DiscordTab = MiscSection:Tab({
    Title = "Discord Webhook",
    Icon = "message-circle-more"
})

getgenv().DiscordWebhookToggle = DiscordTab:Toggle({
    Title = "Enable",
    Desc = [[
Toggles sending messages to the Discord webhook when catching something.
]],
    Icon = "check",
    Type = "Toggle",
    Callback = function (state)
        getgenv().WindUI:Notify({
            Title = ((state and "Enabled") or (not state and "Disabled")) .. " Discord Webhook"
        })
    end
})

local DiscordWebhookToggleOnce = false
getgenv().DiscordWebhookTokenInput = DiscordTab:Input({
    Title = "Discord Webhook URL",
    Desc = [[
The full URL/Token of the Discord webhook. AutoFish will not send any messages unless the URL is provided, even if the module is enabled.

For example: https://discord.com/api/webhooks/WEBHOOOK_ID/WEBHOOK_TOKEN
]],
    Value = "",
    InputIcon = "link",
    Type = "Input",
    Placeholder = "https://discord.com/api/webhooks/WEBHOOOK_ID/WEBHOOK_TOKEN",
    Callback = function (input)
        local IsValid = string.match(input, "^https://discord%.com/api/webhooks/%d+/.+$")

        if not IsValid then
            if DiscordWebhookToggleOnce then
                print("AutoFish | Webhook URL is not valid")
                getgenv().WindUI:Notify({
                    Title = "Webhook URL is not valid",
                    Duration = 5
                })
            else
                DiscordWebhookToggleOnce = true
            end

            getgenv().DiscordWebhookToggle:Set(false)
            getgenv().DiscordWebhookToggle:Lock()
        else
            print("AutoFish | Webhook URL is valid")
            getgenv().WindUI:Notify({
                Title = "Webhook URL is valid",
                Duration = 5
            })

            getgenv().DiscordWebhookToggle:Unlock()
        end
    end
})

Window:SelectTab(1)

Window:OnDestroy(
    function ()
        print("AutoFish | Unloading")

        getgenv().StopAll()

        getgenv().ESPDisable()

        getgenv().WindUI:Notify({
            Title = "Disabled all modules",
            Duration = 5
        })
    end
)

-- Config Manager

local ConfigManager = Window.ConfigManager
local FolderPath = "WindUI/AutoFishAO/config"

makefolder(FolderPath)

local function LoadFile (FileName)
    local FilePath = FolderPath .. "/" .. FileName .. ".json"
    if isfile(FilePath) then
        local JSONData = readfile(FilePath)
        return HttpService:JSONDecode(JSONData)
    end
end

local ConfigSection = Window:Section({
    Title = "Config",
    Opened = true
})

local ConfigTab = ConfigSection:Tab({
    Title = "Configuration",
    Icon = "settings",
    Locked = false
})

local SaveSection = ConfigTab:Section({
    Title = "Save",
    TextXAlignment = "Left",
    TextSize = 17
})

local SaveInputValue = nil
local SaveInput = ConfigTab:Input({
    Title = "File Name",
    Desc = [[
The name of the configuration file to save
]],
    Value = "",
    InputIcon = "file-pen",
    Type = "Input",
    Placeholder = "Default Configuration",
    Callback = function (input)
        SaveInputValue = input
    end
})

local SaveButton = ConfigTab:Button({
    Title = "Save/Overwrite Configuration",
    Desc = "Saves/Ovewrites the current configuration to a file",
    Callback = function ()
        if not SaveInputValue or SaveInputValue == "" then
            getgenv().WindUI:Notify({
                Title = "Please input a valid name",
                Duration = 5
            })

            return
        end

        local ConfigData = ConfigManager:CreateConfig(SaveInputValue)

        ConfigData:Register("AutoFishToggle", getgenv().AutoFishToggle)
        ConfigData:Register("ReelSpeedSlider", getgenv().ReelSpeedSlider)
        ConfigData:Register("ReelSpeedRandomnessSlider", getgenv().ReelSpeedRandomnessSlider)
        ConfigData:Register("CastAgainWaitSlider", getgenv().CastAgainWaitSlider)
        ConfigData:Register("ESPToggle", ESPToggle)
        ConfigData:Register("DiscordWebhookToggle", getgenv().DiscordWebhookToggle)
        ConfigData:Register("DiscordWebhookTokenInput", getgenv().DiscordWebhookTokenInput)

        ConfigData:Save()
        ConfigData = nil

        getgenv().WindUI:Notify({
            Title = "Saved configuration",
            Duration = 5
        })

        if getgenv().LoadDropdown then
            getgenv().LoadDropdown:Refresh(ConfigManager:AllConfigs())
        end
    end
})

local LoadSection =  ConfigTab:Section({
    Title = "Load",
    TextXAlignment = "Left",
    TextSize = 17
})

local ConfigFiles = ConfigManager:AllConfigs()

local SelectedOption = nil
getgenv().LoadDropdown = ConfigTab:Dropdown({
    Title = "Configuration Files",
    Values = ConfigFiles,
    AllowNone = false,
    Callback = function (option)
        SelectedOption = option
    end
})

local LoadButton = ConfigTab:Button({
    Title = "Load Configuration",
    Desc = "Loads the selected configuration",
    Callback = function ()
        if not SelectedOption then
            getgenv().WindUI:Notify({
                Title = "Please select a file",
                Duration = 5
            })

            return
        end

        local JSONData = LoadFile(SelectedOption)

        getgenv().DiscordWebhookTokenInput:Set(JSONData.Elements.DiscordWebhookTokenInput.value)
        getgenv().DiscordWebhookToggle:Set(JSONData.Elements.DiscordWebhookToggle.value)

        ESPToggle:Set(JSONData.Elements.ESPToggle.value)

        getgenv().CastAgainWaitSlider:Set(JSONData.Elements.CastAgainWaitSlider.value)
        getgenv().ReelSpeedRandomnessSlider:Set(JSONData.Elements.ReelSpeedRandomnessSlider.value)
        getgenv().ReelSpeedSlider:Set(JSONData.Elements.ReelSpeedSlider.value)
        getgenv().AutoFishToggle:Set(JSONData.Elements.AutoFishToggle.value)

        getgenv().WindUI:Notify({
            Title = "Loaded configuration",
            Duration = 5
        })
    end
})

local UpdateListButton = ConfigTab:Button({
    Title = "Update Configuration List",
    Desc = "Updates the configuration list",
    Callback = function ()
        getgenv().LoadDropdown:Refresh(ConfigManager:AllConfigs())
    end
})

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Auto Fish | By Xono",
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
                        WindUI:Notify({
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
local AutoFishToggle = AutoFishTab:Toggle({
    Title = "Enable",
    Desc = "Starts automatically fishing.",
    Icon = "check",
    Type = "Toggle",
    Callback = function (state)
        if not AutoFishToggleOnce then
            AutoFishToggleOnce = true
            return
        end
        
        if state and StartLogging then
            AutoFishEnabled = true
            StartLogging()
            
            WindUI:Notify({
                Title = "Enabled Auto Fish",
                Duration = 5,
            })
        else
            AutoFishEnabled = false
            StopAll()
            
            WindUI:Notify({
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

local ReelSpeedSlider = AutoFishTab:Slider({
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
    },
    Callback = function (value)
        ReelSpeedValue = value
    end
})


local ReelSpeedRandomnessSlider = AutoFishTab:Slider({
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
    },
    Callback = function (value)
        ReelSpeedRandomnessValue = value
    end
})

local AutoFishWaitSection = AutoFishTab:Section({ 
    Title = "Waiting",
    TextXAlignment = "Left",
    TextSize = 17
})

local CastAgainWaitSlider = AutoFishTab:Slider({
    Title = "Cast Again Wait",
    Desc = [[
Controls how many seconds to wait before casting the rod again.
]],
    Step = 1,
    Value = {
        Min = 0,
        Max = 60,
        Default = 5,
    },
    Callback = function (value)
        SecondsWaitForReelAgain = value
    end
})

-- Auto Eat Tab
local AutoEatTab = AutomaticSection:Tab({
    Title = "Auto Eat",
    Icon = "utensils"
})

local AutoEatToggle = AutoEatTab:Toggle({
    Title = "Enable",
    Desc = [[
Enables auto eating when the hunger reaches a certain level.

Automatically selects the first dish it can find and consumes it. DOES NOT LOOK FOR DISHES THAT NEED TO BE PLACED.

Only works if Auto Fish is enabled.
]],
    Icon = "check",
    Type = "Toggle",
    Locked = true,
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
local DiscordTab = MiscSection:Tab({
    Title = "ESP",
    Icon = "radar"
})

-- Discord Tab
local DiscordTab = MiscSection:Tab({
    Title = "Discord Webhook",
    Icon = "message-circle-more"
})

Window:SelectTab(1)

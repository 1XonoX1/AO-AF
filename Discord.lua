local DefaultWebhookAuthor = "AutoFish | By XonoX"

local HttpService = game:GetService("HttpService")

local Request = http_request or request or (http and http.request)

if not Request then
    getgenv().WindUI:Notify({
        Title = "There is no available library for HTTP requests, Discord webhooks will be disabled",
        Duration = 5
    })
end

getgenv().SendWebhook = function ()
    if not getgenv().DiscordWebhookToggle.Value then
        return
    end

    -- local JSONData = HttpService:JSONEncode({
    --     embeds = [
    --         {
    --             title = "Caught: " .. getgenv().LastCatch
    --         }
    --     ],
    --     username = "AutoFish | By XonoX",
    --     attachments = {}
    -- })

    local Title = (getgenv().LastCatch and (getgenv().LastCatch.Alt .. " ") or "") .. getgenv().LastCatch.Name
    local CaughAt = os.date("*t", getgenv().LastCatch.Caught)
    local Description = string.format(
        "Caught at: %02d/%02d/%d %02d:%02d:%02d",
        CaughAt.day,
        CaughAt.month,
        CaughAt.year,
        CaughAt.hour,
        CaughAt.min,
        CaughAt.sec
    )

    if Request then
        local Response = Request({
            Url = getgenv().DiscordWebhookTokenInput.Value,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = "{\"content\":null,\"embeds\":[{\"title\":\"Caught: " .. Title .."\",\"description\": \"" .. Description .."\",\"color\":16777214}],\"username\":\"AutoFish | By XonoX\",\"attachments\":[]}"
        })

        print("AutoFish | Webhook message sent. Status code:", Response.StatusCode)
    end
end

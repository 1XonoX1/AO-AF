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

    if Request then
        local Response = Request({
            Url = getgenv().DiscordWebhookTokenInput.Value,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = "{\"content\":null,\"embeds\":[{\"title\":\"Caught: " .. getgenv().LastCatch .."\",\"color\":16777214}],\"username\":\"AutoFish | By XonoX\",\"attachments\":[]}"
        })

        print("AutoFish | Webhook message sent. Status code:", Response.StatusCode)
    end
end

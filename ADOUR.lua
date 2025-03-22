getgenv().animpos = 1.755
getgenv().underground = -2.6

local enabled = false
local runserv = game:GetService("RunService")
local lplr = game:GetService("Players").LocalPlayer
local mouse = lplr:GetMouse()
local animation = Instance.new("Animation")
animation.AnimationId = "http://www.roblox.com/asset/?id=15693621070"
local danceTrack
mouse.KeyDown:Connect(function(key)
    if key == string.lower("k") then
        pcall(function()
            if enabled == false then
                enabled = true
                danceTrack = lplr.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
                danceTrack.Looped = false
                danceTrack:Play(.1, 1, 0)
            elseif enabled then
                enabled = false
                danceTrack:Stop()
                danceTrack:Destroy()
            end
        end)
        print(enabled and "spinning the meat" or "not spinning anymore")
    end
end)
local dysenc = {}
local temp = 1
runserv.Heartbeat:Connect(function()
    temp = temp + 1
    if enabled and lplr.Character and lplr.Character.HumanoidRootPart then
        danceTrack.TimePosition = animpos
        dysenc[1] = lplr.Character.HumanoidRootPart.CFrame
        dysenc[2] = lplr.Character.HumanoidRootPart.AssemblyLinearVelocity
        local SpoofThis = lplr.Character.HumanoidRootPart.CFrame
        SpoofThis = SpoofThis + Vector3.new(0, getgenv().underground, 0)
        lplr.Character.HumanoidRootPart.CFrame = SpoofThis
        runserv.RenderStepped:Wait()
        if lplr.Character and lplr.Character.HumanoidRootPart then
            lplr.Character.HumanoidRootPart.CFrame = dysenc[1]
            lplr.Character.HumanoidRootPart.AssemblyLinearVelocity = dysenc[2]
        end
    end
end)

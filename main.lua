
local replStorage = game:GetService("ReplicatedStorage")
local remotes = replStorage:WaitForChild("Remotes")
local network = nil
if game.PlaceId == 9503261072 then
    network = replStorage:WaitForChild("Network")
end
local localPlayer = game:GetService("Players").LocalPlayer
local playerGui = localPlayer.PlayerGui

local tdxScript = {}

local function verboseLog(message)
    if getfenv().enableVerbose == true then
        print("AUTOFARM | "..message)
    end
end
-- IN LOBBY --

function tdxScript.StartLogging()
end

function tdxScript.JoinMap(mapName)
    if game.PlaceId == 9503261072 then
        while task.wait() do
            local display = nil
            local chosenDisplay = nil
            for i,v in pairs(workspace:WaitForChild("APCs"):GetChildren()) do
                display = v.mapdisplay.screen.displayscreen
                if display.map.Text == mapName then
                    if display.plrcount.Text == "0/4" then
                        print("map is available and there are no people in it")
                        chosenDisplay = display
                        localPlayer.Character.HumanoidRootPart.CFrame = v.APC.Detector.CFrame
                        break
                    end
                end
            end
            task.wait(1)
            if chosenDisplay then
                repeat task.wait()
                until tonumber(string.match(display.plrcount.Text, "^(%d+)/")) >= 2 and 0 < tonumber(string.match(display.plrcount.Text, "^(%d+)/"))
               network.LeaveQueue:FireServer()
            end
        end
    end
end

function tdxScript:SetLoadout(tower1, tower2, tower3, tower4, tower5, tower6)
    if game.PlaceId == 9503261072 then
        local args = {
            [1] = {
                [1] = tower1,
                [2] = tower2,
                [3] = tower3,
                [4] = tower4,
                [5] = tower5,
                [6] = tower6
            }
        }
        
        network:WaitForChild("UpdateLoadout"):FireServer(unpack(args))
    end
end
-- IN GAME --

function tdxScript.Start(Difficulty)
    remotes:WaitForChild("DifficultyVoteCast"):FireServer(Difficulty)
    task.wait()
    remotes:WaitForChild("DifficultyVoteReady"):FireServer()
end

function tdxScript:placeTower(tower, strangeValue, location, tryUntilSucceed)
    local args = { strangeValue, tower, location, 0 }
    local towerCountText = playerGui.Interface.BottomBar.TowerCountFrame.Text.Text
    local currentPlacedTowers = string.match(towerCountText, "^(%d+)/")

    remotes:WaitForChild("PlaceTower"):InvokeServer(unpack(args))

    local newTowerCountText = playerGui.Interface.BottomBar.TowerCountFrame.Text.Text
    local newPlacedTowers = string.match(newTowerCountText, "^(%d+)/")

    if currentPlacedTowers < newPlacedTowers then
        verboseLog("Placed tower")
    else
        if tryUntilSucceed then
            repeat task.wait()
                newPlacedTowers = string.match(newTowerCountText, "^(%d+)/")
            until currentPlacedTowers < newPlacedTowers
        end
    end
end

function tdxScript:SellTower(towerId)
    remotes:WaitForChild("SellTower"):FireServer(towerId)
end

function tdxScript:SkipWave()
    remotes:WaitForChild("SkipWaveVoteCast"):FireServer(true)
end

return tdxScript

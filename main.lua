local replStorage = game:GetService("ReplicatedStorage")
local remotes = replStorage:WaitForChild("Remotes")

local localPlayer = game:GetService("Players").LocalPlayer
local playerGui = localPlayer.PlayerGui

local tdxScript = {}

local args = {
    [1] = "Easy"
}

remotes:WaitForChild("DifficultyVoteCast"):FireServer(unpack(args))

local function verboseLog(message)
    if getfenv().enableVerbose == true then
        print("AUTOFARM | "..message)
    end
end

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

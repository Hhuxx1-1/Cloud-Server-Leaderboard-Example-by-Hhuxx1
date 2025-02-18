# Cloud-Server-Leaderboard-Example-by-Hhuxx1
<a href="https://github.com/Hhuxx1-1/Cloud-Server-Leaderboard-Example-by-Hhuxx1/blob/main/Leaderboard%20Aura%20%2B9999.lua"> This Script</a>
implements a Killstreak Leaderboard System in Lua for a multiplayer game using CloudSever for data storage and Graphics for UI display. Below is a step-by-step breakdown of how the script functions:
<div>
<h3> Host Pov :</h3>
<img src="https://github.com/user-attachments/assets/e7c90224-a549-409e-bafb-b0ce1a2a4fbf" style="width:500px;height:auto;">
<h3> Client Pov :</h3>
<img src="https://github.com/user-attachments/assets/7b59d430-5199-45b5-bf1c-9eaccf7873b9" style="width:500px;height:auto;">
</div>

## 1. Leaderboard Setup

Setup the Variable on Trigger Menu as Follows:
<img src="https://github.com/user-attachments/assets/211c4991-2469-4053-9451-94cc6ed4d72c" style="width:80%;height:auto;">

The script initializes a leaderboard table (leaderboard) with:
```lua
leaderboard.data = {} → Stores leaderboard data.
leaderboard.pos = {x=-10, y=64, z=0} → The position where the leaderboard UI is displayed.
leaderboard.name = "KillStreak_Hhuxx1_00" → The name of the leaderboard in CloudSever.
```
It also defines a function:
```lua
leaderboard.insert = function(i, v)
    leaderboard.data[i] = v
end
```
This function inserts player data (v) at index (i) in the leaderboard.

## 2. Reset Rank Function
```lua
leaderboard.resetRank = function()
    CloudSever:ClearOrderData(leaderboard.name);
end
```
Clears the leaderboard data on the CloudSever, effectively resetting the rankings.

## 3. Handling Server Data Fetching
Failure Handling Function
```lua
local function Failure(msg)
    for i, a in ipairs(graph) do 
        Graphics:updateGraphicsTextById(a, "#R"..msg, 15, 76);
    end 
end
```
Displays an error message on the leaderboard UI if data retrieval fails.
Loading Server Data
```lua
leaderboard.loadServerData = function()
    local callback = function (ret, value)
        if ret and value then
            for ix, v in pairs(value) do
                leaderboard.insert(ix, v)
            end
        end
    end
    local ret = CloudSever:getOrderDataIndexArea(leaderboard.name, -70, callback);
    if ret ~= ErrorCode.OK then
        reqtime = 1200;
    end
end
```
Calls ```CloudSever:getOrderDataIndexArea()``` to fetch the top 70 players in descending order.
If the request fails, the retry interval (reqtime) is set to 1200 seconds (20 minutes).

## 4. Initializing the Leaderboard UI
Offset Positions for Display
The offset table determines the positioning of the leaderboard entries.

``` lua
local offset = {
    {z=-7,y=5},{z=-7,y=4},{z=-7,y=3},{z=-7,y=2},{z=-7,y=1},
    {z=-3,y=5},{z=-3,y=4},{z=-3,y=3},{z=-3,y=2},{z=-3,y=1},
    ...
}
```
Each entry has a z and y coordinate shift.
midPos = {y=7, z=1} determines the title position.
### Function to Display Leaderboard UI :
```lua
local function initLeaderBoardOnPos()
    local pos = leaderboard.pos
    for i, a in ipairs(offset) do 
        local ox, oy, oz = a.x or 0, a.y or 0, a.z or 0
        local x, y, z = pos.x+ox, pos.y+oy, pos.z+oz
        local grapid = Graphics:makeGraphicsText([[  Loading...   ]], 15, 80, i)
        local _, di = Graphics:createGraphicsTxtByPos(x, y, z, grapid, 0, 0)
        graph[i] = di
    end 
    local grapido1 = Graphics:makeGraphicsText([[   #GKillstreak ]], 19, 80, #offset+1)
    local grapido2 = Graphics:makeGraphicsText([[  #GLeaderboard ]], 19, 80, #offset+2)
    local _, di = Graphics:createGraphicsTxtByPos(pos.x, pos.y+8, pos.z, grapido1, 0, 0)
    local _, di = Graphics:createGraphicsTxtByPos(pos.x, pos.y+7, pos.z, grapido2, 0, 0)
end
```
Creates text graphics at various positions for displaying leaderboard ranks.
Initializes two header texts: "Killstreak" and "Leaderboard."

## 5. Displaying the Leaderboard Data
``` lua
leaderboard.display = function()
    local ret = 0
    for i, a in ipairs(leaderboard.data) do 
        ret = i
        local playerName, uiid = a.nick, a.k
        if not playerName then playerName = "Unknown Player" end
        local st = "#Y[#R"..i.."#Y] #W"..playerName.." : #G"..a.v.." Kills "..[[  ]]
        Graphics:updateGraphicsTextById(graph[i], st, 15, 76)
    end 
    Graphics:snycGraphicsInfo2Client()
    return ret
end
```
Iterates over leaderboard.data and updates the leaderboard UI with:
```
Player Rank
Player Name
Killstreak Count
```
Calls ```Graphics:snycGraphicsInfo2Client()``` to update client UI.

## 6. Running the Leaderboard System
Game Loop Handling
```lua
local isGame = true 

local function doSleep()
    return threadpool:wait(reqtime)
end

ScriptSupportEvent:registerEvent("Game.Start", function(e)
    initLeaderBoardOnPos()
    -- This is Not recommended to use. Please use Game.RunTime Instead;
    while isGame do
        doSleep()
        local success, err = pcall(function() leaderboard.loadServerData() end)
        if not success then Failure("[1] Error in loadServerData: " .. err) end

        local r
        success, err = pcall(function() r = leaderboard.display() end)
        if not success then Failure("[3] Error in display: " .. err) end

        if r < 1 then
            local buffing = ""
            for i = 0, math.random(1, 4) do buffing = buffing.."." end
            Failure("#W[4] Loading"..buffing..[[ ]])
        end
    end 
end)
```
Runs an infinite loop (while isGame do ... end) that:
Waits for reqtime seconds.
Loads leaderboard data (leaderboard.loadServerData()).
Updates leaderboard UI (leaderboard.display()).
Displays loading dots if no data is present.
## Stopping the Game Loop
```lua
ScriptSupportEvent:registerEvent("Game.End", function()
    isGame = false
end)
```
Stops the loop when the game ends.

## 7. Admin Commands for Resetting Leaderboard
```lua
ScriptSupportEvent:registerEvent("Player.NewInputContent", function(e)
    local playerid = e.eventobjid
    local Admin = 1029380338
    local content = e.content
    if playerid == Admin then 
        if content == "CODE:RESET_RANK" then 
            leaderboard.resetRank()
        end 
    end 
end)
```
Listens for player chat input.
If the sender is the Admin (ID: 1029380338) and types "CODE:RESET_RANK", the leaderboard is cleared.



local leaderboard = {};leaderboard.data = {};
leaderboard.pos = {    x=-10,y=64,z=0   }
leaderboard.name = "KillStreak_Hhuxx1_00";

leaderboard.insert = function(i,v)
    leaderboard.data[i] = v ; 
end
leaderboard.resetRank = function()
    CloudSever:ClearOrderData(leaderboard.name);
end
local graph = {};
local reqtime = 5;
local function Failure(msg)
    for i,a in ipairs(graph) do 
        Graphics:updateGraphicsTextById(a, "#R"..msg, 15, 76);
    end 
end 

leaderboard.loadServerData = function()
    local callback = function (ret,value)
        --print("Callback : ",ret,value) --ret in here is returning boolean 
        if ret and value then
            for ix,  v in pairs(value) do
                leaderboard.insert(ix,v);
            end
        end
    end
    -- Get Top 70 Descending Value order 
    local ret = CloudSever:getOrderDataIndexArea(leaderboard.name,-70,callback);
    --print(ret);
    if ret == ErrorCode.OK then
        --print('Leaderboard data request successful')
    else
        --Failure("[2] Retrying in ")
        --print(ret,"Leaderboard data request failed")
        reqtime = 1200;
    end
end

local offset = {
    {z=-7,y=5},{z=-7,y=4},{z=-7,y=3},{z=-7,y=2},{z=-7,y=1},
    {z=-3,y=5},{z=-3,y=4},{z=-3,y=3},{z=-3,y=2},{z=-3,y=1},
    {z=1,y=5},{z=1,y=4},{z=1,y=3},{z=1,y=2},{z=1,y=1},
    {z=5,y=5},{z=5,y=4},{z=5,y=3},{z=5,y=2},{z=5,y=1},
    {z=9,y=5},{z=9,y=4},{z=9,y=3},{z=9,y=2},{z=9,y=1},
}
local midPos = {y=7,z=1}

local function initLeaderBoardOnPos()
    local pos = leaderboard.pos;

    for i,a in ipairs(offset) do 
        local ox,oy,oz = a.x or 0 , a.y or 0 , a.z or 0;
        local x,y,z = pos.x+ox,pos.y+oy,pos.z+oz;
        local grapid = Graphics:makeGraphicsText([[  Loading...   
        ]], 15, 80, i);
        local _,di = Graphics:createGraphicsTxtByPos(x,y,z,grapid, 0,0)
        graph[i]=di;
    end 
    local grapido1 = Graphics:makeGraphicsText([[   #GKillstreak      
    ]], 19, 80, #offset+1);
    local grapido2 = Graphics:makeGraphicsText([[  #GLeaderboard        
    ]], 19, 80, #offset+2);
    local mox,moy,moz = midPos.x or 0 , midPos.y or 0 , midPos.z or 0;
    local _,di = Graphics:createGraphicsTxtByPos(pos.x+mox,pos.y+moy+1,pos.z+moz,grapido1, 0,0)
    local _,di = Graphics:createGraphicsTxtByPos(pos.x+mox,pos.y+moy,pos.z+moz,grapido2, 0,0)
end


leaderboard.display = function()
    local ret = 0;
    --print(leaderboard.data);
    for i,a in ipairs(leaderboard.data) do 
        ret=i;
        local playerName,uiid = a.nick,a.k;
        if(playerName==nil)then playerName = "Unknown Player" 
        print(a);
        end;
        local st="#Y[#R"..i.."#Y] #W"..playerName.." : #G"..a.v.." Kills "..[[         
        ]];
        Graphics:updateGraphicsTextById(graph[i], st, 15, 76);
        --Chat:sendSystemMsg(st,1029380338);
    end 
    Graphics:snycGraphicsInfo2Client();
    return ret;
end

local isGame = true ;

local function  doSleep()
    return threadpool:wait(reqtime);
end

ScriptSupportEvent:registerEvent([=[Game.Start]=]
    ,function(e)
        initLeaderBoardOnPos()
    while isGame do
        doSleep(); 
           -- Safely load server data
    local success, err = pcall(function()
        leaderboard.loadServerData()
    end)
    if not success then
        Failure("[1] Error in loadServerData: " .. err)
        --print(err);
    end

    -- Safely display leaderboard
    local r
    success, err = pcall(function()
        r = leaderboard.display()
    end)
    if not success then
        Failure("[3] Error in display: " .. err)
        --print(err);
    end

    -- Check display result
    if r < 1 then
        --print(r);
        local buffing = "";
        for i=0,math.random(1,4) do buffing= buffing..".";end 
        Failure("#W[4] Loading"..buffing..[[

        ]]);
    end

    end 
end) 

ScriptSupportEvent:registerEvent([=[Game.End]=], function()
    isGame = false;
end)

ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=],function(e)
    local playerid = e.eventobjid;
    local Admin = 1029380338;
    local content = e.content;
    if(playerid==Admin)then 
        if(content=="CODE:RESET_RANK")then 
            leaderboard.resetRank()
        end 
    end 
end)


easy21State = {}
function easy21State: new(state)
  if not state then
    local new_state = {playerNum = 0, dealerNum = 0, terminal = false}
    self.__index = self
    return setmetatable(new_state, self)
  else
    local new_state = {playerNum = state.playerNum, dealerNum = state.dealerNum, terminal = state.terminal}
    self.__index = self
    return setmetatable(new_state, self)
  end
end

function easy21State: initialize()
  self.playerNum =  math.random(1,10)
  self.dealerNum = math.random(1,10)
end

function easy21State: step(action)
  dealerStickThreshold = 17
  reward = 0
  nextstate = easy21State: new(self)
  
  if action == 1 then -- 'hit'
    --draw
    nextstate.playerNum = self.playerNum + draw()
    -- check
    if checkBust(nextstate.playerNum) then
      reward = -1
      nextstate.terminal = true
    end
    
  elseif action == 2 then -- 'stick'
    --draw
    while nextstate.dealerNum < dealerStickThreshold
          and nextstate.dealerNum >= 1 do 
      nextstate.dealerNum = nextstate.dealerNum + draw()
    end
    -- check
      if checkBust(nextstate.dealerNum) then
        reward = 1
        nextstate.terminal = true
      else
        if nextstate.dealerNum > nextstate.playerNum then
          reward = -1
        elseif nextstate.dealerNum < nextstate.playerNum then
          reward = 1
        else
          reward = 0        
        end
        nextstate.terminal = true
      end
  end
  
  return nextstate, reward
  
end

function draw()
  cardNum =  math.random(1,10)
  cardColorNum = math.random(3)
  if cardColorNum == 3 then
    return -cardNum
  else
    return cardNum
  end  
end

function checkBust(num)
  if num>21 or num<1 then
    return true
  else
    return false
  end
end
--[[
state = easy21State:new()
state:initialize()
print(state)
nextstate,reward = state:step(2)
print(state)
print(nextstate)
]]--

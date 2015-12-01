actionValue = {}
actionValue.playerStateNum = 21
actionValue.dealerStateNum = 10
actionValue.actionNum = 2
actionValue.LUT = torch.Tensor(actionValue.playerStateNum,actionValue.dealerStateNum,actionValue.actionNum):zero()

function actionValue:greedy(state)
  --print(state)
  actions = self.LUT[{{state.playerNum},{state.dealerNum},{}}]
  _, i = torch.max(actions,3)
  --print(y, i[{1,1,1}])
  return i[{1,1,1}]
end

function actionValue:epslonGreedy(state,epslon)

  uniformSample = math.random()
  --print(state)
  if uniformSample > epslon then -- greedy
    --print('greedy action')
    return self:greedy(state)
  else
    --print('random action')
    return math.random(self.actionNum)
  end
  
    
  
end

function actionValue:valueFunction()
  y, i = torch.max(self.LUT,3)
  return y[{{},{},1}]
end

require('step')
monteCarloControl = {}
monteCarloControl.visitedTimes = torch.Tensor(actionValue.playerStateNum,actionValue.dealerStateNum,actionValue.actionNum):zero()
monteCarloControl.stateActionRecord = {}
function monteCarloControl:runEpisode()
  --print('-----------runEpisode------------')
  state = easy21State: new()
  state:initialize()
  
  N0 = 100
  t = 0
  while not state.terminal do
    t = t + 1
    
    currentActionStateVistedTimes = self.visitedTimes[{state.playerNum,state.dealerNum,{}}]
    curentStateVistedTimes = torch.sum(currentActionStateVistedTimes)
    epslon = N0/(N0+curentStateVistedTimes)
    action = actionValue:epslonGreedy(state, epslon)
    --print('t', 'payer', 'dealer', 'action', 'epslon')
    --print(t, state.playerNum,state.dealerNum, action, epslon)
    nextstate, reward = state:step(action)
    self.stateActionRecord[t] = {state = state, action = action, reward = reward, nextstate = nextstate}
    --print(self.stateActionRecord[t].state)
    state = nextstate
    --print('terminal')
    --print(state.terminal)
  end
    
end

function monteCarloControl:update()
  --print('----------update--------------')
  rewardsum = 0
  stateNum = #self.stateActionRecord
  endstate = self.stateActionRecord[stateNum].nextstate
  --print('payer', 'dealer', 'reward')
  --print(endstate.playerNum,endstate.dealerNum, self.stateActionRecord[stateNum].reward)
  --print('payer', 'dealer', 'action')
  for t = stateNum, 1, -1 do 
    state = self.stateActionRecord[t].state
    sp = state.playerNum
    sd = state.dealerNum
    a = self.stateActionRecord[t].action
    --print(sp,sd,a)
    rewardsum = rewardsum + self.stateActionRecord[t].reward
    
    self.visitedTimes[sp][sd][a] = self.visitedTimes[sp][sd][a] + 1
    delta = rewardsum - actionValue.LUT[sp][sd][a]
    alpha = 1/self.visitedTimes[sp][sd][a]
    actionValue.LUT[sp][sd][a] = actionValue.LUT[sp][sd][a]+ alpha*delta
    
  end
  self.stateActionRecord = {} -- reset 
  return rewardsum
end


--[[
gfx = require("gfx.js")
Plot = require("itorch.Plot")
appendGfxToPlot = require("appendGfxToPlot")
appendGfxToPlot(gfx,Plot)
]]--
math.randomseed(os.time())
iterMax = 2e6
itnum = 1e5
rewardmean = 0
for i = 1, iterMax do
  monteCarloControl:runEpisode()
  rewardmean = rewardmean + monteCarloControl:update()
  if i%itnum == itnum-1 then
    print('reward per episode: ', rewardmean/itnum)
    rewardmean = 0
  end
end
--print(actionValue:valueFunction())

require('gnuplot')
gnuplot.figure(1)
gnuplot.title('Value function')
gnuplot.splot(actionValue:valueFunction())
gnuplot.figure(2)
gnuplot.title('Action value function of \'hit\'')
gnuplot.splot(actionValue.LUT[{{},{},1}])
gnuplot.figure(3)
gnuplot.title('Action value function of \'stick\'')
gnuplot.splot(actionValue.LUT[{{},{},2}])







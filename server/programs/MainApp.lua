function MainApp(root)

  dofile(root .. "objects/CommonFunctions.lua")  
  dofile(root .. "objects/LoadPeripherals.lua")
  dofile(root .. "objects/Communicator.lua")

  dofile(root .. "GUI/GUIMessages.lua") 
  
  dofile(root .. "controller/DataController.lua")
  
  dofile(root .. "programs/Configuration.lua")

  self = {}

  local commonF = CommonFunctions()
  local guiMessages = GUIMessages()
  local communicator = Communicator()
  local dataController = DataController(commonF,root)
  
  dataController.load()
  
  local slaves = (dataController.getObjects()).slaveList.getSlaves()
  
  local continue = true

  local tasksIteratorList = {}
  
  local protocolCallsList = {}
  local callers = {}
  
  local save = false
  
  local selectedSlave = nil
  
  local function taskIterator(data)
  
    local function findNextTask(tasks)
	  for i,task in ipairs(tasks) do
		if (not task.complete) then
		  return task
        end			  
      end
	  return nil
    end
	
	local slave = data
	
	coroutine.yield()
  
    while true do
      if (#slave.tasks > 0)	then        	  
        local task = findNextTask(slave.tasks)            			
	    if (task ~= nil) then
		  if (not task.sent) then
		    for i = 1,17 do		
              --print(task.execution .. ": trying for the " .. i .. " time")			
		      rednet.send(slave.id,textutils.serialize(task),slave.protocol)
			  coroutine.yield()
		    end
		    task.sent = true	
            save = true			
	      else
		    coroutine.yield()
		  end
		end
	  end
	  coroutine.yield()
	end
  end
  
  local function addSlave(protocol,id)
    if (slaves[id] == nil) then
      slaves[id] = {["protocol"] = protocol, ["id"] = id, ["tasks"] = {}}
	  tasksIteratorList[id] = coroutine.create(taskIterator)
	  dataController.saveData()
	else
	  slaves[id].protocol = protocol
	  tasksIteratorList[id] = coroutine.create(taskIterator)
	  dataController.saveData()
	end
  end
  
  local function protocolCalls(data)
    
	local function executeNTimes(f,params)
      local data = nil
      for i = 1,10 do
	    data = f(params)   
        if data ~= nil then		  
	      return data,true
        end	 		
        coroutine.yield()		
	  end
	  return nil,false
    end 
	
	local caller = data
	
    local s,m,p = caller[1], caller[2], caller[3]
	caller.randomKey = commonF.randomness(100,999)
	caller.finished = true
	caller.step = 0
	caller.completed = false
	local r = caller.randomKey
	
	coroutine.yield()
	
	local data,status = executeNTimes(
	  function (params) 
		rednet.send(params[1],r,os.getComputerID() .. params[1])
        if (caller.completed) then
          return "finished"
        else		  
          return nil
        end		  
	  end,
	  {s}
	)
	
	coroutine.yield()
	
  end
  
  local function protocolCallsIteratorList()
    while true do
	  if (#callers > 0) then
	    for k,v in ipairs(callers) do	          	
	      if (coroutine.status(protocolCallsList[v[1]]) ~= "dead") then
	        coroutine.resume(protocolCallsList[v[1]],v)
		    coroutine.yield()
		  else	 		  
            protocolCallsList[v[1]] = nil
	      end
        end		
	  end
	  coroutine.yield()
	end	
  end
  
  local function protocolCallsReceiver()  
    local s,m,p = rednet.receive(0.2)
	if (s~=nil and p~=nil) then
	  if (p=="apmtSlaveConnection" and (protocolCallsList[s] == nil or coroutine.status(protocolCallsList[s]) == "dead")) then
	    callers[#callers+1] = {s,m,p}
	    protocolCallsList[s] = coroutine.create(protocolCalls)  
	  end	
    end
    if (#callers > 0) then
      for k,caller in ipairs(callers) do	
        if (protocolCallsList[caller[1]] ~=nil) then			
  		  if (coroutine.status(protocolCallsList[caller[1]]) ~= "dead") then
  		    if (caller.finished ~= nil) then
  	          if (caller.finished) then
  	            if (not caller.completed) then
  	              if (caller.step < 10) then
				    if (s ~= nil) then
  			          if (p == (os.getComputerID() .. caller[1])) then
  			            caller.completed = true
  			            addSlave(os.getComputerID() .. caller[1] .. (caller.randomKey * m), caller[1])
  			          end
					end
					caller.step = caller.step + 1
  		          end
  		        end
  	          end
  		    end
  		  else	   
  	        callers[k] = nil
  	      end
  	    end
  	  end
	end
	if selectedSlave ~= nil then
	  --print(textutils.serialize(selectedSlave))
	  if (tasksIteratorList[selectedSlave.id] ~= nil) then
	    for k,task in ipairs(selectedSlave.tasks) do
	      if task.sent and (not task.complete) then
            --print(selectedSlave.protocol .. " " .. task.execution)		  
			if (s~=nil) then
              --print(p .. " " .. selectedSlave.protocol .. " " .. s)			
		      if (selectedSlave.protocol == p) then
	  	        if (s == selectedSlave.id) then
	  		      local receivedTask = textutils.unserialize(m)
	  	          if receivedTask ~=nil then
				    --print(p .. " " .. selectedSlave.protocol .. " " .. task.execution .. " " .. receivedTask.execution)
	  	            if receivedTask.complete == true and receivedTask.execution==task.execution then
	  		          task.complete = true		
                      task.status = receivedTask.status			
                      save = true	
	  		        end
		          end
	            end
              end				
	        end
	      end
	    end
	  end    
    end	  
  end
  
  local function lastCall()
    
  end 
  
  local function slaveSelector()
    while true do
      for k,slave in pairs(slaves) do	
	    selectedSlave = slave
		coroutine.yield()
	  end
	  coroutine.yield()
	end
  end
  
  local function slavesIterator()
    while true do
	  for k,slave in pairs(slaves) do
		if (tasksIteratorList[slave.id] ~= nil) then
	      coroutine.resume(tasksIteratorList[slave.id],slave)
		  coroutine.yield()
		end
	  end	  
	  coroutine.yield()
	end	
  end
  
  local function patternAction()
    local pcil = coroutine.create(protocolCallsIteratorList)
	local si = coroutine.create(slavesIterator)
	local ss  = coroutine.create(slaveSelector)
	while true do
	  coroutine.resume(ss)
	  protocolCallsReceiver()
	  coroutine.resume(pcil)       
      coroutine.resume(si)	  
      if commonF.keyPressed(0.1) ~= 0 then
		break
      end
	  if save then
	    save = false
		dataController.saveData()		
      end	
	end
  end
  
  local mainCase = commonF.switch{
    [1] = function(x)
      Configuration(root,commonF,dataController,guiMessages)
    end,
    [2] = function(x)
      patternAction()
    end,
	[3] = function(x)
      os.reboot()
    end,
    [4] = function(x)
      continue = false
    end,
    default = function (x) continue = false end
  }
  
  local function menu()
    guiMessages.showHeader("------Main Menu------")
    print("1: Configure")
    print("2: Applications")
	print("3: Reboot")
    print("4: Exit")
    return commonF.limitToWrite(15)
  end

  function self.main()
    (dataController.getObjects()).slaveList.reset()
	dataController.saveData()
    rednet.host("apmtSlaveConnection","apmtServer" .. os.getComputerID())
    if (communicator.modemIsEnabled()) then	  
	  while continue do
	    patternAction()
		mainCase:case(tonumber(menu()))	        	
      end		
	else
	  guiMessages.showErrorMsg("Error: This computer has no modems atached")
	end
  end

  return self
end

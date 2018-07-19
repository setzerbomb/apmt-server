function Configuration(root,commonF,dataController,guiMessages)

  local slaves = (dataController.getObjects()).slaveList.getSlaves()

  local continue = true
  
  local function createTask(id,execution,params)
    task = {}
	task.id = id or 0
	task.complete = false
	task.sent = false
	task.params = params or {}
	task.execution = execution or ""
	return task
  end
  
  local function showAvailableTurtles()
    guiMessages.showSuccessMsg("Available Turtles")
	for k,slave in pairs(slaves) do
	  io.write("[".. slave.id .."]")
	end
	print("")
  end
  
  local function createAndAssign()
    if (next(slaves)~=nil) then
      guiMessages.showHeader("------Create and Assign------")
	  showAvailableTurtles()
      guiMessages.showInfoMsg("Select the Turtle")
	  local selected = tonumber(io.read())
	  if (selected ~= nil) then
	    selected = slaves[selected]
	    if (selected ~= nil) then
		  local tasks = selected.tasks
	      guiMessages.showInfoMsg("---Available Tasks---")
		  print("1: Create a Stair")
          print("2: Create a Tunnel")
          print("3: Go to a specific position [x,y,z]")
          print("4: Quarry mode")
          print("5: Diamond Quarry mode")
		  local resp = tonumber(io.read())
		  if resp == 1 then
		    tasks[#tasks+1]=createTask(
			  #tasks+1,
			  "Stairs",
			  {}
			)
		  else
		    if resp == 2 then
			  print("Inform limit 3x3x?")
			  local limit = tonumber(io.read())
			  if limit ~= nil then
		        tasks[#tasks+1]=createTask(
			      #tasks+1,
			      "Tunnel",
			      {limit}
			    )
				guiMessages.showSuccessMsg("Success")
			  else
			    guiMessages.showErrorMsg("Error: Limit must be a number")
			  end
		    else
			  if resp == 3 then
			    print("Type the X value")
				local x = tonumber(io.read())
				print("Type the Y value")
				local y = tonumber(io.read())
				print("Type the Z value")
				local z = tonumber(io.read())
			    if (x~=nil and y~=nil and z~=nil) then
		          tasks[#tasks+1]=createTask(
			        #tasks+1,
			        "GoToPosition",
			        {x,y,z}
			      )
				  guiMessages.showSuccessMsg("Success")
			    else
			      guiMessages.showErrorMsg("Error: Limit must be a number")
			    end
		      else
			    if resp == 4 then
				  print("Type the X value")
				  local x = tonumber(io.read())
				  print("Type the Y value")
				  local y = tonumber(io.read())
				  if (x~=nil and y~=nil) then
		            tasks[#tasks+1]=createTask(
			          #tasks+1,
			          "Quarry",
			          {x,y}
			        )
					guiMessages.showSuccessMsg("Success")
			      else
			        guiMessages.showErrorMsg("Error: Limit must be a number")
			      end
		        else
				  if resp == 5 then
		            print("Type the X value")
				    local x = tonumber(io.read())
				    print("Type the Y value")
				    local y = tonumber(io.read())
				    if (x~=nil and y~=nil) then
		              tasks[#tasks+1]=createTask(
			            #tasks+1,
			            "DiamondQuarry",
			            {x,y}
			          )
				  	  guiMessages.showSuccessMsg("Success")
			        else
			          guiMessages.showErrorMsg("Error: Limit must be a number")
			        end
		          end
		        end
		      end
		    end
		  end
	    end
	  end
	  dataController.saveData()
	else
	  guiMessages.showInfoMsg("No turtles to show")
	end
  end
  
  local function showTaskList()
    if (next(slaves)~=nil) then
      guiMessages.showHeader("------Task List------")
	  showAvailableTurtles()
      guiMessages.showInfoMsg("Select the Turtle")
	  local selected = tonumber(io.read())
	  if (selected ~= nil) then
	    selected = slaves[selected]
	    if (selected ~= nil) then
	      if (#selected.tasks > 0 ) then
		    for i = 1,#selected.tasks do
			  io.write("[".. selected.tasks[i].id ..":".. selected.tasks[i].execution .."]")
			end
			print("")
			print("1: Show detailed info of: [-1:None; ...]")
			print("2: Delete all finished tasks of selected turtle")
			local option = tonumber(io.read())
			if option == 1 then
			  print("Type task number")
			  local action = tonumber(io.read())
			  if action ~= nil then
			    guiMessages.showInfoMsg(textutils.serialize(selected.tasks[action]))
			  else
			    guiMessages.showErrorMsg("Error: Must be a number")
			  end
			end
			if option ==2 then
			  local newListOfTasks = {}
			  for i = 1,#selected.tasks do
			    if selected.tasks[i].complete == false then
				  newListOfTasks[#newListOfTasks + 1] = selected.tasks[i]
				end
			  end 
			  selected.tasks = newListOfTasks
			  guiMessages.showInfoMsg("Deleted completed tasks of " .. selected.id)
			end
		  else
		    guiMessages.showInfoMsg("Tasks of Turtle " .. selected.id .. ": None")
		  end
	    end
	  end
	  dataController.saveData()
	else
	  guiMessages.showInfoMsg("No turtles or tasks to show")
	end
  end
  
  local optionsCase = commonF.switch{
    [1] = function(x)
      createAndAssign()
    end,
	[2] = function(x)
      showTaskList()
    end,
	[3] = function(x)
      continue = false
    end,
    default = function (x) guiMessages.showErrorMsg("Invalid option") continue = false end
  }
  
  local function menu()
    guiMessages.showHeader("------Configuration------")
    print("1: Create and Assign a task to a Turtle")
    print("2: Show task list of a Turtle")
    print("3: Exit")
    return commonF.limitToWrite(15)
  end
  
  while continue do
    optionsCase:case(tonumber(menu()))
  end
end

function Communicator(commonF)

  local self = {}

  local loadPeripherals = nil
  local hasModem = false
  
  local function executeNTimes(f,params)
    local data = nil
    for i = 1,10 do
	  data = f(params)   
      if data ~= nil then
	    return data,true
      end	  
	end
	return nil,false
  end
    
  local function main()
    lp = LoadPeripherals()
	hasModem = lp.openWirelessModem(lp.getTypes())
  end
  
  self.modemIsEnabled = function()
    return hasModem
  end
  
  main()

  return self
end

function SlaveList()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.getSlaves()
    return data
  end
  
  function self.addSlave(slave)
    data.slaves[slave.id] = slave
  end
  
  function self.subSlave(slave)
    data.slaves[slave.id] = nil
  end

  function self.start(tabela)
    data = tabela
  end
  
  function self.reset()
    if data ~= nil then
	  for k,slave in pairs(data) do
	    for i,task in ipairs(slave.tasks) do
		  if not task.complete then
		    task.sent = false
		  end
		end
	  end
	end
  end

  return self
end

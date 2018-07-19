function Slave()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.setId(id)
    data.id = id
  end

  function self.getId()
    return data.id
  end

  function self.setProtocol(protocol)
    data.protocol = protocol
  end  
  
  function self.getProtocol()
    return data.protocol
  end

  function self.getTasks()
    return data.tasks
  end

  function self.addTask(task)
    data.tasks[task.id] = task
  end

  function self.subTask(task)
    data.tasks[task.id] = nil
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end

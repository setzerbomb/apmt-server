function DataController(commonFunctions,root)

  dofile(root .. "objects/TableHandler.lua")

  dofile(root .. "objects/Slave.lua")
  dofile(root .. "objects/SlaveList.lua")

  -- Local variables of the object / Variáveis locais do objeto
  local self = {}

  local TableH = TableHandler()
  
  local values = nil
  local objects = {}
  objects.slaveList = SlaveList()
  
  -- Local functions of the object / Funções locais do objeto

  local function fillObjects()
    objects.slaveList.start(values.SlaveList)
  end

  -- Create a new set data if the data file is empty / Cria um novo conjunto de dados se o arquivo de dados está vazio
  local function newData()
    values = {}

    values.SlaveList = {}
    fillObjects()
    self.saveData()
  end

  -- Global functions of the object / Funções Globais do objeto

  -- Load all the data from file / Carrega todos os dados do arquivo
  local function configureDataObjects()
    if values ~= nil and next(values) ~= nil then
      fillObjects()
    else
      newData()
    end
  end

  local function tryToSave()
    TableH.save(values,os.getComputerLabel())
  end

  -- Retrieve the data from the config file / Puxa os dados do arquivo de configuração
  function self.load()
    if TableH.fileExists(os.getComputerLabel()) then
      values =  TableH.load(os.getComputerLabel())
      configureDataObjects()
    else
      configureDataObjects()
    end
  end

  -- Save the data into the config file / Salva os dados no arquivo de configuração
  function self.saveData()
    commonFunctions.try(
      tryToSave,
      function(exeception) guiKP.showErrorMsg("DataController: Cautch exception while trying to save turtle data: " .. exeception) end
    )
  end

-- Getters

  function self.getObjects()
    return objects
  end

return self
end

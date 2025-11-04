Vagrant.configure("2") do |config|
  # Usamos la caja de Debian 11 (Bullseye)
  config.vm.box = "debian/bullseye64" 
  
  # Asigna un nombre a la VM
  config.vm.hostname = "servidor-dns"

  # Configuración de red privada (IP Estática)
  config.vm.network "private_network", ip: "192.168.56.10"

  # Especifica la memoria RAM
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
  end
  
  # ESTA LÍNEA DEBE EXISTIR: Configuración del aprovisionamiento
  config.vm.provision "shell", path: "bootstrap.sh" 

end
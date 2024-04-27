Vagrant.configure("2") do |config|
    config.vm.provider :virtualbox do |v|
            v.name = "mikrocicd"
            v.customize ["modifyvm", :id, "--groups", "/vagrant"]
            v.gui = false
            v.memory = 4096
            v.cpus = 2
        end
    config.vm.box = "ubuntu/jammy64"
    config.vm.network "private_network", ip: "192.168.56.70"
    config.vm.hostname = "mikrocicd"
    config.vm.cloud_init :user_data do |cloud_init|
        cloud_init.content_type = "text/cloud-config"
        cloud_init.path = "misc/cloudinit/user-data.yml"
    end
end

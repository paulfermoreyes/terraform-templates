#
# Cookbook Name:: web
# Recipe:: default
#

execute "install-updates" do
    action: run
    command "sudo apt-get update"
end

execute "install-apache" do
    action: run
    command <<- EOH
        sudo apt install apache2
    EOH
end

execute "install-mysql" do
    action: run
    command <<- EOH
        sudo apt install mysql-server
        sudo systemctl start mysql.service
    EOH
end

git submodule update --init --recursive

add "exit 0" at the end of run-docker-compose.sh in order not to break the following service when there are running containers with the same name

sudo apt install autossh
ssh-keygen -t rsa -b 4096 -C "<your_email@example.com>"
ssh-copy-id root@<ip>

sudo cp dhr-software-management-framework.service /etc/systemd/system/dhr-software-management-framework.service

sudo systemctl daemon-reload
sudo systemctl start dhr-software-management-framework.service
sudo systemctl enable dhr-software-management-framework.service

if the service fails you can devug it with the following commands:
sudo systemctl status dhr-software-management-framework.service
sudo journalctl -u dhr-software-management-framework.service

verify that ssh tunnel is running
ss -tnp | grep ssh

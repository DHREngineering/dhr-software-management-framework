# dhr-software-management-framework

## Overview

The DHR Software Management Framework is the central project for the 3D printing farm and includes the following key services, listed as Git Submodules and operating within Docker containers on the same Docker network (You can read more about them and the techstack by following the links):

* [Printer Service](https://github.com/DHREngineering/printer-service)  
Python-based automation tool for managing 3D printers, including monitoring, control, and automatic handling of G-code file uploads. It integrates with Printer Utilization to track usage and sends print job completion notifications to the Robot Arm Orchestrator via RabbitMQ "ready" queue. Data is stored and accessed through MongoDB.

* [Pantheon API](https://github.com/DHREngineering/pantheon-api)  
FastAPI application that serves as the backend for our [Dashboard](https://3dhrmanager.com/). It manages and monitors the data in MongoDB, Printer Services, Printer Utilization, G-code files, Print beds. And Robot Arm, and Robot Arm Orchestrator via 3D Printer Pantheon Control Panel API.

* [Printer Utilization](https://github.com/DHREngineering/printer-utilization)  
Python-based automation tool to track and analyze Printer Service usage by querying real-time status and print job completions, with data stored in MySQL.

* [Robot Arm Orchestrator](https://github.com/DHREngineering/robot-arm-orchestrator)  
Python-based automation tool that processes print completion notifications from the Printer Service via RabbitMQ "ready" queue. It then directs the Robot Arm by pushing tasks to the Mosquitto MQTT broker to which RobotArm is subscribed. The tasks are take (printed part retrieval) and replace (put a new print bed plate), managing the selection of appropriate beds according to their location and type. Additionally it sends a homing task to the robot every 24h through the "homing" queue.

Additionally, there are other services used in the system that aren't integrated into this project or Docker cluster. These dependencies are accessed via the hosts IPs:

* [Robot Arm](https://github.com/DHREngineering/RobotArm)  
Python ROS application for controlling the Robot Arm PLC either manually or via state machines with predefined positions for printers and print beds. It handles the retrieval of printed parts and the replacement of print bed plates. Additionally, it offers a FastAPI application for manual robot control.

* [3D Printer Pantheon Control Panel API](https://github.com/DHREngineering/3DPrinterPantheonControlPanelAPI)  
FastAPI application for managing and monitoring the Robot Arm and Robot Arm Orchestrator. It handles checking statuses, starting and stopping services, purging queues, and retrieving logs, all via SSH connections to the hosts running the services.

* SFTP Server deployed within a Docker container used for storing the G-code files.

* [Pricing and gcode slicer API](https://github.com/DHREngineering/slicer)  
FastAPI application for converting STL and STEP files into G-code. It provides an endpoint for retrieving print model pricing, used by the [3DHR shop](https://3dhr.eu/bg/), and another endpoint for automatically slicing models and uploading the G-code to the Pantheon API, accessed by the [WordPress backend of the 3DHR shop](https://3dhr.eu/wp-admin).

* [Datadog](https://github.com/DHREngineering/datadog)  
A monitoring and analytics platform that offers real-time insights into metrics, logs, and traces. The Datadog agent operates within a Docker container to ensure comprehensive performance monitoring and optimization.

## How to run

### Setup

install docker and docker compose  
`$ sudo apt update && sudo apt upgrade`  
`$ sudo apt install docker && sudo apt install docker-compose`

Clone this repository.  
`$ git clone git@github.com:DHREngineering/dhr-software-management-framework.git`

Cd into the directory.  
`$ cd dhr-software-management-framework`

Update the Git Submodules.  
`$ git submodule update --init --recursive`

### Run locally for testing

Execute the [Run script](run-docker-compose.sh)  
`$ ./run-docker-compose.sh`  
This starts the Printer Services and their dependencies - MongoDB and RabbitMQ, Pantheon API, Printer Utilization and its dependency - MySQL. Also creates a RabbitMQ admin user.  
***The services interface directly with physical printers, SFTP server and 3D Printer Pantheon Control Panel API so please exercise caution when sending commands!***

The orchestrator is run separately for safety reasons:  
`$ ./run-docker-compose-orchestrator.sh`  
This starts it the dependencies - RabbitMQ (if not already started) and Mosquitto MQTT broker  
***To actually control the Robot Arm, it must be subscribed to this broker.***

### Debug

`$ docker ps`  
`$ docker logs -f <container_name>`  
This can also be done from Portainer.

### Stop and clean up

`$ docker kill <container_name>`  
`$ docker system prune`  
This can also be done from Portainer.

## CURRENT DEPLOYMENT

The 3D Printing Farm system consists of multiple repositories distributed across different hosts:

### 192.168.0.100 - This repository, Datadog

`$ ssh dhr@192.168.0.100`  

To set up automatic service management and create an SSH tunnel that connects the Dashboard with the Pantheon API, follow these steps:  

`dhr@dhr:~$ sudo apt install autossh`  
Edit the remote machine ip in `ubuntu_services/dhr-software-management-framework.service` and copy it  
`dhr@dhr:~$ sudo cp ubuntu_services/dhr-software-management-framework.service /etc/systemd/system/dhr-software-management-framework.service`  
`dhr@dhr:~$ sudo systemctl daemon-reload`  

Allow necessary ports - 22, 27017, 9971, 15672, 3306, 1883, 5672, 90, 9000, 9443  
`dhr@dhr:~$ sudo ufw allow <port>`  

Start the service  
`dhr@dhr:~$ sudo systemctl start dhr-software-management-framework.service`  
`dhr@dhr:~$ sudo systemctl enable dhr-software-management-framework.service`  

Verify the service is active and the ssh tunnel is running  
`dhr@dhr:~$ sudo systemctl status dhr-software-management-framework.service`  
`dhr@dhr:~$ sudo journalctl -u dhr-software-management-framework.service`  
`dhr@dhr:~$ ss -tnp | grep ssh`

Manually start the orchestrator from 3D Printer Pantheon Control Panel API running at <http://192.168.0.127:30000/docs#/default/restart_service_orchestrator_start_post>  

If you'd like to run a cron job to send homing tasks to the robot-arm-orchestrator every 24h follow [these steps](homing_task_cron_job/README.md)

Ubuntu service to automatically run Portainer  
`dhr@dhr:~$ sudo cp ubuntu_services/portainer.service /etc/systemd/system/portainer.service`  
`dhr@dhr:~$ sudo systemctl start portainer.service`  
`dhr@dhr:~$ sudo systemctl enable portainer.service`  

Ubuntu service to automatically run Datadog  
`dhr@dhr:~$ cd /home/dhr/`  
`dhr@dhr:~$ git clone git@github.com:DHREngineering/datadog.git`  
`dhr@dhr:~$ sudo cp ubuntu_services/datadog.service /etc/systemd/system/datadog.service`  
`dhr@dhr:~$ sudo systemctl start datadog.service`  
`dhr@dhr:~$ sudo systemctl enable datadog.service`  

### 192.168.0.109 - SFTP server for G-code files

`$ ssh dhr@192.168.0.109`

`dhr@dhr:~$ sudo cp ubuntu_services/sftp.service /etc/systemd/system/sftp.service`  
`dhr@dhr:~$ sudo systemctl start sftp.service`  
`dhr@dhr:~$ sudo systemctl enable sftp.service`  

### 192.168.0.127 - RobotArm and 3D Printer Pantheon Control Panel API, Datadog

`$ ssh dhr@192.168.0.127`  

Ubuntu service to automatically run 3D Printer Pantheon Control Panel API  
`dhr@dhr:~$ cd /home/dhr/`  
`dhr@dhr:~$ git clone git@github.com:DHREngineering/3DPrinterPantheonControlPanelAPI.git`  
`dhr@dhr:~$ sudo cp ubuntu_services/robot-arm-api.service /lib/systemd/system/robot-arm-api.service`  
`dhr@dhr:~$ sudo systemctl start robot-arm-api.service`  
`dhr@dhr:~$ sudo systemctl enable robot-arm-api.service`  

Manually start the RobotArm from 3D Printer Pantheon Control Panel API - <http://192.168.0.127:30000/docs#/default/start_robot_robot_start_post>  
This runs RobotArm inside a tmux session that you can access with  
`dhr@dhr:~$ tmux attach`  
This includes Robot Arm Web Controls API to manually control the robot.

Ubuntu service to automatically run Datadog  
`dhr@dhr:~$ sudo cp ubuntu_services/datadog.service /etc/systemd/system/datadog.service`  
`dhr@dhr:~$ sudo systemctl start datadog.service`  
`dhr@dhr:~$ sudo systemctl enable datadog.service`  

### Remote machine - Pricing and gcode slicer API

`$ ssh root@...135`  

The API is currently run within a Docker container that is an instance of a plain ubuntu image  
`$ root@F055788:~# docker exec -ti 359800a4dd78 bash`  
`$ root@359800a4dd78:/# cd root/slider_nedko/`  
`$ git clone git@github.com:DHREngineering/slicer.git`

it is run inside a tmux session:  
`$ root@359800a4dd78:~/slider_nedko# tmux attach`

## Tools in the Current Deployment

***Please be mindful using these tools!***  
***For passwords check in config files or ask around ;)***

* [Dashboard](https://3dhrmanager.com/) - A web application for managing and monitoring the 3D Printing Farm

* [Portainer](http://192.168.0.100:9000/) - A a web UI for managing and monitoring Docker containers

* [PantheonApi](https://pantheon.3dhrmanager.com/docs) - The backend serving the Dashboard

* [MongoDB Compass](https://www.mongodb.com/products/tools/compass) - a MongoDB client used to access the db that stores the current state of the farm.  
Connect via SSH with Password to host 192.168.0.100.

* mysql-client - a mysql client to access the db that stores the 3D printers utilization data  
`$ mysql -h 192.168.0.100 -u root -p utilization`  

* [RabbitMQ](http://192.168.0.100:15672/) - a message broker for handling two types of messages: print completion notifications and robot homing requests. You can simulate a print completion by pushing <printer_id> into the `ready` queue and can make the robot home by pushing anything into the `homing` queue.

* [3D Printer Pantheon Control Panel API](http://192.168.0.127:30000/docs) - a FastAPI application for managing and monitoring Robot Arm and Robot Arm Orchestrator

* [Robot Arm Web Controls API](<http://192.168.0.127:8000/>) - a web application to manually control the Robot Arm

* [Datadog Dashboard](<https://app.datadoghq.eu/dashboard/36c-n2c-6n8/>) - a cloud-based platform for monitoring and analytics of the infrastructure (hosts).

* [Pricing and gcode slicer API](<https://dhr3dpricingapiservice.xyz/docs#/>) - a FastAPI application for converting STL and STEP files into G-code (and calculating the resale price)

* [WordPress application](https://3dhr.eu/wp-admin) - Backend for the [3DHR shop](https://3dhr.eu/bg/)

* [MQTT Explorer](http://mqtt-explorer.com/) - a tool for visualizing and managing MQTT message traffic.  
Topics on the broker at `mqtt://192.168.0.100:1883`:
  * **robot_arm/status** - subsribe to receive notifications when the robot changes its status, and you can even push `{"status": "available"}` to simulate the robot changing status to available.

  * **robot_arm/job** You can send the following jobs:  
  ***First make sure the orchestrator is stopped!***
    * take

        ```json
        {
            "printer_id":14,
            "bed_id":801,
            "take_from_printer":true,
            "load_next_bed_without_homing":true,
            "open_doors":[
                "printer14"
            ]
        }
        ```

    * replace

        ```json
        {
            "printer_id":14,
            "bed_id":801,
            "take_from_printer":false,
            "load_next_bed_without_homing":true,
            "open_doors":[
                "printer14"
            ]
        }
        ```

    * homing

        ```json
        {
            "printer_id":null,
            "bed_id":null,
            "take_from_printer":false,
            "load_next_bed_without_homing":false,
            "open_doors":[]
        }
        ```

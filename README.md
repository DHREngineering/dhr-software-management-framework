# dhr-software-management-framework

The DHR Software Management Framework is the central project for the 3D printing farm and includes the following key services, listed as [Git Submodules](#git-submodules):

* [Printer Service](https://github.com/DHREngineering/printer-service)  
Python-based automation tool that manages 3D printers by handling monitoring, control, and file management while integrating with the other services for usage tracking and print job completion notifications. Stores and reads data in MongoDB.

* [Pantheon API](https://github.com/DHREngineering/pantheon-api)  
FastAPI application for managing 3D printer services and resources, offering monitoring, control (gRPC client), file management, utilization reporting, and integration with Docker and Swagger for streamlined deployment and documentation. Stores and reads data in the same MongoDB.

* [Printer Utilization](https://github.com/DHREngineering/printer-utilization)  
Python-based automation tool to track and analyze 3D printer usage by querying real-time status and print job completions, with data stored in MySQL for scalability and consistent operation.

* [Robot Arm Orchestrator](https://github.com/DHREngineering/robot-arm-orchestrator)

In addition, there are other services utilized but not integrated into this project:

* [Robot Arm](https://github.com/DHREngineering/RobotArm)
* [3D Printer Pantheon Control Panel API](https://github.com/DHREngineering/3DPrinterPantheonControlPanelAPI)
* [SFTP Server](#sftp)  
Where [G-code](#gcode) files are stored.
* [Pricing and gcode slicer API](https://github.com/DHREngineering/slicer)

## How to run

### Setup

Clone this repository.  
`$ git clone git@github.com:DHREngineering/dhr-software-management-framework.git`

Cd into the directory.  
`$ cd dhr-software-management-framework`

Update the [Git Submodules](#git-submodules).  
`$ git submodule update --init --recursive`

`$ sudo cp dhr-software-management-framework.service /etc/systemd/system/dhr-software-management-framework.service`  
`$ sudo systemctl daemon-reload`

Make sure that all [Dependencies](#dependencies):

* autossh, docker and docker compose are installed.
* the necessary ports are allowed.
* SFTP server, RobotArm and 3DPrinterPantheonControlPanelAPI are running
* configurations are correct

### Run

`$ sudo systemctl start dhr-software-management-framework.service`  
`$ sudo systemctl enable dhr-software-management-framework.service`

### Debug

`$ sudo systemctl status dhr-software-management-framework.service`  
`$ sudo journalctl -u dhr-software-management-framework.service`

`$ docker ps`  
`$ docker logs -f <container_name>`  
This can also be done from [Portainer](#portainer).

verify the ssh tunnel is running  
`$ ss -tnp | grep ssh`

### Stop and clean up

`$ docker kill <container_name>`  
`$ docker system prune`  
This can also be done from [Portainer](#portainer).

## Used technologies

### Git, GitHub

#### Git

Git is a distributed version control system that tracks changes to files and coordinates work among multiple contributors.

#### GitHub

GitHub is a platform that provides hosting for Git repositories, collaborative tools for developers, and facilitates code management and sharing.

Most of DHR Engineering's repositories can be found inside the [DHR Engineering GitHub organization](https://github.com/DHREngineering)

GitHub Actions is a CI/CD automation tool that allows you to create custom workflows for building, testing, and deploying code directly from your GitHub repository.

#### Git Submodules

[Git Submodules](.gitmodules) are a feature in Git that allows a repository to include and manage external repositories within its directory, enabling the main project to incorporate and track dependencies on other projects.

...

Update the git submodules.  
`$ git submodule update --init --recursive`

### Docker

Enables effortless deployment and management of multiple instances tailored for different printers, enhancing scalability, updates, and consistent operation across various environments. It optimizes resource utilization, isolates dependencies, and boosts system reliability and flexibility.

The Dockerfile contains instructions for building a Docker image. It is used to define the environment, dependencies, and other configurations required to run an application inside a Docker container.

The [docker-compose.yaml](docker-compose.yaml) file help us easily run and manage multiple containers, the dependencies between them, networking and so on.
It specifies that the dhr-software-management-framework Docker container(s), depend on the [MongoDB](#mongodb) container (which is an instance of a official public MongoDB image). It also defines the Docker network where the containers run.
...

To run manually, execute the [Run script](run-docker-compose.sh).  
`$ ./run-docker-compose.sh`  
This starts the dhr-software-management-framework container(s) as well as a mongo container.
...

To stop and clean up run:  
`$ docker kill <container_name>`  
`$ docker system prune`  
This can also be done from [Portainer](#portainer).

#### Portainer

Portainer is a lightweight management GUI tool that allows you to easily manage your Docker environments, including containers, images, networks, and volumes.

Run the following command on the same machine as the docker containers you would like to monitor/manage:  
`$ docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --name portainer portainer/portainer-ce:latest`

You can access the tool at `http://<ip>:9000/#!/2/docker/containers`, where you can:

* monitor logs
* inspect containers
* start, stop, restart, kill, remove containers. ***Be careful in production.***
* attach a shell to a container

## Architecture

The printer service runs inside a docker container as a single service, where mutiple [Microservice](#microservices) objects can live together. This facilitates easy setup and control of multiple printer-specific instances of the printer service, ensuring seamless scalability and consistent operation.

## Key Features

* **Compatibility**: Works seamlessly with different types of printers utilizing multiple client interfaces. Achieved by instantiating an object of an implementation of the [Printer Client](#printer-client) abstract class

* **Monitoring**:: Track printer status, printing progress, and more. Achieved by instantiating a [State Service Object](#state-service-object).

* **Control**: Ability to send commands to the printers: print management (set available, cancel, resume, pause), advanced G-code commands (move bed on Z axis), and real-time status reports. Achieved by instantiating a [gRPC Server Object](#grpc-server-object)

* **File Management**: Automates the retrieval of appropriate G-code file from the SFTP server according to the printer configuration and state and uploads it to the printer, tracking number of printed copies.  Achieved by instantiating a [Available Service Object](#available-service-object) and [State Service Object](#state-service-object).

* **Utilization Reporting**: Notifies the [Printer Utilizarion](https://github.com/DHREngineering/printer-utilization) upon print completion for accurate usage tracking. Achieved by instantiating a [Print Job Service Object](#print-job-service-object).  
Can be prompted by Printer Utilizarion service for real-time status report that can be logged and subsequently analyzed to inspect printer usage. Achieved by calling the [GetStatus Endpoint](#getstatus-endpoint) of the [gRPC Server Object](#grpc-server-object).

* **Print Completion Notification**: Notify [RobotArm Orchestrator](https://github.com/DHREngineering/robot-arm-orchestrator) upon print completion for automated retrieval of the printed part and subsequent replace of the bed plate. Achieved by instantiating a [State Service Object](#state-service-object).

* **Scalability**: [Docker](#docker) facilitates easy setup and control of multiple printer-specific instances, ensuring seamless scalability and consistent operation.

## Updates

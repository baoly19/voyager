# RMIT GenAI and Cyber Security Hackathon
# 1. Introduction
This file contains the deployment description for the Voyager application in RMIT GenAI and Cyber Security Hackathon 2024.
The deployment is designed with the requirements of Challenge 1 as well as the provided services of AWS (EC2).

# 2. Architecture
The following figure depicts the deployment solution

# 3. Setup
## 3.1. Pre-requisite
The following resources are required to have the successful deployment:
1. AWS Account
2. GitHub Account
3. Access to Voyager project

## 3.1. Create EC2 AWS instance

## 3.2. Connect to EC2 instance

## 3.3. Install dependencies
1. Create the new file ``ec2_setup.sh`` via the command line
```
nano ec2_setup.sh
```
2. Copy and paste all the content the files ec2_setup.sh in **infra** folder
This file is the initialization script that aim to install the development libraries and application libraries.
| Library type | Packages |
| - | - | 
| Development | git, wget, |
| Application | Docker |  

3. Set permission for running the file
```
chmod +x ec2_setup.sh
```

4. Run the script
```
./ec2_setup.sh
```

## 3.4. Setup NGINX reverse proxy
1. Create the new file ``nginx_setup.sh`` via the command line
```
nano nginx_setup.sh
```
2. Copy and paste all the content the files nginx_setup.sh in **infra** folder
This file contains the code to setup the NGINX reverse proxy with the following configurations:


3. Set permission for running the file
```
chmod +x nginx_setup.sh
```

4. Run the script
```
./nginx_setup.sh
```

## 3.5. Voyager application setup
Only enable the TLS data


# 3. Update application
At the moment, the project does not setup the CI-CD pipeline so, to update please run the file ``restart_service.sh`` in the
**infra** folder.

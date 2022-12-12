# Step 0

## clone the repos for both awx and terraform

terraform-repo: https://github.com/Pr3c10us/AWSAZURE-Postgres.git<br>
disaster-recovery-ansible-repo: https://github.com/Pr3c10us/postgres-ansible-disaster-recovery.git

# Step 1

## Run terraform init

> terraform init

# Step 2

## Run terraform plan

> terraform plan

# Step 3

## Run terraform apply

> terraform apply

# Step 4

## Input all required variables value

### - For AWS provider, you can get the value from AWS console in IAM service

### - For Azure provider, you can get the value by following this steps on azure cli in the azure porter:

> -   az login
> -   az account list
> -   az account set --subscription="SUBSCRIPTION_ID"
> -   az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

### This would output 5 values, you need to use the value of:

-   appid for client_id
-   password for client_secret
-   tenant for tenant_id
-   subscription_id for subscription_id

### - Then fill in the remaining variables as pleased

# Step 5

## Get the awx Ec2 instance public ip address from the ec2 console

# Step 6

## Enter the ansible directory in the cloned terraform connfiguration repo

# Step 7

## Use any text editor to edit the file "inventory" and replace the value of '<awx_IP>' with the public ip address of awx ec2 instance

# Step 8

## Copy private key pem file to the directory

# Step 9

## Run the ansible playbook to install awx with this command

> ansible-playbook -i inventory --private-key postgres-instance-key.pem ./playbooks/awx-installation.yml -v

If you are using a diffrent key name, replace the "postgres-instance-key.pem" with the key name

# Step 10

## Open the awx url in the browser and login with the default username and password

> username: admin

> password: password

Make sure you are using http not https

# Step 11

## Create a new Inventory in Awx by following this steps

> -   Click on the inventory tab
> -   Click on the add button
> -   Fill in the name of the inventory
> -   Select the organization
> -   Fill in the description
> -   Click on the save button

# Step 12

## Create a host in Awx for all three instances by following this steps

> -   Click on the hosts tab
> -   Click on the add button
> -   Fill in the name of the host with the instance ip address
> -   Select the inventory
> -   Fill in the description
> -   Click on the save button

# Step 13

## Create a credential in Awx for the instances by following this steps

> -   Click on the credential tab
> -   Click on the add button
> -   Select the machine credential type
> -   Fill in the name of the credential
> -   Select the organization
> -   Fill in the username with "ubuntu"
> -   Fill in the ssh key with the private key pem file
> -   Choose sudo as the privilege escalation method
> -   Click on the save button

# Step 14

## Create a project in Awx by following this steps

> -   Click on the project tab
> -   Click on the add button
> -   Fill in the name of the project
> -   Select the organization
> -   Fill in the description
> -   Paste the git repo url in the scm url field
> -   Fill the source control branch with "main"
> -   Tick the "Update Revision on Launch" checkbox
> -   Click on the save button

# Step 15

## Create a job template in Awx by following this steps

> -   Click on the job template tab
> -   Click on the add button
> -   Click Add Job Template
> -   Fill in the name of the job template
> -   Fill in the description
> -   Select the Inventory
> -   Select the Project
> -   Select the Playbook
> -   Select the Credential
> -   Fill the variables field with the following values:<br>
>     ---<br>
>     aws_IP: <master_ip_address> <br>
>     aws_IP_haproxy: <haproxy_instance_ip_address><br>
>     azure_IP: <slave_ip_address><br>
>     rep_user: <replication_username_of_choice><br>
>     rep_user_password: <replication_password_of_choice><br> <br>
>     example <br>
>     ---<br>
>     aws_IP: 44.193.224.211 <br>
>     aws_IP_haproxy: 54.158.229.88<br>
>     azure_IP: 20.123.174.208<br>
>     rep_user: repuser<br>
>     rep_user_password: repuser12345<br>
> -   Tick the "Enable Privilege Escalation" checkbox
> -   Click on the save button

# Step 16

## Run the job template by following this steps

> -   Click on the job template tab
> -   Click on the job template name
> -   Click on the launch button

# Step 17

## You can check the status of the postgres instances by following this steps

> -   Copy the haproxy instance ip address
> -   Open the browser and paste the ip address in the url with port 7000
> -   You should see the haproxy dashboard

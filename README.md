# 2017/08/17 — `csr-aug-talk`


## Agenda :loudspeaker:

1. [Install the required tools]
2. [Establish your AWS account & client credentials]
3. [Configure your control machine]
4. Deploy things!
  1. [Apache on Centos](https://github.com/b-long/csr-aug-talk#1-apache-on-centos)
  2. [Apache on Ubuntu](https://github.com/b-long/csr-aug-talk#2-apache-on-ubuntu)
  3. [Simple Flask Application (Python)](https://github.com/b-long/csr-aug-talk#3-simple-flask-application-python)
  4. [Simple Express Application (Node.js)](https://github.com/b-long/csr-aug-talk#4-simple-express-application-nodejs)
5. Cleanup

### Install the required tools. :hammer:
To establish a consistent environment, we'll create an _virtual machine_ or "VM".  The VM will give us consistent configuration across our machines and allow us to work with AWS and Ansible.  The tool set we've chosen to use is platform agnostic.  It will work on Windows, Mac, and Linux.  However, this guide will prefer Linux commands.  If there are any questions, please use this project's GitHub repository to [create an issue] and we'll be sure to support you! :star:

To begin, make sure you're running the latest (stable) version of Vagrant and VirtualBox.  These are free (open source) software.  Download and install them from the addresses below (in this order) and return to this guide.  
1. https://www.virtualbox.org/wiki/Downloads
2. https://www.vagrantup.com/downloads.html

Next, we're going to create our Vagrant VM.  It may take a few minutes.  Run the following commands and return to this guide:

```shell
# Clone the git repository
git clone git@github.com:b-long/csr-aug-talk.git

# Open the directory in your terminal
cd csr-aug-talk

# Create the VM
vagrant up
```
### Establish your AWS account & client credentials :satellite:
For AWS orchestration, we have to configure the credentials which will interact with the AWS API's.  To create your credentials, follow these steps:

1. Log into the AWS console at  **https://console.aws.amazon.com/**  .  If needed, follow the provided steps to create an account.
2. Once you're logged into AWS, we'll create an identity for actions we perform using Ansible.  To do this, click on "**Services**".  Under the section header "*Security, Identity & Compliance*" click "**IAM**" (Identity and Access Management).  If you can't find it, click [here](https://console.aws.amazon.com/iam/home?region=us-east-1#/users).
3. Next, click "**Add user**".  <u>Note</u>: Amazon does not charge a fee to create IAM users.
4. Next, enter the user details.  For the user name, enter "**my-ansible-user**" and check the box for "**Programmatic access**" (since this account will not need to use the AWS web application).  Click the button labeled "*Next: Permissions*"
5. On the "Set permissions" screen, click the large box labeled "**Attach existing policies directly**", then in the table below check the box to the left of the row for "**AdministratorAccess**" and click the button for "*Next: Review*"
6. Finally, at the Review screen, click "**Create user**" , which will bring you to a confirmation page (there should be a green rectangle labelled **Success** ).  
7. ***Read carefully :** On the **Success** screen, we have to collect security credentials for your new Ansible user.  This will be your only opportunity to access these keys you must do so now.  Copy the "**Access key ID**" to your clipboard.  Paste the value into the placeholder at line #4 of  `configure.sh` (in this repository). After that,view the  "**Secret access key**" and copy it to your clipboard.  Paste the value into the placeholder at line #5 of  `configure.sh` (in this repository)

### Configure your "_control machine_" :electric_plug:

Ansible refers to the machine performing the orchestration as the <u>control machine</u>.  To allow Ansible to manage resources inside your AWS account, we'll perform some initial setup.  We've tried to simplify the configuration of these components by providing the `configure.sh` script.  You're going to run this script inside your VM, and it will do the following: 

* Establish an AWS credentials file ( `~/.aws/credentials` )
* Export AWS environment variables

To invoke the setup script, peform the steps below.  Note that instructions (comments) begin with the `#` character, commands that you need to run do not. 

```shell
# If necessary, navigate to this directory
cd csr-aug-talk

# Login to your virtual machine (VM)
# This command will open a shell for you on our virtual control machine
vagrant ssh

# On initial login, you should be in the /home/ubuntu/ directory.
# Optionally, you can double check this with the following command:
pwd

# Navigate to the csr-aug-talk directory
cd /home/ubuntu/csr-aug-talk

# Use the setup script by "sourcing" it
source configure.sh
```

Sourcing this file should produce the following output: 
```
Awesome!  The Ansible control machine is now configured.
```
If this message is printed, you're doing great!  :thumbsup:  If the message is not printed, please [create an issue] so that we can help get you setup to work with Ansible on AWS :smile: 

Next, navigate to our Ansible working directory:


```shell
cd /home/ubuntu/csr-aug-talk/ansible-code
```
Let's take a look at accessing remote hosts with Ansible.  Remember that it turns out ping in Ansible is not `ICMP ping`.  The default usage of Ansible's `ping` module is actually making an SSH connection to some server.  This means that we need authorization & access to connect to said server.



Assuming that you aren't a Google employee, the next command should timeout & fail.  The `-i` flag below indicates the _***inventory***_ we're targetting for Ansible management:  

```shell
# This is expected to fail after 10 seconds
ansible -m ping all -i inventory/google.txt
```

Alternatively — Ansible can perform actions on a local machine.  Try the following command which uses Ansible's `ping` module without SSH.

```shell
# This command doesn't require a network connection
ansible -m ping all -i inventory/your-computer.txt
```

The two commands above are useful to familiarize you with Ansible's conventions for normal output and error text.  The `-m` flag indicates we're using the Ping module, which you can read more about online: http://docs.ansible.com/ansible/latest/ping_module.html

Let's run a command against AWS inventory.  Ansible provides this feature by accepting a Python script as an argument to the `-i` (inventory) parameter.  Assuming this is your first time using AWS, the command will attempt connection to zero EC2 instances.

```shell
# A python script, querying AWS, as our "inventory" file
ansible -m ping all -i inventory/ec2.py
```

This command should produce the following output:

```
No hosts matched, nothing to do
```

If your output looks like the above example, continue onward.  If it doesn't [create an issue] and we'll help you debug :smile:


## Deploy things! :globe_with_meridians:

In order to give you an understanding of the capabilities provided by Ansible, we've created 4 deployment playbooks.  Run each of the below to observe what you can do with Ansible and AWS.  Note that each playbook will destroy the server created in the previous step.  At the final step (step 4) you'll need to manually terminate the instance from EC2.

### 1. Apache on Centos
Run this playbook, passing the dynamic inventory: 
```shell
ansible-playbook -i inventory/ec2.py apache-on-centos.yml
```
The final output should dislplay something like this: 
```
RUNNING HANDLER [geerlingguy.apache : restart apache] ****************************************
changed: [ec2-54-89-73-59.compute-1.amazonaws.com]

PLAY RECAP ***********************************************************************************
ec2-54-89-73-59.compute-1.amazonaws.com : ok=16   changed=6    unreachable=0    failed=0   
localhost                  : ok=16   changed=2    unreachable=0    failed=0  
```
***To view the Apache starter web page*** note the IP address given in the output.  Then, open your web browser and prepend "*http://"* .  For instance, the above server would be visible at the address: http://ec2-54-89-73-59.compute-1.amazonaws.com
### 2. Apache on Ubuntu
Run this playbook, passing the dynamic inventory: 
```shell
ansible-playbook -i inventory/ec2.py apache-on-ubuntu.yml
```
The final output should dislplay the following: 
```
RUNNING HANDLER [geerlingguy.apache : restart apache] ****************************************
changed: [ec2-34-229-167-233.compute-1.amazonaws.com]

PLAY RECAP ***********************************************************************************
ec2-34-229-167-233.compute-1.amazonaws.com : ok=16   changed=6    unreachable=0    failed=0   
localhost                  : ok=17   changed=3    unreachable=0    failed=0   
```
Navigate to it to view the Apache welcome screen for CentOS.  For instance, using the address: http://ec2-34-229-167-233.compute-1.amazonaws.com
### 3. Simple Flask Application (Python)
Run the Flask application playbook, passing the dynamic inventory: 
```shell
ansible-playbook -i inventory/ec2.py simple-flask-app.yml

```
### 4. Simple Express Application (Node.js)
Run the Express application playbook, passing the dynamic inventory: 
```shell
ansible-playbook -i inventory/ec2.py simple-express-app.yml
```

## Cleanup
Last, but NOT LEAST, you'll want to cleanup any resources created in AWS.

1. Login to the AWS Console: https://console.aws.amazon.com/
2. Click "_Services_" -> "_EC2_"
3. The Resources screen should display metrics, click on the item that says "*1 Running Instances*"
4. A table with past (possibly) and present EC2 servers will be displayed.  Click to the left of any
  running machines.  Next, click the "_*Actions*_" drop-down, and select "_*Instance State*_" -> "_*Terminate*_"
5. In addition, AWS will leave behind the disk that was attached to the EC2 instance.  The disk is called an EBS volume.  To terminate the EBS volume, click **Volumes** on the left side of the EC2 console.  Highlight the 4 volumes we've created and click **Action** -> **Terminate**.

----


#### Next Steps :mortar_board:

The intent of this walkthrough was to be both brieft, and helpful.  Hopefully, we've hit the mark, but if we missed it please ask a question, make a comment, or file a bug report via GitHub issues: https://github.com/b-long/csr-aug-talk/issues

In addition, you may find the following resources useful in getting yourself familiar with Ansible and interrelated tools

##### Additional Documentation

- https://docs.ansible.com/ansible/latest/guide_aws.html
- https://docs.ansible.com/ansible/latest/list_of_cloud_modules.html
- https://docs.ansible.com/ansible/latest/playbooks_variables.html

##### Support

- Ansible mailing list (very helpful): https://groups.google.com/forum/#!forum/ansible-project
- Ansible on StackOverflow: https://stackoverflow.com/questions/tagged/ansible
- Chat about Ansible on Gitter (like Slack): https://gitter.im/ansible/ansible




# :tophat: 

*Tip of the hat* to @[ryansb](https://github.com/ryansb) for recommending I use Vagrant instead of Docker for this project.  Thanks Ryan!

<!-- 

	See also: http://www.tivix.com/blog/using-ansible-create-aws-instances/
--> 

[create an issue]: https://github.com/b-long/csr-aug-talk/issues/new
[Install the required tools]: https://github.com/b-long/csr-aug-talk/blob/master/README.md#install-the-required-tools-hammer
[Establish your AWS account & client credentials]: https://github.com/b-long/csr-aug-talk/blob/master/README.md#establish-your-aws-account--client-credentials-satellite
[Configure your control machine]: https://github.com/b-long/csr-aug-talk#configure-your-control-machine-electric_plug

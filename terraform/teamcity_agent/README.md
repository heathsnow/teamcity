# teamcity/terraform/teamcity_agent

Terraform configuration for deploying TeamCity agents in an AWS VPC.

## Directory Structure

| Name | Description |
|------|-------------|
| [modules](modules) | Terraform modules.  (Reusable, self contained configurations with limited variable scope.) |

## Usage

The following example will deploy TeamCity agents to Blu.

Install [Docker Community Edition](https://store.docker.com/search?offering=community&type=edition).

Clone the necessary repositories:

```bash
$> git clone git@github.com:daptiv/teamcity.git
$> git clone git@github.com:daptiv/terraform_environment.git
```

Run the Terraform configuration to deploy TeamCity agents:

```bash
$> cd teamcity/terraform/teamcity_agents
$>
$> export AWS_CRED_DIR='~/.aws/'
$> export AWS_ACCESS_KEY_ID='access_key_for_blu'
$> export AWS_SECRET_ACCESS_KEY='secret_access_key_for_blu'
$> export CHEF_CONFIG_DIR='~/.chef/'
$> export CHEF_SECRET_FILE='my_data_bag_key'
$> export TF_VARIABLE_FILE='us_blu.tfvars'
$> export TF_VARIABLE_PATH='../../../terraform_environment/variables/'
$>
$> docker-compose run --rm terraform rake validate
$> docker-compose run --rm terraform rake deploy
```

Verify that provisioned services are operational:

```bash
$> docker-compose run --rm terraform rake verify
```

Deprovision all services deployed by this configuration:

```bash
$> docker-compose run --rm terraform rake destroy
```

## Modules

The following modules are defined in the *modules.tf* file.

| Name | Description |
|------|-------------|
| [instances](modules/instances) | Creates individual EC2 instances running Elasticsearch. |
| [load_balancers](modules/load_balancers) | Creates a Consul ELB. |
| [volumes](modules/volumes) | Creates volumes for storing critical data independent of EC2 instance lifecycle. |

## Input Variables

The following root level inputs are required to successfully apply all modules contained in this Terraform configuration.  These variables are read from the environment specific *.tfvars* files contained in the [terraform_environment](https://github.com/daptiv/terraform_environment) repo.

| Name | Description |
|------|-------------|
| bastion_host | FQDN or IP address of bastion host to use to connect to destination EC2 instances. |
| bastion_user | Username used to authenticate SSH sessions to bastion host instance. |
| chef_environment | Chef environment to associate with new EC2 instances. |
| chef_server_url | Chef server URL. |
| chef_user_name | Username used to authenticate Chef server sessions. |
| chef_version | Version of the Chef client to install on EC2 instances. |
| domain_name | Domain name associated with the current VPC. |
| env_hostname_prefix | AWS environment name abbreviation. (Ex. BLU) |
| instance_key_name | Name of EC2 key pair to associate with new EC2 instances. |
| instance_private_key | Private key file used to authenticate EC2 SSH sessions. |
| teamcity_agent_ami_name | Name of AMI to use when creating servers. |
| teamcity_agent_ami_owners | Comma separated list of AWS account IDs to filter on when locating AMI. |
| teamcity_agent_data_volume_size | Desired size of the 'data' volume. |
| teamcity_agent_instance_count | Desired number of servers. |
| teamcity_agent_instance_type | Instance type to use when provisioning servers. |
| teamcity_agent_instance_user | Username used to authenticate SSH sessions to destination EC2 instances. |
| teamcity_agent_log_volume_size | Desired size of the 'log' volume. |
| teamcity_agent_service_name | Unique identifier to use when naming resources provisioned by this configuration. |
| remote_state_bucket | S3 bucket where Terraform state files are stored. |
| remote_state_region | AWS region to use when accessing S3. |
| secret_key_file | Private key file used to access Chef data bags. |
| user_key_file | Private key file used to authenticate Chef server sessions. |
| vpc_state_file | Name of Terraform state file containing VPC state. |

## Output Variables

The following root level outputs are available once all modules in this Terraform configuration have been applied.  These variables can by read by other Terraform configurations via the "terraform_remote_state" resource.

| Name | Description |
|------|-------------|
| non_yet |  |

## Contributing

1. Fork the repository on GitHub.
2. Create a named feature branch.
3. Write your change.
4. Write tests for your change, if applicable.
5. Run the tests, ensuring they all pass.
6. Submit a pull request.

## License and Authors

Author:: Changepoint Engineering (cpc_sea_teamengineering@changepoint.com)

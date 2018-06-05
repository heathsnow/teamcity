# teamcity

Configuration for deploying TeamCity in an AWS VPC.

## Directory Structure

| Name | Description |
|------|-------------|
| [chef](chef) | Chef cookbooks which install and configure services on target servers. |
| [gocd](gocd) | GoCD pipeline configurations. |
| [packer](packer) | Packer templates which create application specific AMIs for use in EC2. |
| [terraform](terraform) | Terraform configurations which provision infrastructure in AWS. |

## Contributing

1. Fork the repository on GitHub.
2. Create a named feature branch.
3. Write your change.
4. Write tests for your change, if applicable.
5. Run the tests, ensuring they all pass.
6. Submit a pull request.

## License and Authors

Author:: Changepoint Engineering (cpc_sea_teamengineering@changepoint.com)

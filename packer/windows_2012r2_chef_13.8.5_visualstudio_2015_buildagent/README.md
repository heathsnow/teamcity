# Build Agent AMI

Creates an EC2 AMI with daptiv_buildagent_windows_role cookbook run using the
windows_2012r2_chef_13.8.5_visualstudio_2015 AMI as its base.

## Prereq's

* [Packer](https://www.packer.io/intro/)

## Supported Platforms

* Windows 2012 R2

Usage
=====

```
$> rake build
```

## Contributing

1. Fork the repository on GitHub.
2. Create a named feature branch.
3. Write your change.
4. Write tests for your change, if applicable.
5. Run the tests, ensuring they all pass.
6. Submit a pull request.

## License and Authors

Author:: Changepoint Engineering (cpc_sea_teamengineering@changepoint.com)

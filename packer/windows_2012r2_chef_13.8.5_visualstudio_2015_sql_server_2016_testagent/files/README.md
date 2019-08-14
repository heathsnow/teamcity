semver_helper
=============

A ruby helper script to be used by CI builds to generate semantic versions based on repository tags in Github.

Add a call to this script at the start of your CI build to automate the setting of a semantic version for your build.

An example implementation can be found in the Daptiv.Bcl teamcity project.

This script works as follows:

- It first looks for repository tags on github that match the semver spec and uses the highest version found as a basis for further execution.
    - If no valid semver tag exists on a repo, it will create a tag for version 0.0.1.
- Upon locating a valid tag the script then determines if the build is for a master or feature branch.
- After determining branch it looks for an associated pull request and then outputs a new version based on the body of the pull request.
    - If there is no pull request found, then for feature branches the script will exit with an intentional error to fail the build; master branch builds without pull requests will have their patch build number incremented.
- The first line of pull request body (main comment) is parsed to determine how to increment the version
    - MAJOR on the first line will increment the Major version and reset the Minor and Patch versions to zero.
    - MINOR on the first line will increment the Minor version and reset the Patch version to zero (Major version will be unchanged).
    - Any other string on the first line (as well as a null body) will increment the Patch version and leave the other versions unchanged.
- Feature branch builds will additionally gain a pre-release suffix that contains the pull request ID and number of commits that have occured on the branch since creation.

## Terminologies
- Chef Zero -> a deployment style where Chef server-client is installed in one server
- Chef Client -> machines managed by the Chef server
- Chef Workstation -> developer tool kit that includes Chef Infra, InSpec and Habitat plus a host of resources, helpers and testing tools that make automating infrastructure, application and security testing easier
- Chef Resources -> built-in functions to perform file/user/package-related operations
- Chef Recipe -> Group of resources. Stored in a `.rb` (Ruby) file.
- Chef Cookbook -> Re-usable and shareable units formed by multiple recipes

## Use case
To manage and install services in a single server (Chef Zero setup)

## Todos
1. A Chef recipe that runs the following:
    - Install Apache2 package
    - Install Mysql package
    - Create index.html in '/var/www/html/' folder
    - index.html should contain "Hello [Your Name]"

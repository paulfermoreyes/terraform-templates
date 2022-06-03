## AWS Terraform Deployment
#### Templates
- `./management`
- `./application`

Deployment of Management Infra
1. Navigate to `./management`
2. Execute the following
    ```bash
    terraform init
    # When asked about the name of the S3 bucket, input terraform-state
    # Initializing the backend...
    # bucket
    #     The name of the S3 bucket

    #     Enter a value: terraform-state
    terraform apply
    ```
3. To check the IP address of bastion and workspace, execute `terraform output`
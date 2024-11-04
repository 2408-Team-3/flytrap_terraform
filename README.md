# Instructions

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

3. Create a new secret for your RDS database credentials by running the following code snippet.
    - Update the `secret-string` to include your desired PostgreSQL username and password.
    - Update the `region` to your AWS region.

    ```bash
    aws secretsmanager create-secret \
        --name flytrap_db_credentials \
        --description "Credentials for Flytrap database" \
        --secret-string '{"username":"dev_user", "password":"dev_password"}' \
        --region us-east-1
    ```

4. Update any `variables.tf` files as needed. Adjust the AWS region and any desired changes to the default CIDR blocks.

5. Run `terraform init` and `terraform apply`.

6. Run `terraform destroy` to destroy the provisioned architecture.
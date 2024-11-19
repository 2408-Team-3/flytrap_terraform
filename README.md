# Instructions

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

3. Create a secret for your RDS database credentials by running the following code snippet.
    - Update the `secret-string` to include your desired PostgreSQL username and password.
    - Update the `region` to your AWS region.

    ```bash
    aws secretsmanager create-secret \
        --name flytrap_db_credentials \
        --description "Credentials for Flytrap database" \
        --secret-string '{"username":"flytrap_admin", "password":"flytrap_password"}' \
        --region us-east-1
    ```
4. Create a secret for a JSON Web Token secret key for secure communication with the Flytrap API by
running the following code snippet.

    ```bash
    aws secretsmanager create-secret \
      --name jwt_secret_key \
      --description "JWT Secret Key for Flytrap API" \
      --secret-string "{\"jwt_secret_key\":\"$(openssl rand -hex 32)\"}"
    ```

5. Run `terraform init`.

6. Run `terraform apply -var="aws_region=us-east-1"` to set your AWS region and provision the architecture.
Update the value in the command to use your AWS region.

7. Run `terraform destroy -var="aws_region=us-east-1"` to destroy the provisioned architecture. Update
the value in the command to use your AWS region.
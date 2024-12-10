![Organization Logo](https://raw.githubusercontent.com/getflytrap/.github/main/profile/flytrap_logo.png)

# Flytrap Terraform Installation Guide
The Flytrap Terraform repository provides everything you need to set up Flytrap in a production environment. Using Terraform, you can deploy the required AWS infrastructure, including the API, processor, database, and all related services, ensuring Flytrap is fully operational in your cloud environment.

This guide will walk you through provisioning Flytrap's architecture using Terraform.

To learn more about Flytrap, check out our [case study](https://getflytrap.github.io/).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Getting Started
To deploy Flytrap in your AWS account, follow these steps:

1. Install Prerequisites:
  - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
  - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2. Clone the Repository:
    ```bash
    git clone https://github.com/getflytrap/flytrap_terraform.git
    cd flytrap_terraform
    ```

## 🕵️‍♀️ Setting Up Secrets
Flytrap uses AWS Secrets Manager to securely store sensitive information like database credentials and JWT secret keys.

1. **Create Database Credentials:** Run the following command to create a secret for your PostgreSQL database credentials. Replace the values as necessary:

    ```bash
    aws secretsmanager create-secret \
        --name flytrap_db_credentials \
        --description "Credentials for Flytrap database" \
        --secret-string '{"username":"flytrap_admin", "password":"flytrap_password"}' \
        --region us-east-1
    ```
    - `flytrap_admin`: Replace with your desired PostgreSQL username.
    - `flytrap_password`: Replace with your desired PostgreSQL password.
    - `us-east-1`: Replace with your AWS region.

2. **Create a JWT Secret Key:** Run the following command to create a secret for the JWT secret key used for secure communication with the Flytrap API:

    ```bash
    aws secretsmanager create-secret \
      --name jwt_secret_key \
      --description "JWT Secret Key for Flytrap API" \
      --secret-string "{\"jwt_secret_key\":\"$(openssl rand -hex 32)\"}"
    ```
    
    This generates a secure 32-byte random key for JWT signing.

## 📦 Deploying Flytrap
1. **Initialize Terraform:** Run the following command to initialize Terraform and download the required providers:

    ```bash
    terraform init
    ```

2. **Apply the Terraform Configuration:** Run the following command to set your AWS region and provision the architecture:

    ```bash
    terraform apply -var="aws_region=us-east-1"
    ```

    - Replace `us-east-1` with your AWS region.

### 🌟 What Terraform Will Provision:
The Flytrap architecture manages the flow of error data from capture to resolution, leveraging AWS services for efficiency and scalability. Terraform will provision:
- **API Gateway:** Validate and route incoming error data from Flytrap SDKs.
- **Amazon SQS:** Decouple ingestion and processing by queuing error messages for efficient handling.
- **AWS Lambda:** Process error payloads, unminify stack traces using S3 source maps, and store data in the database.
- **Amazon RDS:** Set up a PostgreSQL database as the central repository for structured error and project data.
- **S3 Bucket:** Store source maps securely for error trace resolution.
- **Amazon EC2:** Host the React-based dashboard and the Flytrap API, enabling developers to manage errors and projects.
- **VPC:** Create a Virtual Private Cloud (VPC) to isolate and secure resources, ensuring network-level control and protection for all Flytrap services.

### 🎯 Post-Provisioning Outputs
After Terraform completes the setup, it will generate several outputs critical for accessing and managing Flytrap:

- **`flytrap_app_public_ip_for_DNS`:** The public IP address of the Flytrap application EC2 instance. Use this to configure your DNS settings if needed.
- **`flytrap_bucket_name`:** The name of the Flytrap S3 bucket where you can upload source maps for unminifying stack traces. This bucket is critical for resolving errors in minified code.
- **`flytrap_client_dashboard_url`:** The URL for accessing the Flytrap dashboard. Developers can use this dashboard to view, manage, and resolve captured errors.
- **`default_admin_email_dashboard_login`:** The default admin email for logging into the Flytrap dashboard. Replace this with a more secure email address post-deployment.
- **`default_admin_password_dashboard_login`:** The default admin password for the Flytrap dashboard. Replace this immediately after the first login for security.

### 🔧 Post-Deployment Steps
1. **Configure DNS:** If desired, associate the `flytrap_app_public_ip_for_DNS` with a custom domain name using any DNS provider (e.g., AWS Route 53, GoDaddy, Cloudflare). This will simplify accessing the Flytrap application.  

    - Create an A record pointing to the public IP address (`flytrap_app_public_ip_for_DNS`).
    - For subdomains, create CNAME records pointing to the root domain or other destinations.  

    To enable HTTPS, provision an SSL certificate using [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) or [Certbot](https://certbot.eff.org/). Certbot can automatically configure SSL for NGINX on your EC2 instance.

    **Note:** HTTPS is required for sessions (cookies) to function properly and ensure secure communication between the client and the Flytrap application.

2. **Upload Source Maps:** Use the `flytrap_bucket_name` to securely upload source maps for resolving minified stack traces. Refer to the [Flytrap Processor](https://github.com/getflytrap/flytrap_processor) for more details.

3. **Secure Admin Credentials:** Update the default admin email and password after your first login via the Flytrap dashboard to enhance security.

3. **Create Developer Accounts:** The default admin account is meant only for user and project management. Developers, including the person provisioning this infrastructure, should create their own accounts via the Flytrap dashboard.

4. **Start Using Flytrap:** Access the dashboard using the `flytrap_client_dashboard_url`, log in with your updated admin credentials, and begin managing projects, users, and errors.

## 🖥️ Managing Your Flytrap Infrastructure

### Modifying Configuration
To make changes to the infrastructure, update the main.tf file or relevant configuration files, then reapply:

```bash
terraform apply -var="aws_region=us-east-1"
```
- Replace `us-east-1` with your AWS region.

Flytrap strives to be cost-effective by provisioning resources with default sizes, such as an RDS instance of `t3.micro` and an EC2 instance of `t2.small`. These configurations are suitable for small-scale applications and testing environments but can be increased as needed based on your application's size and the anticipated volume of errors. If you expect high traffic or frequent error logging, consider scaling up the RDS or EC2 instance types.

### Destroying the Infrastructure
To remove the Flytrap infrastructure from your AWS account, run:

```bash
terraform destroy -var="aws_region=us-east-1"
```

- Replace `us-east-1` with your AWS region.

This ensures all provisioned resources are cleaned up to avoid unnecessary charges.

## 🚦 Important Notes

1. **Secure Your AWS Account:** Ensure your AWS CLI is authenticated with appropriate permissions to create Secrets Manager entries, RDS instances, and other AWS resources.
2. **Monitoring Costs:** Flytrap uses AWS resources like RDS and Lambda, which may incur costs. Monitor your AWS usage to avoid unexpected charges.

For questions or issues, feel free to open an issue in this repository or contact the Flytrap team. 🚀

---

<div align="center">
  🪰🪤🪲🌱🚦🛠️🪴
</div>
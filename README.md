# Secure Site Environment with Jump Servers, Zabbix Monitoring, and CI/CD using Terraform

### Description:
The Hacker Technologies Project aims to design and implement a robust and secure environment for a web application. The project leverages various cutting-edge technologies to fortify the site's infrastructure against potential cyber threats. The key components of the project include Jump Servers, Zabbix Monitoring, Continuous Integration/Continuous Deployment (CI/CD) pipeline, and the utilization of Terraform for infrastructure as code.

#### 1. Jump Servers:
- Implementing a secure access gateway through Jump Servers to control and monitor access to the site's infrastructure.
- Employing secure authentication protocols and access controls to ensure only authorized personnel can access critical components.

#### 2. Zabbix Monitoring:
- Integrating Zabbix for comprehensive monitoring of the entire infrastructure, including servers, applications, and network devices.
- Setting up alerting mechanisms for proactive identification and response to potential security incidents or performance issues.

#### 3. CI/CD Pipeline:
- Establishing a CI/CD pipeline to automate the deployment process and ensure rapid, reliable, and secure releases of software updates.
- Implementing version control and automated testing within the CI/CD pipeline to maintain code integrity and reduce the risk of vulnerabilities.

#### 4. Test Environment:
- Creating a dedicated test environment within the CI/CD pipeline to simulate and validate changes before they are deployed to the production environment.

#### 5. Terraform for Infrastructure as Code:
- Utilizing Terraform to define, provision, and manage the infrastructure in a declarative manner.
- Implementing Infrastructure as Code (IaC) principles to enhance repeatability, scalability, and maintainability of the entire infrastructure.

### Benefits:
- **Enhanced Security:** The implementation of Jump Servers and strict access controls ensures a secure gateway, reducing the risk of unauthorized access.
- **Proactive Monitoring:** Zabbix provides real-time monitoring and alerting, enabling the quick identification and mitigation of security threats or performance issues.
- **Efficient Deployment:** The CI/CD pipeline streamlines the deployment process, reducing downtime and minimizing the window of vulnerability.
- **Scalability and Consistency:** Terraform's IaC approach allows for seamless scaling of infrastructure, ensuring consistency across environments.

This Project represents a comprehensive approach to building and maintaining a secure, monitored, and efficiently managed web application environment. Through the integration of these technologies, the project aims to establish a robust foundation for the site's operations while mitigating potential security risks.

## How to use

### 1. [Adding hosts to zabbix](https://youtu.be/igJCMYnx0LM)


### How to run


#### 1. Create AMIs:
- Create two AMIs:
   - One with Ubuntu 22.04 and PostgreSQL installed.
   - Another with Ubuntu 22.04, PostgreSQL, and the Zabbix Client set up.

#### 2. Set up GitHub Repository:
- Fork the [get-it-django](https://github.com/RicardoRibeiroRodrigues/get-it-django) repository.
- [Generate a Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with at least webhook permissions.

#### 3. Configure Environment Variables:
- Copy `.env.example` to `.env` in the forked repository.
- Replace the placeholder variables in `.env` with your specific values.
- Modify relevant variables in the `variables.tf` file in the Terraform folder.

#### 4. Run Terraform:
- Open a terminal in the `terraform` folder.

```bash
# Initialize Terraform
terraform init

# Generate and review the Terraform plan
terraform plan -out myPlan

# Apply the Terraform plan
terraform apply myPlan


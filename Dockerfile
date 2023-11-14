# Base image
FROM hashicorp/terraform

# Set working directory
WORKDIR /app

# Copy the Terraform files into the container
COPY . .

# Install any necessary packages or dependencies
# RUN apk update && apk add --no-cache git

# # Install the AWS CLI
# RUN apk add --no-cache \
#     python3 \
#     gcc \
#     python3-dev \
#     py3-scipy \
#     py3-numpy \
#     py3-pandas \
#     py3-pip \
#     && pip3 install --upgrade pip \
#     && pip3 install --no-cache-dir \
#     awscli boto3 sagemaker \
#     && rm -rf /var/cache/apk/*

# Export .env variables
# CMD ["/bin/sh", "-c", "source .env"]

# Define the entrypoint for the container
ENTRYPOINT ["sh"]
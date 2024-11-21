
import sys
import boto3 


# Initialize datazone client
region = 'us-east-1'
dzclient = boto3.client(service_name='datazone', region_name='us-east-1') 

def create_domain(name): 
    return dzclient.create_domain( 
        name = name, 
        description = "this is a description", 
        domainExecutionRole = "arn:aws:iam::<account>:role/AmazonDataZoneDomainExecutionRole", 
    )

def create_project(domainId): 
    return dzclient.create_project(domainIdentifier = domainId, name = "sample-project")
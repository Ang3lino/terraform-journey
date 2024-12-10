### **POC: Using Amazon DataZone with Amazon Redshift for Pfizer**

#### **What is Amazon DataZone?**
Amazon DataZone (DZ) is a data governance service developed by AWS. It streamlines data production and consumption across teams through approval-based workflows. Key features include:
- Automatic schema inference.
- Naming conventions for schemas and assets.
- Visualization of schema composition and data relationships.

---

#### **Prerequisites**
- A Redshift cluster must be created before starting the process.

---

#### **Steps**

1. **Create Users and Assign Policies**  
   Define users and assign policies based on their roles (e.g., producing or consuming data in Redshift/DataZone). The required policies are:  
   - `AmazonRedshiftFullAccess`
   - `AmazonDataZoneFullAccess`
   - `AmazonRedshiftDataFullAccess`
   - `AmazonRedshiftQueryEditorV2FullAccess`

2. **Enable the Blueprint**  
   The `admin-datazone` user must enable the appropriate blueprint. For this POC, use the `DefaultDataWarehouse` blueprint. You can restrict projects during this step.

3. **Create a Parameter Set for Redshift**  
   Follow the steps to create a parameter set in the blueprint to connect to Redshift. When creating the secret for the Redshift cluster credentials, ensure you add the required tags. Missing tags will prevent the secret from appearing in later steps.

4. **Set Up Projects in DataZone**  
   - Create three projects in the DZ portal: one for the DZ administrator, one for publishing data, and another for consuming data.  
   - Note: Users other than the domain creator may face difficulties managing the domain.

5. **Create an Environment Profile**  
   - For both producers and consumers, create an environment profile by selecting the project and the corresponding parameter set.  
   - You can set specific schemas (e.g., default, existing schemas) to publish or none for consumers case in this step.

6. **Publish Data**  
   - In the producer’s project, create a data source.  
   - Select the Redshift cluster as the source, define the schema, and choose tables to include.  
   - Metadata can be updated dynamically (e.g., when consumed or at scheduled intervals).  
   - After creation, review and approve the schema attributes and naming conventions.  
   - To make the asset visible to other users, publish it.

7. **Consume Data**  
   - In the consumer’s project, search for the desired asset and request access through a subscription.  
   - The producer must approve the request. Once approved, the data can be queried using the Query Editor in Redshift.

---

#### **Notes**
- **Parameter Set Creation**: The CLI does not support parameter set creation.  
- **Custom Roles for Blueprint Admins**: Documentation lacks detailed descriptions of the required roles in case you use IaC approach. Reverse engineering was necessary to infer the correct setup. Incorrect role configurations may lead to issues like undeletable environments.  
- **Cluster Recreation**: If a Redshift cluster is deleted and recreated, DZ does not account for these changes, potentially causing unexpected behavior.

---

#### **References**
[1] *Getting started with Amazon DataZone using Amazon Redshift | Amazon Web Services*  
[YouTube Link](https://youtu.be/-CByCCCxnPM?si=70kNtrDqJP6f3_UW)  

[2] *Amazon DataZone Quickstart with Amazon Redshift*  
[Documentation PDF](https://docs.aws.amazon.com/pdfs/datazone/latest/userguide/datazone-ug.pdf)  
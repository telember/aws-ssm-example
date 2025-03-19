from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.management import SystemsManager
from diagrams.aws.network import VPC, InternetGateway
from diagrams.aws.security import IAMRole, IAM
from diagrams.aws.general import Client

with Diagram("AWS SSM with EC2 and RDS via Internet Gateway", show=False, outformat="jpg"):
    ssm = SystemsManager("SSM")

    with Cluster("VPC"):
        igw = InternetGateway("Internet Gateway")
        
        with Cluster("Public Subnet"):
            ec2 = EC2("EC2 Instance with Public IP")
        
        with Cluster("Private Subnet"):
            rds = RDS("RDS Instance")

        vpc = VPC("VPC")

    # Internet Gateway connects to SSM (AWS Region)
    igw >> Edge(label="connects to") >> ssm

    # EC2 connecting to RDS
    ec2 >> Edge(label="Connects to") >> rds

    # EC2 accessing the internet through Internet Gateway
    ec2 >> Edge(label="Internet Access") >> igw

 
    

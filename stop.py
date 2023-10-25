import boto3

def lambda_handler(event, context):
   
    ec2 = boto3.client('ec2', region_name='us-east-1')
   
    filters = [
        {
            'Name': 'tag:Environment',
            'Values': ['Dev']
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]

    instances = ec2.describe_instances(Filters=filters)

    instance_ids = []
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])

    if instance_ids:
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopped the following instances: {', '.join(instance_ids)}")
    else:
        print("No instances found with the specified tag and in a running state.")
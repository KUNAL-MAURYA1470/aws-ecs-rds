import json
import boto3
import os

def lambda_handler(event, context):
    service_client = boto3.client('secretsmanager')
    arn = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']
    
    metadata = service_client.describe_secret(SecretId=arn)
    if not metadata['RotationEnabled']:
        raise ValueError("Secret %s is not enabled for rotation" % arn)
    versions = metadata['VersionIdsToStages']
    if token not in versions:
        raise ValueError("Secret version %s has no stage for rotation of secret %s." % (token, arn))
    if "AWSCURRENT" in versions[token]:
        return
    elif "AWSPENDING" not in versions[token]:
        raise ValueError("Secret version %s not set as AWSPENDING for rotation of secret %s." % (token, arn))
    
    if step == "createSecret":
        create_secret(service_client, arn, token)
    elif step == "setSecret":
        set_secret(service_client, arn, token)
    elif step == "testSecret":
        test_secret(service_client, arn, token)
    elif step == "finishSecret":
        finish_secret(service_client, arn, token)
    else:
        raise ValueError("Invalid step parameter")

def create_secret(service_client, arn, token):
    service_client.get_secret_value(SecretId=arn, VersionStage="AWSCURRENT")
    try:
        service_client.get_secret_value(SecretId=arn, VersionId=token, VersionStage="AWSPENDING")
    except service_client.exceptions.ResourceNotFoundException:
        passwd = service_client.get_random_password(ExcludeCharacters='/@"\'\\')
        current_dict = json.loads(service_client.get_secret_value(SecretId=arn, VersionStage="AWSCURRENT")['SecretString'])
        current_dict['password'] = passwd['RandomPassword']
        service_client.put_secret_value(SecretId=arn, ClientRequestToken=token, SecretString=json.dumps(current_dict), VersionStages=['AWSPENDING'])

def set_secret(service_client, arn, token):
    pass

def test_secret(service_client, arn, token):
    pass

def finish_secret(service_client, arn, token):
    metadata = service_client.describe_secret(SecretId=arn)
    current_version = None
    for version in metadata["VersionIdsToStages"]:
        if "AWSCURRENT" in metadata["VersionIdsToStages"][version]:
            if version == token:
                return
            current_version = version
            break
    service_client.update_secret_version_stage(SecretId=arn, VersionStage="AWSCURRENT", MoveToVersionId=token, RemoveFromVersionId=current_version)

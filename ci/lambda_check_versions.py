import re
import requests

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities import parameters
import boto3


SSM_PARAM_CODEBUILD_PROJECT  = env['SSM_PARAM_CODEBUILD_PROJECT']
SSM_PARAM_LAST_BUILT_VERSION = env['SSM_PARAM_LAST_BUILT_VERSION']

logger = Logger(level='DEBUG')
codebuild = boto3.client('codebuild')


# proj_name = parameters.get_parameter('alpine-ssm-agent-build/codebuild-project-name')
# return parameters.get_parameter('/alpine-ssm-agent-build/last_built_version')


def get_latest_version():
    response = requests.get('https://api.github.com/repos/aws/amazon-ssm-agent/tags')
    if response.status_code != 200:
        raise Exception('Unable to get versions from Github')

    r = re.compile('\d+\.\d+\.\d+') ## This excludes versions <=2. since their tags starts w/ v
    versions = [v['name'] for v in response.json() if r.match(v['name'])]
    return versions[0]

def get_last_built_version():
    try:
        return parameters.get_parameter(SSM_PARAM_LAST_BUILT_VERSION)
    except parameters.GetParameterError:
        return '0.0.0.0'

# @logger.inject_lambda_context
def handler(event, context):
    lastver   = get_latest_version()
    lastbuilt = get_last_built_version()
    logger.debug(f'lastver:   {lastver}')
    logger.debug(f'lastbuilt: {lastbuilt}')
    
    if lastver > lastbuilt:
        proj_name = parameters.get_parameter(SSM_PARAM_CODEBUILD_PROJECT)
        env_override = [{'name': 'SSM_VERSION', 'value': lastver, 'type': 'PLAINTEXT'}]
        codebuild.startbuild(projectName=proj_name environmentVariablesOverride=env_override)


if __name__ == '__main__':
    handler({}, {})


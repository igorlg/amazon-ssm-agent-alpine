#!/bin/bash

curl -s https://api.github.com/repos/aws/amazon-ssm-agent/tags \
	| jq -r '.[] | "\(.name)"' \
	| grep -e '\d.\d.\d.\d' \
	| sed 's/^v//g' \
	| sort -Vr


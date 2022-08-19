#!/bin/bash

#
# List all available versions of the SSM Agent from the GitHub Releases page
# using the GitHub API.
# 
# Versions are listed in descending order.
# 
# Note: The grep and sed commands are used to filter and sanitise the tags, 
# leaving only the numeric version format "a.b.c.d" with a, b, c, d all numbers
#

curl -s https://api.github.com/repos/aws/amazon-ssm-agent/tags \
	| jq -r '.[] | "\(.name)"' \
	| grep -e '\d.\d.\d.\d' \
	| sed 's/^v//g' \
	| sort -Vr

# amazon-ssm-agent-alpine
Alpine Linux build for Amazon SSM Agent

# TODO

In `Dockerfile`

[] Feed keys from secret to build instead of generating new ones

In `Makefile`

[x] Fix VERSIONS variable, to use script `list_versions.sh` instead of reading from a file
[] Make sure that Makefile doesn't try to rebuild files already present in `target/` folder
[] Replace Makefile with [Justfile](https://github.com/casey/just)

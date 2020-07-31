#!/bin/bash
GITHUB_TOKEN=9d9aad51a3eb343d67bdab7c8570774b2405d078
GITHUB_BASEURL=https://api.github.com
GITHUB_API=/repos/ardito-jp/sb-scm-api/pulls?state=open

curl -k -s -u :$GITHUB_TOKEN $GITHUB_BASEURL$GITHUB_API

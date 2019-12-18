#!/bin/bash

set -x -u -e

ytt -f openapi.star -f expand.yml -f examples/basic/ \
	--file-mark expand.yml:exclusive-for-output=true

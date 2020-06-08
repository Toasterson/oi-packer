#!/usr/bin/env bash

packer build -var-file=.packer-vars.json -parallel=false hipster.pkr.hcl

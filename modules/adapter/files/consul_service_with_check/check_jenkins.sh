#!/usr/bin/env bash

STATUS=$(service jenkins status)

if [[ "$STATUS" =~ "not running" ]]; then
  exit 1
else
  exit 0
fi

#!/usr/bin/env bash

STATUS=$(st2ctl status)

if [[ "$STATUS" =~ "not running" ]]; then
  exit 1
else
  exit 0
fi

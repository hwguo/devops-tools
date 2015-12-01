#!/bin/bash

for proc in $(find /proc -maxdepth 1 -regex '/proc/[0-9]+'); do
    printf "%2d\t %5d\t %s\n" \
        "$(cat $proc/oom_score)" \
        "$(basename $proc)" \
        "$(cat $proc/cmdline | tr '\0' ' ' | head -c 100)"
done 2>/dev/null | sort -nr | head -n 10

#!/bin/bash

ls -al /var/lib/postgresql/data &>/dev/null || exit 1

exit 0
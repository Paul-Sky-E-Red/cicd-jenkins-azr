#!/bin/bash
set -e

# A simple wrapper script to create multiple users in Kubernetes, change the names as needed.
# Usage: ./wrapper.sh

for USER in paul1 paul2 paulx;do
    for STAGE in dev prod; do
        echo "Creating User: $USER-$STAGE"
        ./create-user.sh $USER-$STAGE
        echo "User $USER-$STAGE created successfully."
    done
done
echo "All users created successfully."
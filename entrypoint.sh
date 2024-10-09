#!/bin/bash

# Source the nvm script
export NVM_DIR="/usr/local/nvm"
source $NVM_DIR/nvm.sh

# Execute the passed command arguments
exec "$@"

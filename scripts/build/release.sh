#!/bin/bash

# This script assumes you're running it from the root of the project
# i.e. ./scripts/build-prod.sh

crystal build src/tanda_webhook.cr --release --no-debug --progress --stats \
  && mv tanda_webhook bin/tanda-webhook \
  && echo \
  && printf "\e[32mSuccess:\e[0m compiled release binary to $(pwd)/bin/tanda-webhook\n"

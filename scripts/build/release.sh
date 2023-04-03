#!/bin/bash

crystal build src/tanda_webhook.cr --release --no-debug --progress && mv tanda_webhook bin/tanda-webhook

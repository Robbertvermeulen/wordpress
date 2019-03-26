#!/bin/bash
set -euo pipefail

# mute CMD from official wordpress image
sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh

# execute bash script from official wordpress image
source /usr/local/bin/docker-entrypoint.sh

# custom scripts
user.sh
ssl.sh

# execute CMD
exec "$@"
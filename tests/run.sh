#!/bin/bash -e

cd "$(dirname "$(realpath "$0")")/.." || exit 1

function cleanup() {
    # Throw some logs
    echo
    echo "app logs:"
    podman logs app || :
    # Stop everything
    podman stop app &>/dev/null || :
    podman stop database &>/dev/null || :
    podman network rm php-app-migration &>/dev/null || :
}
trap cleanup EXIT

# Rebuild images
podman build tests/database -t database
podman build . -t app -f tests/app/Containerfile

# Create network for aardvark
podman network create php-app-migration

# Start up
podman run --rm -d --name database --network=php-app-migration --healthcheck-command 'CMD-SHELL mysqladmin -h localhost -u visitor --password="R3dh4t1!" status' database
podman run --rm -dp 8080:8080 --network=php-app-migration --name app app
echo -n "Waiting for database to be up"
while ! podman healthcheck run database &>/dev/null; do
    echo -n "."
    sleep 1
done
echo
echo

# See if app is responding
ret=0
if ! curl -s http://localhost:8080 | grep -qF 'You are the visitor number'; then
    # Dump logs and fail out if not
    podman logs app
    ret=1
else
    # Show multiple curls if responding
    echo "Curling repeatedly:"
    for _ in $(seq 10); do
        curl -s http://localhost:8080
        echo
        sleep 1
    done
fi

# cleanup will run
exit $ret

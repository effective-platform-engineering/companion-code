## ***Exercise 4.2: Create a bash script that will sign a docker image and then verify the results***

Now that we’ve talked about how to write policies, use them with compliance at the point of change, and the importance of supply chain security, apply what you’ve learned and write a zero trust policy that enforces our requirements and can be reused as a Compliance controller. To do this, you’ll need to use a tool called Cosign. Cosign is a project managed by Sigstore, a governing body within the OpenSSF (Open Source Security Foundation). 

Also, consider how you might write a policy that enforces our image security concerns, from code signing to image signing.

Note: You can learn about Software Supply Chain security in great detail by learning more about the projects within Sigstore and the OpenSSF.

### **Solution**

#!/usr/bin/env bash
set -eo pipefail

# Script expects registry and image reference as parameters
registry="$1"
image="$2"

# Validate that the cosign generated key files are available in the current directly,
# and that the key passphrase is set in the local environment
if [ ! -f "cosign.key" ]; then
    echo "signing key not available; not able to sign image."
    exit 1
fi

if [ ! -f "cosign.pub" ]; then
    echo "verification key not available; not able to validate signing process."
    exit 1
fi

if [ ! "${COSIGN_PASSWORD}" ]; then
    echo "signing key passphrase is not available; not able to sign image."
    exit 1
fi

# Validate image registry credentials and access
if [ ! "${DOCKER_LOGIN}" ]; then
    echo "registry access username is not set, will not be able to push image."
    exit 1
fi

if [ ! "${DOCKER_PASSWORD}" ]; then
    echo "registry access password is not set, will not be able to push image."
    exit 1
fi

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_LOGIN}" --password-stdin "${registry}"

# get image manifest
docker image inspect --format='{{index .RepoDigests 0}}' "${registry}/${image}" > manifestid
# sign iamge and store signature
cosign sign --key cosign.key $(cat manifestid) -y
# verify signature
cosign verify --key cosign.pub "${registry}/${image}"
#!/bin/bash
set -e

# Read version from argument
VERSION=${1}
if [ -z "${VERSION}" ]; then
    echo "You need to set VERSION string to upload"
    echo 'Usage: docker run --rm -v $(pwd):/gopath/${$(pwd)#*${GOPATH}/} -w /gopath/${$(pwd)#*${GOPATH}/} tcnksm/go-release:1.5-beta VERSION USER TOKEN'
    exit 1
fi

# Read owner name from argument
OWNER=${2}
if [ -z "${OWNER}" ]; then
    echo "You need to set Github OWNER name (Github account name)"
    echo 'Usage: docker run --rm -v $(pwd):/gopath/${$(pwd)#*${GOPATH}/} -w /gopath/${$(pwd)#*${GOPATH}/} tcnksm/go-release:1.5-beta VERSION USER TOKEN'
    exit 1
fi

# Read GITHUB_TOKEN from argument
GITHUB_TOKEN=${3}
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "You need to set GITHUB_TOKEN"
    echo 'Usage: docker run --rm -v $(pwd):/gopath/${$(pwd)#*${GOPATH}/} -w /gopath/${$(pwd)#*${GOPATH}/} tcnksm/go-release:1.5-beta VERSION USER TOKEN'
    exit 1
fi

# Change directory where script is called
DIR=$(pwd)
cd ${DIR}

# Script must be called from $GOPATH/src/github.com/AUTHOR/REPO
REPO=$(basename "$(pwd)")

echo "====> Cross-compiling ${REPO} by mitchellh/gox"
# You can set ghr option via docker run option -e 'GOX_OPT=YOUR_OPT'"
XC_ARCH=${XC_ARCH:-386 amd64}
XC_OS=${XC_OS:-darwin linux windows}
XC_PARALLEL=${XC_PARALLEL:-6}

rm -rf go-release-pkg/
gox \
    -parallel=${XC_PARALLEL} \
    -os="${XC_OS}" \
    -arch="${XC_ARCH}" \
    -output="go-release-pkg/{{.OS}}_{{.Arch}}/{{.Dir}}" \
    ${GOX_OPT}

    
echo "====> Package all binary by zip"
mkdir -p ./go-release-pkg/dist/${VERSION}
for PLATFORM in $(find ./go-release-pkg -mindepth 1 -maxdepth 1 -type d); do
    PLATFORM_NAME=$(basename ${PLATFORM})
    ARCHIVE_NAME=${REPO}_${VERSION}_${PLATFORM_NAME}

    if [ $PLATFORM_NAME = "dist" ]; then
        continue
    fi

    pushd ${PLATFORM}
    zip ${DIR}/go-release-pkg/dist/${VERSION}/${ARCHIVE_NAME}.zip ./*
    popd
done

# Generate shasum
pushd ./go-release-pkg/dist/${VERSION}
shasum * > ./${VERSION}_SHASUMS
popd

echo "====> Release to GitHub by tcnksm/ghr"
# You can set ghr option via docker run option -e GHR_OPT=YOUR_OPT"
# e.g., "-e GHR_OPT=--replace"
ghr --username ${OWNER} \
    --repository ${REPO} \
    --token ${GITHUB_TOKEN} \
    ${GHR_OPT} \
    ${VERSION} go-release-pkg/dist/${VERSION}/

# Check command is success or not    
if [ $? -eq 0 ]; then
    echo ""
    echo "Artifacts are uploaded https://github.com/${OWNER}/${REPO}/releases/tag/${VERSION}"
    exit 0
fi 

exit $?

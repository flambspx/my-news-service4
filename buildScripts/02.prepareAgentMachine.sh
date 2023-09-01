#!/bin/bash
# shellcheck source=/dev/null

echo "Updating OS software"
sudo apt -y update

echo "Updating base libraries..."
sudo apt-get -y update
echo "Installing prerequisites..."
maxRetries=15
crtRetry=0
lSuccess=1

while [ $lSuccess -ne 0 ]; do
  sudo apt-get install -y ca-certificates curl gnupg2 fuse-overlayfs
  lSuccess=$?
  if [ $lSuccess -eq 0 ]; then
    echo "Libraries installed successfully"
  else
    crtRetry=$((crtRetry+1))
    if [ $crtRetry -gt $maxRetries ]; then
      echo "Could not install the required libraries after the maximum number of retries!"
      exit 1
    fi
    echo "Installation of required libraries failed with code $lSuccess. Retrying $crtRetry/$maxRetries ..."
    sleep 10
  fi
done

. /etc/os-release

echo "Installing buildah for OS release ${VERSION_ID}..."
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -fsL "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add - &&
sudo apt-get -qq -y update
sudo apt-get -qq -y install buildah

crtRetry=0
lSuccess=1
while [ $lSuccess -ne 0 ]; do
  sudo apt-get -qq -y install buildah
  lSuccess=$?
  if [ $lSuccess -eq 0 ]; then
    echo "Buildah installed successfully"
  else
    crtRetry=$((crtRetry+1))
    if [ $crtRetry -gt $maxRetries ]; then
      echo "Could not install buildah after the maximum number of retries!"
      exit 1
    fi
    echo "Installation of buildah failed with code $lSuccess. Retrying $crtRetry/$maxRetries ..."
    sleep 10
  fi
done

if [ ! "$(buildah version)" ] ; then
  echo "Buildah is not available! Cannot continue"
  exit 3
fi


echo "Machine prepared"
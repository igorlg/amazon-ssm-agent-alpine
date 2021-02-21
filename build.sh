#!/bin/ash
set -e -o pipefail
version_param="$1"

github_repo_url="https://github.com/aws/amazon-ssm-agent"
github_output_file="${version_param}.tar.gz"
github_archive_url="${github_repo_url}/archive/${github_output_file}"

echo "[Info] :: Downloading ${github_archive_url}..."
# Curl fails on non http status 2xx and follows redirect since archives are stored on CF/S3 via pre-sign urls.
curl -s --fail --location "${github_archive_url}" -o "${github_output_file}"
curl_status=$?

if [ $curl_status -eq 0 ]; then
  echo "[Info] :: ${github_output_file} downloaded. Extracting info to create the APKBUILD file "
  # Rationale:
  #   Unfortunately, amazon-ssm-agent doesn't publish the sha512sum of their releases nor does Github. I will cut a
  #   issue to amazon-ssm-agent repo. Hopefully, they wil add it in the future.
  # extract checksum
  checksum="$(sha512sum "${github_output_file}" | awk '{print $1}')"
  # Clean up file
  rm -f "${github_output_file}"

  # Replace vars in the template
  echo "[Info] :: Building version: ${version_param} checksum: ${checksum}"
  sed -e "s/SED_PKGVER/${version_param}/g" -e "s/SED_PKGSUM/${checksum}/g" APKBUILD.template > APKBUILD

  # Build
  echo "[Info] :: Buckle up and grab a coffee ... this might take a while"
  abuild -rF
else
  echo "[Error] :: ${github_archive_url} doesn't seem to exist. Have you specified the right version. Aborting..."
fi



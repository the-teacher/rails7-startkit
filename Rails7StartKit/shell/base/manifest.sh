# Run from the root of the project
#
# source Rails7StartKit/shell/base/manifest.sh

docker manifest create \
  iamteacher/rails7.base:latest \
  --amend iamteacher/rails7.base:arm64 \
  --amend iamteacher/rails7.base:amd64

docker manifest push iamteacher/rails7.base:latest

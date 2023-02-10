# Run from the root of the project
#
# source Rails7StartKit/shell/rails/manifest.sh

docker manifest create \
  iamteacher/rails7:latest \
  --amend iamteacher/rails7:amd64 \
  --amend iamteacher/rails7:arm64

docker manifest push iamteacher/rails7:latest

# Run from the root of the project
#
# source Rails7StartKit/shell/base/build.sh

docker build \
  -t iamteacher/rails7.base:arm64 \
  -f Rails7StartKit/docker/_Base.Dockerfile \
  --build-arg BUILDPLATFORM="linux/arm64" \
  --build-arg TARGETARCH="arm64" \
  .

docker build \
  -t iamteacher/rails7.base:amd64 \
  -f Rails7StartKit/docker/_Base.Dockerfile \
  --build-arg BUILDPLATFORM="linux/amd64" \
  --build-arg TARGETARCH="amd64" \
  .

# docker run -ti iamteacher/rails7.base:arm64 bash
# uname -m => aarch64

# docker run -ti iamteacher/rails7.base:amd64 bash
# uname -m => x86_64

# Run from the root of the project
#
# source Rails7StartKit/shell/rails/build.sh

docker build \
  -t iamteacher/rails7:arm64 \
  -f Rails7StartKit/docker/_Rails.Dockerfile \
  --build-arg BUILDPLATFORM="linux/arm64" \
  --build-arg TARGETARCH="arm64" \
  .

docker build \
  -t iamteacher/rails7:amd64 \
  -f Rails7StartKit/docker/_Rails.Dockerfile \
  --build-arg BUILDPLATFORM="linux/amd64" \
  --build-arg TARGETARCH="amd64" \
  .

# (crashed on M1 with) `qemu: uncaught target signal 6 (Aborted) - core dumped`
# docker build -t iamteacher/rails7:386 \
#   -f Rails7StartKit/docker/Dockerfile \
#   --build-arg BUILDPLATFORM="linux/386" \
#   --build-arg TARGETARCH="386" \
#   .

# docker run -ti iamteacher/rails7:arm64 bash
# uname -m => aarch64

# docker run -ti iamteacher/rails7:amd64 bash
# uname -m => x86_64

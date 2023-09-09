# Run from the root of the project
#
# source Rails7StartKit/shell/rails/push.sh

docker push iamteacher/rails7:arm64
docker push iamteacher/rails7:amd64
docker manifest push --purge iamteacher/rails7:latest

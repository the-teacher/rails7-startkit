#!/bin/bash

# source /dev/stdin <<< "$(\curl -sSL https://raw.githubusercontent.com/the-teacher/rails7-startkit/master/Rails7StartKit/install.sh)"

export TTY_OFF="-T"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Rails7. Start Kit"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

if command -v ruby &> /dev/null
then
  echo "=> Ruby found"
else
  echo "=> Ruby not found"
  echo "To continue please install Ruby"
  echo "https://www.ruby-lang.org/en/documentation/installation"
  return
fi

if command -v git &> /dev/null
then
  echo "=> Git found"
else
  echo "=> Git not found"
  echo "To continue please install git"
  echo "https://git-scm.com/downloads"
  return
fi

if command -v docker &> /dev/null
then
  echo "=> Docker found"
else
  echo "=> Docker not found"
  echo "To continue please install Docker"
  echo "https://docs.docker.com/get-docker"
  return
fi

if [[ $(docker ps) == *"CONTAINER ID"* ]]
then
  echo "=> Docker is running"
else
  echo "=> Docker not running"
  echo "To continue please run Docker"
  return
fi

if [[ $(docker compose version) == *"v2"* ]]
then
  echo "=> Docker Compose Version 2 found"
else
  echo "=> Docker Compose v2 not found"
  echo "To continue please install Docker Compose v2"
  echo "https://docs.docker.com/compose/install"
  exit
fi

if [ -d "./rails7-startkit" ]
then
  echo "Folder 'rails7-startkit' exists"
else
  echo "Folder 'rails7-startkit' does not exists"
  git clone https://github.com/the-teacher/rails7-startkit.git
fi

cd ./rails7-startkit
bin/setup
unset TTY_OFF

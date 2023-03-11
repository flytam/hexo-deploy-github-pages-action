#!/bin/sh -l

set -e

# check values

if [ -n "${PUBLISH_REPOSITORY}" ]; then
    TARGET_REPOSITORY=${PUBLISH_REPOSITORY}
else
    TARGET_REPOSITORY=${GITHUB_REPOSITORY}
fi

if [ -n "${BRANCH}" ]; then
    TARGET_BRANCH=${BRANCH}
else
    TARGET_BRANCH="gh-pages"
fi

if [ -n "${PUBLISH_DIR}" ]; then
    TARGET_PUBLISH_DIR=${PUBLISH_DIR}
else
    TARGET_PUBLISH_DIR="./public"
fi

if [ -z "$PERSONAL_TOKEN" ]
then
  echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
  exit 1
fi

REPOSITORY_PATH="https://x-access-token:${PERSONAL_TOKEN}@github.com/${TARGET_REPOSITORY}.git"

# deploy to
echo ">>>>> Start deploy to ${TARGET_REPOSITORY} <<<<<"

# Installs Git.
echo ">>> Install Git ..."
apt-get update && \
apt-get install -y git && \

# Directs the action to the the Github workspace.
cd "${GITHUB_WORKSPACE}"

echo ">>> Install NPM dependencies ..."
npm install

echo ">>> Clean folder ..."
npx hexo clean

echo ">>> Generate file ..."
npx hexo generate

echo ">>>  Deploy ..."
npx hexo deploy

cd $TARGET_PUBLISH_DIR

echo ">>> Config git ..."

# Configures Git.
git init

ls -al

echo '>>> Config git config...'

git config --global user.name "blog-bot"
git config --global user.email "blog-bot@github.com"


echo '>>> Config git remote add...'

git remote add origin "${REPOSITORY_PATH}"

echo '>>> Config git checkout...'

git checkout --orphan $TARGET_BRANCH

echo '>>> Config git add...'

git add .

echo '>>> Start Commit ...'
git commit --allow-empty -m "Building and deploying Hexo project from Github Action"

echo '>>> Start Push ...'
git push -u origin "${TARGET_BRANCH}" --force

echo ">>> Deployment successful!"

#!/bin/bash

# Build the site
echo "Building the site..."
bundle exec jekyll build

# Check if build was successful
if [ $? -ne 0 ]; then
  echo "Build failed. Exiting."
  exit 1
fi

# Check if we're on the main branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
  echo "You're not on the main branch. Please switch to main before deploying."
  exit 1
fi

# Make sure everything is committed
if [ -n "$(git status --porcelain)" ]; then
  echo "There are uncommitted changes. Please commit all changes before deploying."
  exit 1
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push origin main

echo "Deployment complete! Your site should be available at https://yourusername.github.io/repository-name/"
echo "Remember to update the URL in the README.md file with your actual GitHub Pages URL." 
#!/bin/bash

# This script is designed to be run periodically (e.g., via cron)
# to update the Leatherman product listings with the latest data from eBay
# Note: This is an alternative to using GitHub Actions, which is the recommended approach

# Change to the project directory
cd "$(dirname "$0")"

# Log file for the update process
LOG_FILE="logs/update_log.txt"

# Create logs directory if it doesn't exist
mkdir -p logs

# Start logging
echo "=== Updating Leatherman listings at $(date) ===" >> $LOG_FILE

# Run the scraping script
bundle exec ruby scrape_ebay_listings.rb >> $LOG_FILE 2>&1

# Rebuild the Jekyll site if necessary (uncomment if you're hosting this somewhere that needs rebuilding)
# bundle exec jekyll build --incremental >> $LOG_FILE 2>&1

# Add, commit, and push changes if using git (uncomment if needed)
git status --porcelain | grep -q .
if [ $? -eq 0 ]; then
  echo "Changes detected, committing..." >> $LOG_FILE
  git add _leatherman/ assets/images/leatherman/ logs/update_log.txt
  git commit -m "Auto-update Leatherman listings - $(date)" >> $LOG_FILE 2>&1
  git push origin main >> $LOG_FILE 2>&1
else
  echo "No changes detected" >> $LOG_FILE
fi

echo "Update completed at $(date)" >> $LOG_FILE
echo "=======================================" >> $LOG_FILE 
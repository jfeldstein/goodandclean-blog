# Amazon Link Checker

This document explains the automated link checking system that runs daily to verify all Amazon product links on Good&Clean.shop.

## What It Does

The link checker:

1. Runs automatically every day at 2:00 AM UTC
2. Scans all product files and blog posts for Amazon links
3. Checks each link to verify it's accessible
4. Automatically retries links that return 5xx errors (server errors)
5. Generates a report of any problematic links
6. Emails a notification to jfeldstein@gmail.com if issues are found
7. Saves a JSON report as a GitHub Actions artifact for reference

## How It Works

The system uses a GitHub Actions workflow (`.github/workflows/check-amazon-links.yml`) that:

- Runs a Ruby script to find and check all Amazon product links
- Retries any links that return server errors (5xx) up to 5 times with exponential backoff
- Uses SMTP to send email reports when issues are detected
- Uploads a JSON report as an artifact for future reference

## Setting Up Email Notifications

For the email notifications to work, you need to add the following secrets to your GitHub repository:

1. Go to your repository's Settings → Secrets and variables → Actions
2. Add two new repository secrets:
   - `EMAIL_USERNAME`: Your Gmail address that will send the notifications
   - `EMAIL_PASSWORD`: An app password for your Gmail account (not your regular password)

**Important**: To create an app password for Gmail:
1. Go to your Google Account
2. Navigate to Security
3. Under "Signing in to Google," select "App passwords" (requires 2-Step Verification to be enabled)
4. Create a new app password for "GitHub Actions"
5. Use this generated password as your `EMAIL_PASSWORD` secret

## Manual Triggering

You can manually trigger the link checker at any time:

1. Go to the "Actions" tab in the GitHub repository
2. Select the "Check Amazon Links" workflow
3. Click "Run workflow"
4. Confirm by clicking "Run workflow" button

## Understanding the Reports

The email report includes:
- The URL that's having issues
- The HTTP status code returned (or "Error" if it couldn't connect)
- A description of the error

Common status codes:
- 404: Not Found - The product no longer exists
- 503: Service Unavailable - Amazon may be blocking requests or having issues
- 301/302: Redirect - The product URL has changed
- 403: Forbidden - Access is blocked (possibly rate limiting)

## Responding to Issues

When you receive a report of broken links:

1. Check the links manually in your browser
2. For permanently removed products:
   - Find a replacement product
   - Update the product file with the new link
   - Update any blog posts referencing the product
3. For temporary issues (like 503 errors):
   - Monitor for a few days to see if the problem persists
   - Contact Amazon if issues continue with active products

## Maintenance

The link checker is designed to run without intervention, but you should:

- Periodically review the GitHub Actions logs to ensure it's running properly
- Update the user agent in the script if Amazon begins blocking requests
- Consider adjusting the retry strategy if needed 
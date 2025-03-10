# Amazon Link Checker

This document explains the automated link checking system that runs daily to verify all Amazon product links on Good&Clean.shop.

## What It Does

The link checker:

1. Runs automatically every day at 2:00 AM UTC
2. Scans all product files and blog posts for Amazon links
3. Checks each link to verify it's accessible
4. Automatically retries links that return 5xx errors (server errors)
5. Generates a comprehensive report of any problematic links
6. Emails a detailed notification with all broken links to jfeldstein@gmail.com

## How It Works

The system uses a GitHub Actions workflow (`.github/workflows/check-amazon-links.yml`) that:

- Runs a Ruby script (`scripts/check_amazon_links.rb`) to find and check all Amazon product links
- Retries any links that return server errors (5xx) up to 5 times with exponential backoff
- Uses Mailgun's API to send detailed email reports when issues are detected
- Includes comprehensive troubleshooting information in the email report

## Setting Up Email Notifications

For the email notifications to work, you need to add the following secrets to your GitHub repository:

1. Go to your repository's Settings → Secrets and variables → Actions
2. Add two new repository secrets:
   - `MAILGUN_API_KEY`: Your Mailgun API key (begins with "key-")
   - `MAILGUN_DOMAIN`: Your Mailgun domain (e.g., "mg.yourdomain.com")

**Important**: To set up a Mailgun account if you don't have one:
1. Sign up at [Mailgun.com](https://www.mailgun.com/)
2. Verify your domain or use Mailgun's sandbox domain for testing
3. Find your API key in the Mailgun dashboard under "API Keys"
4. Copy your API key and domain to use as GitHub secrets

## Manual Triggering

You can manually trigger the link checker at any time:

1. Go to the "Actions" tab in the GitHub repository
2. Select the "Check Amazon Links" workflow
3. Click "Run workflow"
4. Confirm by clicking "Run workflow" button

## Understanding the Reports

The email report includes several sections:

### Summary Section
- Total number of problematic links found
- Breakdown of issues by status code (e.g., 404, 503, etc.)

### Detailed Report
- Clickable URLs of problematic links
- HTTP status codes or error messages
- Color-coded rows for easy identification of error types:
  - Red: Connection errors
  - Yellow: Server errors (5xx)
  - Orange: Client errors (4xx)

### Troubleshooting Guide
- Explanation of common error codes
- Suggestions for how to resolve different types of issues

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
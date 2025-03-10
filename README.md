# Good&Clean.shop

A curated collection of product recommendations hosted on GitHub Pages.

## Website

Visit the live site at: https://jfeldstein.github.io/goodandclean.shop/

## Adding Products

Products can be added in several ways:

### 1. Using the GitHub Actions Workflow (Recommended)

The easiest way to add a new product is through the GitHub Actions workflow:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Add New Product" workflow
3. Click on "Run workflow"
4. Enter the Amazon product URL (required)
5. Optionally provide:
   - Custom product title
   - Custom category
   - Product pros (comma-separated)
   - Product cons (comma-separated)
6. Click "Run workflow"

The workflow will automatically:
- Fetch product details from Amazon
- Download the product image
- Create the product page
- Commit and push the changes
- Deploy the updated site via GitHub Pages

### 2. Using the Ruby Script Locally

You can also use the Ruby script locally:

```bash
# Interactive mode
ruby add_product.rb

# Non-interactive mode
ruby add_product.rb --url https://www.amazon.com/dp/XXXXXXXXXX --non-interactive

# Process multiple URLs
./process_urls.sh
```

## GitHub Pages Setup

This site is configured to deploy automatically to GitHub Pages when changes are pushed to the main branch:

1. The GitHub Actions workflow in `.github/workflows/github-pages.yml` builds and deploys the site
2. The site is published to the `gh-pages` branch
3. GitHub serves the content from this branch at your GitHub Pages URL

## Local Development

To run the site locally:

1. Install dependencies: `bundle install`
2. Start the Jekyll server: `bundle exec jekyll serve`
3. Visit `http://localhost:4000/goodandclean.shop/` in your browser

## Updating Configuration

To update the site configuration, edit the `_config.yml` file:

- Update `baseurl` with your repository name
- Update `url` with your GitHub Pages URL
- Update `amazon_affiliate_id` with your Amazon Affiliate ID

## Automated eBay Listings

The site includes automation for keeping eBay product listings up-to-date with your Good&Clean eBay store.

### How It Works

1. The `scrape_ebay_listings.rb` script fetches the current listings from your eBay store
2. It creates Markdown files for each product in the `_leatherman` directory
3. Each product page includes the correct eBay link, redirecting visitors to your eBay listing
4. The script also removes listings that are no longer available (sold items)

### Setting Up Automated Updates

To keep your product listings in sync with your eBay store, you can use GitHub Actions:

#### GitHub Actions (Recommended)

The repository includes a GitHub Actions workflow that automatically:
- Runs every hour to check for new/updated/sold listings
- Commits any changes back to the repository
- Requires no manual setup beyond pushing the code to GitHub

The workflow file is located at `.github/workflows/update-ebay-listings.yml`.

To manually trigger the update process, you can:
1. Go to the "Actions" tab in your GitHub repository
2. Select the "Update eBay Listings" workflow
3. Click "Run workflow"

#### Alternative: Local Scheduled Tasks

If you prefer to run the updates locally instead of using GitHub Actions:

##### macOS/Linux (Cron)

1. Open your crontab for editing:
   ```
   crontab -e
   ```

2. Add a line to run the update script daily (for example, at 2 AM):
   ```
   0 2 * * * /path/to/your/site/update_listings.sh
   ```

3. Save and exit

##### Windows (Task Scheduler)

1. Open Task Scheduler
2. Create a new task to run `update_listings.sh` via WSL or Git Bash
3. Set it to run daily

## Development

### Prerequisites

- Ruby (version in `.ruby-version`)
- Bundler

### Getting Started

1. Install dependencies:
   ```
   bundle install
   ```

2. Run the Jekyll server:
   ```
   bundle exec jekyll serve
   ```

3. View the site at http://localhost:4000

## Managing eBay Links

The eBay listings are dynamically fetched from your eBay store page. If you need to:

- Change the eBay store URL, edit the URL in `scrape_ebay_listings.rb`
- Manually update the products, run `bundle exec ruby scrape_ebay_listings.rb`
- Force a rebuild of the site, run `bundle exec jekyll build`

## Features

- Responsive design that works on mobile, tablet, and desktop
- Product showcase with pros and cons
- Automatic fetching of product title and category from Amazon URLs
- Blog posts that can feature multiple products
- Automatic addition of your Amazon affiliate ID to all product links
- Easy to customize and extend
- Automatic eBay store integration

## Setup

1. Clone this repository
2. Update `_config.yml` with your information:
   - Change the `title`, `email`, and `description` (already set to Good&Clean)
   - Set your `github_username`
   - Update the `amazon_affiliate_id` with your Amazon Affiliate ID

## Running Locally

To run the site locally:

```
bundle exec jekyll serve
```

Then visit `http://localhost:4000/goodandclean.shop/`
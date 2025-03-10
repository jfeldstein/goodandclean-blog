# Good&Clean Blog

This is a Jekyll-based blog for Good&Clean products, featuring Amazon affiliate recommendations and eBay store listings.

## Automated eBay Listings

The site includes automation for keeping eBay product listings up-to-date with your Good&Clean eBay store.

### How It Works

1. The `scrape_ebay_listings.rb` script fetches the current listings from your eBay store
2. It creates Markdown files for each product in the `_leatherman` directory
3. Each product page includes the correct eBay link, redirecting visitors to your eBay listing

### Setting Up Automated Updates

To keep your product listings in sync with your eBay store, you can set up a scheduled task:

#### macOS/Linux (Cron)

1. Open your crontab for editing:
   ```
   crontab -e
   ```

2. Add a line to run the update script daily (for example, at 2 AM):
   ```
   0 2 * * * /path/to/your/site/update_listings.sh
   ```

3. Save and exit

#### Windows (Task Scheduler)

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

## Adding Products

You can add products in two ways:

### Using the Script (Recommended)

Run the script:

```
./add_product.rb
```

Follow the prompts to enter the required information.

### Manually

1. Create a new Markdown file in the `_products` directory
2. Use the proper front matter template

## Running Locally

To run the site locally:

```
bundle exec jekyll serve
```

Then visit `http://localhost:4000` in your browser.

## Deploying to GitHub Pages

1. Push your changes to GitHub
2. Go to your repository settings
3. Under "GitHub Pages", select the branch you want to deploy from
4. Your site will be available at `https://jfeldstein.github.io/goodandclean-blog/`

## Amazon Affiliate Program

Remember to follow Amazon's affiliate program rules:
- Disclose your affiliate relationship (already included in the footer and about page)
- Don't use affiliate links in emails or offline materials
- Don't make false claims about products

## License

This project is licensed under the MIT License - see the LICENSE file for details.
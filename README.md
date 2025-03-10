# Amazon Affiliate Product Recommendations Blog

This is a Jekyll-based blog for showcasing Amazon products with affiliate links. It's designed to be hosted on GitHub Pages and allows you to earn commission from Amazon's affiliate program.

## Features

- Responsive design that works on mobile, tablet, and desktop
- Product showcase with pros and cons
- Automatic fetching of product title and category from Amazon URLs
- Blog posts that can feature multiple products
- Automatic addition of your Amazon affiliate ID to all product links
- Easy to customize and extend

## Setup

1. Clone this repository
2. Update `_config.yml` with your information:
   - Change the `title`, `email`, and `description`
   - Set your `github_username`
   - Most importantly, update the `amazon_affiliate_id` with your Amazon Affiliate ID
3. Install required Ruby gems:
   ```
   gem install nokogiri open-uri
   ```

## Adding Products

You can add products in two ways:

### Using the Script (Recommended)

Run the script:

```
./add_product.rb
```

Follow the prompts to enter:
- Amazon product URL (title and category will be fetched automatically)
- Confirm or edit the fetched title and category
- Pros and cons

The script will:
- Extract the Amazon ASIN from the URL
- Fetch the product title and category automatically
- Create a properly formatted product file in the `_products` directory
- Set up the necessary front matter

### Manually

1. Create a new Markdown file in the `_products` directory
2. Use the following front matter template:

```yaml
---
layout: product
title: "Product Name"
slug: product-name
category: Category
image: /assets/images/product-placeholder.jpg
amazon_link: https://www.amazon.com/dp/ASIN/
pros:
  - Pro 1
  - Pro 2
  - Pro 3
cons:
  - Con 1
  - Con 2
---
```

3. Write your product review in Markdown format below the front matter

## Adding Product Images

1. Add your product images to the `assets/images` directory
2. Update the `image` path in the product's front matter to point to your image

## Writing Blog Posts

1. Create a new Markdown file in the `_posts` directory with the filename format: `YYYY-MM-DD-title.md`
2. Use the following front matter template:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD
categories: category1 category2
featured_products:
  - product-slug-1
  - product-slug-2
---
```

3. Write your blog post content in Markdown format
4. Reference products using their slugs in the `featured_products` section

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
4. Your site will be available at `https://yourusername.github.io/repository-name/`

## Customizing

- Edit the CSS in `assets/css/main.scss` to change the look and feel
- Modify the layouts in the `_layouts` directory to change the structure
- Update the templates in the `_includes` directory for reusable components

## Amazon Affiliate Program

Remember to follow Amazon's affiliate program rules:
- Disclose your affiliate relationship (already included in the footer and about page)
- Don't use affiliate links in emails or offline materials
- Don't make false claims about products
- Keep your affiliate ID private

## License

This project is licensed under the MIT License - see the LICENSE file for details. 
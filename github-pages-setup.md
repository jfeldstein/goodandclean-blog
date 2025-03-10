# GitHub Pages Setup Guide

## 1. Push your changes to GitHub

Use the following commands to push your changes to GitHub:

```bash
# Add all changes to staging
git add .

# Commit the changes
git commit -m "Set up GitHub Pages"

# Push to GitHub
git push origin main
```

## 2. Configure GitHub Pages in Repository Settings

1. Go to your GitHub repository page
2. Click on "Settings" (tab at the top of the repository)
3. Scroll down to the "GitHub Pages" section (or click on "Pages" in the sidebar)
4. Under "Source", select:
   - Deploy from a branch
   - Branch: gh-pages
   - Folder: / (root)
5. Click "Save"

## 3. Wait for Deployment

1. The GitHub Actions workflow will automatically build and deploy your site
2. You can check the progress in the "Actions" tab of your repository
3. Once deployment is complete, your site will be available at: 
   `https://USERNAME.github.io/Recommended-Products-Blog/` 
   (replace USERNAME with your GitHub username)

## 4. Update Your Configuration

Make sure to update these settings in your `_config.yml` file:

1. Replace `USERNAME` in the `url` parameter with your actual GitHub username
2. Update `amazon_affiliate_id` with your actual Amazon Affiliate ID

After making these changes, commit and push again to trigger a new deployment. 
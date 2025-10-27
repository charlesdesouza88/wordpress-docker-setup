# WordPress Themes Directory

This directory contains WordPress themes. Themes control the appearance and layout of your WordPress site.

## Structure

- **themes/** - Custom and downloaded themes
- **Default themes** - WordPress default themes will be installed here
- **Custom themes** - Place your custom theme development here

## Development

When developing custom themes, create a new directory here with your theme name:

```bash
mkdir wp-content/themes/my-custom-theme
```

All theme files placed in this directory will be persistent across container restarts.

## Popular Themes

The wp-tools.sh script can install popular themes automatically:
- Astra
- GeneratePress  
- Neve
- OceanWP
- Kadence

Run `./wp-tools.sh install-theme` to install themes interactively.
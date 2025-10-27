#!/bin/bash

# WordPress WP-CLI Management Tools
# Advanced WordPress management using WP-CLI in Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${CYAN}[WP-CLI]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if WordPress is running
check_wordpress() {
    if ! docker compose ps | grep -q "wp_wordpress.*Up"; then
        error "WordPress is not running. Please run './setup.sh start' first."
    fi
}

# Execute WP-CLI command
wp_exec() {
    docker compose exec wpcli wp "$@"
}

# Show WordPress information
show_wp_info() {
    log "WordPress Installation Information:"
    echo ""
    
    check_wordpress
    
    echo "📊 WordPress Core:"
    wp_exec core version --extra
    echo ""
    
    echo "🗄️ Database Status:"
    wp_exec db check
    echo ""
    
    echo "👥 User Count:"
    wp_exec user count
    echo ""
    
    echo "📄 Post Count:"
    wp_exec post count
    echo ""
    
    echo "🎨 Active Theme:"
    wp_exec theme status
    echo ""
    
    echo "🔌 Active Plugins:"
    wp_exec plugin list --status=active --format=table
    echo ""
    
    echo "⚙️ WordPress URL:"
    wp_exec option get home
    wp_exec option get siteurl
}

# Create admin user
create_admin_user() {
    log "Creating WordPress admin user..."
    
    check_wordpress
    
    read -p "Admin username: " admin_user
    read -p "Admin email: " admin_email
    read -s -p "Admin password (leave empty for auto-generated): " admin_pass
    echo
    
    if [[ -z "$admin_pass" ]]; then
        # Generate random password
        admin_pass=$(openssl rand -base64 12)
        info "Generated password: $admin_pass"
    fi
    
    if wp_exec user create "$admin_user" "$admin_email" --role=administrator --user_pass="$admin_pass"; then
        success "Admin user created successfully!"
        info ""
        info "Login details:"
        info "Username: $admin_user"
        info "Email: $admin_email"
        info "Password: $admin_pass"
        info "Login URL: http://localhost:8080/wp-admin/"
    else
        error "Failed to create admin user"
    fi
}

# Install popular plugins
install_plugins() {
    log "Installing popular WordPress plugins..."
    
    check_wordpress
    
    plugins=(
        "akismet"
        "jetpack"
        "yoast-seo"
        "contact-form-7"
        "elementor"
        "woocommerce"
        "wp-super-cache"
        "wordfence"
        "updraftplus"
        "classic-editor"
    )
    
    echo "Available plugins:"
    for i in "${!plugins[@]}"; do
        echo "$((i+1)). ${plugins[$i]}"
    done
    echo "$((${#plugins[@]}+1)). Install all"
    echo "$((${#plugins[@]}+2)). Custom plugin"
    
    read -p "Select plugins to install (comma-separated numbers): " selection
    
    if [[ "$selection" == "$((${#plugins[@]}+1))" ]]; then
        # Install all plugins
        for plugin in "${plugins[@]}"; do
            log "Installing $plugin..."
            wp_exec plugin install "$plugin" --activate || warning "Failed to install $plugin"
        done
        success "All plugins installed!"
    elif [[ "$selection" == "$((${#plugins[@]}+2))" ]]; then
        # Install custom plugin
        read -p "Enter plugin slug or URL: " custom_plugin
        wp_exec plugin install "$custom_plugin" --activate
        success "Custom plugin installed!"
    else
        # Install selected plugins
        IFS=',' read -ra SELECTED <<< "$selection"
        for i in "${SELECTED[@]}"; do
            i=$((i-1))
            if [[ $i -ge 0 && $i -lt ${#plugins[@]} ]]; then
                log "Installing ${plugins[$i]}..."
                wp_exec plugin install "${plugins[$i]}" --activate || warning "Failed to install ${plugins[$i]}"
            fi
        done
        success "Selected plugins installed!"
    fi
}

# Install themes
install_themes() {
    log "Installing WordPress themes..."
    
    check_wordpress
    
    themes=(
        "twentytwentythree"
        "twentytwentytwo"
        "twentytwentyone"
        "astra"
        "generatepress"
        "neve"
        "oceanwp"
        "kadence"
        "blocksy"
        "customify"
    )
    
    echo "Available themes:"
    for i in "${!themes[@]}"; do
        echo "$((i+1)). ${themes[$i]}"
    done
    echo "$((${#themes[@]}+1)). Custom theme"
    
    read -p "Select theme to install and activate: " selection
    
    if [[ "$selection" == "$((${#themes[@]}+1))" ]]; then
        # Install custom theme
        read -p "Enter theme slug or URL: " custom_theme
        wp_exec theme install "$custom_theme" --activate
        success "Custom theme installed and activated!"
    else
        # Install selected theme
        index=$((selection-1))
        if [[ $index -ge 0 && $index -lt ${#themes[@]} ]]; then
            log "Installing ${themes[$index]}..."
            wp_exec theme install "${themes[$index]}" --activate
            success "Theme ${themes[$index]} installed and activated!"
        else
            error "Invalid selection"
        fi
    fi
}

# Update WordPress
update_wordpress() {
    log "Updating WordPress core, plugins, and themes..."
    
    check_wordpress
    
    echo "🔄 Updating WordPress core..."
    wp_exec core update
    wp_exec core update-db
    
    echo "🔄 Updating plugins..."
    wp_exec plugin update --all
    
    echo "🔄 Updating themes..."
    wp_exec theme update --all
    
    echo "🔄 Optimizing database..."
    wp_exec db optimize
    
    success "WordPress updated successfully!"
}

# Backup WordPress
backup_wordpress() {
    log "Creating WordPress backup..."
    
    check_wordpress
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_dir="backups/$timestamp"
    
    mkdir -p "$backup_dir"
    
    # Export database
    log "Exporting database..."
    wp_exec db export "$backup_dir/database.sql" --add-drop-table
    
    # Export WordPress files (via docker cp)
    log "Backing up WordPress files..."
    docker cp wp_wordpress:/var/www/html "$backup_dir/wordpress-files"
    
    # Create backup info
    cat > "$backup_dir/backup-info.txt" << EOF
WordPress Backup
================
Date: $(date)
WordPress Version: $(wp_exec core version)
Database: wordpress
Site URL: $(wp_exec option get siteurl)
Admin URL: $(wp_exec option get siteurl)/wp-admin/

Files:
- database.sql: Complete database export
- wordpress-files/: Complete WordPress installation

Restore with:
1. Import database.sql
2. Copy wordpress-files/ contents to WordPress directory
3. Update URLs if needed
EOF
    
    success "Backup created in $backup_dir"
}

# Database operations
db_operations() {
    check_wordpress
    
    echo "Database Operations:"
    echo "1. Export database"
    echo "2. Import database"
    echo "3. Reset database"
    echo "4. Optimize database"
    echo "5. Search and replace URLs"
    
    read -p "Select operation: " choice
    
    case $choice in
        1)
            read -p "Export filename (default: export.sql): " filename
            filename=${filename:-export.sql}
            wp_exec db export "$filename"
            success "Database exported to $filename"
            ;;
        2)
            read -p "SQL file path: " sql_file
            if [[ -f "$sql_file" ]]; then
                wp_exec db import "$sql_file"
                success "Database imported from $sql_file"
            else
                error "File not found: $sql_file"
            fi
            ;;
        3)
            warning "This will DELETE ALL WordPress data!"
            read -p "Are you sure? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                wp_exec db reset --yes
                success "Database reset!"
            fi
            ;;
        4)
            wp_exec db optimize
            success "Database optimized!"
            ;;
        5)
            read -p "Old URL: " old_url
            read -p "New URL: " new_url
            wp_exec search-replace "$old_url" "$new_url"
            success "URLs updated!"
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
}

# Site management
site_management() {
    check_wordpress
    
    echo "Site Management:"
    echo "1. Flush rewrite rules"
    echo "2. Clear all caches"
    echo "3. Update permalink structure"
    echo "4. Set maintenance mode"
    echo "5. Disable maintenance mode"
    echo "6. Generate sample content"
    
    read -p "Select operation: " choice
    
    case $choice in
        1)
            wp_exec rewrite flush
            success "Rewrite rules flushed!"
            ;;
        2)
            wp_exec cache flush
            wp_exec transient delete --all
            success "All caches cleared!"
            ;;
        3)
            echo "Permalink structures:"
            echo "1. Plain: http://example.com/?p=123"
            echo "2. Day and name: http://example.com/2023/04/15/sample-post/"
            echo "3. Month and name: http://example.com/2023/04/sample-post/"
            echo "4. Numeric: http://example.com/archives/123"
            echo "5. Post name: http://example.com/sample-post/"
            echo "6. Custom structure"
            
            read -p "Select structure: " perm_choice
            
            case $perm_choice in
                1) wp_exec rewrite structure "" ;;
                2) wp_exec rewrite structure "/%year%/%monthnum%/%day%/%postname%/" ;;
                3) wp_exec rewrite structure "/%year%/%monthnum%/%postname%/" ;;
                4) wp_exec rewrite structure "/archives/%post_id%" ;;
                5) wp_exec rewrite structure "/%postname%/" ;;
                6) 
                    read -p "Enter custom structure: " custom_struct
                    wp_exec rewrite structure "$custom_struct"
                    ;;
            esac
            success "Permalink structure updated!"
            ;;
        4)
            wp_exec maintenance-mode activate
            success "Maintenance mode enabled!"
            ;;
        5)
            wp_exec maintenance-mode deactivate
            success "Maintenance mode disabled!"
            ;;
        6)
            wp_exec post generate --count=10
            wp_exec user generate --count=5
            wp_exec comment generate --count=20
            success "Sample content generated!"
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
}

# Show help
show_help() {
    echo -e "${PURPLE}WordPress WP-CLI Management Tools${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo -e "${YELLOW}Available commands:${NC}"
    echo "  info           Show WordPress installation information"
    echo "  create-admin   Create WordPress admin user"
    echo "  install-plugin Install popular plugins"
    echo "  install-theme  Install and activate themes"
    echo "  update         Update WordPress core, plugins, and themes"
    echo "  backup         Create complete WordPress backup"
    echo "  db-export      Export database to SQL file"
    echo "  db-import      Import database from SQL file"  
    echo "  db-ops         Database operations menu"
    echo "  site-mgmt      Site management operations"
    echo "  search-replace Search and replace URLs in database"
    echo "  help           Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 info                    # Show WordPress info"
    echo "  $0 create-admin           # Create admin user"
    echo "  $0 backup                 # Create backup"
    echo ""
    echo -e "${YELLOW}Direct WP-CLI:${NC}"
    echo "  docker compose exec wpcli wp [command]"
    echo "  Example: docker compose exec wpcli wp user list"
}

# Main command handling
case "${1:-help}" in
    "info")
        show_wp_info
        ;;
    "create-admin")
        create_admin_user
        ;;
    "install-plugin")
        install_plugins
        ;;
    "install-theme")
        install_themes
        ;;
    "update")
        update_wordpress
        ;;
    "backup")
        backup_wordpress
        ;;
    "db-export")
        read -p "Export filename (default: wordpress_export.sql): " filename
        filename=${filename:-wordpress_export.sql}
        wp_exec db export "$filename"
        success "Database exported to $filename"
        ;;
    "db-import")
        read -p "SQL file path: " sql_file
        if [[ -f "$sql_file" ]]; then
            wp_exec db import "$sql_file"
            success "Database imported successfully!"
        else
            error "File not found: $sql_file"
        fi
        ;;
    "db-ops")
        db_operations
        ;;
    "site-mgmt")
        site_management
        ;;
    "search-replace")
        read -p "Old URL: " old_url
        read -p "New URL: " new_url
        wp_exec search-replace "$old_url" "$new_url"
        success "URLs updated successfully!"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        error "Unknown command: $1"
        echo ""
        show_help
        ;;
esac
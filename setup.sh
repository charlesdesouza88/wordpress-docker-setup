#!/bin/bash

# WordPress Docker Environment Management Script
# Created for easy development environment control

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.yml"
BACKUP_DIR="backups"
LOG_FILE="setup.log"

# Helper functions
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        error "Docker is not running. Please start Docker Desktop first."
    fi
}

# Check if docker-compose.yml exists
check_compose_file() {
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        error "docker-compose.yml not found in current directory"
    fi
}

# Create necessary directories
create_directories() {
    log "Creating necessary directories..."
    
    # Create wp-content structure
    mkdir -p wp-content/{themes,plugins,uploads,mu-plugins}
    mkdir -p "$BACKUP_DIR"
    
    # Set proper permissions
    chmod -R 755 wp-content/
    
    success "Directories created successfully"
}

# Start the WordPress environment
start_environment() {
    log "Starting WordPress development environment..."
    
    check_docker
    check_compose_file
    create_directories
    
    # Pull latest images
    log "Pulling latest Docker images..."
    docker compose pull
    
    # Start services
    log "Starting all services..."
    docker compose up -d
    
    # Wait for services to be ready
    log "Waiting for services to be ready..."
    sleep 10
    
    # Check if services are running
    if docker compose ps | grep -q "Up"; then
        success "WordPress environment started successfully!"
        info ""
        info "🌐 WordPress: http://localhost:8080"
        info "🗄️  phpMyAdmin: http://localhost:8081"
        info "📊 MySQL: localhost:3307"
        info ""
        info "Default database credentials:"
        info "  Database: wordpress"
        info "  Username: wordpress"
        info "  Password: wordpress_password"
        info ""
        info "Use './wp-tools.sh create-admin' to create a WordPress admin user"
    else
        error "Failed to start some services. Check logs with './setup.sh logs'"
    fi
}

# Stop the WordPress environment
stop_environment() {
    log "Stopping WordPress development environment..."
    
    check_compose_file
    
    docker compose down
    
    success "WordPress environment stopped successfully!"
}

# Restart the WordPress environment
restart_environment() {
    log "Restarting WordPress development environment..."
    
    stop_environment
    sleep 2
    start_environment
}

# Show service status
show_status() {
    log "WordPress Environment Status:"
    echo ""
    
    if docker compose ps --format table 2>/dev/null; then
        echo ""
        info "Service URLs:"
        info "🌐 WordPress: http://localhost:8080"
        info "🗄️  phpMyAdmin: http://localhost:8081"
        info "📊 MySQL: localhost:3307"
    else
        warning "No services are currently running"
        info "Use './setup.sh start' to start the environment"
    fi
}

# Show logs
show_logs() {
    log "Showing WordPress logs..."
    
    check_compose_file
    
    if [[ $# -gt 1 ]]; then
        # Show logs for specific service
        docker compose logs -f "$2"
    else
        # Show logs for all services
        docker compose logs -f
    fi
}

# Reset environment (removes all data)
reset_environment() {
    warning "This will remove ALL WordPress data including database, uploads, and plugins!"
    read -p "Are you sure you want to continue? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Resetting WordPress environment..."
        
        # Stop services
        docker compose down
        
        # Remove volumes and data
        docker compose down -v
        docker volume rm wp_db_data 2>/dev/null || true
        
        # Remove wp-content (keep structure)
        if [[ -d "wp-content" ]]; then
            log "Backing up wp-content before reset..."
            timestamp=$(date +%Y%m%d_%H%M%S)
            cp -r wp-content "wp-content.backup.$timestamp"
            
            rm -rf wp-content/*
            create_directories
        fi
        
        success "Environment reset successfully!"
        info "Previous wp-content backed up as wp-content.backup.$timestamp"
        info "Use './setup.sh start' to recreate the environment"
    else
        info "Reset cancelled"
    fi
}

# Create backup
create_backup() {
    log "Creating WordPress backup..."
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_path="$BACKUP_DIR/$timestamp"
    
    mkdir -p "$backup_path"
    
    # Backup wp-content
    if [[ -d "wp-content" ]]; then
        log "Backing up wp-content..."
        cp -r wp-content "$backup_path/"
    fi
    
    # Backup database if running
    if docker compose ps | grep -q "wp_mysql.*Up"; then
        log "Backing up database..."
        docker compose exec -T db mysqldump \
            --user=wordpress \
            --password=wordpress_password \
            --single-transaction \
            --routines \
            --triggers \
            wordpress > "$backup_path/database.sql"
    else
        warning "Database not running - skipping database backup"
    fi
    
    # Create backup info
    cat > "$backup_path/backup_info.txt" << EOF
WordPress Backup Information
===========================
Created: $(date)
Environment: WordPress Docker Development
Database: wordpress
User: wordpress

Backup Contents:
- wp-content/ (themes, plugins, uploads)
- database.sql (complete database dump)

Restore Instructions:
1. Copy wp-content/ back to your environment
2. Import database.sql using phpMyAdmin or WP-CLI
3. Update URLs if needed with search-replace
EOF
    
    success "Backup created: $backup_path"
    info "Backup size: $(du -sh "$backup_path" | cut -f1)"
}

# Update environment
update_environment() {
    log "Updating WordPress environment..."
    
    # Pull latest images
    docker compose pull
    
    # Recreate containers with new images
    docker compose up -d --force-recreate
    
    success "Environment updated successfully!"
}

# Install sample content
install_sample_content() {
    log "Installing sample WordPress content..."
    
    if ! docker compose ps | grep -q "wp_wordpress.*Up"; then
        error "WordPress is not running. Use './setup.sh start' first."
    fi
    
    # Install sample content using WP-CLI
    docker compose exec wpcli wp plugin install hello-dolly --activate
    docker compose exec wpcli wp theme install twentytwentythree --activate
    docker compose exec wpcli wp post create --post_type=page --post_title="Sample Page" --post_content="This is a sample page created by the setup script."
    
    success "Sample content installed!"
}

# Show help
show_help() {
    echo -e "${PURPLE}WordPress Docker Environment Management${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo -e "${YELLOW}Available commands:${NC}"
    echo "  start          Start the WordPress environment"
    echo "  stop           Stop the WordPress environment"
    echo "  restart        Restart the WordPress environment"
    echo "  status         Show current status of all services"
    echo "  logs           Show logs for all services (or 'logs [service]' for specific service)"
    echo "  reset          Reset environment (removes all data - use with caution!)"
    echo "  backup         Create a backup of wp-content and database"
    echo "  update         Update Docker images and recreate containers"
    echo "  sample         Install sample content (themes, plugins, pages)"
    echo "  help           Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 start                 # Start WordPress environment"
    echo "  $0 logs wordpress       # Show WordPress container logs"
    echo "  $0 backup               # Create backup"
    echo ""
    echo -e "${YELLOW}Service URLs:${NC}"
    echo "  🌐 WordPress:   http://localhost:8080"
    echo "  🗄️  phpMyAdmin: http://localhost:8081"
    echo "  📊 MySQL:       localhost:3307"
    echo ""
    echo -e "${YELLOW}Management Tools:${NC}"
    echo "  ./wp-tools.sh           # WordPress-specific management tools"
    echo "  docker compose logs     # View all container logs"
    echo "  docker compose ps       # View container status"
}

# Main command handling
case "${1:-help}" in
    "start")
        start_environment
        ;;
    "stop")
        stop_environment
        ;;
    "restart")
        restart_environment
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$@"
        ;;
    "reset")
        reset_environment
        ;;
    "backup")
        create_backup
        ;;
    "update")
        update_environment
        ;;
    "sample")
        install_sample_content
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
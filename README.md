# 🚀 WordPress Docker Development Environment

A complete, production-ready WordPress development environment using Docker Compose with MySQL, phpMyAdmin, and WP-CLI.

![WordPress](https://img.shields.io/badge/WordPress-Latest-blue.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

- 🐳 **Dockerized Environment** - Complete WordPress stack in containers
- 🗄️ **MySQL 8.0** - Modern database with persistent storage
- 🛠️ **phpMyAdmin** - Web-based database management
- ⚡ **WP-CLI** - Command-line WordPress management
- 🔧 **Development Ready** - Debug mode, custom PHP settings
- 📦 **Persistent Data** - Volumes for database and wp-content
- 🚀 **Easy Management** - Scripts for common operations
- 🔒 **Secure** - Proper network isolation and credentials

## 🎯 Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running
- [Git](https://git-scm.com/) for cloning the repository

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/charlesdesouza88/wordpress-docker-setup.git
   cd wordpress-docker-setup
   ```

2. **Start the environment**
   ```bash
   chmod +x setup.sh wp-tools.sh
   ./setup.sh start
   ```

3. **Access your WordPress site**
   - 🌐 WordPress: http://localhost:8080
   - 🗄️ phpMyAdmin: http://localhost:8081
   - 📊 MySQL: localhost:3307

## 🌐 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **WordPress** | http://localhost:8080 | Setup during first visit |
| **phpMyAdmin** | http://localhost:8081 | User: `wordpress`<br>Pass: `wordpress_password` |
| **MySQL** | localhost:3307 | Database: `wordpress`<br>User: `wordpress`<br>Pass: `wordpress_password` |

## 🛠️ Management Commands

### Environment Control

```bash
# Start all services
./setup.sh start

# Stop all services  
./setup.sh stop

# Restart all services
./setup.sh restart

# Check service status
./setup.sh status

# View WordPress logs
./setup.sh logs

# Reset environment (⚠️ removes all data)
./setup.sh reset

# Create backup
./setup.sh backup
```

### WordPress Management

```bash
# Show WordPress information
./wp-tools.sh info

# Create admin user
./wp-tools.sh create-admin

# Install popular plugins
./wp-tools.sh install-plugin

# Install popular themes
./wp-tools.sh install-theme

# Update WordPress core, plugins, themes
./wp-tools.sh update

# Create backup
./wp-tools.sh backup

# Import/export database
./wp-tools.sh db-import
./wp-tools.sh db-export

# Search and replace URLs
./wp-tools.sh search-replace
```

## 📁 Directory Structure

```
wordpress-docker-setup/
├── 📄 docker-compose.yml          # Container orchestration
├── 🔧 setup.sh                    # Environment management
├── 🛠️ wp-tools.sh                 # WordPress utilities
├── ⚙️ uploads.ini                  # PHP configuration
├── 🔨 wp-config-local.php          # WordPress dev config
├── 📁 wp-content/                  # Themes, plugins, uploads
│   ├── themes/
│   ├── plugins/
│   └── uploads/
├── 📁 backups/                     # Automatic backups
└── 📄 README.md                    # This file
```

## 🐳 Docker Services

### WordPress (`wordpress:latest`)
- **Port**: 8080
- **Features**: Latest WordPress with debug mode enabled
- **Volumes**: Persistent wp-content and WordPress files

### MySQL (`mysql:8.0`)  
- **Port**: 3307
- **Database**: `wordpress`
- **Features**: Optimized for WordPress, persistent storage

### phpMyAdmin (`phpmyadmin:latest`)
- **Port**: 8081  
- **Features**: Full database management interface

### WP-CLI (`wordpress:cli`)
- **Purpose**: Command-line WordPress management
- **Usage**: `docker compose exec wpcli wp [command]`

## 🚀 Development Workflow

### 1. Initial Setup
```bash
# Start environment
./setup.sh start

# Create admin user
./wp-tools.sh create-admin

# Install essential plugins
./wp-tools.sh install-plugin
```

### 2. Theme Development
```bash
# Create custom theme directory
mkdir -p wp-content/themes/my-theme

# Edit theme files directly in wp-content/themes/
# Changes are immediately reflected in WordPress
```

### 3. Plugin Development
```bash
# Create custom plugin directory
mkdir -p wp-content/plugins/my-plugin

# Edit plugin files directly in wp-content/plugins/
# Activate via WordPress admin or WP-CLI
```

### 4. Database Management
```bash
# Access phpMyAdmin: http://localhost:8081
# Or use WP-CLI commands
docker compose exec wpcli wp db query "SHOW TABLES;"
```

## 🔧 Customization

### Environment Variables

Edit `docker-compose.yml` to customize:

```yaml
environment:
  WORDPRESS_DB_HOST: db:3306
  WORDPRESS_DB_USER: wordpress  
  WORDPRESS_DB_PASSWORD: wordpress_password
  WORDPRESS_DB_NAME: wordpress
```

### PHP Configuration

Modify `uploads.ini` for custom PHP settings:

```ini
file_uploads = On
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
```

### WordPress Configuration

Edit `wp-config-local.php` for development settings:

```php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('SCRIPT_DEBUG', true);
```

## 📊 Monitoring & Debugging

### View Logs
```bash
# WordPress logs
./setup.sh logs

# Database logs  
docker compose logs db

# All services
docker compose logs
```

### Debug Information
```bash
# WordPress info
./wp-tools.sh info

# Container status
docker compose ps

# Resource usage
docker stats
```

## 🔄 Backup & Restore

### Automatic Backups
```bash
# Create timestamped backup
./wp-tools.sh backup
# Creates: backups/YYYYMMDD_HHMMSS/
```

### Manual Database Backup
```bash
# Export database
./wp-tools.sh db-export

# Import database  
./wp-tools.sh db-import /path/to/backup.sql
```

### Complete Environment Backup
```bash
# Backup everything
./setup.sh backup

# Includes:
# - Database dump
# - wp-content files  
# - Configuration files
```

## 🔒 Security Considerations

### Development Environment
- **Default passwords** - Change for production use
- **Debug mode enabled** - Disable in production
- **Open ports** - Only accessible locally

### Production Deployment
- Use environment-specific passwords
- Disable debug mode
- Configure proper SSL/TLS
- Set up proper firewall rules
- Use secrets management

## 🐛 Troubleshooting

### Common Issues

**Docker not running**
```bash
# Start Docker Desktop
open -a "Docker Desktop"
# Wait for Docker to start, then retry
```

**Port conflicts**  
```bash
# Check if ports 8080, 8081, or 3307 are in use
lsof -i :8080
lsof -i :8081  
lsof -i :3307

# Change ports in docker-compose.yml if needed
```

**Permission issues**
```bash
# Fix wp-content permissions
sudo chown -R $USER:$USER wp-content/
chmod -R 755 wp-content/
```

**WordPress installation loop**
```bash
# Reset WordPress
./setup.sh reset
# Then visit http://localhost:8080 to reinstall
```

### Getting Help

1. Check container logs: `docker compose logs`
2. Verify services: `./setup.sh status`  
3. Test connectivity: `curl http://localhost:8080`
4. Check Docker: `docker info`

## 📋 Requirements

- **Docker Desktop** 4.0+ 
- **Docker Compose** 2.0+
- **macOS/Linux/Windows** with Docker support
- **4GB RAM** minimum (8GB recommended)
- **5GB disk space** for images and data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Acknowledgments

- [WordPress](https://wordpress.org/) - The world's most popular CMS
- [Docker](https://docker.com/) - Containerization platform
- [MySQL](https://mysql.com/) - Reliable database system
- [phpMyAdmin](https://phpmyadmin.net/) - Database management tool

## 🔗 Related Projects

- [WordPress Official Docker](https://hub.docker.com/_/wordpress)
- [Local by Flywheel](https://localwp.com/) - Alternative local WordPress
- [Laravel Valet](https://laravel.com/docs/valet) - macOS development environment

---

Made with ❤️ for WordPress developers

**⚡ Quick Commands Reference:**
```bash
./setup.sh start          # Start WordPress
./wp-tools.sh create-admin # Create admin user  
./wp-tools.sh backup      # Backup everything
```

Visit **http://localhost:8080** to get started! 🚀
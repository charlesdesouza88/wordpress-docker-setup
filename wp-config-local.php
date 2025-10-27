<?php
/**
 * Local WordPress configuration for development environment
 * This file contains development-specific settings
 */

// Enable WordPress debug mode for development
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', true);
define('SAVEQUERIES', true);

// Disable file editing from admin
define('DISALLOW_FILE_EDIT', false);

// Enable auto-updates for development
define('WP_AUTO_UPDATE_CORE', true);

// Memory limit
define('WP_MEMORY_LIMIT', '256M');

// Increase heartbeat interval for performance
define('WP_POST_REVISIONS', 10);

// Development-specific constants
define('WP_ENVIRONMENT_TYPE', 'development');

// Allow direct file system access
define('FS_METHOD', 'direct');

// Set proper file permissions
define('FS_CHMOD_DIR', (0755 & ~ umask()));
define('FS_CHMOD_FILE', (0644 & ~ umask()));
?>
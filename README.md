# Ubuntu PHP, Composer, Laravel & Node, NPM Installer Script

This script installs phpup php 8.2.3, nvm node v18.14.2

## PHP
- PHP Version Management | Name: PhpUp | https://github.com/masan4444/phpup
- PHP Version: 8.2.3
- Comnposer Version Latest
- Laravel Global Version Latest

<hr/>

### Using PHPUP
```bash
# List remote PHP versions [aliases: ls-remote]
phpup list-remote

# List local PHP versions [aliases: ls]
phpup list 

# Print the current PHP version for active console session
phpup current

# Install the version specified 
phpup install 8.2.3

# Uninstall a PHP version
phpup uninstall 8.2.3

# Switch PHP version for your active console session
phpup use 8.2.3

# Switch PHP version Globally
phpup default 8.2.3

# Alias a version to a common name
phpup alias phpS 7.2.34

# Remove an alias definition
phpup unalias php72

# Print shell completions
phpup completions
```
<hr/>

## Node
- Node Version Management | Name: NVM | https://github.com/nvm-sh/nvm
- Node Version v18.14.2
- NPM Version Latest

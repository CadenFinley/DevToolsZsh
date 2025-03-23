# DevToolsZsh

A customizable Zsh framework designed to enhance your terminal experience with custom prompts, themes, and plugins.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)

## Description

DevToolsZsh is a modern, lightweight framework for Zsh that transforms your terminal into a powerful development environment. It provides an aesthetically pleasing and informative prompt with intelligent Git integration, making your command-line workflow more efficient and enjoyable.

The framework is designed with customization in mind, allowing you to personalize your terminal experience through themes and plugins without the bloat of larger Zsh frameworks. Whether you're a developer, system administrator, or terminal enthusiast, DevToolsZsh enhances your productivity with minimal setup and resource usage.

Key advantages include:
- **Minimalist Design**: Focused on providing essential features without unnecessary complexity
- **Performance**: Optimized for speed with quick startup time
- **Extensibility**: Easy-to-use plugin system for adding custom functionality
- **Git-Centric**: Smart Git status display for efficient repository management
- **Customizable**: Simple theming system to match your visual preferences

## Overview

DevToolsZsh is a lightweight framework that provides:
- Custom terminal prompts with Git integration
- Theme switching capabilities
- Plugin system for extending functionality
- Easy installation and uninstallation

## Installation

You can install DevToolsZsh with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/cadenfinley/DevToolsZsh/main/install.sh | bash
```

This command downloads and executes the installation script automatically.

For manual installation:

```bash
# Clone the repository
git clone https://github.com/cadenfinley/DevToolsZsh.git

# Navigate to the directory
cd DevToolsZsh

# Run the installation script
./install.sh
```

The installation script will automatically activate DevToolsZsh in your current session when possible. If it can't be activated automatically, you'll need to restart your terminal or manually source your zshrc file.

## Features

### Custom Prompt

DevToolsZsh provides a customizable prompt that shows:
- Current directory or full path (togglable)
- Git branch and repository information when in a git directory
- Color-coded elements for better readability

### Themes

Available themes:
- `default` - Red, blue, yellow, and green color scheme
- `dracula` - Purple, cyan, green, and red color scheme

Switch themes with:
```bash
switch_theme theme_name
```

### Plugin System

DevToolsZsh includes a plugin system that allows you to extend functionality.

#### Available Plugins

- `git_helpers` - Git workflow enhancement functions
- `example` - An example plugin to demonstrate functionality

#### Plugin Management

List available plugins:
```bash
list_plugins
```

Enable a plugin:
```bash
enable_plugin plugin_name
```

Disable a plugin:
```bash
disable_plugin plugin_name
```

### Path Display Control

Toggle between displaying the full path or just the current directory:
```bash
toggle_path_display
```

## Creating Custom Plugins

Create a new file in the `plugins` directory:

```bash
#!/bin/zsh

# Plugin metadata
PLUGIN_NAME="your_plugin"
PLUGIN_DESCRIPTION="Description of your plugin"
PLUGIN_VERSION="1.0.0"
PLUGIN_AUTHOR="Your Name"

# Define your functions
function your_function() {
    echo "Your function running"
}

# Define aliases
alias yf="your_function"

# Optional initialization message
echo "Plugin '$PLUGIN_NAME' v$PLUGIN_VERSION loaded"
```

Then enable your plugin:
```bash
enable_plugin your_plugin
```

## Creating Custom Themes

Create a new file in the `themes` directory:

```bash
#!/bin/zsh

# Your theme colors
DEVTOOLSZSH_SHELL_COLOR="\033[1;35m"      # Purple
DEVTOOLSZSH_DIRECTORY_COLOR="\033[1;36m"   # Cyan
DEVTOOLSZSH_BRANCH_COLOR="\033[1;32m"      # Green
DEVTOOLSZSH_GIT_COLOR="\033[1;31m"         # Red
```

Switch to your theme:
```bash
switch_theme your_theme
```

## Uninstallation

To uninstall DevToolsZsh:

```bash
./uninstall.sh
```

The uninstallation script will automatically restore your default prompt in the current session when possible. If it can't be done automatically, you'll need to restart your terminal or manually source your zshrc file.

## License

Created by Caden Finley (c) 2025 @ Abilene Christian University

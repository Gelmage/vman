# VMan - Virtual Environment Manager

A directory-aware Python virtual environment management tool for Bash.

## Overview

VMan provides a simple interface for managing Python virtual environments within your current working directory. Instead of maintaining a central repository of environments, it detects and manages virtual environments wherever you create them.

## Features

- Detect virtual environments in the current directory
- Create and activate environments with a single command
- Inspect packages without activating environments
- Safe deletion with confirmation prompts
- Clean, informative output

## Installation

### Quick Install
```bash
curl -sSL https://raw.githubusercontent.com/username/vman/main/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/username/vman.git
echo "source $(pwd)/vman/vman.sh" >> ~/.bashrc
source ~/.bashrc
```

## Usage

### Basic Commands
```bash
virtual myproject        # Create and activate environment
virtual --detect          # List environments in current directory  
virtual --info            # Show packages in active environment
virtual myproject --info  # Show packages in specific environment
virtual --exit            # Deactivate current environment
virtual --delete myproject # Delete environment with confirmation
virtual --help            # Show all commands
```

### Examples

**Create a new environment:**
```bash
virtual webapp
```
Output:
```
Creating virtual environment: webapp
Virtual environment created: webapp-env
Activating environment...
Success! You are now in the 'webapp' virtual environment
```

**List environments in current directory:**
```bash
virtual --detect
```
Output:
```
Virtual environments in current directory:
webapp-env (Python 3.11.5)
testing-env (Python 3.9.2)
```

**Check installed packages:**
```bash
virtual webapp --info
```
Output:
```
Packages in virtual environment: webapp
Location: /home/user/project/webapp-env

Package    Version
---------- -------
flask      2.3.3
requests   2.31.0
```

## Requirements

- Bash 4.0+
- Python 3.6+ with venv module
- Standard Unix utilities (grep, awk, ls)

## How it Works

VMan scans the current directory for folders containing `pyvenv.cfg` files, which indicate Python virtual environments. It supports common naming patterns:
- `project-env`
- `project_env` 
- `.venv`
- `venv`

## Contributing

Contributions are welcome. Please read CONTRIBUTING.md for guidelines.

## License

MIT License - see LICENSE file for details.

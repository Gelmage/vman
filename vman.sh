#!/bin/bash

# VMan - Virtual Environment Manager
# A directory-aware Python virtual environment management tool

virtual() {
    case "$1" in
        "--help"|"-h"|"help")
            echo "🐍 VIRTUAL ENVIRONMENT MANAGER"
            echo "=============================="
            echo ""
            echo "USAGE:"
            echo "  virtual <name>           Create venv with <name> in current dir and activate it"
            echo "  virtual --detect         List all virtual environments in current directory"
            echo "  virtual <name> --info    Show packages installed in specific virtual environment"
            echo "  virtual --info           Show packages in currently active virtual environment"
            echo "  virtual --exit           Exit/deactivate current virtual environment"
            echo "  virtual --delete <name>  Delete a virtual environment permanently"
            echo "  virtual --help           Show this help message"
            echo ""
            echo "EXAMPLES:"
            echo "  virtual myproject        # Creates 'myproject-env' and activates it"
            echo "  virtual --detect         # Lists all venvs in current folder"
            echo "  virtual myproject --info # Shows what's installed in myproject-env"
            echo "  virtual --info           # Shows current venv packages"
            echo "  virtual --exit           # Exit current virtual environment"
            echo "  virtual --delete myproject # Delete 'myproject-env' folder"
            ;;
            
        "--detect")
            echo "🔍 VIRTUAL ENVIRONMENTS IN CURRENT DIRECTORY:"
            echo "============================================="
            
            # Look for pyvenv.cfg files (indicates a venv) - single pass to avoid duplicates
            found_venvs=false
            declare -A seen_venvs
            
            for dir in */; do
                if [ -f "${dir}pyvenv.cfg" ]; then
                    venv_name="${dir%/}"
                    
                    # Check if we've already seen this venv
                    if [[ -z "${seen_venvs[$venv_name]}" ]]; then
                        echo "📁 $venv_name"
                        
                        # Get Python version from pyvenv.cfg
                        version=$(grep "version" "${dir}pyvenv.cfg" | cut -d' ' -f3 2>/dev/null)
                        if [ -n "$version" ]; then
                            echo "   └── Python $version"
                        fi
                        
                        seen_venvs[$venv_name]=1
                        found_venvs=true
                    fi
                fi
            done
            
            if [ "$found_venvs" = false ]; then
                echo "❌ No virtual environments found in current directory"
                echo "💡 Use 'virtual <name>' to create one!"
            fi
            ;;
            
        "--info")
            if [ -n "$VIRTUAL_ENV" ]; then
                echo "📦 PACKAGES IN ACTIVE VIRTUAL ENVIRONMENT:"
                echo "=========================================="
                echo "🏠 Environment: $(basename $VIRTUAL_ENV)"
                echo "📍 Location: $VIRTUAL_ENV"
                echo ""
                pip list --format=columns
            else
                echo "❌ No virtual environment is currently active"
                echo "💡 Activate a venv first, or use: virtual <name> --info"
            fi
            ;;
            
        "--exit")
            if [ -n "$VIRTUAL_ENV" ]; then
                venv_name=$(basename "$VIRTUAL_ENV")
                echo "🚪 EXITING VIRTUAL ENVIRONMENT: $venv_name"
                echo "====================================="
                deactivate 2>/dev/null || true
                echo "✅ Successfully exited virtual environment"
                echo "🐍 Back to system Python: $(python3 --version)"
            else
                echo "❌ No virtual environment is currently active"
                echo "💡 You're already using system Python"
            fi
            ;;
            
        "--delete")
            if [ -z "$2" ]; then
                echo "❌ Please specify a virtual environment name to delete"
                echo "💡 Usage: virtual --delete <name>"
                echo "💡 Use 'virtual --detect' to see available environments"
                return 1
            fi
            
            venv_name="$2"
            
            # Look for the venv folder (try common patterns)
            venv_path=""
            for pattern in "${venv_name}" "${venv_name}-env" "${venv_name}_env" "${venv_name}env"; do
                if [ -d "$pattern" ] && [ -f "${pattern}/pyvenv.cfg" ]; then
                    venv_path="$pattern"
                    break
                fi
            done
            
            if [ -n "$venv_path" ]; then
                echo "⚠️  WARNING: About to permanently delete virtual environment"
                echo "📁 Name: $venv_name"
                echo "📍 Path: $(pwd)/$venv_path"
                echo ""
                read -p "Are you sure? Type 'DELETE' to confirm: " confirmation
                
                if [ "$confirmation" = "DELETE" ]; then
                    # If currently in this venv, exit it first
                    if [ -n "$VIRTUAL_ENV" ] && [[ "$VIRTUAL_ENV" == *"$venv_path"* ]]; then
                        echo "🚪 Exiting current virtual environment first..."
                        deactivate 2>/dev/null || true
                    fi
                    
                    # Delete the folder
                    rm -rf "$venv_path"
                    echo "💥 Virtual environment '$venv_name' has been permanently deleted"
                else
                    echo "❌ Deletion cancelled (you didn't type 'DELETE')"
                fi
            else
                echo "❌ Virtual environment '$venv_name' not found in current directory"
                echo "💡 Available venvs:"
                virtual --detect
            fi
            ;;
            
        *)
            # Check if second argument is --info
            if [ "$2" = "--info" ]; then
                venv_name="$1"
                
                # Look for the venv folder (try common patterns)
                venv_path=""
                for pattern in "${venv_name}" "${venv_name}-env" "${venv_name}_env" "${venv_name}env"; do
                    if [ -d "$pattern" ] && [ -f "${pattern}/pyvenv.cfg" ]; then
                        venv_path="$pattern"
                        break
                    fi
                done
                
                if [ -n "$venv_path" ]; then
                    echo "📦 PACKAGES IN VIRTUAL ENVIRONMENT: $venv_name"
                    echo "===================================="
                    echo "📍 Location: $(pwd)/$venv_path"
                    echo ""
                    
                    # Activate the venv temporarily and list packages
                    source "$venv_path/bin/activate"
                    pip list --format=columns
                    deactivate 2>/dev/null || true
                else
                    echo "❌ Virtual environment '$venv_name' not found in current directory"
                    echo "💡 Available venvs:"
                    virtual --detect
                fi
                
            # Create new virtual environment
            elif [ -n "$1" ] && [ "$1" != "--help" ] && [ "$1" != "--detect" ] && [ "$1" != "--info" ] && [ "$1" != "--exit" ] && [ "$1" != "--delete" ]; then
                venv_name="$1"
                venv_folder="${venv_name}-env"
                
                echo "🐍 CREATING VIRTUAL ENVIRONMENT: $venv_name"
                echo "============================================"
                
                # Create the virtual environment
                if python3 -m venv "$venv_folder"; then
                    echo "✅ Virtual environment created: $venv_folder"
                    echo "🔄 Activating environment..."
                    
                    # Activate the environment
                    source "$venv_folder/bin/activate"
                    
                    echo "🎉 SUCCESS! You are now in the '$venv_name' virtual environment"
                    echo "📍 Location: $(pwd)/$venv_folder"
                    echo "🐍 Python: $(python --version)"
                    echo ""
                    echo "💡 To exit this environment later, type: virtual --exit"
                    echo "💡 To see installed packages, type: virtual --info"
                    
                    # Update the shell to show the new environment
                    export PS1="($venv_name) $PS1"
                else
                    echo "❌ Failed to create virtual environment"
                fi
            else
                echo "❌ Invalid command. Use 'virtual --help' for usage information."
            fi
            ;;
    esac
}

# Export the function so it's available globally
export -f virtual

echo "🎉 Virtual Environment Manager loaded!"
echo "💡 Type 'virtual --help' to get started"

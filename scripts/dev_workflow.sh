#!/bin/bash

# HabitQuest Development Workflow Script
# This script provides common development tasks including testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "HabitQuest Development Workflow"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  setup           Set up development environment"
    echo "  test            Run all tests (unit, widget, integration)"
    echo "  test-unit       Run unit tests only"
    echo "  test-widget     Run widget tests only"
    echo "  test-integration Run integration tests only"
    echo "  analyze         Run code analysis"
    echo "  format          Format code"
    echo "  build           Build the app"
    echo "  clean           Clean build artifacts"
    echo "  generate        Generate code (build_runner)"
    echo "  check           Run all quality checks"
    echo "  help            Show this help message"
    echo ""
    echo "Options:"
    echo "  -v, --verbose   Enable verbose output"
    echo "  -d, --device    Specify device for testing"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 test -v"
    echo "  $0 test-integration -d \"iPhone 15 Simulator\""
    echo "  $0 check"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Please run this script from the project root."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to set up development environment
setup_dev_environment() {
    print_status "Setting up development environment..."
    
    # Get dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code
    print_status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Make scripts executable
    print_status "Making scripts executable..."
    chmod +x integration_test/run_tests.sh
    chmod +x scripts/dev_workflow.sh
    
    print_success "Development environment setup complete!"
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    flutter test test/unit/ $VERBOSE_FLAG
    print_success "Unit tests completed"
}

# Function to run widget tests
run_widget_tests() {
    print_status "Running widget tests..."
    flutter test test/widget/ $VERBOSE_FLAG
    print_success "Widget tests completed"
}

# Function to run integration tests
run_integration_tests() {
    print_status "Running integration tests..."
    
    if [ -n "$DEVICE" ]; then
        ./integration_test/run_tests.sh -d "$DEVICE" $VERBOSE_FLAG
    else
        ./integration_test/run_tests.sh $VERBOSE_FLAG
    fi
    
    print_success "Integration tests completed"
}

# Function to run all tests
run_all_tests() {
    print_status "Running all tests..."
    
    run_unit_tests
    run_widget_tests
    run_integration_tests
    
    print_success "All tests completed successfully!"
}

# Function to run code analysis
run_analysis() {
    print_status "Running code analysis..."
    flutter analyze
    print_success "Code analysis completed"
}

# Function to format code
format_code() {
    print_status "Formatting code..."
    dart format .
    print_success "Code formatting completed"
}

# Function to build app
build_app() {
    print_status "Building app..."
    
    if [ -n "$DEVICE" ]; then
        flutter build apk --debug
    else
        flutter build apk --debug
        flutter build ios --debug --no-codesign
    fi
    
    print_success "App build completed"
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    flutter clean
    flutter pub get
    print_success "Clean completed"
}

# Function to generate code
generate_code() {
    print_status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    print_success "Code generation completed"
}

# Function to run all quality checks
run_quality_checks() {
    print_status "Running all quality checks..."
    
    # Format check
    print_status "Checking code formatting..."
    dart format --set-exit-if-changed .
    
    # Analysis
    run_analysis
    
    # Tests
    run_all_tests
    
    print_success "All quality checks passed!"
}

# Parse command line arguments
VERBOSE_FLAG=""
DEVICE=""
COMMAND=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE_FLAG="--verbose"
            shift
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        setup|test|test-unit|test-widget|test-integration|analyze|format|build|clean|generate|check|help)
            COMMAND="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites

# Execute command
case $COMMAND in
    setup)
        setup_dev_environment
        ;;
    test)
        run_all_tests
        ;;
    test-unit)
        run_unit_tests
        ;;
    test-widget)
        run_widget_tests
        ;;
    test-integration)
        run_integration_tests
        ;;
    analyze)
        run_analysis
        ;;
    format)
        format_code
        ;;
    build)
        build_app
        ;;
    clean)
        clean_build
        ;;
    generate)
        generate_code
        ;;
    check)
        run_quality_checks
        ;;
    help|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

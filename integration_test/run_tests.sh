#!/bin/bash

# HabitQuest Integration Test Runner
# This script runs integration tests for the HabitQuest app

set -e

echo "🧪 HabitQuest Integration Test Runner"
echo "======================================"

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

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Parse command line arguments
DEVICE=""
VERBOSE=false
COVERAGE=false
SPECIFIC_TEST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -t|--test)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -d, --device DEVICE    Run tests on specific device"
            echo "  -v, --verbose          Enable verbose output"
            echo "  -c, --coverage         Generate code coverage report"
            echo "  -t, --test TEST_FILE   Run specific test file"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Generate code if needed
if [ -f "build.yaml" ]; then
    print_status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# List available devices
print_status "Available devices:"
flutter devices

# Set device if not specified
if [ -z "$DEVICE" ]; then
    print_warning "No device specified. Using default device."
    DEVICE_FLAG=""
else
    print_status "Using device: $DEVICE"
    DEVICE_FLAG="-d $DEVICE"
fi

# Set test file
if [ -n "$SPECIFIC_TEST" ]; then
    TEST_FILE="integration_test/$SPECIFIC_TEST"
    if [ ! -f "$TEST_FILE" ]; then
        print_error "Test file not found: $TEST_FILE"
        exit 1
    fi
    print_status "Running specific test: $TEST_FILE"
else
    TEST_FILE="integration_test/app_test.dart"
    print_status "Running all integration tests"
fi

# Build test command
TEST_CMD="flutter test $DEVICE_FLAG $TEST_FILE"

if [ "$VERBOSE" = true ]; then
    TEST_CMD="$TEST_CMD --verbose"
fi

if [ "$COVERAGE" = true ]; then
    TEST_CMD="$TEST_CMD --coverage"
    print_status "Code coverage will be generated"
fi

# Run the tests
print_status "Running integration tests..."
echo "Command: $TEST_CMD"
echo ""

if eval $TEST_CMD; then
    print_success "Integration tests completed successfully!"
    
    # Generate coverage report if requested
    if [ "$COVERAGE" = true ] && [ -f "coverage/lcov.info" ]; then
        print_status "Generating coverage report..."
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            print_success "Coverage report generated in coverage/html/"
        else
            print_warning "genhtml not found. Install lcov to generate HTML coverage reports."
        fi
    fi
else
    print_error "Integration tests failed!"
    exit 1
fi

echo ""
print_success "All done! 🎉"

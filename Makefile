APP_NAME = Caffeine
VERSION = 1.0.0
BUILD_DIR = build
DIST_DIR = dist

.PHONY: all app zip dmg test clean run install help

all: app zip

test:
	@echo "Running tests..."
	@swiftc -module-cache-path /tmp/clang-cache -parse-as-library -target arm64-apple-macos11.0 Tests/CaffeineTests.swift -o build/caffeine_tests
	@build/caffeine_tests

app:
	@chmod +x scripts/build_app.sh
	@scripts/build_app.sh

zip: app
	@echo "Zip archive is created in $(DIST_DIR)/$(APP_NAME)-v$(VERSION)-macOS.zip"

dmg: app
	@chmod +x scripts/create_dmg.sh
	@scripts/create_dmg.sh

run: app
	@echo "Launching $(APP_NAME)..."
	@open $(BUILD_DIR)/$(APP_NAME).app

install: app
	@echo "Installing $(APP_NAME).app into /Applications..."
	@rm -rf /Applications/$(APP_NAME).app
	@cp -R $(BUILD_DIR)/$(APP_NAME).app /Applications/$(APP_NAME).app
	@echo "✅ Installed $(APP_NAME).app in /Applications"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@echo "Cleaned."

help:
	@echo "Caffeine for Apple Silicon - Build Targets:"
	@echo "  make app     - Compile universal binary and build $(APP_NAME).app"
	@echo "  make zip     - Build app and create distributable zip archive"
	@echo "  make dmg     - Build app and create distributable DMG disk image"
	@echo "  make run     - Build and run the app locally"
	@echo "  make install - Build and copy app to /Applications"
	@echo "  make clean   - Remove build and dist directories"

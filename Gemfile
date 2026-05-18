source "https://rubygems.org"

gem "fastlane", ">= 2.225.0"
gem "cocoapods", ">= 1.15.0" # optional; project uses SPM-ready layout

plugins_path = File.join(File.dirname(__FILE__), "fastlane", "Pluginfile")
eval_gemfile(plugins_path) if File.exist?(plugins_path)

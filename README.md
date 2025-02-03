# FancyBox for cli/ui

A new FrameStyle for [Shopify/cli-ui](https://github.com/Shopify/cli-ui) gem

## Usage:

    require 'cli/ui'
    require_relative 'fancy_box'

    CLI::UI::StdoutRouter.enable

    # The original default :box
    CLI::UI::Frame.open('{{i}} Initializing', color: :cyan) do
      puts "Testing Box"
    end
    puts

    # Enable FancyBox as our framestyle
    CLI::UI.frame_style = FancyBox
    CLI::UI::Frame.open('{{i}} Initializing', color: :cyan) do
      puts "Testing FancyBox"
    end
    puts

    # Trim FancyBox down
    FancyBox.width = 80
    CLI::UI::Frame.open('{{i}} Initializing', color: :cyan) do
      puts "Testing FancyBox 80 wide"
      CLI::UI::Frame.divider("{{i}} Let's do a divider too")
      puts "More information"
    end
    puts

    # But what about the missing bar on other lines?
    CLI::UI::Frame.open('{{i}} Initializing', color: :cyan) do
      puts "Testing FancyBox 80 wide with lineterm" << FancyBox.lineterm
      CLI::UI::Frame.divider("{{i}} Let's do a divider too")
      puts "More information" << FancyBox.lineterm
    end

## Produces this ouput

<img width="1021" alt="Screenshot 2025-02-03 at 1 51 24 PM" src="https://github.com/user-attachments/assets/3a425dbc-13a4-4ee9-8a7d-ad91b080ce79" />


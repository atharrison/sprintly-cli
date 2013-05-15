require 'thor'

# Command-Line Interface, using Thor
module SprintlyCli
  class Cli < Thor
    namespace :sprintlycli

    desc "list", "List items"
    def list

      puts "Listing items..."
      sprintlyClient = SprintlyClient.new
      puts sprintlyClient.list

    end

    desc "products", "List products"
    def products
      puts "Listing products..."
      sprintlyClient = SprintlyClient.new
      puts sprintlyClient.products

    end
  end
end

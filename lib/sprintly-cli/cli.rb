require 'thor'

# Command-Line Interface, using Thor
module SprintlyCli
  class Cli < Thor
    namespace :sprintlycli

    desc "list", "List tasks"
    def list

      sprintly = Sprintly.new
      puts sprintly.list

    end
  end
end

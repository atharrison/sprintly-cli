require 'thor'

# Command-Line Interface, using Thor
module SprintlyCli
  class Cli < Thor
    namespace :sprintlycli

    OPTIONS = { #Hack to use a constant here.
        :api_user => '',
        :api_key => '',
        :product_id => ''

    }

    CONFIG_FILE = File.join(ENV['HOME'], '.sprintly-cli.rc.yaml')
    if File.exists? CONFIG_FILE
      config_options = YAML.load_file(CONFIG_FILE).inject({}){|symhash,(k,v)| symhash[k.to_sym] = v; symhash}
      OPTIONS.merge!(config_options)
    else
      unless ARGV.any?{|val| val == 'config'}
        STDERR.puts "You haven't configured sprintly-cli yet."
        STDERR.puts "Run 'sprintly-cli config' first."
        exit(0)
      end
    end

    desc "config", "Configure sprintly-cli"
    def config
      setup = SprintlyCli::Setup.new
      user_options = setup.first_run
      all_options = OPTIONS.merge(user_options)

      File.open(CONFIG_FILE, 'w') {|file| YAML::dump(all_options, file)}
      STDERR.puts "Initialized configuration file in #{CONFIG_FILE}"
    end

    desc "list", "List items"
    def list

      sprintly_client = SprintlyClient.new(OPTIONS[:api_user],OPTIONS[:api_key])
      product_id = OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)
      items = sprintly_client.list(product_id)

      puts format_items(items, "[#{product["name"]}] Items:")

    end

    desc "products", "List products"
    def products
      sprintlyClient = SprintlyClient.new(OPTIONS[:api_user], OPTIONS[:api_key])
      puts sprintlyClient.products
    end

    private

    def format_items(items, header="Items:")
      items_str = [header]
      items.each do |item|
        items_str << "#{item["number"]}\t(#{item["status"]}): #{name_from_first_last(item["assigned_to"], "unassigned")}\t- #{item["title"]}"
      end
      items_str.join("\n")
    end

    def name_from_first_last(first_last_hash, nilval="unknown")
      return nilval if first_last_hash.nil?

      "#{first_last_hash["first_name"]} #{first_last_hash["last_name"]}"
    end

  end
end

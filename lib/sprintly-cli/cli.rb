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
      setup = SprintlyCli::SprintlyHelper.new
      user_options = setup.first_run
      all_options = OPTIONS.merge(user_options)

      File.open(CONFIG_FILE, 'w') {|file| YAML::dump(all_options, file)}
      STDERR.puts "Initialized configuration file in #{CONFIG_FILE}"
    end

    desc "list", "List items"
    def list

      sprintly_client = new_client
      product_id = OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)
      items = sprintly_client.list(product_id)

      puts format_items(items, "[#{product["name"]}] Items:")

    end

    desc "products", "List products"
    def products
      sprintly_client = new_client
      puts sprintly_client.products
    end

    desc "create", "Create an item under the current Product"
    def create
      sprintly_client = new_client
      product_id = OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      helper = SprintlyCli::SprintlyHelper.new
      new_item_params = helper.ask_for_new_item(product["name"])
      sprintly_client.create_item(product_id, new_item_params)
    end

    option :item, :type => :numeric
    desc "start", "Start a given item"
    def start
      sprintly_client = new_client
      product_id = OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      item_number = options[:item].to_i
      begin
        sprintly_client.start_item(product_id, item_number)
        say "Started item #{item_number} for [#{product["name"]}]"
      rescue => ex
        say "Could not start item #{item_number} for [#{product["name"]}]"
        say "#{ex.message}"
      end
    end

    option :item, :type => :numeric
    desc "complete", "Complete a given item"
    def complete
      sprintly_client = new_client
      product_id = OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      item_number = options[:item].to_i
      begin
        sprintly_client.complete_item(product_id, item_number)
        say "Completed item #{item_number} for [#{product["name"]}]"
      rescue => ex
        say "Could not complete item #{item_number} for [#{product["name"]}]"
        say "#{ex.message}"
      end
    end

    private

    def new_client
      SprintlyClient.new(OPTIONS[:api_user], OPTIONS[:api_key])
    end

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

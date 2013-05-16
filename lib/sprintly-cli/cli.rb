require 'thor'

# Command-Line Interface, using Thor
module SprintlyCli
  class Cli < Thor
    namespace :sprintlycli

    GLOBAL_OPTIONS = { #Hack to use a constant here.
        :api_user => '',
        :api_key => '',
        :product_id => ''

    }

    CONFIG_FILE = File.join(ENV['HOME'], '.sprintly-cli.rc.yaml')
    if File.exists? CONFIG_FILE
      config_options = YAML.load_file(CONFIG_FILE).inject({}){|symhash,(k,v)| symhash[k.to_sym] = v; symhash}
      GLOBAL_OPTIONS.merge!(config_options)
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
      all_options = GLOBAL_OPTIONS.merge(user_options)

      File.open(CONFIG_FILE, 'w') {|file| YAML::dump(all_options, file)}
      say "Initialized configuration file in #{CONFIG_FILE}", :green
    end

    desc "list", "List items"
    def list

      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)
      items = sprintly_client.list(product_id)
      helper = SprintlyCli::SprintlyHelper.new

      items = helper.format_items(items, "[#{product["name"]}] Items:")
      items.each do |msg, color|
        say msg, color
      end

    end

    desc "products", "List products"
    def products
      sprintly_client = new_client
      puts sprintly_client.products
    end

    desc "create", "Create an item under the current Product"
    def create
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      helper = SprintlyCli::SprintlyHelper.new
      new_item_params = helper.ask_for_new_item(product["name"])
      sprintly_client.create_item(product_id, new_item_params)
    end

    option :item, :type => :numeric
    desc "start", "Start a given item"
    def start
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      item_number = options[:item].to_i
      begin
        sprintly_client.start_item(product_id, item_number)
        say "Started item #{item_number} for [#{product["name"]}]", :green
      rescue => ex
        say "Could not start item #{item_number} for [#{product["name"]}]", :red
        say "#{ex.message}", :grey
      end
    end

    option :item, :type => :numeric
    desc "complete", "Complete a given item"
    def complete
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      item_number = get_item_number(options)
      begin
        sprintly_client.complete_item(product_id, item_number)
        say "Completed item #{item_number} for [#{product["name"]}]"
      rescue => ex
        say "Could not complete item #{item_number} for [#{product["name"]}]", :red
        say "#{ex.message}", :grey
      end
    end

    option :item, :type => :numeric
    option :score, :type => :string
    desc "score", "Score (size) a given item"
    def score
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      item_number = options[:item].to_i
      score = options[:score]
      score ||= ask "What score would you like to give this item?", :limited_to => %w(~ S M L XL)
      begin
        sprintly_client.score_item(product_id, item_number, score)
        say "Scored item #{item_number} for [#{product["name"]}] as #{score}", :green
      rescue => ex
        say "Could not score item #{item_number} for [#{product["name"]}]", :red
        say "#{ex.message}", :grey
      end
    end

    option :item, :type => :numeric
    option :tag, :type => :string
    desc "tag", "Tag a given item"
    def tag
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      product = sprintly_client.product(product_id)

      item_number = get_item_number(options)
      tag = options[:tag]
      tag ||= ask "What tag would you like to add to this item?"
      begin
        sprintly_client.tag_item(product_id, item_number, tag)
        say "Tagged item #{item_number} for [#{product["name"]}] with #{tag}", :green
      rescue => ex
        say "Could not tag item #{item_number} for [#{product["name"]}]", :red
        say "#{ex.message}"
      end
    end

    private

    def new_client
      SprintlyClient.new(GLOBAL_OPTIONS[:api_user], GLOBAL_OPTIONS[:api_key])
    end

    def get_item_number(options)
      item_number = options[:item].to_i
      if item_number.nil?
        list
        item_number = ask "Which item would you like to update?"
      end
      item_number
    end


  end
end

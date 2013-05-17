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

    desc "list_users", "List users"
    def list_users
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i

      users = sprintly_client.list_users(product_id)
      index = 1
      users.each do |user|
        say "#{index}: #{user["first_name"]} #{user["last_name"]} (id: #{user["id"]})", :green
        index += 1
      end
      users
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

      item_number = get_item_number(options)
      begin
        sprintly_client.start_item(product_id, item_number)
        say "Started item #{item_number} for [#{product["name"]}]", :green
      rescue => ex
        say "Could not start item #{item_number} for [#{product["name"]}]", :red
        say "#{ex.message}"
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
        say "#{ex.message}"
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
        say "#{ex.message}"
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

    option :item, :type => :numeric
    desc "assign_item", "Assign user to item"
    def assign_item
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i

      item_number = get_item_number(options)
      user_id = get_user_id(options)

      begin
        sprintly_client.assign_item_to_user(product_id, item_number, user_id)
        say "Assigned item #{item_number} to #{user_id}"
      rescue => ex
        say "Could not assign item #{item_number} to #{user_id}", :red
        say "#{ex.message}"
      end

    end

    option :item, :type => :numeric
    option :text, :type => :string
    desc "add_comment", "Add comment to item"
    def add_comment
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i

      item_number = get_item_number(options)

      text = get_text(options)

      begin
        sprintly_client.add_comment(product_id, item_number, text)
        say "Added comment to #{item_number}", :green
      rescue => ex
        say "Could not add comment to #{item_number}", :red
        say "#{ex.message}"
      end

    end

    option :item, :type => :numeric
    desc "list_comments", "List comments for item"
    def list_comments
      sprintly_client = new_client
      product_id = GLOBAL_OPTIONS[:product_id].to_i
      helper = SprintlyCli::SprintlyHelper.new
      item_number = get_item_number(options)
      item = sprintly_client.get_item(product_id, item_number)

      header = "Comments for #{item_number}: #{item["title"]}"
      comments = helper.format_comments(sprintly_client.get_comments(product_id, item_number), header)
      comments.each do |msg, color|
        say msg, color
      end
    end

    private

    def new_client
      SprintlyClient.new(GLOBAL_OPTIONS[:api_user], GLOBAL_OPTIONS[:api_key])
    end

    def get_item_number(options)
      item_number = options[:item].to_i
      if item_number.nil? || item_number == 0
        list
        item_number = ask "Which item would you like to update?", :yellow
      end
      item_number
    end

    def get_user_id(options)
      user_id = options[:user].to_i
      users = nil
      if user_id.nil? || user_id == 0
        users = list_users
        user_id = ask "Which user would you like to assign?", :yellow
      end
      user_id = user_id.to_i

      if user_id < 100 # User input the index, not the id, but that's ok.
        user_id = users[user_id-1]["id"]
      end
      user_id
    end

    def get_text(options)
      text = options[:text]
      if text.nil?
        text = ask "Enter comment text: ", :yellow
      end
      text
    end

  end
end

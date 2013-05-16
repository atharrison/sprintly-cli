module SprintlyCli
  class SprintlyHelper < Thor::Shell::Basic

    def first_run
      say "Configuring sprintly-cli. I'm going to ask you a few questions."
      result = {}
      loop do
        api_user = ask "What is your Sprint.ly username?"
        #Readline.readline("> ", true)
        api_key = ask "What is your Sprint.ly API key? (found on Username->Profile)"
        #api_key = Readline.readline("> ", true)
        say "Pick a default Product Id:"
        products = list_products_for(api_user, api_key)
        product_index = ask "(Enter a number)", :limited_to => (1..products.count).to_a.map{|num| num.to_s}
        product_id = products[product_index.to_i-1]["id"]

        result = {:api_user => api_user,
                  :api_key => api_key,
                  :product_id => product_id.to_s}
        say "You enterered:"
        say "  Username: #{api_user}"
        say "  API Key:  #{api_key}"
        say "  Product Id: #{product_id}"
        if yes? "Is this correct?"
          break
        end
      end

      result
    end

    def list_products_for(api_user, api_key)
      client = SprintlyCli::SprintlyClient.new(api_user, api_key)
      products = client.products
      index = 1
      products.each do |product|
        say "#{index}: #{product["name"]} (#{product["id"]})"
        index += 1
      end
      products
    end

    def ask_for_new_item(product)
      say "Enter details for new item in [#{product}]"
      args = {}
      args["type"] = ask "Type:", :limited_to => %w(story task defect test)
      case args["type"]
        when "story"
          args["who"] = ask "As a:"
          args["what"] = ask "I want:"
          args["why"] = ask "so that:"
        when "task", "defect", "test"
          args["title"] = ask "Title:"
      end
      args["desc"] = ask "Description (optional):"

      args
    end

    def format_items(items, header="Items:")
      items_array = []
      items_array << [header, :green]
      #items_str = [header]
      items.each do |item|
        color = color_by_status(item["status"])
        items_array << ["(#{item["score"]}) #{item["number"]}\t(#{item["status"]}): #{name_from_first_last(item["assigned_to"], "unassigned")}\t- #{item["title"]}", color]
      end
      items_array
    end

    def name_from_first_last(first_last_hash, nilval="unknown")
      return nilval if first_last_hash.nil?

      "#{first_last_hash["first_name"]} #{first_last_hash["last_name"]}"
    end

    def color_by_status(status)
      case status
        when "backlog"
          :yellow
        when "in-progress"
          :blue
        when "completed"
          :green
        when "accepted"
          :gray
        else
          :white
      end
    end
  end
end

require 'require_all'
require 'yaml'
require 'thor'

require 'sprintly-cli_version.rb'
require_all File.expand_path("../sprintly-cli", __FILE__)

module SprintlyCli

  class Setup < Thor::Shell::Basic
    #include

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
  end

end


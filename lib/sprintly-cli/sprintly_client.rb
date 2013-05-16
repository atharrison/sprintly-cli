require 'sprintly'

module SprintlyCli
  class SprintlyClient

    API_URL_ROOT = "https://sprint.ly/api"

    attr_reader :api_user, :api_key

    def initialize(api_user, api_key)
      @api_user = api_user
      @api_key = api_key
    end

    def list(product_id)
      api.get_items(product_id)
    end

    def products
      api.get_products
    end

    def product(product_id)
      api.get_product(product_id)
    end

    def create_item(product_id, params)
      api.create_item(product_id, params)
    end

    def start_item(product_id, item_number)
      api.update_item(product_id, item_number, :status => "in-progress")
    end

    def complete_item(product_id, item_number)
      api.update_item(product_id, item_number, :status => "completed")
    end

    private

    def api
      @api ||= begin
        client = Sprintly::Client.new(api_user, api_key)
        Sprintly::API.new(client)
      end
    end
  end
end

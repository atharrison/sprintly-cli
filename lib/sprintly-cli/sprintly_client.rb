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

    def list_users(product_id)
      api.get_people(product_id)
    end

    def get_item(product_id, item_number)
      api.get_item(product_id, item_number)
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

    def score_item(product_id, item_number, score)
      api.update_item(product_id, item_number, :score => score)
    end

    def tag_item(product_id, item_number, tag)
      item = get_item(product_id, item_number)
      tags = item["tags"]
      tags << tag
      api.update_item(product_id, item_number, :tags => tags.uniq.join(","))
    end

    def assign_item_to_user(product_id, item_number, user_id)
      api.update_item(product_id, item_number, :assigned_to => user_id)
    end

    def add_comment(product_id, item_number, text)
      api.create_comment(product_id, item_number, text)
    end

    def get_comments(product_id, item_number)
      api.get_comments(product_id, item_number)
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

require 'sprintly'

module SprintlyCli
  class SprintlyClient

    API_URL_ROOT = "https://sprint.ly/api"
    API_USER = "andrewharrison+sprintly@otherinbox.com" #HACK!
    API_KEY = "MGQLHsuywDzAyzUh6s3eH7w7CXST2RAX" #HACK!
    DEFAULT_PRODUCT_ID = 11685

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

    private

    def api
      @api ||= begin
         #api_key = ENV['SPRINTLY_API_KEY']
         #@email_address = ENV['SPRINTLY_EMAIL_ADDRESS']
        #api_key = API_KEY
        #api_user = API_USER
        client = Sprintly::Client.new(api_user, api_key)
        Sprintly::API.new(client)
      end
    end
  end
end

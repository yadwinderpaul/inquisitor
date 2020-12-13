class OmdbException < StandardError; end

# This class handles HTTP calls to the Omdb API
# Faraday is used as a HTTP client library
class Omdb
  # Each instance is intialized with a Faraday connection with
  # base url of API and common params for each request like for auth.
  # Faraday middleware for logging and response json parsing is also added
  def initialize
    url = 'http://www.omdbapi.com/search'
    apikey = Rails.application.credentials.omdb[:apikey]
    @conn = Faraday.new(url, params: { apikey: apikey, r: 'json' }) do |conn|
      conn.adapter Faraday.default_adapter
      conn.response :json
      conn.response :logger, nil, { bodies: true, log_level: :debug }
    end
  end

  # The only public method for the class
  # Receives search_string and page for pagination
  def find_by_title(search_string, current_page)
    @search_string = search_string
    @current_page = current_page ||= 1
    begin
      call_omdb_api
    rescue Faraday::Error => e
      raise OmdbException, "Error in Omdb API: #{e}"
    end
  end

  private

  # Raises OmdbException if response received is not 200
  # return hash of results and pagination data
  def call_omdb_api
    response = @conn.get '/', { s: @search_string, page: @current_page }
    raise OmdbException, response.body.fetch('Error', 'Error in Omdb API') if response.status != 200

    {
      collection: parse_collection(response),
      pagination: parse_pagination(response)
    }
  end

  # Omdb returns keys in Pascal case, so to maintain standard
  # the keys are converted to snakecase
  def parse_collection(response)
    results = response.body.fetch('Search', [])
    to_snake_case_keys(results)
  end

  # Return pagination data for rendering the UI
  def parse_pagination(response)
    total_results = response.body.fetch('totalResults', 1).to_i
    total_pages = 1 + (total_results - 1) / 10
    {
      total_results: total_results,
      total_pages: total_pages,
      current_page: @current_page
    }
  end

  def to_snake_case_keys(elements)
    elements.collect do |element|
      element.deep_transform_keys! { |key| key.to_s.underscore }
    end
  end
end

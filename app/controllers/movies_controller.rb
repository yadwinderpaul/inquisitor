class MoviesController < ApplicationController
  def index
    param! :query, String
    param! :page,  Integer, min: 1

    @query = params[:query]
    @page = params[:page].to_i
    return if @query.nil?

    service = Omdb.new
    result = service.find_by_title @query, @page
    @collection = result[:collection]
    @pagination = result[:pagination]
  end
end

require 'pry'

class ApiController < ApplicationController
  JAM = "http://api.thisismyjam.com/1/search/jam.json"
  RANDO = "http://api.thisismyjam.com/1/explore/chance.json"
  POPULAR = "http://api.thisismyjam.com/1/explore/popular.json"

  def search
    begin
      response = HTTParty.get(JAM, query: { "by" => "artist", "q" => params[:artist] })
      data = setup_data(response)
      code = :ok
    rescue
      data = {}
      code = :no_content
    end

    render json: data.as_json, code: code
  end

  def randomizer
    apiresponse(RANDO)
  end

  def popular
    apiresponse(POPULAR)
  end

  private

  def apiresponse(url)
    begin
      response = HTTParty.get(url)
      data = setup_data(response)
      code = :ok
    rescue
      data = {}
      code = :no_content
    end

    render json: data.as_json, code: code
  end

  def setup_data(response)

    jams = response.fetch "jams", {}

    if response["list"]["next"].nil?
      return jams
    else
      jams = jams.first(10)
    end
    
    jams.map do |jam|
      {
        via: jam.fetch("via", ""),
        url: jam.fetch("viaUrl", ""),
        title: jam.fetch("title", ""),
        artist: jam.fetch("artist", "")
      }
    end
  end
end

class DistrictsController < ApplicationController
  def index
    @zip = params['zip']
    if @zip then
      @districts = Zip2cd.find_cd_by_zip(@zip)
      @districts += Zip2cd.find_state_by_zip(@zip)
      require 'pp'
      pp @districts
    end
  end
end

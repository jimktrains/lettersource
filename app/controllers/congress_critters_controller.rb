class CongressCrittersController < ApplicationController
  def index
    @search_term = params['zip']
    if @search_term then
      @critters = CongressCritter.find_by_zip(params[:zip])
    end
  end
end

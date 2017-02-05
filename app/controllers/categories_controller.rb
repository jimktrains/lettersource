class CategoriesController < ApplicationController
  def index
    @search_term = params['q']
    if @search_term then
      @search_term = "%" + @search_term + "%"
      @search_term = @search_term.gsub('*', '%')
      @categories = Category.where("name ILIKE ?",  @search_term)
    else
      @categories = Category.all
    end
  end
end

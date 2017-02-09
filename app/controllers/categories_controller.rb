class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]
  def index
    @search_term = params['q']
    if @search_term then
      @categories = Category.search_with_alias(@search_term)
    else
      @categories = Category.all
    end
  end

  def show
    @descendants = @category.descendant_categories
    @letters = @category.descendant_letters
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end
end

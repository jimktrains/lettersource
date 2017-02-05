require "kramdown"

class LettersController < ApplicationController
  before_action :set_letter, only: [:show, :edit, :update, :destroy]

  # GET /letters
  # GET /letters.json
  def index
    @search_term = params['q']
    if @search_term then
      @letters = Letter.search_full_text(@search_term)
    else
      @letters = Letter.all
    end
  end


  # GET /letters/1
  # GET /letters/1.json
  def show
    # Debating if this should be cached in the db or generated
    # generated allows me to change the rendering...but how often will that
    # happen. For testing it'll stay here, but
    # I probably will end up
    # @TODO move rendering into `Letter#body=`
    doc = Kramdown::Document.new(@letter.body)
    @letter.rendered_body, @warnings = LettersHelper::HTMLConverterWithoutLinks.convert(doc.root)
  end

  # GET /letters/new
  def new
    @letter = Letter.new
  end

  # GET /letters/1/edit
  def edit
  end

  # POST /letters/1/duplicate

  # POST /letters
  # POST /letters.json
  def create
    @letter = Letter.new(letter_params)
    unless params[:categories].nil? then
      for category in params[:categories]
        @letter.categories << category
      end
    end

    respond_to do |format|
      if @letter.save
        format.html { redirect_to @letter, notice: 'Letter was successfully created.' }
        format.json { render :show, status: :created, location: @letter }
      else
        format.html { render :new }
        format.json { render json: @letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /letters/1
  # PATCH/PUT /letters/1.json
  def update
    respond_to do |format|
      if @letter.update(letter_params)
        format.html { redirect_to @letter, notice: 'Letter was successfully updated.' }
        format.json { render :show, status: :ok, location: @letter }
      else
        format.html { render :edit }
        format.json { render json: @letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /letters/1
  # DELETE /letters/1.json
  def destroy
    @letter.destroy
    respond_to do |format|
      format.html { redirect_to letters_url, notice: 'Letter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_letter
      @letter = Letter.eager_load(:categories).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def letter_params
      p = params.require(:letter).permit(:title, :body, :categories=>[])
      if p[:categories] then
        for i in 0...p[:categories].length
          p[:categories][i] = Category.find(p[:categories][i])
        end
      end
      p
    end
end
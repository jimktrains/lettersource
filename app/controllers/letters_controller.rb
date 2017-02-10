require "kramdown"

class LettersController < ApplicationController
  before_action :set_letter, only: [:show, :edit, :update, :duplicate, :format]
  layout "plain", :only => :format

  # GET /letters
  # GET /letters.json
  def index
    @search_term = params['q']
    @zip = params['zip']
    if @search_term then
      @letters = Letter.search_full_text(@search_term)
    elsif @zip then
      @letters = Letter.find_by_zip(@zip)
    else
      @letters = Letter.all
    end
  end


  # GET /letters/1
  # GET /letters/1.json
  def show

    @sender = {
      :name => "Sender's Name",
      :street_address => "Street",
      :city => "City",
      :state => "State",
      :zip => "00000"
    }

    @recipient = {
      :name => "Sender's Name",
      :street_address => "Street",
      :city => "City",
      :state => "State",
      :zip => "00000"
    }

    @can_edit = can_edit
  end

  def select_legislators
    @critters = CongressCritter.find_by_zip(params[:zip])
    @sender = {
      :name => params[:name],
      :street_address => params[:street_address],
      :city => params[:city],
      :state => params[:state],
      :zip => params[:zip]
    }
  end

  def format
    @critters = params[:critters].map { |x| CongressCritter.find(x) }
    @sender = {
      :name => params[:name],
      :street_address => params[:street_address],
      :city => params[:city],
      :state => params[:state],
      :zip => params[:zip]
    }
  end

  # GET /letters/new
  def new
    @letter = Letter.new
  end

  # GET /letters/1/edit
  def edit
    redirect_to @letter unless can_edit
  end

  # POST /letters/1/duplicate
  def duplicate
    @new_letter = @letter.dup
    @new_letter.categories = @letter.categories
    @letter = @new_letter

    if @letter.save
      add_letter_to_session
      redirect_to edit_letter_path(@letter)
    else
      format.html { render :new }
      format.json { render json: @letter.errors, status: :unprocessable_entity }
    end
  end

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
        add_letter_to_session
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
    redirect_to @letter unless can_edit

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
  #def destroy
  #  @letter.destroy
  #  respond_to do |format|
  #    format.html { redirect_to letters_url, notice: 'Letter was successfully destroyed.' }
  #    format.json { head :no_content }
  #  end
  #end

  private
    def can_edit
      if can_edit_id @letter.id then
        return true unless edit_too_old @letter
        # if we can't edit, we might as well clear it from the session
        session[:letters].delete_if {|l| l == @letter.id }
      end
      return false
    end

    def can_edit_id(id)
      id = id.to_i
      unless session[:letters].nil? then
        return session[:letters].include? id
      end
      return false
    end

    def edit_too_old(letter)
      return letter.created_at + 1.hour < DateTime.now.utc
    end

    def add_letter_to_session
      session[:letters] = [] if session[:letters].nil?
      session[:letters] << @letter.id

      clean_session if session[:letters].length > 100
    end

    def clean_session
      session[:letters].delete_if do |l|
          l = Letter.find(l)
          return edit_too_old l
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_letter
      @letter = Letter.eager_load(:categories)
      if can_edit_id params[:id] then
        @letter = @letter.unscoped
      end
      @letter = @letter.find(params[:id])
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

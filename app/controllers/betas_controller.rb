class BetasController < ApplicationController
  def index
    @betas = Beta.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @betas }
    end
  end

  def edit
    @beta = Beta.find(params[:id])
  end

  def new
    @beta = Beta.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @beta }
    end
  end

  def create
    @beta = Beta.new(params[:beta])

    respond_to do |format|
      if @beta.save
        format.html { redirect_to @beta, notice: 'Beta was successfully created.' }
        format.json { render json: @beta, status: :created, location: @beta }
      else
        format.html { render action: "new" }
        format.json { render json: @beta.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @beta = Beta.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @beta }
    end
  end

  def update
    @beta = Beta.find(params[:id])

    respond_to do |format|
      if @beta.update_attributes(params[:beta])
        format.html { redirect_to @beta, notice: 'Beta was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @beta.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @beta = Beta.find(params[:id])
    @beta.destroy

    respond_to do |format|
      format.html { redirect_to betas_url }
      format.json { head :no_content }
    end
  end
end

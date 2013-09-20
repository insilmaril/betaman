class BetasController < ApplicationController
  def index
    @betas = Beta.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @betas }
    end
  end

  def edit
    if @current_user.admin?
      @beta = Beta.find(params[:id])
    else
      flash[:error] = "Access denied: Editing Beta test"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin?
    @beta = Beta.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @beta }
    end
    else
      flash[:error] = "Access denied: New Beta test"
      redirect_to root_path
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
    if @current_user.admin?
      @beta = Beta.find(params[:id])
      @beta.destroy

      respond_to do |format|
        format.html { redirect_to betas_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete Beta test"
      redirect_to root_path
    end
  end

  def users
    @beta = Beta.find(params[:id])
    @users = @beta.users
  end

  def add_user(user)
    if @current_user.admin?
      @beta.users << user
    end
  end

  def rmuser
    if @current_user.admin?
      beta = Beta.find(params[:id])
      user = User.find(params[:user_id])

      #@beta = Beta.find(params[:user_id])
      flash[:success] = "Removed user #{user.id} from beta #{beta.id}!"
      redirect_to root_path
      #@beta.users.delete(user)
    end
  end
end

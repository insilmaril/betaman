class CompaniesController < ApplicationController
  def index
    @companies = Company.order('name ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
    end
  end

  def edit
    if @current_user.admin?
      @company = Company.find(params[:id]) 
    else
      flash[:error] = "Access denied: Editing Company"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin? || @current_user.employee?
      @company = Company.new

      session[:return_to] ||= request.referer
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @company }
      end
    else
      flash[:error] = "Access denied: New Beta test"
      redirect_to root_path
    end
  end

  def create
    @company = Company.new(params[:company])

    respond_to do |format|
      if @company.save
        flash[:success] = "Created company #{@company.name}"
        format.html { redirect_to session.delete(:return_to) }
        format.json { render json: @company, status: :created, location: @company }
      else
        flash[:warning] = "Failed to create company #{@company.name}"
        format.html { render action: "new" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @company = Company.find(params[:id]) 

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  def update
    @company = Company.find(params[:id]) 

    respond_to do |format|
      if @company.update_attributes(params[:company])
        flash[:success] = "Updated company #{@company.name}"
        format.html { redirect_to @company }
        format.json { head :no_content }
      else
        flash[:warning] = "Failed to update company #{@company.name}"
        format.html { render action: "edit" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @current_user.admin?
      @company = Company.find(params[:id]) 
      @company.destroy

      respond_to do |format|
        format.html { redirect_to companies_path }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete company test"
      redirect_to root_path
    end
  end
end

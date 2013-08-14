class StaticPagesController < ApplicationController
  skip_before_filter :login_required

  def home
  end

  def help
  end
end

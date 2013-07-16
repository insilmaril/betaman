class StaticPagesController < ApplicationController
  skip_before_filter :login_required

  def home
    flash.keep
  end

  def help
  end
end

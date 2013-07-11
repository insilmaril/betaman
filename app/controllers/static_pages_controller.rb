class StaticPagesController < ApplicationController
  def home
    flash.keep
    logger.info "** static home"
  end

  def help
  end
end

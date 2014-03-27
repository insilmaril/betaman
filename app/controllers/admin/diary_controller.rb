class Admin::DiaryController < ApplicationController
  def index
    @diary_entries = DiaryEntry.order('created_at DESC')
  end

  def user
    @user = User.find(params[:user_id])
    @diary_entries = DiaryEntry.where('user_id = ?', @user.id) 
    #@diary_entries = DiaryEntry.where("user_id = ?", params[:user_id]) 
  end
end


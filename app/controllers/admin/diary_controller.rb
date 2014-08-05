class Admin::DiaryController < ApplicationController
  def index
    @diary_entries = DiaryEntry.order('created_at DESC').page(params[:page]).per_page(7)
  end

  def user
    @user = User.find(params[:user_id])
    @diary_entries = DiaryEntry.where('(user_id = ?) OR (actor_id = ?)', @user.id, @user.id).order('created_at DESC')
  end
end


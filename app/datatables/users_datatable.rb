class UsersDatatable
  delegate :params, :h, :link_to, :mail_to, :number_to_currency, to: :@view

  def initialize(view)
      @view = view
  end

  def as_json(options = {})
    # Make sure to call 'data' before using @users_count!
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      aaData: data,
      iTotalDisplayRecords: @users_count
    }
  end

private
  def data
    users.map do |user|
      betas = user.betas.count.to_s
      if user.betas.count > 0
        betas = link_to betas, Rails.application.routes.url_helpers.user_betas_path(user)
      end
      cname = user.name 
      [
        link_to(User.find(user.id).full_name_reverse_comma, user),
        mail_to(user.email),
        cname,
        betas
      ]
    end
  end

  def users
    @users ||=fetch_users
  end

  def fetch_users
    ga = []
    ga << 'users.id'
    ga << 'users.last_name'
    ga << 'users.first_name'
    ga << 'users.email'
    ga << 'companies.name'
    ga << 'participations.user_id'
    grouping = ga.join ', '

    users = User.joins("LEFT OUTER JOIN companies ON users.company_id = companies.id LEFT OUTER JOIN participations ON users.id = participations.user_id").
      select("#{grouping}, COUNT (*) AS betas_count").
      group( grouping )

    if params[:sSearch].present?
      s = ['users.email']
      s << 'users.last_name'
      s << 'users.first_name'
      s << 'companies.name'
      s.map!{ |a| "lower(#{a}) like :search" }
      users = users.where(s.join(' or '), search: "%#{params[:sSearch]}%".downcase)
    end

    users = users.order("#{sort_column} #{sort_direction}")
    @users_count = users.to_a.count
    users = users.page(page).per_page(per_page)
    users
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column  
    columns = %w[last_name email companies.name betas_count]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

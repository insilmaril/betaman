module DownloadHelper 
  def self.find_betas_with_downloads(sync=false)
    @betas_with_downloads = []
    Beta.all.each do |b|

      bdata = {}
      bdata[:beta] = b

      if b.has_novell_download?
        if sync
          r = b.sync_downloads_to_intern
          bdata[:added] = r[:added]
          bdata[:dropped] = r[:dropped]
        end

        missing_dls = []
        available_dls = []
        missing_support = []
        b.participations.each do |p|
          if p.downloads_act.blank? && !p.user.employee?
            missing_dls << p.user
          end

          if !p.support_req
            missing_support << p.user
          end

          if p.downloads_act 
            available_dls << p.user
          end
        end

        ext_missing_lists = []
        int_missing_lists = []
        b.users.each do |u|
          if !b.list.users.include? u
            if u.employee?
              int_missing_lists << u
            else
              ext_missing_lists << u
            end
          end
        end

        bdata[:int_users_without_list] = int_missing_lists
        bdata[:ext_users_without_list] = ext_missing_lists
        bdata[:all_users_without_list] = ext_missing_lists + int_missing_lists
        bdata[:ext_users_without_downloads] = missing_dls
        bdata[:ext_users_with_downloads_nosupport] = User.external & available_dls & missing_support
        bdata[:users_with_downloads] = available_dls

        @betas_with_downloads << bdata
      end
    end
    return @betas_with_downloads 
  end
end

module Views
  class AllChannels < ApplicationView
    attrs :current_user, :page, :letter

    fetches :channels, proc {
      if letter && !letter.blank?
        Channel.with_letter(letter)
      else
        Channel.all_channels(current_user, page)
      end
    }
  end
end

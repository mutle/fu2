class Api::UsersController < Api::ApiController

  def stats
    user = User.find params[:id]
    @view = Views::UserStats.new({
      user: user
    })
    @view.finalize
  end

end

module PaymentsHelper
  def new_expiration_time
    [Time.current, current_user.expiration_date].max + 1.year
  end

  def new_expiration_date
    new_expiration_time.to_date.to_formatted_s(:long)
  end
end

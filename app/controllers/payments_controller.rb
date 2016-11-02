class PaymentsController < ApplicationController
  include PaymentsHelper

  before_action :logged_in_user

  def new
  end

  def create
    @user = current_user
    @payment = PayPal::SDK::REST::Payment
               .new(payment_details(params[:br])
                     .merge(experience_profile_id: fetch_experience_profile_id))
    @payment.create
    redirect_to @payment.links.find { |l| l.rel == 'approval_url' }.href
  end

  def show
    @payment = Payment.find(params[:id])
    @total, @currency = payment_values
  rescue
    flash[:primary] = 'Could not retrieve payment info from Paypal. '\
                      'Don\'t worry, you have not been charged.'
    redirect_to root_url
  end

  def update
    if execute_payment
      extend_expiration_date
      flash[:success] =
        'Your\'ve just subscribed to 1 more year of Sourcerer. Thank you!'
    else
      flash[:alert] = 'An error ocurred while executing payment.'
    end
    redirect_to root_url
  end

  private

  def payment_details(br)
    pc = br ? %w(60 BRL) : %w(20 USD)
    { intent: 'sale',
      payer: { payment_method: 'paypal' },
      redirect_urls: { return_url: payment_url(@user.payments.create),
                       cancel_url: new_payment_url },
      transactions: [{ amount: { total: pc[0], currency: pc[1] },
                       item_list: { items: [quantity: '1',
                                            name: 'Sourcerer (1 year)',
                                            price: pc[0],
                                            currency: pc[1]] } }] }
  end

  def web_profile_details
    { name: 'Sourcerer',
      input_fields: { no_shipping: 1 },
      presentation: { brand_name: 'Sourcerer' } }
  end

  def fetch_experience_profile_id
    return PayPal::SDK::REST::WebProfile.get_list.first.id
  rescue
    wp = PayPal::SDK::REST::WebProfile.new(web_profile_details)
    wp.create
    wp.id
  end

  def execute_payment
    payment = PayPal::SDK::REST::Payment.find(params['paymentId'])
    return payment.execute(payer_id: params['PayerID'])
  rescue
    false
  end

  def extend_expiration_date
    params[:executed] = true
    current_user.update_attribute(:expiration_date, new_expiration_time)
    Payment.find(params[:id]).update_attributes(payment_params)
  end

  def payment_values
    amount = PayPal::SDK::REST::Payment
             .find(params['paymentId']).transactions.first.amount
    [amount.total, amount.currency]
  end

  def payment_params
    params.permit(:paymentId, :token, :PayerID, :executed)
  end
end

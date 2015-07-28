class BillingController < ApplicationController
  include ApplicationHelper
  include BillingHelper

  before_action :logged_in_user
  before_action :expiration_date_check

  def expired
  end

  def checkout
    # should this be defined as a constant elsewhere?
    @payment = PayPal::SDK::REST::Payment
               .new(payment_details(params[:br])
                     .merge(experience_profile_id: fetch_experience_profile_id))
    @payment.create
    redirect_to @payment.links.find { |l| l.rel == 'approval_url' }.href
  end

  def confirm
    payment = PayPal::SDK::REST::Payment.find(params['paymentId'])
    amount = payment.transactions.first.amount
    @total = amount.total
    @currency = amount.currency
  rescue
    flash[:info] = 'Could not retrieve payment info from Paypal. Don\'t worry,
 you have not been charged.'
    redirect_to root_url
  end

  def finalize
    if execute_payment
      extend_expiration_date
      flash[:success] =
        'Your\'re now subscribed to 1 year of Sourcerer. Thank you!'
      redirect_to next_path
    else
      flash[:alert] = 'An error ocurred while executing payment.'
      redirect_to root_url
    end
  end

  private

  def payment_details(br)
    pc = br ? %w(50 BRL) : %w(15 USD)
    { intent: 'sale',
      payer: { payment_method: 'paypal' },
      redirect_urls: { return_url: billing_confirm_url,
                       cancel_url: billing_expired_url },
      transactions: [{ amount: { total: pc[0], currency: pc[1] },
                       item_list: { items: [quantity: '1',
                                            name: 'Sourcerer (1 year)',
                                            price: pc[0],
                                            currency: pc[1]] } }] }
  end

  def payment_details_without_item_list(br)
    pc = br ? %w(50 BRL) : %w(15 USD)
    { intent: 'sale',
      payer: { payment_method: 'paypal' },
      redirect_urls: { return_url: billing_confirm_url,
                       cancel_url: billing_expired_url },
      transactions: [{ amount: { total: pc[0], currency: pc[1] },
                       description: 'Sourcerer (1 year)' }] }
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
    @payment = PayPal::SDK::REST::Payment.find(params['paymentId'])
    return @payment.execute(payer_id: params['PayerID'])
  rescue
    false
  end

  def extend_expiration_date
    current_user.update_attributes(paypal_payment_id: params['paymentId'],
                                   expiration_date: new_expiration_time)
  end

  def expiration_date_check
    return if Time.current > current_user.expiration_date - 1.week
    flash[:info] = 'Too early to talk about money :)'
    redirect_to root_url
  end
end
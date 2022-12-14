class TransactionService
  USER_CARDS_LIMIT = 3 # 4 cards per user
  USER_DEVICES_LIMIT = 3 # 4 devices per user



  def initialize(params)
    @params = params
  end

  def create_transaction
    Transaction.transaction do
      set_instance_variables
      validations
      if @user.blocked || @card.blocked || @device.blocked || @merchant.blocked || @user.chargeback_count.positive?
        @transaction.recommendation = 'deny'
      end
      if save_instances
        ValidateTooManyTransactionsInARowJob.perform_later(@user, @card, @device, @merchant, @transaction)
        ValidateTransactionsAboveCertainAmountJob.perform_later(@user, @card, @device, @merchant, @transaction)
      end
    end
    @transaction
  end

  private

  def validations
    validate_card_user
    validate_device_user
    validate_too_many_transactions_in_a_row

  end

  def transaction_params
    {
      id: @params[:transaction_id],
      merchant_id: @params[:merchant_id],
      user_id: @params[:user_id],
      date: @params[:transaction_date],
      amount: @params[:transaction_amount],
      device_id: @params[:device_id],
      card: @card
    }
  end

  def set_instance_variables
    @user = User.find_or_create_by(id: @params[:user_id])
    @card = Card.find_or_create_by(number: @params[:card_number])
    @merchant = Merchant.find_or_create_by(id: @params[:merchant_id])
    @device = Device.find_or_create_by(id: @params[:device_id])
    @transaction = Transaction.new(transaction_params)
  end

  def validate_card_user
    @card.user = @user if @card.user.nil?
    block_if_card_user_mismatch
    block_if_too_many_cards

  end

  def block_if_card_user_mismatch
    return unless @card.user != @user

    puts 'block_if_card_user_mismatch'
    block_user_card_device
  end

  def block_if_too_many_cards
    return unless @user.cards.size > USER_CARDS_LIMIT

    puts 'block_if_too_many_cards'
    block_user_card_device
    @user.cards.each do |card|
      card.blocked = true
      card.save
    end
  end

  def validate_device_user
    @device.user = @user if @device.user.nil?
    block_if_device_user_mismatch
    block_if_too_many_devices
  end

  def block_if_device_user_mismatch
    return unless @device.user != @user

    puts 'block_if_device_user_mismatch'
    block_user_card_device
  end

  def block_if_too_many_devices
    return unless @user.devices.size > USER_DEVICES_LIMIT

    puts 'block_if_too_many_devices'
    block_user_card_device
    @user.devices.each do |device|
      device.blocked = true
      device.save
    end
  end

  def validate_too_many_transactions_in_a_row
    block_if_transactions_have_less_than_1_minute_between


  end

  def block_if_transactions_have_less_than_1_minute_between
    if @user.transactions.size.positive? &&
       @transaction.date <= @user.transactions.last.date + 1.minute &&
       @transaction.merchant_id == @user.transactions.last.merchant_id
      puts 'block_if_transactions_have_less_than_1_minute_between'
      block_user_card_device
    end
  end



  def block_user_card_device
    @user.blocked = true
    @card.blocked = true
    @device.blocked = true
  end

  def save_instances
    @user.save
    @card.save
    @device.save
    @merchant.save
    @transaction.save
  end
end

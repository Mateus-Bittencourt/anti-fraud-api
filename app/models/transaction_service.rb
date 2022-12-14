class TransactionService
  USER_CARDS_LIMIT = 3
  USER_DEVICES_LIMIT = 3
  USER_TRANSACTIONS_LIMIT = 15
  USER_MERCHANT_TRANSACTIONS_LIMIT = 10
  USER_AMOUNT_LIMIT = 20_000
  USER_MERCHANT_AMOUNT_LIMIT = 10_000

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
      save_instances
    end
    @transaction
  end

  private

  def validations
    validate_card_user
    validate_device_user
    validate_too_many_transactions_in_a_row
    validate_transactions_above_certain_amount
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
    @user.blocked = true
    @device.blocked = true
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
    @user.blocked = true
    @card.blocked = true
    @user.devices.each do |device|
      device.blocked = true
      device.save
    end
  end

  def validate_too_many_transactions_in_a_row
    block_if_transactions_have_less_than_1_minute_between

    block_if_user_have_too_many_transactions_in_a_day

    block_if_user_and_merchant_have_too_many_transactions_in_a_day
  end

  def block_if_transactions_have_less_than_1_minute_between
    if @user.transactions.size.positive? &&
       @transaction.date <= @user.transactions.last.date + 1 &&
       @transaction.merchant_id == @user.transactions.last.merchant_id
      puts 'block_if_transactions_have_less_than_1_minute_between'
      block_user_card_device
    end
  end

  def block_if_user_have_too_many_transactions_in_a_day
    transactions_count = 1
    @user.transactions.each do |transaction|
      transactions_count += 1 if transaction.date.to_date == @transaction.date.to_date
    end
    puts 'block_if_user_have_too_many_transactions_in_a_day' if transactions_count > USER_TRANSACTIONS_LIMIT
    block_user_card_device if transactions_count > USER_TRANSACTIONS_LIMIT
  end

  def block_if_user_and_merchant_have_too_many_transactions_in_a_day
    transactions_count = 0
    @user.transactions.each do |transaction|
      if transaction.merchant_id == @transaction.merchant_id &&
         transaction.date.to_date == @transaction.date.to_date
        transactions_count += 1
      end
    end
    return unless transactions_count > USER_MERCHANT_TRANSACTIONS_LIMIT
    puts 'block_if_user_and_merchant_have_too_many_transactions_in_a_day'
    block_user_card_device
    @merchant.blocked = true
  end

  def validate_transactions_above_certain_amount
    user_amount = count_user_amount_in_a_day
    user_merchant_amount = count_user_merchant_amount_in_a_day

    @merchant.blocked = true if user_merchant_amount > 10_000
    puts 'block_if_user_have_too_many_transactions_above_certain_amount_in_a_day' if user_amount > USER_AMOUNT_LIMIT
    block_user_card_device if user_amount > USER_AMOUNT_LIMIT || user_merchant_amount > USER_MERCHANT_AMOUNT_LIMIT
  end

  def count_user_amount_in_a_day
    user_amount = 0
    @user.transactions.each do |transaction|
      user_amount += transaction.amount if transaction.date.to_date == @transaction.date.to_date
    end
    user_amount
  end

  def count_user_merchant_amount_in_a_day
    user_merchant_amount = 0
    @user.transactions.each do |transaction|
      if transaction.date.to_date == @transaction.date.to_date && transaction.merchant_id == @transaction.merchant_id
        user_merchant_amount += transaction.amount
      end
    end
    user_merchant_amount
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

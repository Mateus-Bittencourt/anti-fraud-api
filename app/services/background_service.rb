class BackgroundService
  USER_TRANSACTIONS_LIMIT = 15
  USER_MERCHANT_TRANSACTIONS_LIMIT = 10
  USER_AMOUNT_LIMIT = 20_000
  USER_MERCHANT_AMOUNT_LIMIT = 10_000

  def initialize(params)
    @user = User.find(params[:user_id])
    @card = Card.find(params[:card_id])
    @device = Device.find(params[:device_id])
    @merchant = Merchant.find(params[:merchant_id])
    @transaction = Transaction.find(params[:transaction_id])
  end

  def validate_too_many_transactions_in_a_row
    block_if_user_have_too_many_transactions_in_a_day
    block_if_user_and_merchant_have_too_many_transactions_in_a_day
  end

  def validate_transactions_above_certain_amount
    user_amount = count_user_amount_in_a_day
    user_merchant_amount = count_user_merchant_amount_in_a_day

    if user_merchant_amount > USER_MERCHANT_AMOUNT_LIMIT

      @merchant.blocked = true
      @merchant.save
    end
    return unless user_amount > USER_AMOUNT_LIMIT || user_merchant_amount > USER_MERCHANT_AMOUNT_LIMIT

    block_user_card_device_and_save
  end

  private

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

  def block_if_user_have_too_many_transactions_in_a_day
    transactions_count = 0
    @user.transactions.each do |transaction|
      transactions_count += 1 if transaction.date.to_date == @transaction.date.to_date
    end

    block_user_card_device_and_save if transactions_count > USER_TRANSACTIONS_LIMIT
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

    block_user_card_device_and_save
    @merchant.blocked = true
    @merchant.save
  end

  def block_user_card_device_and_save
    @user.blocked = true
    @card.blocked = true
    @device.blocked = true
    @user.save
    @card.save
    @device.save
  end
end

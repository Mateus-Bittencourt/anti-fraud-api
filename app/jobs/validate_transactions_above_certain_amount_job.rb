class ValidateTransactionsAboveCertainAmountJob < ApplicationJob
  queue_as :default

  USER_AMOUNT_LIMIT = 20_000
  USER_MERCHANT_AMOUNT_LIMIT = 10_000

  def perform(user, card, device, merchant, transaction)
    instance_variables(user, card, device, merchant, transaction)
    user_amount = count_user_amount_in_a_day + @transaction.amount
    user_merchant_amount = count_user_merchant_amount_in_a_day + @transaction.amount

    @merchant.blocked = true if user_merchant_amount > 10_000
    puts 'block_if_user_have_too_many_transactions_above_certain_amount_in_a_day' if user_amount > USER_AMOUNT_LIMIT
    if user_merchant_amount > USER_MERCHANT_AMOUNT_LIMIT
      puts 'block_if_user_have_too_many_transactions_above_certain_amount_in_a_day-merchant'
      @merchant.blocked = true
      @merchant.save
    end
    block_user_card_device_and_save if user_amount > USER_AMOUNT_LIMIT || user_merchant_amount > USER_MERCHANT_AMOUNT_LIMIT
  end

  private

  def instance_variables(user, card, device, merchant, transaction)
    @user = user
    @card = card
    @device = device
    @merchant = merchant
    @transaction = transaction
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

  def block_user_card_device_and_save
    @user.blocked = true
    @card.blocked = true
    @device.blocked = true
    @user.save
    @card.save
    @device.save
  end
end

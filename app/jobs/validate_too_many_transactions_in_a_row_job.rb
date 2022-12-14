class ValidateTooManyTransactionsInARowJob < ApplicationJob
  queue_as :default

  USER_TRANSACTIONS_LIMIT = 15
  USER_MERCHANT_TRANSACTIONS_LIMIT = 10

  def perform(user, card, device, merchant, transaction)
    @user = user
    @card = card
    @device = device
    @merchant = merchant
    @transaction = transaction
    block_if_user_have_too_many_transactions_in_a_day
    block_if_user_and_merchant_have_too_many_transactions_in_a_day
  end

  private

  def block_if_user_have_too_many_transactions_in_a_day
    transactions_count = 1
    @user.transactions.each do |transaction|
      transactions_count += 1 if transaction.date.to_date == @transaction.date.to_date
    end
    puts 'block_if_user_have_too_many_transactions_in_a_day' if transactions_count > USER_TRANSACTIONS_LIMIT
    block_user_card_device if transactions_count > USER_TRANSACTIONS_LIMIT
  end

  def block_if_user_and_merchant_have_too_many_transactions_in_a_day
    transactions_count = 1
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

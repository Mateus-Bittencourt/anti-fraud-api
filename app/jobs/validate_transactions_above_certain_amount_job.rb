class ValidateTransactionsAboveCertainAmountJob < ApplicationJob
  queue_as :default

  def perform(user_id, card_id, device_id, merchant_id, transaction_id)
    params = {
      user_id:,
      card_id:,
      device_id:,
      merchant_id:,
      transaction_id:
    }
    BackgroundService.new(params).validate_transactions_above_certain_amount
  end
end

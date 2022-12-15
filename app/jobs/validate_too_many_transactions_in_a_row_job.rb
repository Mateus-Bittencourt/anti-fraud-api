class ValidateTooManyTransactionsInARowJob < ApplicationJob
  queue_as :default

  def perform(user_id, card_id, device_id, merchant_id, transaction_id)
    params = {
      user_id:,
      card_id:,
      device_id:,
      merchant_id:,
      transaction_id:
    }

    BackgroundService.new(params).validate_too_many_transactions_in_a_row
  end
end

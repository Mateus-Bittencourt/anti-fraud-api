class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/v1/transactions
  def create
    @transaction = TransactionService.new(params).create_transaction
  end

end

class ChargebackService
  def initialize(params)
    @transaction = Transaction.find(params[:transaction_id])
    @user = @transaction.user
    @merchant = @transaction.merchant
  end

  def save_chargeback
    @transaction.chargeback = true
    @user.chargeback_count += 1
    @merchant.chargeback_count += 1
    Transaction.transaction do
        @transaction.save
        @user.save
        @merchant.save
    end
    @transaction
  end
end

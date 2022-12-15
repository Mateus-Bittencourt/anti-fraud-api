class ChargebacksController < ApplicationController
  def update
    @transaction = ChargebackService.new(params).save_chargeback
    render json: @transaction
  end
end

class ChargebacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    @transaction = ChargebackService.new(params).save_chargeback
    render json: @transaction
  end
end

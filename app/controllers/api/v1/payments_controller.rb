class Api::V1::PaymentsController < ApiController
  respond_to :xml, :json

  def index
    user = User.find_by(id: params[:user_id])

    result = []
    if params.has_key?(:pending)
      result = payments(paid=false, user)
    else
      result = payments(paid=true, user)
    end
    render json: {:payments => result}
  end

  def show

  end

  def create
    user = User.find_by(id: params[:user_id])
    from_user = User.find_by(id: params[:from_user_id])
    result = user.ratings.create!(from_user: from_user.id, ride_id: params[:ride_id], rating_type: params[:rating_type])

    unless result.nil?
      render json: {:result => "1"}
    else
      render json: {:result => "0"}
    end
  end

  private

  def payments(paid=true, user)
    result = []
    user.rides_as_passenger.each do |p|
      if p[:is_paid] == paid
        payment = {}
        payment[:ride_id] = p[:id]
        payment[:is_paid] = p[:is_paid]
        payment[:driver_id] = p.driver.id
        result.append(payment)
      end
    end
    result
  end


end
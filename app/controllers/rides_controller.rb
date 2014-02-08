class RidesController < ApplicationController
  before_action :signed_in_user, only: [:new, :destroy]

  def index

  end

  def new
    @ride = Ride.new
  end

  def create
    @ride = current_user.rides.build(ride_params)
    if @ride.save
      flash[:success] = "Ride was added!"
      redirect_to current_user
    else
      render 'new'
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end


  private

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats, :meeting_poing)
  end

end

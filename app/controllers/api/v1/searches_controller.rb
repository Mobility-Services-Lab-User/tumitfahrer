class Api::V1::SearchesController < ApiController
  respond_to :json, :xml

  def show
    render json: {:status => :ok}
  end

  def create
    start_carpool = params[:start_carpool]
    end_carpool = params[:end_carpool]
    ride_date = params[:ride_date]

    results = []
    Ride.all.each do |ride|
      duration = extra_duration(ride[:departure_place], ride[:destination], start_carpool, end_carpool)
      #if duration < ride[:duration]/10 # && (ride_date-ride[:departure_time])/3600<24
        ride_attributes = ride.attributes

      logger.debug "RESULT1: #{ride_attributes}"
        ride_attributes[:detour] = duration
        ride_attributes[:driver_id] = ride.driver.id
        results.append(ride_attributes)
      #end
    end

    logger.debug "RESULT: #{results.to_s}"

    respond_to do |format|
      format.json { render json: {:rides => results} }
      format.xml { render xml: {:rides => results} }
    end
  end

  private

  def extra_duration(start_point, end_point, start_carpool, end_carpool)
    logger.debug "Preparing result"
    result = prepare_url(start_point, end_point, start_carpool, end_carpool)
    return result["routes"].first["legs"].first["duration"]["value"]/60
  end

  def prepare_url(start_point, end_point, start_carpool, end_carpool)
    url = URI.parse(URI.encode("http://maps.googleapis.com/maps/api/directions/json?origin=\"#{start_point}\"&destination=\"#{end_point}\"&waypoints=\"#{start_carpool}\"|\"#{end_carpool}\"&region=de&&sensor=false"))
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
    return JSON.parse(res.body)
  end

end

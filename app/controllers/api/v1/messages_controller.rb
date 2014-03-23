class Api::V1::MessagesController < ApiController
  respond_to :xml, :json

  def index
    user = User.find_by(id: params[:user_id])
    senders = Message.select(:sender_id).where(receiver_id:user.id).map(&:sender_id).uniq
    receivers = Message.select(:receiver_id).where(sender_id:user.id).map(&:receiver_id).uniq

    partner_ids = (senders + receivers).uniq
    results = []
    partner_ids.each do |partner_id|
      sent = Message.where(sender_id:user.id, receiver_id: partner_id).order("created_at").last
      received = Message.where(sender_id:partner_id, receiver_id: user.id).order("created_at").last

      if received.nil? || (!sent.nil? && sent[:created_at]>received[:created_at])
        results.append(sent)
      else
        results.append(received)
      end
    end

    respond_to do |format|
      format.json { render json: {:conversations => results}}
      format.xml { render xml: {:conversations => results} }
    end

  end

  def show
    user = User.find_by(id: params[:user_id])
    other_user = User.find_by(id: params[:id])
    sent_messages = user.sent_messages.where(receiver_id: other_user.id)
    received_messages = user.received_messages.where(sender_id: other_user.id)
    messages = sent_messages + received_messages

    respond_to do |format|
      format.json { render json: {:messages => messages} }
      format.xml { render xml: {:messages => messages} }
    end
  end

  def create
    user = User.find_by(id: params[:user_id])
    other_user = User.find_by(id: params[:receiver_id])
    user.send_message!(other_user, params[:content])

    respond_to do |format|
      format.json { render json: {:status => 200} }
      format.xml { render xml: {:status => 200} }
    end
  end

  def update
    Message.find_by(id: params[:message_id]).update_attribute(:is_seen, params[:is_seen])
    respond_to do |format|
      format.json { render json: {:status => 200} }
      format.xml { render xml: {:status => 200} }
    end
  end

end
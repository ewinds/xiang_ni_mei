require 'base64'

class Api::CardsController < Api::BaseApiController
  def create
    @user = User.find_by_authentication_token(params[:auth_token])
    if @user.nil?
      logger.info('Token not found.')
      render :status => 401, :json => {:message => 'Invalid token.'}
    else
      @card = @user.add_card(params[:client_id])

      image_content_type = params[:image_data].match(/data:(\w+\/\w+);.+/).captures
      image_file = Tempfile.new('imagefile')
      image_file.binmode
      image_file.write(Base64.strict_decode64(params[:image_data].gsub!(/.*;base64,/, '').gsub!("\n", '')))
      #create a new uploaded file
      image_uploaded_file = ActionDispatch::Http::UploadedFile.new(
          :tempfile => image_file, :filename => 'image', :content_type => image_content_type)
      @card.update_attribute :image, image_uploaded_file

      if params.has_key? :audio_data
        audio_content_type = params[:audio_data].match(/data:(\w+\/\w+);.+/).captures
        audio_file = Tempfile.new('audiofile')
        audio_file.binmode
        audio_file.write(Base64.strict_decode64(params[:audio_data].gsub!(/.*;base64,/, '').gsub!("\n", '')))
        #create a new uploaded file
        audio_uploaded_file = ActionDispatch::Http::UploadedFile.new(
            :tempfile => audio_file, :filename => 'audio', :content_type => audio_content_type)
        @card.update_attribute :audio, audio_uploaded_file
      end

      if @card.save
        render :status => 200, :json => {:message => 'Card was successfully created.'}
      else
        render :status => 500, :json => {:message => 'Unable to save card.'}
      end
    end
  end
end

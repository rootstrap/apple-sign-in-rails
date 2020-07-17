module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :exception
      include Api::Concerns::ActAsApiRequest

      def apple_sign_up
        binding.pry
        AppleSignIn::UserIdentity.new(apple_sign_up_params[:user_identity], apple_sign_up_params[:jwt]).valid?
        # @resource = User.sign_up_with_provider('apple', apple_sign_up_params)
        custom_sign_in
      rescue ActiveRecord::RecordNotUnique
        render_error(:bad_request, I18n.t('api.errors.user.already_registered'))
      end

      private
      def custom_sign_in
        # sign_in(:api_v1_user, @resource)
        # new_auth_header = @resource.create_new_auth_token
        # # update response with the header that will be required by the next request
        # response.headers.merge!(new_auth_header)
        # render_create_success
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation,
                                     :username, :first_name, :last_name)
      end

      def apple_sign_up_params
        params.permit(:user_identity, :jwt)
      end

      def render_create_success
        render json: { user: resource_data }
      end
    end
  end
end

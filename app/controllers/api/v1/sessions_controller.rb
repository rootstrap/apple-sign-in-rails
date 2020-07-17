module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      protect_from_forgery with: :null_session
      include Api::Concerns::ActAsApiRequest
      def apple_sign_in
        
      rescue ActiveRecord::RecordNotFound
        render_error(:not_found, I18n.t('api.errors.user.not_registered'))
      end

      private

      def resource_params
        params.require(:user).permit(:email, :password)
      end

      def render_create_success
        render json: { user: resource_data }
      end
    end
  end
end

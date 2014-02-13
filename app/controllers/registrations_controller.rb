class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    if request.format == "text/html"
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        # custom code #
        flash[:alert] = resource.errors.full_messages.join('; ')
        ###############
        clean_up_passwords resource
        respond_with resource
      end
    else
      if resource.save
        logger.info "BBBBBBBBBBBBBBBBBBB"
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          return render :json => {:success => true}
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          return render :json => {:success => true}
        end
      else
        logger.info "CCCCCCCCCCCCCCCCCCCC"
        clean_up_passwords resource
        return render :json => {:success => false}
      end
    end
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end
end

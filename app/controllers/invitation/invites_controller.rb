module Invitation

  #
  # Invitation::InvitesController - issue invitations to users via email address.
  #
  # Controller uses an (inner class) Form object that is not a persisted model. The
  # form can accept many email addresses, and creates on Invite per email address.
  #
  # Subclass and modify/extend, or copy the controller into your app with `rails generate invitation:controller`.
  #
  # Common extensions could include:
  # * add authorization checks: subclass and add before_actions to :new and :create.
  # * override after_invite_existing_user or after_invite_new_user
  #
  class InvitesController < ApplicationController

    def new
      @invite = InviteForm.new(invite_params)
      render template: 'invites/new'
    end

    #
    # Create one or more Invite instances.
    #   invite: { invitable_id, invitable_type, email or emails:[] }
    #
    def create
      invites = InviteForm.new(invite_params).build_invites(current_user)
      failures = Invitation::InviteEmails.new(invites).send_invites
      logger.info "!!!!!!!!!!!!!!!!!!!!! INSIDE CREATE: current_user: #{current_user.inspect}"
      respond_to do |format|
        format.html do
          if failures.empty?
            flash[:notice] = t('invitation.flash.invite_issued', count: invites.count)
          else
            flash[:error] = t('invitation.flash.invite_error', count: failures.count, email: failures.to_sentence)
          end
          redirect_to url_after_invite(invites.first) # FIXME: redirect to back
        end
        format.json do
          if failures.empty?
            # If we received a single email, json response should be a scalar, not an array.
            invites = params[:invite].key?('email') ? invites.first : invites
            render json: invites.as_json(except: [:token, :created_at, :updated_at]), status: 201
          else
            render json: {
              message: t('invitation.flash.invite_error', count: failures.count, email: failures.to_sentence),
              status: :unprocessable_entity
            }
          end
        end
      end
    end

    # After an invite is created, redirect the user here.
    # Default implementation doesn't return a url, just the invitable.
    def url_after_invite(invite)
      invite.invitable
    end

    def invite_params
      params[:invite] ? params.require(:invite).permit(:invitable_id, :invitable_type, :email, emails: []) : {}
    end
  end
end

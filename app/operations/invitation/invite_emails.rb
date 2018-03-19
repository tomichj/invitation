module Invitation
  class InviteEmails
    attr_reader :invites, :failures, :mailer

    def initialize(invites, opts = {})
      @invites = invites
      @mailer = opts[:mailer] || InviteMailer
    end

    def send_invites
      @failures = []
      ActiveRecord::Base.transaction do
        invites.each { |invite| invite.save ? do_invite(invite) : @failures << invite.email }
      end
      @failures
    end

    # Invite user by sending email.
    # Existing users are granted permissions via #after_invite_existing_user.
    # New users are granted permissions via #after_invite_new_user, currently a null op.
    def do_invite(invite)
      if invite.existing_user?
        deliver_email(mailer.existing_user(invite))
        after_invite_existing_user(invite)
        invite.save
      else
        deliver_email(mailer.new_user(invite))
        after_invite_new_user(invite)
      end
    end

    # Use deliver_later from rails 4.2+ if available.
    def deliver_email(mail)
      if mail.respond_to?(:deliver_later)
        mail.deliver_later
      else
        mail.deliver
      end
    end

    private

    # Override this if you want to do something more complicated for existing users.
    # For example, if you have a more complex permissions scheme than just a simple
    # has_many relationship, enable it here.
    def after_invite_existing_user(invite)
      # Add the user to the invitable resource/organization
      invite.invitable.add_invited_user(invite.recipient)
    end

    # Override if you want to do something more complicated for new users.
    # By default we don't do anything extra.
    def after_invite_new_user(invite)
    end
  end
end

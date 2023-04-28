require 'spec_helper'

RSpec.describe Invitation::InviteEmails do
  describe 'custom mailer' do
    let(:mail) { double('Mail') }
    let(:test_mailer) { double('InviteMailer') }

    subject { described_class.new(invites, mailer: test_mailer).send_invites }

    let(:invites) { [create(:invite, :recipient_is_existing_user)] }

    it 'sends email through the given mailer' do
      allow(mail).to receive(:deliver).once
      expect(test_mailer).to receive(:existing_user).once.and_return(mail)
      subject
    end
  end
end

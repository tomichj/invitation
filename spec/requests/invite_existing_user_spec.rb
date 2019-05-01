require 'spec_helper'
require 'support/requests/request_helpers'

describe 'invite api' do
  before(:each) do
    @user = create(:user, :with_company)
    @company = @user.companies.first
  end

  context 'invite an existing user' do
    let(:existing_user) { create(:user, :with_company)}
    subject {
      do_post invites_path,
              params: { invite: { invitable_id: @company.id,
                                  invitable_type: @company.class.name,
                                  email: existing_user.email } },
              **json_headers()
    }


    it 'creates invite to new resource' do
      sign_in_with @user
      subject
      expect(existing_user.invitations.first.invitable).to eq @company
    end

    it 'adds existing user to new resource immediately' do
      sign_in_with @user
      subject
      expect(existing_user.companies).to include @company
    end
  end
end

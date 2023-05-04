require 'spec_helper'
require 'support/requests/request_helpers'

describe 'api' do
  before(:each) do
    @user = create(:user, :with_company)
    @company = @user.companies.first
  end

  context 'invite a new user' do
    let(:email) { 'gug@gug.com' }
    subject do
      do_post invites_path,
              params: { invite: { invitable_id: @company.id,
                                  invitable_type: @company.class.name,
                                  email: email } },
              **json_headers
    end

    it 'returns json' do
      sign_in_with @user
      subject
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns success' do
      sign_in_with @user
      subject
      expect(response).to have_http_status(:success)
      expect(response).to have_http_status(:created)
    end

    it 'sends invitation email' do
      sign_in_with @user
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'json reply describes invite' do
      sign_in_with @user
      subject
      invite = JSON.parse(response.body)
      expect(invite['email']).to eq email
      expect(invite['recipient_id']).to be nil
      expect(invite['sender_id']).to eq @user.id
      expect(invite['invitable_id']).to eq @company.id
      expect(invite['invitable_type']).to eq @company.class.name
    end
  end
end

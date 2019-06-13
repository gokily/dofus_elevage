require 'rails_helper'

RSpec.describe MountsController, type: :controller do


  describe "#index" do
    context "as an authenticated user" do
      before do
        @user = create(:user)
      end
      it "returns a 200 response" do
        sign_in @user
        get :index
        expect(response).to have_http_status(200)
      end
    end

    context "as a guest user" do
      it 'returns a 302 response' do
        get :index
        expect(response).to have_http_status(302)
      end
      it 'redirects to the signin page' do
        get :index
        expect(response).to redirect_to('/users/sign_in')
      end
    end
  end

  describe '#create' do
    context 'as an authenticated user' do
      before do
        @user = create(:user)
      end
      
      it 'adds a mount' do
        mount_params = attributes_for(:mount)
        sign_in @user
        expect {
          post :create, params: {mount: mount_params}
        }.to change(@user.mounts, :count).by 1
      end
    end

    context 'as a guest user' do
      it 'returns a 302 response' do
        mount_params = attributes_for(:mount)
        post :create, params: {mount: mount_params}
        expect(response).to have_http_status(302)
      end

      it 'redirects to the sign_in page' do
        mount_params = attributes_for(:mount)
        post :create, params: {mount: mount_params}
        expect(response).to redirect_to('/users/sign_in')
      end
    end
  end
end

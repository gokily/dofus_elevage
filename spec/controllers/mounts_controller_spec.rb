# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MountsController, type: :controller do
  describe '#index' do
    context 'as an authenticated user' do
      before do
        @user = create(:user)
      end
      it 'returns a 200 response' do
        sign_in @user
        get :index
        expect(response).to have_http_status(200)
      end
    end

    context 'as a guest user' do
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
        expect do
          post :create, params: { mount: mount_params }
        end.to change(@user.mounts, :count).by 1
      end
    end

    context 'as a guest user' do
      it 'returns a 302 response' do
        mount_params = attributes_for(:mount)
        post :create, params: { mount: mount_params }
        expect(response).to have_http_status(302)
      end

      it 'redirects to the sign_in page' do
        mount_params = attributes_for(:mount)
        post :create, params: { mount: mount_params }
        expect(response).to redirect_to('/users/sign_in')
      end
    end
  end

  describe '#update' do
    before do
      @user = create(:user)
      @mount = create(:mount, owner: @user, name: 'old')
    end

    context 'as the correct user' do
      it 'edit the mounts' do
        sign_in @user
        mount_params = attributes_for(:mount, name: 'new')
        patch :update, params: { id: @mount.id, mount: mount_params }
        expect(@mount.reload.name).to eq 'new'
      end
    end
    context 'as an incorrect user' do
      context 'as a guest user' do
        it 'redirects to the sign in page' do
          mount_params = attributes_for(:mount, name: 'new')
          patch :update, params: { id: @mount.id, mount: mount_params }
          expect(response).to redirect_to '/users/sign_in'
        end
      end
      context 'as an other user' do
        before do
          @other_user = create(:user)
        end
        it 'does not update the mount' do
          sign_in @other_user
          mount_params = attributes_for(:mount, name: 'new')
          patch :update, params: { id: @mount.id, mount: mount_params }
          expect(@mount.reload.name).to eq 'old'
        end
        it 'redirects to the mounts index of the current_user' do
          sign_in @other_user
          mount_params = attributes_for(:mount, name: 'new')
          patch :update, params: { id: @mount.id, mount: mount_params }
          expect(response).to redirect_to mounts_path
        end
      end
    end
  end

  describe '#destroy' do
    before do
      @user = create(:user)
      @mount = create(:mount, owner: @user)
    end

    context 'as the correct user' do
      it 'deletes the mount' do
        sign_in @user
        expect do
          delete :destroy, params: { id: @mount.id }
        end.to change(@user.mounts, :count).by -1
      end
    end
    context 'as another user' do
      context 'as the incorrect user' do
        before do
          @other_user = create(:user)
          sign_in @other_user
        end
        it 'does not delete the mount' do
          expect do
            delete :destroy, params: { id: @mount.id }
          end.to change(@user.mounts, :count).by 0
        end
        it 'redirects to the mount index' do
          delete :destroy, params: { id: @mount.id }
          expect(response).to redirect_to mounts_path
        end
      end
      context 'as a guest user' do
        it 'does not delete the mount' do
          expect do
            delete :destroy, params: { id: @mount.id }
          end.to change(@user.mounts, :count).by 0
        end
        it 'redirects to the sign_in page' do
          delete :destroy, params: { id: @mount.id }
          expect(response).to redirect_to '/users/sign_in'
        end
      end
    end
  end

  describe '#mate' do
    before do
      @user = create(:user)
      @male = create(:mount,
                     owner: @user, reproduction: 4, pregnant: false, sex: 'M')
      @female = create(:mount,
                       owner: @user, reproduction: 3, pregnant: false, sex: 'F')
    end
    context 'as the correct user' do
      before do
        sign_in @user
      end
      it 'mates the mounts' do
        get :mate, params: { id: @male.id, parent2: @female.id }
        expect(@male.reload.pregnant).to be false
        expect(@female.reload.pregnant).to be true
      end

      it 'reduces the reproduction count by 1' do
        expect do
          get :mate, params: { id: @male.id, parent2: @female.id }
        end.to change { @male.reload.reproduction }.by(-1)
                                                   .and change { @female.reload.reproduction }.by(-1)
      end
    end
    context 'as an incorrect user' do
      context 'as a guest user' do
        it 'does not mate the mounts' do
          get :mate, params: { id: @male.id, parent2: @female.id }
          expect(@male.reload.pregnant).to be false
          expect(@female.reload.pregnant).to be false
        end
        it 'redirects to the sign in page' do
          get :mate, params: { id: @male.id, parent2: @female.id }
          expect(response).to redirect_to '/users/sign_in'
        end
      end
      context 'as an other user' do
        before do
          @other_user = create(:user)
          sign_in @other_user
        end
        it 'does not mate the mounts' do
          get :mate, params: { id: @male.id, parent2: @female.id }
          expect(@male.reload.pregnant).to be false
          expect(@female.reload.pregnant).to be false
        end
        it 'redirects to the current_user\'s mounts index' do
          get :mate, params: { id: @male.id, parent2: @female.id }
          expect(response).to redirect_to(mounts_path)
        end
      end
    end
  end

  describe '#birth_create' do
    before do
      @user = create(:user)
      @father = create(:mount, owner: @user, sex: 'M')
      @mother = create(:mount, owner: @user, sex: 'F', pregnant: true)
      @mount_params1 = attributes_for(:mount, father_id: @father.id,
                                      mother_id: @mother.id)
      @mount_params2 = attributes_for(:mount, father_id: @father.id,
                                      mother_id: @mother.id)
    end
    context 'as the correct user' do
      before do
        sign_in @user
      end
      it 'gives birth to babies from the mother and father' do
        expect do
          post :birth_create, params: { children: { '0' => @mount_params1,
                                                    '1' => @mount_params2 } }
        end.to change(@user.mounts, :count).by 2
      end
      it 'change the pregnancy status of the mother' do
        post :birth_create, params: { children: { '0' => @mount_params1,
                                                  '1' => @mount_params2 } }
        expect(@mother.pregnant).to be true
        expect(@mother.reload.pregnant).to be false
      end
    end
    context 'as an incorrect user' do
      context 'as a guest user' do
        it 'does not give birth to the mounts' do
          expect do
            post :birth_create, params: { children: { '0' => @mount_params1,
                                                      '1' => @mount_params2 } }
          end.to change(@user.mounts, :count).by 0
        end
        it 'redirects to the sign in page' do
          post :birth_create, params: { children: { '0' => @mount_params1,
                                                    '1' => @mount_params2 } }
          expect(response).to redirect_to '/users/sign_in'
        end
      end
      context 'as an other user' do
        before do
          @other_user = create(:user)
          sign_in @other_user
        end
        it 'does not give birth to the mounts' do
          expect do
            post :birth_create, params: { children: { '0' => @mount_params1,
                                                      '1' => @mount_params2 } }
          end.to change(@user.mounts, :count).by 0
        end
        it 'redirects to the current_user\'s mounts index' do
          post :birth_create, params: { children: { '0' => @mount_params1,
                                                    '1' => @mount_params2 } }
          expect(response).to redirect_to(mounts_path)
        end
      end
    end
  end
end

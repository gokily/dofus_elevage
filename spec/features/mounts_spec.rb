require 'rails_helper'

RSpec.feature "Mounts", type: :feature do
  let(:user) { create(:user) }

  scenario 'user adds a new mount' do
    sign_in user
    visit muldos_path

    expect do
      click_link 'New mount'
      fill_in 'Name', with: 'new'
      select 'Amande et Ivoire', from: 'Color'
      choose 'Male'
      choose 'No'
      click_button 'Add muldo'
      expect(page).to have_content 'New mount added!'
      expect(page).to have_current_path muldos_path
    end.to change(user.mounts, :count).by 1
  end

  scenario 'user looks at the mount details' do
    sign_in user
    mount = create(:muldo, name: 'first', owner: user)
    visit muldos_path
    within('ol.mount-list') do
      expect(page).to have_css('.mount-name')
    end
    click_link(mount.name)
    aggregate_failures do
      expect(page).to have_content(mount.name)
      expect(page).to have_content(mount.color)
      expect(page).to have_content(mount.sex)
      expect(page).to have_content(mount.repro_status)
      within('.mount-reproduction') do
        expect(page).to have_content(mount.reproduction)
      end
    end
  end
end

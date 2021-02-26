require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  describe 'ログイン前' do
    let(:user) { create(:user, password: 'password') }
    before do
      visit login_path
    end
    context 'フォームの入力値が正常' do
      it 'ログイン処理が成功する' do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
    end
    context 'フォームが未入力' do
      it 'ログイン処理が失敗する' do
        fill_in 'Email', with: ''
        fill_in 'Password', with: ''
        click_button 'Login'
        expect(page).to have_content 'Login failed'
        expect(current_path).to eq login_path
      end
    end
  end

  describe 'ログイン後' do
    let(:user) { create(:user, password: 'password') }
    context 'ログアウトボタンをクリック' do
      it 'ログアウト処理が成功する' do
        login_as user
        visit root_path
        click_link 'Logout'
        expect(page).to have_content 'Logged out'
        expect(current_path).to eq root_path
      end
    end
  end
end

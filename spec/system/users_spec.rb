require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe 'ログイン前' do
    let(:user) { build(:user) }
    describe 'ユーザー新規登録' do
      before do
        visit sign_up_path
      end
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          expect {
            fill_in 'Email', with: user.email
            fill_in 'Password', with: user.password
            fill_in 'Password confirmation', with: user.password_confirmation
            click_button 'SignUp'
          }.to change(User, :count).by(1)
          expect(page).to have_content 'User was successfully created.'
          expect(current_path).to eq login_path
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          expect {
            fill_in 'Email', with: ''
            fill_in 'Password', with: user.password
            fill_in 'Password confirmation', with: user.password_confirmation
            click_button 'SignUp'
          }.to change(User, :count).by(0)
          expect(page).to have_content "Email can't be blank"
          expect(current_path).to eq users_path
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          signed_up_user = create(:user)
          expect {
            fill_in 'Email', with: signed_up_user.email
            fill_in 'Password', with: signed_up_user.password
            fill_in 'Password confirmation', with: signed_up_user.password_confirmation
            click_button 'SignUp'
          }.to change(User, :count).by(0)
          expect(page).to have_content 'Email has already been taken'
          expect(current_path).to eq users_path
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path(1)
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end
    end
  end

  describe 'ログイン後' do
    let(:user) { create(:user, password: 'password') }
    let(:other_signed_up_user) { create(:user) }
    before do
      sign_in_as user
    end
    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          visit edit_user_path(user.id)
          fill_in 'Email', with: user.email
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Update'
          expect(page).to have_content 'User was successfully updated.'
          expect(current_path).to eq user_path(user.id)
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user.id)
          fill_in 'Email', with: ''
          click_button 'Update'
          expect(page).to have_content "Email can't be blank"
          expect(current_path).to eq user_path(user.id)
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user.id)
          fill_in 'Email', with: other_signed_up_user.email
          click_button 'Update'
          expect(page).to have_content 'Email has already been taken'
          expect(current_path).to eq user_path(user.id)
        end
      end
      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_user_path(other_signed_up_user.id)
          expect(page).to have_content 'Forbidden access.'
          expect(current_path).to eq user_path(user.id)
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        let!(:task) { create(:task, user: user) }
        it '新規作成したタスクが表示される' do
          visit user_path(user.id)
          expect(page).to have_content task.title
        end
      end
    end
  end
end

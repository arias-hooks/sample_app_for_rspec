require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let(:user) { create(:user, password: 'password') }
  describe 'ログイン後' do
    before do
      login_as user
    end
    describe 'タスクの新規登録' do
      it 'タスクの新規登録が成功する' do
        visit new_task_path
        expect {
          fill_in 'Title', with: 'title_1'
          fill_in 'Content', with: 'content'
          select 'todo', from: 'Status'
          fill_in 'Deadline', with: 1.week.from_now
          click_button 'Create Task'
        }.to change(Task, :count).by(1)
        expect(page).to have_content 'Task was successfully created.'
        expect(page).to have_content 'title_1'
        expect(current_path).to eq task_path(1)
      end
    end
    describe 'タスクの編集' do
      it 'タスクの編集が成功する' do
        task = create(:task, user: user)
        visit edit_task_path(task.id)
        fill_in 'Title', with: 'edit_title'
        click_button 'Update Task'
        expect(page).to have_content 'Task was successfully updated.'
        expect(page).to have_content 'edit_title'
        expect(current_path).to eq task_path(task.id)
      end
    end
    describe 'タスクの削除' do
      it 'タスクの削除が成功する' do
        task = create(:task, user: user)
        visit tasks_path
        page.accept_alert 'Are you sure?' do
          click_link 'Destroy'
        end
        expect(page).to have_content 'Task was successfully destroyed.'
        expect(current_path).to eq tasks_path
      end
    end
  end

  describe 'ログイン前' do
    describe 'タスクの新規登録' do
      it 'タスクの新規登録ページへのアクセスが失敗する' do
        visit new_task_path
        expect(page).to have_content 'Login required'
        expect(current_path).to eq login_path
      end
    end
    describe 'タスクの編集' do
      it 'タスクの編集ページへのアクセスが失敗する' do
        task = create(:task, user: user)
        visit edit_task_path(task.id)
        expect(page).to have_content 'Login required'
        expect(current_path).to eq login_path
      end
    end
  end
end

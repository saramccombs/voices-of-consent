require 'rails_helper'

RSpec.describe "message_logs/new", type: :view do
  before(:each) do
    messageable = create(:box_request)
    @message_log = create(:message_log,
           messageable_type: "BoxRequest",
           messageable_id: messageable.id,
           content: "MyText",
           delivery_type: 3,
           delivery_status: "Delivery Status",
           sendable_type: "Volunteer"
           sendable_id: create(:user),
           sent_by: create(:user)
    )
  end

  it "renders new message_log form" do
    render

    assert_select "form[action=?][method=?]", message_log_path(@message_log), "post" do
      assert_select "input[name=?]", "message_log[messageable_type]"
      assert_select "input[name=?]", "message_log[messageable_id]"
      assert_select "textarea[name=?]", "message_log[content]"
      assert_select "input[name=?]", "message_log[delivery_type]"
      assert_select "input[name=?]", "message_log[delivery_status]"
      assert_select "input[name=?]", "message_log[sendable_type]"
      assert_select "input[name=?]", "message_log[sendable_id]"
      assert_select "input[name=?]", "message_log[sent_by_id]"
    end
    page = render
    expect(page).to include('react-root')
    expect(page).to include('js/message_log_form')
  end
end

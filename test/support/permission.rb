def with_permission(permission)
  code = yield
  response code, "with #{permission} permission" do
    let(:user) { create :user, :as_member, permissions: [permission] }
    run_test!
  end
end

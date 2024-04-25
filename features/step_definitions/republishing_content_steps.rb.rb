Given(/^the "([^"]*)" page can be republished$/) do |_page_title|
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "([^"]*)" page$/) do |page_title|
  visit admin_republishing_index_path
  find(republishing_link_id_from_page_title(page_title)).click
  click_button("Confirm republishing")
end

Then(/^I can see the "([^"]*)" page has been scheduled for republishing/) do |page_title|
  expect(page).to have_selector(".gem-c-success-alert", text: "The '#{page_title}' page has been scheduled for republishing")
end

Given(/^a published organisation "An Existing Organisation" exists$/) do
  create(:organisation, name: "An Existing Organisation", slug: "an-existing-organisation")
end

Given(/^the "An Existing Organisation" organisation can be republished$/) do
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "An Existing Organisation" organisation$/) do
  visit admin_republishing_index_path
  find("#republish-organisation").click
  fill_in "Enter the slug for the organisation", with: "an-existing-organisation"
  click_button("Continue")
  click_button("Confirm republishing")
end

Then(/^I can see the "An Existing Organisation" organisation has been scheduled for republishing/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "The 'An Existing Organisation' organisation has been scheduled for republishing")
end

Given(/^a published person "Existing Person" exists$/) do
  create(:person, forename: "Existing", surname: "Person", slug: "existing-person")
end

Given(/^the "Existing Person" person can be republished$/) do
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "Existing Person" person$/) do
  visit admin_republishing_index_path
  find("#republish-person").click
  fill_in "Enter the slug for the person", with: "existing-person"
  click_button("Continue")
  click_button("Confirm republishing")
end

Then(/^I can see the "Existing Person" person has been scheduled for republishing/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "The 'Existing Person' person has been scheduled for republishing")
end

Given(/^a published role "An Existing Role" exists$/) do
  create(:role, name: "An Existing Role", slug: "an-existing-role")
end

Given(/^the "An Existing Role" role can be republished$/) do
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "An Existing Role" role$/) do
  visit admin_republishing_index_path
  find("#republish-role").click
  fill_in "Enter the slug for the role", with: "an-existing-role"
  click_button("Continue")
  click_button("Confirm republishing")
end

Then(/^I can see the "An Existing Role" role has been scheduled for republishing/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "The 'An Existing Role' role has been scheduled for republishing")
end

def republishing_link_id_from_page_title(page_title)
  link_id = "#republish-"

  link_id += case page_title
             when "Find a British embassy, high commission or consulate"
               "embassies"
             when "Help and services around the world"
               "world"
             when "Departments, agencies and public bodies"
               "organisations"
             else
               page_title.downcase.gsub(" ", "-")
             end

  link_id
end
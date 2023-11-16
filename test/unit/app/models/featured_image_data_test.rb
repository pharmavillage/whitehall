require "test_helper"

class FeaturedImageDataTest < ActiveSupport::TestCase
  test "rejects SVG logo uploads" do
    svg_image = File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))
    image_data = build(:featured_image_data, file: svg_image)

    assert_not image_data.valid?
    assert_includes image_data.errors.map(&:full_message), "File You are not allowed to upload \"svg\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "rejects non-image file uploads" do
    non_image_file = File.open(Rails.root.join("test/fixtures/folders.zip"))
    topical_event_featuring_image_data = build(:featured_image_data, file: non_image_file)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File You are not allowed to upload \"zip\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "should ensure that file is present" do
    topical_event_featuring_image_data = build(:featured_image_data, file: nil)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File can't be blank"
  end

  test "accepts valid image uploads" do
    jpg_image = File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg"))
    topical_event_featuring_image_data = build(:featured_image_data, file: jpg_image)

    assert topical_event_featuring_image_data
    assert_empty topical_event_featuring_image_data.errors
  end

  test "should ensure the image size to be 960x640" do
    image = File.open(Rails.root.join("test/fixtures/images/50x33_gif.gif"))
    topical_event_featuring_image_data = build(:featured_image_data, file: image)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File is too small. Select an image that is 960 pixels wide and 640 pixels tall"
  end

  test "#all_asset_variants_uploaded? returns true if all assets present" do
    featured_image_data = build(:featured_image_data)

    assert featured_image_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns false if an asset variant is missing" do
    featured_image_data = build(:featured_image_data)
    featured_image_data.assets = []

    assert_not featured_image_data.all_asset_variants_uploaded?
  end

  test "should not delete previous images when FeaturedImageData is updated" do
    featured_image_data = create(:featured_image_data)

    AssetManagerDeleteAssetWorker.expects(:perform_async).never

    featured_image_data.update!(file: upload_fixture("images/960x640_jpeg.jpg"))
  end

  test "should be invalid without a featured_imageable" do
    featured_image_data = build(:featured_image_data, featured_imageable: nil)

    assert_not featured_image_data.valid?
    assert_equal featured_image_data.errors.messages[:featured_imageable], ["can't be blank"]
  end

  test "#republish_on_assets_ready should republish organisation and associations if assets are ready" do
    organisation = create(:organisation, :with_default_news_image)
    news_article = create(:news_article, organisations: [organisation])

    PublishingApiWorker.expects(:perform_async).with(Organisation.to_s, organisation.id)
    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article.document)

    organisation.default_news_image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish worldwide organisation and associations if assets are ready" do
    worldwide_organisation = create(:worldwide_organisation, :with_default_news_image)
    news_article = create(:news_article_world_news_story, worldwide_organisations: [worldwide_organisation])

    PublishingApiWorker.expects(:perform_async).with(WorldwideOrganisation.to_s, worldwide_organisation.id)
    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article.document)

    worldwide_organisation.default_news_image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish topical event if assets are ready" do
    topical_event = create(:topical_event, :with_logo)

    PublishingApiWorker.expects(:perform_async).with(TopicalEvent.to_s, topical_event.id)

    topical_event.logo.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish person and associations if assets are ready" do
    person = create(:person, :with_image)
    speech = create(:speech, role_appointment: create(:role_appointment, role: create(:ministerial_role), person:))
    create(:historical_account, person:)

    PublishingApiWorker.expects(:perform_async).with(Person.to_s, person.id)
    PublishingApiWorker.expects(:perform_async).with(HistoricalAccount.to_s, person.historical_account.id)
    Whitehall::PublishingApi.expects(:republish_document_async).with(speech.document)

    person.image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish take part page if assets are ready" do
    take_part_page = create(:take_part_page)

    PublishingApiWorker.expects(:perform_async).with(TakePartPage.to_s, take_part_page.id)

    take_part_page.image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should not run any republishing action if assets are not ready" do
    person = create(:person, :with_image)
    person.image.assets.destroy_all
    speech = create(:speech, role_appointment: create(:role_appointment, role: create(:ministerial_role), person:))
    create(:historical_account, person:)

    PublishingApiWorker.expects(:perform_async).with(Person.to_s, person.id).never
    PublishingApiWorker.expects(:perform_async).with(HistoricalAccount.to_s, person.historical_account.id).never
    Whitehall::PublishingApi.expects(:republish_document_async).with(speech.document).never

    person.image.republish_on_assets_ready
  end
end

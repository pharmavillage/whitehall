module PublishingApi
  class HistoricalAccountsIndexPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "a258e45a-acbe-4d70-ad2c-a2a20761536a"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Past Prime Ministers",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details: {},
        document_type: "historic_appointments",
        public_updated_at: Time.zone.now,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "historic_appointments",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def base_path
      "/government/history/past-prime-ministers"
    end

    def links
      {
        historical_accounts: HistoricalAccount.all.map(&:content_id),
      }
    end
  end
end

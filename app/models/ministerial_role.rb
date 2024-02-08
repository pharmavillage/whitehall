class MinisterialRole < Role
  include UserOrderable

  has_many :editions, -> { distinct }, through: :role_appointments
  has_many :consultations, -> { where("editions.type" => "Consultation").distinct }, through: :role_appointments
  has_many :news_articles, -> { where("editions.type" => "NewsArticle").distinct }, through: :role_appointments
  has_many :speeches, through: :role_appointments

  after_save :republish_ministerial_pages_to_publishing_api

  def published_speeches(options = {})
    speeches
      .live_edition.published
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  def published_news_articles(options = {})
    news_articles
      .live_edition.published
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  def self.cabinet
    where(cabinet_member: true).alphabetical_by_person
  end

  def ministerial?
    true
  end

  def destroyable?
    super && editions.empty?
  end

private

  def default_person_name
    name
  end

  def republish_ministerial_pages_to_publishing_api
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter")
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter")
  end
end

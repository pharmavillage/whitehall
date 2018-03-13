require 'test_helper'

class AssetManagerAttachmentLinkHeaderUpdateWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  let(:worker) { AssetManagerAttachmentLinkHeaderUpdateWorker.new }
  let(:attachment_data) { attachment.attachment_data }
  let(:edition) { FactoryBot.create(:published_edition) }
  let(:parent_document_url) { Whitehall.url_maker.public_document_url(edition) }

  context "when attachment doesn't belong to an edition" do
    let(:attachment) { FactoryBot.create(:file_attachment) }

    it 'does not update draft status of any assets' do
      AssetManagerUpdateAssetWorker.expects(:perform_async).never

      worker.perform(attachment_data)
    end
  end

  context 'when attachment is not a PDF' do
    let(:sample_rtf) { File.open(fixture_path.join('sample.rtf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf, attachable: edition) }

    it 'sets parent_document_url of corresponding asset' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, parent_document_url: parent_document_url)

      worker.perform(attachment_data)
    end
  end

  context 'when attachment is a PDF' do
    let(:simple_pdf) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf, attachable: edition) }

    it 'sets parent_document_url for attachment & its thumbnail' do
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.asset_manager_path, parent_document_url: parent_document_url)
      AssetManagerUpdateAssetWorker.expects(:perform_async)
        .with(attachment.file.thumbnail.asset_manager_path, parent_document_url: parent_document_url)

      worker.perform(attachment_data)
    end
  end
end

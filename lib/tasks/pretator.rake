require 'json'
require 'hashie'

namespace :pretator do
  desc "Ingest pretdata"
  task ingest_pretadata: :environment do
    Dir["#{Rails.root.join('pretadata','json')}/*.json"].each do |f|
      pret = Hashie::Mash.new(JSON.parse(File.read(f)))
      Pret.create_or_update_from_hashie(pret)
    end
  end
end

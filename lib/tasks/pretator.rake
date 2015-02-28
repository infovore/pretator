require 'json'
require 'hashie'

namespace :pretator do
  desc "Full Ingest"
  task full_ingest: [:delete_prets, :ingest_pretadata]

  desc "Ingest pretdata"
  task ingest_pretadata: :environment do
    puts "Ingesting Prets"
    Dir["#{Rails.root.join('pretadata','json')}/*.json"].each do |f|
      pret = Hashie::Mash.new(JSON.parse(File.read(f)))
      Pret.create_or_update_from_hashie(pret)
      print "."
    end
    puts
  end

  desc "Blow away all Prets in the database."
  task delete_prets: :environment do
    puts "Deleting all Prets."
    Pret.destroy_all
  end
end

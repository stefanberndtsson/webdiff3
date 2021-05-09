namespace :webdiff do
  desc "fetch and notify changes"
  task check: :environment do
    Site.timed_fetch_all_and_notify
  end
end

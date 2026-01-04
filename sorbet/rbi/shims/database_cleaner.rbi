# typed: false

# Minimal shim for the database_cleaner gems.
# The test suite uses DatabaseCleaner to manage truncation/transactions.
module DatabaseCleaner
  def self.clean_with(*args); end

  def self.strategy=(*args); end

  def self.strategy; end

  def self.cleaning(&blk); end
end

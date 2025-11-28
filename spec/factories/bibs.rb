FactoryBot.define do
  factory :bib do
    entry_type { "エントリ種別１" }
    abbreviation { "略１" }
    name { "書誌情報１" }
    journal { "雑誌名１" }
    year { "2014" }
    volume { "1" }
    number { "1" }
    pages { "100" }
    month { "january" }
    note { "注記１" }
    key { "キー１" }
    link_url { "URL１" }
    doi { "doi１" }
    authors {
      [ FactoryBot.create(:author, name: "Test_1"), FactoryBot.create(:author, name: "Test_2") ]
    }
  end
end

require "spec_helper"

describe IconHelper do
  describe "#bi_icon" do
    it "maps legacy glyphicon names to bootstrap icons" do
      html = helper.bi_icon("remove")

      expect(html).to include('class="bi bi-x"')
      expect(html).to include('style="font-size: 1rem;"')
      expect(html).to include('aria-hidden="true"')
    end

    it "supports additional html options and aria labels" do
      html = helper.bi_icon(
        "cloud",
        class: "text-primary me-2",
        title: "Cloud",
        size: "2rem",
        style: "margin-left: 1rem;",
        data: { toggle: "tooltip" },
        aria_label: "Cloud icon"
      )

      expect(html).to include('class="bi bi-cloud text-primary me-2"')
      expect(html).to include('style="font-size: 2rem; margin-left: 1rem;"')
      expect(html).to include('title="Cloud"')
      expect(html).to include('data-toggle="tooltip"')
      expect(html).to include('aria-label="Cloud icon"')
      expect(html).not_to include('aria-hidden="true"')
    end
  end

  describe "#glyphicon" do
    it "delegates to bi_icon for legacy compatibility" do
      expect(helper.glyphicon("refresh", class: "spin")).to eq(helper.bi_icon("refresh", class: "spin"))
    end
  end

  describe "#bi_icon_with_text" do
    it "renders the icon followed by escaped text" do
      html = helper.bi_icon_with_text("plus", "Add <stone>")

      expect(html).to include('class="bi bi-plus"')
      expect(html).to include('Add &lt;stone&gt;')
    end
  end
end
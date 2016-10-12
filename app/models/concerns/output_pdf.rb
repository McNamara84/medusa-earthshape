module OutputPdf
  extend ActiveSupport::Concern

  require 'barby/barcode/qr_code'
  require 'barby/outputter/png_outputter'
  QRCODE_DIM = 6

  def build_card
    report = ThinReports::Report.new(layout: report_template("igsn"))
    report.start_new_page do |page|
      set_card_data(page)
    end
    report
  end

  def build_igsn_card
    report = ThinReports::Report.new(layout: report_template("igsn"))
    report.start_new_page do |page|
      set_igsn_card_data(page)
    end
    report
  end


  def report_template(type)
    File.join(Rails.root, "app", "assets", "reports", "#{type}_template.tlf")
  end

  def set_card_data(page)
    page.item(:name).value(self.try(:name))
    page.item(:global_id).style(:font_size, 15)
    page.item(:global_id).value(global_id)
    page.item(:qr_code).src(qr_image)
#    page.item(:image).value(primary_attachment_file_path)
  end

  def set_igsn_card_data(page)
    page.item(:name).value(self.try(:name))
    page.item(:global_id).style(:font_size, 15)
    page.item(:global_id).value("IGSN:"+igsn)
    page.item(:qr_code).src(igsn_qr_image)
#    page.item(:image).value(primary_attachment_file_path)
  end


  def qr_image
    qr_data = Barby::QrCode.new(global_id).to_png(xdim: QRCODE_DIM, ydim: QRCODE_DIM)
    StringIO.new(qr_data).set_encoding("UTF-8")
  end

  def igsn_qr_image
    igsn_qr_data = Barby::QrCode.new(igsn+" | "+collection.collector+" | "+name).to_png(xdim: QRCODE_DIM, ydim: QRCODE_DIM)
    StringIO.new(igsn_qr_data).set_encoding("UTF-8")
  end


  def primary_attachment_file_path
    if attachment_files.present?
      path = attachment_files.first.data.path
      File.exist?(path) ? path : nil
    end
  end

  module ClassMethods
    def build_a_four(resources)
      report = ThinReports::Report.new(layout: resources.first.report_template("bundle"))
      divide_by_three(resources).each do |resource_1, resource_2, resource_3|
        report.list.add_row do |row|
          set_bundle_data(row, 1, resource_1)
          set_bundle_data(row, 2, resource_2)
          set_bundle_data(row, 3, resource_3)
        end
      end
      report
    end

    def build_cards(resources)
      report = ThinReports::Report.new(layout: resources.first.report_template("igsn"))
      resources.each do |resource|
        report.start_new_page do |page|
          resource.set_card_data(page)
        end
      end
      report
    end

    private

    def divide_by_three(resources)
      ary = []
      resources.in_groups_of(3) { |group| ary << group }
      ary
    end

    def set_bundle_data(row, num, resource)
      targets = ["name_#{num}", "global_id_#{num}", "qr_code_#{num}", "image_#{num}"].map!(&:to_sym)
      if resource
        row.item(targets[0]).value(resource.try(:name))
        row.item(targets[1]).value(resource.global_id)
        row.item(targets[2]).src(resource.qr_image)
        row.item(targets[3]).value(resource.primary_attachment_file_path)
      else
        targets.each { |target| row.item(target).hide }
      end
    end
  end

end

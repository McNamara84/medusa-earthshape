module ApplicationHelper

  def format_date(date)
    date.present? ? Date.parse(date).strftime("%Y-%m-%d") : ""
  end

  def difference_from_now(time)
    return unless time
    now = Time.now
    sec = now - time
    today_in_sec = now - now.at_beginning_of_day
    yesterday_in_sec = now - 1.days.ago.at_beginning_of_day

    if sec <= today_in_sec
      if sec < 60
        "#{sec.floor} s ago"
      elsif sec < (60*60)
        "#{(sec / 60).floor} m ago"
      elsif sec < (60*60*24)
        "#{(sec / (60*60)).floor} h ago"
      end
    elsif (today_in_sec < sec) && (sec < yesterday_in_sec)
      "yesterday, #{time.hour}:#{time.min}"
    else
      time.to_date
    end
  end

  def error_notification(errors)
    return if errors.blank?
    render partial: "parts/error_notification", locals: {errors: errors}
  end

  def qrcode(value, alt: nil)
    alt ||= value
    image_tag(qrcode_path(value), alt: alt)
  end
  
  def li_if_exist(prefix, value)
    return if value.blank?
    content_tag(:li, prefix + value.to_s, {}, false)
  end

  def data_count(array)
    return "" if array.nil? || array.empty?
    " (#{array.size})"
  end

  def active_if_current(tabname)
    if params[:tab]
      " active" if params[:tab] == tabname
    else 
      " active" if tabname == "at-a-glance" 
    end
  end

  def tab_param(filename)
    "?tab=#{tabname_from_filename(filename)}"
  end

  def hidden_tabname_tag(filename)
    hidden_field_tag :tab,tabname_from_filename(filename)
  end

  def link_to_add_fields(name, addfieldsclass, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    addfieldsclass=addfieldsclass+" add_fields"
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: addfieldsclass, data: {id: id, fields: fields.gsub("\n", "")})
  end

  private

  def tabname_from_filename(filename)
    File.basename(filename).sub(/^_/,"").sub(/.html.erb$/,"")
  end

end

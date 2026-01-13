# frozen_string_literal: true

# Icon Helper for Bootstrap 3 → Bootstrap Icons migration
# ========================================================
# This helper provides a compatibility layer for migrating from
# Bootstrap 3 Glyphicons to Bootstrap Icons.
#
# IMPORTANT: The ICON_MAP below translates legacy Glyphicon names to valid
# Bootstrap Icons names. This allows views to continue using familiar names
# like 'remove', 'edit', 'save' while rendering the correct Bootstrap Icon.
#
# Translation Examples:
#   bi_icon('remove')   → ICON_MAP['remove']='x'       → <i class="bi bi-x"></i>
#   bi_icon('edit')     → ICON_MAP['edit']='pencil-square' → <i class="bi bi-pencil-square"></i>
#   bi_icon('save')     → ICON_MAP['save']='floppy'   → <i class="bi bi-floppy"></i>
#   bi_icon('refresh')  → ICON_MAP['refresh']='arrow-clockwise' → <i class="bi bi-arrow-clockwise"></i>
#   bi_icon('link')     → ICON_MAP['link']='link'     → <i class="bi bi-link"></i>
#
# Usage:
#   bi_icon('cloud')           # => <i class="bi bi-cloud"></i>
#   bi_icon('cloud', class: 'text-primary')  # => <i class="bi bi-cloud text-primary"></i>
#   glyphicon('cloud')         # => Legacy alias, same as bi_icon('cloud')
#
module IconHelper
  # Mapping from Bootstrap 3 Glyphicon names to Bootstrap Icons names
  # Some icons have different names in Bootstrap Icons
  ICON_MAP = {
    # Resource icons
    'cloud' => 'cloud',
    'folder-close' => 'folder',
    'folder-open' => 'folder2-open',
    'globe' => 'globe',
    'book' => 'book',
    'stats' => 'graph-up',
    'file' => 'file-earmark',

    # Action icons
    'pencil' => 'pencil',
    'cog' => 'gear',
    'tag' => 'tag',
    'search' => 'search',
    'plus' => 'plus',
    'plus-sign' => 'plus-circle',
    'remove' => 'x',
    'ok' => 'check',
    'ok-sign' => 'check-circle',
    'save' => 'floppy',           # Bootstrap Icons has 'floppy' for save icon (disk symbol)
    'refresh' => 'arrow-clockwise',
    'trash' => 'trash',
    'edit' => 'pencil-square',

    # Navigation icons
    'chevron-left' => 'chevron-left',
    'chevron-right' => 'chevron-right',
    'chevron-up' => 'chevron-up',
    'chevron-down' => 'chevron-down',
    'arrow-left' => 'arrow-left',
    'arrow-right' => 'arrow-right',

    # Status icons
    'ok-circle' => 'check-circle',
    'exclamation-sign' => 'exclamation-circle',
    'remove-circle' => 'x-circle',
    'warning-sign' => 'exclamation-triangle',
    'info-sign' => 'info-circle',
    'question-sign' => 'question-circle',

    # Media icons
    'picture' => 'image',
    'camera' => 'camera',
    'film' => 'film',
    'music' => 'music-note',

    # Object icons
    'tree-conifer' => 'tree',
    'leaf' => 'tree',
    'home' => 'house',
    'user' => 'person',
    'lock' => 'lock',
    'envelope' => 'envelope',
    'star' => 'star',
    'heart' => 'heart',
    'time' => 'clock',
    'calendar' => 'calendar',
    'map-marker' => 'geo-alt',
    'barcode' => 'upc',
    'qrcode' => 'qr-code',

    # UI icons
    'list' => 'list',
    'th-list' => 'list-ul',
    'th' => 'grid',
    'th-large' => 'grid-3x3',
    'menu-hamburger' => 'list',
    'option-horizontal' => 'three-dots',
    'option-vertical' => 'three-dots-vertical',
    'fullscreen' => 'fullscreen',
    'resize-full' => 'arrows-fullscreen',
    'resize-small' => 'fullscreen-exit',
    'move' => 'arrows-move',
    'link' => 'link',
    'new-window' => 'box-arrow-up-right',
    'export' => 'box-arrow-up-right',
    'import' => 'box-arrow-in-down',
    'download' => 'download',
    'upload' => 'upload',
    'share' => 'share',
    'print' => 'printer',
    'comment' => 'chat',
    'eye-open' => 'eye',
    'eye-close' => 'eye-slash',
    'zoom-in' => 'zoom-in',
    'zoom-out' => 'zoom-out',

    # Misc icons
    'asterisk' => 'asterisk',
    'flag' => 'flag',
    'bookmark' => 'bookmark',
    'fire' => 'fire',
    'certificate' => 'award',
    'off' => 'power',             # Power/logout button
    'wrench' => 'wrench'          # Settings/tools icon
  }.freeze

  # Renders a Bootstrap Icon
  #
  # @param name [String] The icon name (can use Glyphicon or Bootstrap Icons naming)
  # @param options [Hash] Additional options
  # @option options [String] :class Additional CSS classes to add
  # @option options [String] :title Title attribute for the icon
  # @option options [String] :size Font size for the icon (default: '1rem')
  # @option options [Hash] :data Data attributes
  # @return [String] HTML safe icon element
  #
  # @example Basic usage
  #   bi_icon('cloud')
  #   # => <i class="bi bi-cloud" style="font-size: 1rem;"></i>
  #
  # @example With additional classes
  #   bi_icon('cloud', class: 'text-primary me-2')
  #   # => <i class="bi bi-cloud text-primary me-2" style="font-size: 1rem;"></i>
  #
  # @example With custom size
  #   bi_icon('cloud', size: '1.5rem')
  #   # => <i class="bi bi-cloud" style="font-size: 1.5rem;"></i>
  #
  def bi_icon(name, options = {})
    # Map old Glyphicon name to Bootstrap Icons name if needed
    mapped_name = ICON_MAP[name.to_s] || name.to_s

    # Build CSS class
    css_class = "bi bi-#{mapped_name}"
    css_class += " #{options[:class]}" if options[:class].present?

    # Build style attribute with font-size (default 1rem for consistent icon sizing)
    icon_size = options[:size] || '1rem'
    style = "font-size: #{icon_size};"
    style += " #{options[:style]}" if options[:style].present?

    # Build HTML attributes
    html_options = { class: css_class, style: style }
    html_options[:title] = options[:title] if options[:title].present?
    html_options[:data] = options[:data] if options[:data].present?
    html_options[:'aria-hidden'] = 'true' unless options[:aria_label].present?
    html_options[:'aria-label'] = options[:aria_label] if options[:aria_label].present?

    content_tag(:i, '', html_options)
  end

  # Legacy compatibility method - alias for bi_icon
  # This allows gradual migration from glyphicon() calls to bi_icon() calls
  #
  # @deprecated Use bi_icon instead
  # @param name [String] The Glyphicon name (without 'glyphicon-' prefix)
  # @param options [Hash] Additional options (same as bi_icon)
  # @return [String] HTML safe icon element
  #
  def glyphicon(name, options = {})
    bi_icon(name, options)
  end

  # Helper to generate icon with text
  #
  # @param name [String] The icon name
  # @param text [String] The text to display after the icon
  # @param options [Hash] Additional options
  # @return [String] HTML safe icon with text
  #
  # @example
  #   bi_icon_with_text('plus', 'Add New')
  #   # => <i class="bi bi-plus"></i> Add New
  #
  def bi_icon_with_text(name, text, options = {})
    icon = bi_icon(name, options)
    "#{icon} #{h(text)}".html_safe
  end
end

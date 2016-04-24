module SectionHelper
  # Codify our conventions.
  # Supporting CSS & JS depend on specific hierarchy and classes
  # foldable_section_tag needs section_content_tag,
  # section_summary_tag is optional.  Summary is still displayed when folded.
  # Defaults as folded
  # To unfold, add class "unfolded"
  def foldable_section_tag(caption, html_attributes={})
    default_id = caption.parameterize
    # merge default and passed classes
    css_classes = %w(fold)
    css_classes += html_attributes.fetch(:class, '').split(" ")
    section_id = html_attributes.fetch(:id, default_id)

    content_tag('section') do
      section_header = content_tag('h3', id: section_id, class: css_classes) do
        content_tag('a', caption, href: "##{section_id}")
      end
      section_body = content_tag('div') do
        yield
      end
      section_header + "\n" + section_body
    end
  end

  def section_summary_tag
    content_tag 'p', class: 'section_summary' do
      yield
    end
  end

  def section_content_tag
    content_tag 'div', class: 'section_content' do
      yield
    end
  end

  def section_content_table(collection)
    section_content_tag do
      content_tag 'table data-sortable' do
        render partial: "components/todo_table", locals: {collection: collection}
      end
    end
  end
end

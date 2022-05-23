module RelatedItemFixtures
  def basic_related_item_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <titleInfo>A Related Item</titleInfo>
        </relatedItem>
      </mods>
    XML
  end

  def linked_related_item_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <titleInfo>A Related Item</titleInfo>
          <location>
            <url>http://library.stanford.edu/</url>
          </location>
        </relatedItem>
      </mods>
    XML
  end

  def related_item_collection_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <titleInfo>This is a Collection</titleInfo>
          <typeOfResource collection='yes' />
        </relatedItem>
      </mods>
    XML
  end

  def related_item_display_label_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem displayLabel='Special Item'>
          <titleInfo>A Related Item</titleInfo>
        </relatedItem>
      </mods>
    XML
  end

  def related_item_location_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <location>The Location</location>
        </relatedItem>
      </mods>
    XML
  end

  def related_item_reference_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem type='isReferencedBy'>
          <titleInfo>The title</titleInfo>
          <note>124</note>
          <originInfo>
            <dateOther>DATE</dateOther>
          </originInfo>
        </relatedItem>
      </mods>
    XML
  end

  def blank_related_item_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <titleInfo>
            <title></title>
          </titleInfo>
          <location>
            <url></url>
          </location>
        </relatedItem>
      </mods>
    XML
  end

  def multi_related_item_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <titleInfo>
            <title>Library</title>
          </titleInfo>
          <location>
            <url>http://library.stanford.edu</url>
          </location>
        </relatedItem>
        <relatedItem>
          <titleInfo>
            <title>SDR</title>
          </titleInfo>
          <location>
            <url>http://purl.stanford.edu</url>
          </location>
        </relatedItem>
      </mods>
    XML
  end

  def citation_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <note type="preferred citation">Sarah Beller, 401 Forbidden: An Empirical Study of Foreign Intelligence Surveillance Act Notices, 1990-2020, 13 Harv. Nat'l Security J. 158 (2021)</note>
        </relatedItem>
      </mods>
    XML
  end
end

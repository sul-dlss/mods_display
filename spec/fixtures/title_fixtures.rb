module TitleFixtures
  def simple_title_fixture
    <<-XML
      <mods>
        <titleInfo><title>Title</title></titleInfo>
      </mods>
    XML
  end

  def title_parts_fixture
    <<-XML
      <mods>
        <titleInfo>
          <nonSort>The</nonSort>
          <title>Title</title>
          <subTitle>For</subTitle>
          <partName>Something</partName>
          <partNumber>Part 62</partNumber>
        </titleInfo>
      </mods>
    XML
  end

  def reverse_title_parts_fixture
    <<-XML
      <mods>
        <titleInfo>
          <nonSort>The</nonSort>
          <title>Title : </title>
          <subTitle>For</subTitle>
          <partNumber>Part 62</partNumber>
          <partName>Something</partName>
        </titleInfo>
      </mods>
    XML
  end

  def display_label_fixture
    <<-XML
      <mods>
        <titleInfo displayLabel='MyTitle'>
          <title>Title</title>
        </titleInfo>
      </mods>
    XML
  end

  def multi_label_fixture
    <<-XML
      <mods>
        <titleInfo>
          <title>Main Title</title>
        </titleInfo>
        <titleInfo type='alternative'>
          <title>Alt Title</title>
        </titleInfo>
        <titleInfo type='uniform'>
          <title>Uniform Title</title>
        </titleInfo>
        <titleInfo type='alternative'>
          <title>Another Alt Title</title>
        </titleInfo>
        <titleInfo type='alternative'>
          <title>Yet Another Alt Title</title>
        </titleInfo>
      </mods>
    XML
  end

  def alt_title_fixture
    <<-XML
      <mods>
        <titleInfo type='alternative'>
          <title>Title</title>
        </titleInfo>
      </mods>
    XML
  end

  def title_puncutation_fixture
    <<-XML
      <mods>
        <titleInfo>
          <title>A title that ends in punctuation.</title>
          <partNumber>2015</partNumber>
        </titleInfo>
      </mods>
    XML
  end

  def ordered_title_fixture
    <<-XML
    <mods>
      <titleInfo>
        <nonSort>The</nonSort>
        <title>medium term expenditure framework (MTEF) for ... and the annual estimates for ...</title>
        <partNumber>016</partNumber>
        <partName>Ministry of Tourism</partName>
        <subTitle>expenditure to be met out of moneys granted and drawn from the consolidated fund, central government budget</subTitle>
      </titleInfo>
    </mods>
    XML
  end
end

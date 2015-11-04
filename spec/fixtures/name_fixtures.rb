module NameFixtures
  def simple_name_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
        </name>
      </mods>
    XML
  end

  def blank_name_fixture
    <<-XML
      <mods>
        <name>
          <namePart/>
          <role>
            <roleTerm></roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def primary_name_fixture
    <<-XML
      <mods>
        <name usage='primary'>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm>lithographer</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def contributor_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm>lithographer</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def encoded_role_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm type='code' authority='marcrelator'>ltg</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def mixed_role_fixture
    <<-XML
      <mods>
        <name>
          <role>
            <roleTerm>publisher</roleTerm>
          </role>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm type='text' authority='marcrelator'>engraver</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def numural_toa_fixture
    <<-XML
      <mods>
        <name>
          <namePart>Unqualfieid</namePart>
          <namePart type='termsOfAddress'>XVII, ToA</namePart>
          <namePart type='date'>date1-date2</namePart>
          <namePart type='given'>Given Name</namePart>
          <namePart type='family'>Family Name</namePart>
        </name>
      </mods>
    XML
  end

  def simple_toa_fixture
    <<-XML
      <mods>
        <name>
          <namePart>Unqualfieid</namePart>
          <namePart type='termsOfAddress'>Ier, empereur</namePart>
          <namePart type='date'>date1-date2</namePart>
          <namePart type='given'>Given Name</namePart>
          <namePart type='family'>Family Name</namePart>
        </name>
      </mods>
    XML
  end

  def display_form_name_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <displayForm>Mr. John Doe</displayForm>
        </name>
      </mods>
    XML
  end

  def collapse_label_name_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
        </name>
        <name>
          <namePart>Jane Doe</namePart>
        </name>
      </mods>
    XML
  end

  def complex_name_label_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
        </name>
        <name>
          <namePart>Jane Doe</namePart>
          <role>
            <roleTerm>lithographer</roleTerm>
          </role>
        </name>
        <name>
          <namePart>John Dough</namePart>
        </name>
        <name>
          <namePart>Jane Dough</namePart>
        </name>
      </mods>
    XML
  end

  def complex_role_name_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm type='text'>Depicted</roleTerm>
            <roleTerm type='code'>dpt</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def name_with_role_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm type='text'>Depicted</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def multiple_roles_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm type='text'>Depicted</roleTerm>
          </role>
          <role>
            <roleTerm type='text'>Artist</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end
end

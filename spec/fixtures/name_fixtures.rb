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

  def primary_name_solo_fixture
    <<-XML
      <mods>
        <name usage='primary'>
          <namePart>John Doe</namePart>
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
  def author_role_fixture
    <<-XML
      <mods>
        <name>
          <namePart>John Doe</namePart>
          <role>
            <roleTerm type='code' authority='marcrelator'>aut</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end
  def many_roles_and_names_fixture # from fs947tw3404
    <<-XML
      <mods>
        <name type="corporate">
          <namePart>United States Coast Survey</namePart>
        </name>
        <name type="personal">
          <namePart>Lawson, J. S.</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Wilkes, Charles</namePart>
          <namePart type="date">1798-1877</namePart>
          <role>
            <roleTerm type="text">cartographer.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Jones, John P. (John Percival)</namePart>
          <namePart type="date">1829-1912</namePart>
          <role>
            <roleTerm type="text">cartographer.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Patterson, C. P. (Carlile Pollock)</namePart>
          <namePart type="date">1816-1881</namePart>
          <role>
            <roleTerm type="text">cartographer.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Schott, C. A.</namePart>
          <role>
            <roleTerm type="text">editor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Cutts, R. D. (Richard Dominicus)</namePart>
          <namePart type="date">1817-1883</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Gilbert, J. J.</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Rockwell, Cleveland</namePart>
          <namePart type="date">1837-1907</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Coffin, G. W.</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Cordell, E.</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Davidson, George</namePart>
          <namePart type="date">1825-1911</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Eimbeck, W.</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Hilgard, J. E. (Julius Erasmus)</namePart>
          <namePart type="date">1825-1891</namePart>
          <role>
            <roleTerm type="text">editor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Bache, A. D. (Alexander Dallas)</namePart>
          <namePart type="date">1806-1867</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Rodgers, A. F.</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Harrison, A. M. (Alexander Medina)</namePart>
          <namePart type="date">1829-1881</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Alden, James</namePart>
          <namePart type="date">1810-1877</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Mathiot, G.</namePart>
          <role>
            <roleTerm type="text">electrotyper.</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Harrison, A. M. (Alexander Medina)</namePart>
          <namePart type="date">1829-1881</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="corporate">
          <namePart>U.S. Coast and Geodetic Survey</namePart>
          <role>
            <roleTerm type="text">surveyor.</roleTerm>
          </role>
        </name>
        <name type="corporate">
          <namePart>N.Y. Lithographing, Engraving & Printing Co</namePart>
          <role>
            <roleTerm type="text">lithographer.</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end
  def names_with_code_and_text_roles_fixture # from vn199zb9806
    <<-XML
      <mods>
        <name type="personal" usage="primary" authority="naf" authorityURI="http://id.loc.gov/authorities/names" valueURI="http://id.loc.gov/authorities/names/n78095825" nameTitleGroup="1">
          <namePart>Johnson, Samuel, 1709-1784</namePart>
          <role>
            <roleTerm type="code" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/aut">aut</roleTerm>
            <roleTerm type="text" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/aut">author</roleTerm>
          </role>
        </name>
        <name type="personal" authority="naf" authorityURI="http://id.loc.gov/authorities/names" valueURI="http://id.loc.gov/authorities/names/n78095825">
          <namePart>Johnson, Samuel, 1709-1784</namePart>
          <role>
            <roleTerm type="code" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/prt">prt</roleTerm>
            <roleTerm type="text" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/prt">printer</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Downing, Donn Faber</namePart>
          <role>
            <roleTerm type="code" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/dnr">dnr</roleTerm>
            <roleTerm type="text" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/dnr">donor</roleTerm>
          </role>
        </name>
        <name type="personal">
          <namePart>Sanders, Letitia Leigh</namePart>
          <role>
            <roleTerm type="code" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/dnr">dnr</roleTerm>
            <roleTerm type="text" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/dnr">donor</roleTerm>
          </role>
        </name>
      </mods>
    XML
  end

  def name_with_marc_role_terms
    <<-XML
    <mods>
      <name type="personal" altRepGroup="05" script="Latn">
        <namePart>渡邊恵章</namePart>
        <role>
          <roleTerm type="text">editor,</roleTerm>
        </role>
        <role>
          <roleTerm type="text">publisher.</roleTerm>
        </role>
      </name>
    </mods>
    XML
  end
end

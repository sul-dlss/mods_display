module ImprintFixtures
  def imprint_mods
    <<-MODS
      <mods>
        <originInfo>
          <edition>An edition</edition>
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
          <dateIssued>An Issue Date</dateIssued>
          <dateOther>Another Date</dateOther>
        </originInfo>
      </mods>
    MODS
  end
  def no_edition_mods
    <<-MODS
      <mods>
        <originInfo>
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
          <dateCreated>A Create Date</dateCreated>
          <dateIssued>An Issue Date</dateIssued>
          <dateCaptured>A Capture Date</dateCaptured>
          <dateOther>Another Date</dateOther>
        </originInfo>
      </mods>
    MODS
  end
  def origin_info_mods
    <<-MODS
      <mods>
        <originInfo>
          <dateValid>A Valid Date</dateValid>
        </originInfo>
        <originInfo>
          <issuance>The Issuance</issuance>
        </originInfo>
      </mods>
    MODS
  end
  def mixed_mods
    <<-MODS
      <mods>
        <originInfo>
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
          <issuance>The Issuance</issuance>
          <dateCaptured>The Capture Date</dateCaptured>
        </originInfo>
      </mods>
    MODS
  end
  def display_form
    <<-MODS
      <mods>
        <originInfo>
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
          <displayForm>The Display Form</displayForm>
        </originInfo>
        <originInfo displayLabel="TheLabel">
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
          <displayForm>The Display Form</displayForm>
        </originInfo>
      </mods>
    MODS
  end
  def display_label
    <<-MODS
      <mods>
        <originInfo displayLabel="TheLabel">
          <edition>The edition</edition>
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
        </originInfo>
        <originInfo displayLabel="IssuanceLabel">
          <place><placeTerm>A Place</placeTerm></place>
          <publisher>A Publisher</publisher>
          <issuance>The Edition</issuance>
        </originInfo>
      </mods>
    MODS
  end
  def date_range
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated point="end">1825</dateCreated>
          <dateCreated point="start">1820</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
  def open_date_range
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated point="start">1820</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
  def dup_qualified_date
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated qualifier="questionable">1820</dateCreated>
          <dateCreated>1820</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
  def dup_unencoded_date
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated encoding="marc">1820</dateCreated>
          <dateCreated>[ca. 1820]</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
  def dup_copyright_date
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated encoding="marc">1820</dateCreated>
          <dateCreated>c1820</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
  def dup_date
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated>1820</dateCreated>
          <dateCreated>1820</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
  def approximate_date
    <<-MODS
      <mods>
        <originInfo>
          <dateValid qualifier="approximate">1820</dateValid>
        </originInfo>
      </mods>
    MODS
  end
  def questionable_date
    <<-MODS
      <mods>
        <originInfo>
          <dateValid qualifier="questionable">1820</dateValid>
        </originInfo>
      </mods>
    MODS
  end
  def inferred_date
    <<-MODS
      <mods>
        <originInfo>
          <dateValid qualifier="inferred">1820</dateValid>
        </originInfo>
      </mods>
    MODS
  end
  def three_imprint_dates
    <<-MODS
      <mods>
        <originInfo>
          <dateIssued>[1820-1825]</dateIssued>
          <dateIssued point="start" qualifier="questionable">1820</dateIssued>
          <dateIssued point="end" qualifier="questionable">1825</dateIssued>
        </originInfo>
      </mods>
    MODS
  end
  def qualified_imprint_date
    <<-MODS
      <mods>
        <originInfo>
          <dateIssued qualifier="questionable">1820</dateIssued>
        </originInfo>
      </mods>
    MODS
  end
  def imprint_date_range
    <<-MODS
      <mods>
        <originInfo>
          <dateIssued>[1820]</dateIssued>
          <dateIssued point="start">1820</dateIssued>
          <dateIssued point="end">1825</dateIssued>
        </originInfo>
      </mods>
    MODS
  end
  def encoded_place
    <<-MODS
      <mods>
        <originInfo>
          <place>
             <placeTerm type="code">ne</placeTerm>
           </place>
           <place>
             <placeTerm type="text">[Amsterdam]</placeTerm>
           </place>
        </originInfo>
        <originInfo>
          <place>
            <placeTerm type="code">us</placeTerm>
            <placeTerm type="text">[United States]</placeTerm>
          </place>
        </originInfo>
      </mods>
    MODS
  end
end
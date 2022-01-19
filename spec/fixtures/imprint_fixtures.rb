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

  def encoded_date_range
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated encoding="w3cdtf" keyDate="yes" point="start">2008-02-01</dateCreated>
          <dateCreated encoding="w3cdtf" point="end">2009-12-02</dateCreated>
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
             <placeTerm type="code" authority="marccountry">ne</placeTerm>
           </place>
           <place>
             <placeTerm type="text" authority="marccountry">[Amsterdam]</placeTerm>
           </place>
        </originInfo>
        <originInfo>
          <place>
            <placeTerm type="code">us</placeTerm>
            <placeTerm type="text">[United States]</placeTerm>
          </place>
        </originInfo>
        <originInfo>
          <place>
            <placeTerm type="code" authority="marccountry">ne</placeTerm>
          </place>
        </originInfo>
      </mods>
    MODS
  end

  def xx_country_code
    <<-MODS
      <mods>
        <originInfo>
          <place>
            <placeTerm type="code" authority="marccountry">xx</placeTerm>
          </place>
          <dateIssued>1994</dateIssued>
        </originInfo>
      </mods>
    MODS
  end

  def encoded_dates
    <<-MODS
      <mods>
        <originInfo>
          <dateOther encoding="w3cDtF">2013</dateOther>
          <dateCreated encoding="W3CdTf">2013-07-10</dateCreated>
          <dateCaptured encoding="W3CDTF">2013-07</dateCaptured>
          <dateModified encoding="w3cdtf">Jul. 22, 2013</dateModified>
        </originInfo>
      </mods>
    MODS
  end

  def iso8601_encoded_dates
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated encoding="iso8601">20131114161429</dateCreated>
          <dateModified encoding="iso8601">Jul. 22, 2013</dateModified>
        </originInfo>
      </mods>
    MODS
  end

  def bad_dates
    <<-MODS
      <mods>
        <originInfo>
          <place>
             <placeTerm>United States</placeTerm>
           </place>
           <dateIssued>
             9999
           </dateIssued>
           <dateModified>
             9999
           </dateModified>
        </originInfo>
      </mods>
    MODS
  end

  def invalid_dates
    <<-MODS
      <mods>
        <originInfo>
          <place>
             <placeTerm>United States</placeTerm>
           </place>
           <dateModified encoding="w3cdtf">1920-09-00</dateModified>
        </originInfo>
      </mods>
    MODS
  end

  def punctuation_imprint_fixture
    <<-MODS
      <mods>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>San Francisco :</placeTerm>
          </place>
          <publisher>Chronicle Books,</publisher>
          <dateIssued>2015.</dateIssued>
        </originInfo>
      </mods>
    MODS
  end

  def bc_ad_imprint_date_fixture
    <<-MODS
      <mods>
        <originInfo>
          <dateCreated encoding="edtf" keydate="yes" point="start">-0013</dateCreated>
          <dateCreated point="end">0044</dateCreated>
        </originInfo>
      </mods>
    MODS
  end
end

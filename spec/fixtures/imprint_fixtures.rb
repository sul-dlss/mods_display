module ImprintFixtures
  def imprint_mods
    <<-MODS
      <mods>
        <originInfo>
          <edition>An edition</edition>
          <place>A Place</place>
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
          <place>A Place</place>
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
  def encoded_date
    <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
          <dateIssued encoding="an-encoding">An Encoded Date</dateIssued>
        </originInfo>
      </mods>
    MODS
  end
  def only_encoded_data
    <<-MODS
      <mods>
        <originInfo>
          <dateIssued encoding="an-encoding">An Encoded Date</dateIssued>
        </originInfo>
      </mods>
    MODS
  end
  def mixed_mods
    <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
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
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <displayForm>The Display Form</displayForm>
        </originInfo>
        <originInfo displayLabel="TheLabel">
          <place>A Place</place>
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
          <place>A Place</place>
          <publisher>A Publisher</publisher>
        </originInfo>
        <originInfo displayLabel="IssuanceLabel">
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <issuance>The Edition</issuance>
        </originInfo>
      </mods>
    MODS
  end
end
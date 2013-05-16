module ImprintFixtures
  def imprint_mods
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
          <edition>The Edition</edition>
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
  def mixed_mods
    <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <edition>The Edition</edition>
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
end
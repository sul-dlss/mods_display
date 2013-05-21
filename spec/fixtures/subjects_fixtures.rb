module SubjectsFixtures
  def subjects
    <<-XML
      <mods>
        <subject>
          <topic>Jazz</topic>
          <geographical>Japan</geographical>
          <topic>History and criticism</topic>
        </subject>
      </mods>
    XML
  end
  
  def emdash_subjects
    <<-XML
      <mods>
        <subject>
          <topic>Jazz -- Japan -- History and criticism</topic>
        </subject>
      </mods>
    XML
  end
  
  def hierarchical_geo_subjects
    <<-XML
      <mods>
        <subject>
          <hierarchicalGeographic>
            <country>United States</country>
            <state>California</state>
            <city>Stanford</city>
          </hierarchicalGeographic>
        </subject>
      </mods>
    XML
  end
end
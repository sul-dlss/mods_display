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
  
  def blank_subject
    <<-XML
      <mods>
        <subject>
          <topic/>
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

  def name_subjects
    <<-XML
      <mods>
        <subject>
          <name>
            <role>
              <roleTerm type='text'>Depicted</roleTerm>
            </role>
            <namePart>John Doe</namePart>
          </name>
          <topic>Anonymous People</topic>
        </subject>
      </mods>
    XML
  end

  def complex_subjects
    <<-XML
      <mods>
        <subject>
          <topic>Jazz</topic>
          <geographical>Japan</geographical>
          <topic>History and criticism</topic>
        </subject>
        <subject>
          <topic>Bay Area</topic>
          <geographical>Stanford</geographical>
        </subject>
      </mods>
    XML
  end
  def display_label_subjects
    <<-XML
      <mods>
        <subject>
          <topic>A Subject</topic>
          <geographical>Another Subject</geographical>
        </subject>
        <subject>
          <topic>B Subject</topic>
          <geographical>Another B Subject</geographical>
        </subject>
        <subject displayLabel="Subject Heading">
          <topic>Jazz</topic>
          <geographical>Japan</geographical>
          <topic>History and criticism</topic>
        </subject>
        <subject>
          <topic>Bay Area</topic>
          <geographical>Stanford</geographical>
        </subject>
      </mods>
    XML
  end
end
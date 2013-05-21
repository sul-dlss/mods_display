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
end
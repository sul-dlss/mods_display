module CartographicsFixtures
  def full_cartographic
    <<-MODS
      <mods>
        <subject>
          <cartographics>
            <scale>The scale</scale>
            <coordinates>the coordinates</coordinates>
            <projection>the projection</projection>
          </cartographics>
        </subject>
      </mods>
    MODS
  end

  def no_scale_cartographic
    <<-MODS
      <mods>
        <subject>
          <cartographics>
            <coordinates>the coordinates</coordinates>
            <projection>the projection</projection>
          </cartographics>
        </subject>
      </mods>
    MODS
  end

  def coordinates_only
    <<-MODS
      <mods>
        <subject>
          <cartographics>
            <coordinates>the coordinates</coordinates>
          </cartographics>
        </subject>
      </mods>
    MODS
  end

  def scale_only
    <<-MODS
      <mods>
        <subject>
          <cartographics>
            <scale>The scale</scale>
          </cartographics>
        </subject>
      </mods>
    MODS
  end
end

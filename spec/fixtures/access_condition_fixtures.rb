module AccessConditionFixtures
  def simple_access_condition_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition>Access Condition Note</accessCondition>
      </mods>
    XML
  end

  def restricted_access_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='restrictionOnAccess'>Restrict Access Note1</accessCondition>
        <accessCondition type='restriction on access'>Restrict Access Note2</accessCondition>
      </mods>
    XML
  end

  def custom_use_reproduction_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='useAndReproduction'>Special use agreement&#10;&#10;Text of the agreement</accessCondition>
      </mods>
    XML
  end

  def copyright_access_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='copyright'>This is a (c) copyright Note.  Single instances of (c) should also be replaced in these notes.</accessCondition>
      </mods>
    XML
  end

  def cc_license_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='license'>CC by-sa: This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License</accessCondition>
      </mods>
    XML
  end

  def legacy_cc_license_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='license'>CC by-sa: This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License</accessCondition>
      </mods>
    XML
  end

  def cc_license_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type="license" xlink:href="https://creativecommons.org/licenses/by/3.0/legalcode">This work is licensed under a Creative Commons Attribution 3.0 Unported license (CC BY).</accessCondition>
      </mods>
    XML
  end

  def odc_license_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='license'>ODC pddl: This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)</accessCondition>
      </mods>
    XML
  end

  def no_license_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='license'>Unknown something: This work is licensed under an Unknown License and will not be linked</accessCondition>
      </mods>
    XML
  end

  def garbage_license_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <accessCondition type='license'>Unknown garbage that does not look like a license</accessCondition>
      </mods>
    XML
  end
end

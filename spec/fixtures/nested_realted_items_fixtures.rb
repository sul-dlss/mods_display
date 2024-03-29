module NestedRelatedItemFixtures
  def related_item_host_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem type="host">
          <titleInfo>A host type related item</titleInfo>
          <note displayLabel="Custom Notes">A note content</note>
        </relatedItem>
        <relatedItem type="host">
          <titleInfo>A collection</titleInfo>
          <typeOfResource collection="yes" />
        </relatedItem>
      </mods>
    XML
  end

  def namespace_prefixed_related_item_fixture
    <<-XML
      <mods:mods xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">
        <mods:relatedItem type="constituent">
          <mods:titleInfo>
            <mods:title>Constituent Title</mods:title>
          </mods:titleInfo>
          <mods:note>Constituent note</mods:note>
        </mods:relatedItem>
      </mods:mods>
    XML
  end

  def multi_constituent_fixture
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem type="constituent">
          <titleInfo>
            <title>Polychronicon (epitome and continuation to 1429)</title>
            <partNumber>ff. 1r - 29v</partNumber>
          </titleInfo>
          <titleInfo displayLabel="Nasmith Title" type="alternative">
            <title>Epitome chronicae Cicestrensis, sed extractum e Polychronico, usque ad annum Christi 1429</title>
          </titleInfo>
          <name type="personal">
            <namePart>Ranulf Higden OSB</namePart>
            <role>
              <roleTerm authority="marcrelator" type="text" valueURI="http://id.loc.gov/vocabulary/relators/aut">author</roleTerm>
            </role>
          </name>
          <note>Dates are marked in the margin. Ends with the coronation of Henry VI at St Denis</note>
          <note displayLabel="Incipit" type="incipit">Ieronimus ad eugenium in epistola 43a dicit quod decime leguntur primum date ab abraham</note>
          <note displayLabel="Explicit" type="explicit">videlicet nono die mensis decembris ano etatis sue 10o</note>
        </relatedItem>
        <relatedItem type="constituent">
          <titleInfo>
            <title>Gesta regum ad Henricum VI</title>
            <partNumber>ff. 30r - 53r</partNumber>
          </titleInfo>
          <titleInfo displayLabel="Nasmith Title" type="alternative">
            <title>Breviarium historiae Angliae ad annum quartum Henrici IV. viz. 1402</title>
          </titleInfo>
          <titleInfo displayLabel="M.R. James Title" type="alternative">
            <title>Breuiarium</title>
          </titleInfo>
          <name type="personal">
            <namePart>Thomas Harsfield</namePart>
            <role>
              <roleTerm authority="marcrelator" type="text" valueURI="http://id.loc.gov/vocabulary/relators/aut">author</roleTerm>
            </role>
          </name>
          <note>Another hand. Begins with 19 lines</note>
          <note displayLabel="Incipit 1" type="incipit">Albion est terra constans in finibus orbis</note>
          <note displayLabel="Explicit 1" type="explicit">Petrus pictauis dat cistrensis monachusque</note>
          <note displayLabel="Incipit 2" type="incipit">Et quia confrater carissime non solum audiendo sacre scripture verbis aurem sedulus auditor accomodatur (!) tenetur</note>
          <note displayLabel="Explicit 2" type="explicit">Tempore huius regis Owynus quidam Wallensis erigens se in principem Wallie toto vite sue tempore cum Wallensibus rebellauit</note>
        </relatedItem>
      </mods>
    XML
  end
end

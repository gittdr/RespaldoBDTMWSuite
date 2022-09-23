SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create procedure [dbo].[d_applicable_taxrates_enh_sp]
   @p_billto varchar(8),
   @p_originstate varchar(6),
   @p_DestState varchar(6),
   @p_effdate datetime,
   @p_billorsettle varchar(10) = 'BILLING'
as

/**
 *
 * NAME:
 * dbo.d_applicable_taxrates_enh_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 *    Returns all applicable tax types and rates for an order.
  *
 * RETURNS:
 *    NONE
 *
 *
 * RESULT SETS:
 *    tax_type smallint (relates to labelfile entry TaxType* where * is the tax_type
 *    tax_rate (percent converted ot a decimal)
 *    gl number form the charge type table for this tax type
 *    tax_description allows the same tax type to have different names by State
 *    tax_appliesto  char(1) 'Y' if tax also taxes fed tax
 *    cht_itemcode
 *
 * PARAMETERS:
 * @p_billto varchar (8) - the party being billed (is he subject to tax)
 *      @p_OriginState varchar (6)  _ the STate or Province of the shipper
 *      @p_DestState varchar (6)  - the State or Province of the consignee
 *      @p_EffectiveDate datetime  -- the effective tax date for this order
 *
 * REVISION HISTORY:
 * 07/27/06.01  PTS33614 - DPETE  Original draft.
 * 02/16/07.02  PTS35867 - PBIDI  Added line per PTS.
 * 04/15/07.03 PTS35555 - EMK Added Tax Authority retrieval
 * 06/30/2010 PTS 51492 - adding new query for PURCHASE
 **/
Declare @taxflags varchar(10)

--PRB PTS35867
SELECT @p_effdate = isnull(@p_effdate, getdate())

/* if trip isn't within the same country, no taxes are applicable */
if (select stc_country_c  from statecountry where stc_state_c = @p_OriginState) <>
   (select stc_country_c  from statecountry where stc_state_c = @p_destState)
 BEGIN
  return
 END
else
 BEGIN
   if @p_billorsettle <> 'SETTLE' and @p_billorsettle <> 'PURCHASE'
    begin
      /* get a 'pattern' of applicable taxes for the bill to company */
      select @taxflags =
       (case cmp_taxtable1 when 'Y' then '1' else '0' end)+
       (case cmp_taxtable2 when 'Y' then '2' else '0' end)+
       (case cmp_taxtable3 when 'Y' then '3' else '0' end)+
       (case cmp_taxtable4 when 'Y' then '4' else '0' end)
      from company where cmp_id = @p_billto

      If @taxflags = '0000' return  /* bill to company is not taxable */

      select tax_type,tax_rate = convert(decimal(9,4)
      ,tax_rate / 100.0000)
      ,cht_glnum
      ,tax_description = case rtrim(isNull(tax_description,'')) when '' then cht_description else tax_description end
      ,tax_appliesto = isnull(tax_appliesto,'N')
      ,cht_itemcode, substring(@taxflags,tax_type,1) tax_flag  --PTS 35555 EMK Added column name
      ,isnull(taxrate.tax_artaxauth,'UNK') tax_artaxauth     --PTS 35555 EMK
      from taxrate
      join labelfile on labeldefinition = 'TaxType'+convert(varchar(10),tax_type) and abbr <> 'UNK'
      join chargetype on cht_itemcode = labelfile.abbr
      where charindex(convert(varchar(10),tax_type),@taxflags) > 0
      and tax_state = @p_destState
      and @p_originstate = Case taxrate.tax_type when 4 then @p_deststate else @p_originstate end
      and tax_rate <> 0
      and @p_EffDate between tax_effectivedate and tax_expirationdate
      --and @p_OriginState = (Case isnull(tax_withinstate,'N')  when 'Y' then  @p_DestState else @p_OriginState end )
   end
   if @p_billorsettle = 'SETTLE'
    begin
      select tax_type,tax_rate = convert(decimal(9,4)
      ,tax_rate / 100.0000)
      ,pyt_ap_glnum cht_glnum
      ,tax_description = case rtrim(isNull(tax_description,'')) when '' then pyt_description else tax_description end
      ,tax_appliesto = isnull(tax_appliesto,'N')
      ,paytype.pyt_itemcode, '0' tax_flag
      ,isnull(taxrate.tax_artaxauth,'UNK') tax_artaxauth
      from taxrate
      join labelfile on labeldefinition like ('TaxType%') and abbr <> 'UNK' and code = tax_type --MRH this may not be valid to join on.
      join paytype on paytype.pyt_itemcode = labelfile.abbr
      JOIN paytypetax ON paytypetax.pyt_number = paytype.pyt_number
      where tax_state = @p_destState
      and @p_originstate = Case taxrate.tax_type when 4 then @p_originstate else @p_deststate end
      AND IsNull(paytypetax.tax_triggered_by, 'TRIP') = 'TRIP'
      and tax_rate <> 0
      and @p_EffDate between tax_effectivedate and tax_expirationdate
   end

   --BEGIN PTS 51492 SPN
   if @p_billorsettle = 'PURCHASE'
   begin
      SELECT taxrate.tax_type                               AS tax_type
           , CONVERT(DECIMAL(9,4), taxrate.tax_rate * .01)  AS tax_rate
           , pyt_ap_glnum                                   AS cht_glnum
           , (CASE RTrim(IsNull(taxrate.tax_description,''))
              WHEN '' THEN paytype.pyt_description
              ELSE taxrate.tax_description
              END
             )                                              AS tax_description
           , IsNull(taxrate.tax_appliesto,'N')              AS tax_appliesto
           , paytype.pyt_itemcode                           AS cht_itemcode
           , '0'                                            AS tax_flag
           , IsNull(taxrate.tax_artaxauth,'UNK')            AS tax_artaxauth
           , 0                                              AS OrderOfDependency
        FROM taxrate
        JOIN labelfile ON taxrate.tax_type = SUBSTRING(labelfile.labeldefinition,LEN('TaxType')+1,2)
        JOIN paytype ON paytype.pyt_itemcode = labelfile.abbr
        JOIN paytypetax ON paytypetax.pyt_number = paytype.pyt_number
       WHERE labelfile.labeldefinition like ('TaxType%')
         AND labelfile.abbr <> 'UNK'
         AND IsNull(paytypetax.tax_triggered_by, 'TRIP') <> 'TRIP'
         AND taxrate.tax_state = @p_destState
         AND @p_originstate = (CASE taxrate.tax_type WHEN 4 THEN @p_deststate ELSE @p_originstate END)
         AND taxrate.tax_rate <> 0
         AND @p_EffDate BETWEEN taxrate.tax_effectivedate AND taxrate.tax_expirationdate
   end
   --END PTS 51492 SPN
   --and @p_OriginState = (Case isnull(tax_withinstate,'N')  when 'Y' then  @p_DestState else @p_OriginState end )
 END

--Note don't recode to core this way. Don't rely on the number, test for 'QST' (inter-state) CA tax.

GO
GRANT EXECUTE ON  [dbo].[d_applicable_taxrates_enh_sp] TO [public]
GO

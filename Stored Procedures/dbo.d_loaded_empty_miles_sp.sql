SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_loaded_empty_miles_sp] (@ordhdr int, @invoiceby varchar(3) ) 
   
AS    

/**
 * 
 * NAME:
 * dbo.d_loaded_empty_miles_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure gets returns the billable stops for a movement combination for use in nvo_loaded_mileage
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * parameters 
 *
 * PARAMETERS:
 * 001 - @mov_number Movment number
 *
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 12/12/07 EMK - Created 38823
 * 05/23/08 REF - 40260 For Donna, Added ord_no_recalc_miles to result set.
 * 06/05/08 REF - 42493 Check GI setting SetBillMilesOnNonBillableStops to return all stops, including non billable
 * 7/15/08 add stp_type to look back for place to start sum miles, add ecr_billable to return billmiles
 * 7/16/08   add ect_billable,ord_hdrnumber,fororder,bill miles and od miles to support computing bill miles
 * 11/20/08 PTS43837 allow invoice by move
 * DPETE PTS 44417 allow invoice by move/consignee
 * PTS51802 DPETE 8/18/10 add country indication and work fields for determining bill miles after rules applied
 * PTS 61769 SGB Changed sort order from stp_arrivaldate to stp_sequence, stp_arrivaldate
 **/

declare @moves TABLE ( mov_number int )
declare @ords  TABLE (ord_hdrnumber int)
declare @BillAllStops varchar(60),
		@ordnorecalcmiles char(1),
		@ordernumber varchar(12)
declare @ordbillto varchar(8),@mov int
declare @consignee varchar(8) 
Declare @DomesticCountry varchar(50)

select @invoiceby = isnull(@invoiceby,'ORD')
/* use domestic country as the default if we cannot determine the country a stop state is in later */
Select @DomesticCountry = gi_string2 from generalinfo where gi_name = 'ApplyIntnlBillingRule'
if @DomesticCountry  is null select @DomesticCountry = '?/?'
If not exists (select 1 from statecountry where stc_country_c =  @DomesticCountry) Select  @DomesticCountry = 'USA'


SELECT @BillAllStops = gi_string1 FROM generalinfo WHERE gi_name = 'SetBillMilesOnNonBillableStops'
IF @BillAllStops IS NULL
	SELECT @BillAllStops = 'N'

SELECT @ordnorecalcmiles = isnull(ord_no_recalc_miles,'N'),
	@ordernumber = ord_number,@ordbillto = ord_billto, @mov = mov_number,@consignee = ord_consignee
FROM orderheader 
WHERE ord_hdrnumber = @ordhdr

if @invoiceby = 'MOV'
   insert into @ords
   select distinct stops.ord_hdrnumber
   from stops join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
   where stops.ord_hdrnumber > 0
   and stops.mov_number = @mov
   and ord_billto = @ordbillto
if @invoiceby = 'CON'
   insert into @ords
   select distinct stops.ord_hdrnumber
   from stops join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
   where stops.ord_hdrnumber > 0
   and stops.mov_number = @mov
   and ord_billto = @ordbillto
   and ord_consignee = @consignee
if (select count(*) from @ords) = 0
   insert into @ords select @ordhdr

IF @BillAllStops = 'N'
	SELECT @ordernumber ord_number, 
		stp.stp_mfh_sequence, 
		stp.stp_number, 
		stp.stp_event,
		isnull(stp.stp_ord_mileage,0) stp_ord_mileage,
		ect.mile_typ_to_stop,  
		ect.mile_typ_from_stop,
		stp.stp_loadstatus,
		stp.cmp_id,
		stp.cmp_name,
		stp.stp_city,
		stp.stp_zipcode,
		cty.cty_nmstct,
		stp.stp_arrivaldate, 
		stp.stp_departuredate, 
		0.0 loaded_miles,
		0.0 empty_miles,
		@ordnorecalcmiles ord_no_recalc_miles,
    stp_type,
    ect_billable,
    stp.ord_hdrnumber,
    for_ordhdr = @ordhdr,
    0.0 bill_miles,
    0.0 od_miles,
    0.0 rule_miles,
    isnull(stc_country_c,@DomesticCountry) country,
    'N' hide_stop_flag
	FROM @ords ords
        JOIN stops stp on ords.ord_hdrnumber = stp.ord_hdrnumber
		JOIN city cty on stp.stp_city = cty.cty_code
		JOIN eventcodetable ect on (stp.stp_event = ect.abbr and ect.ect_billable = 'Y')
        LEFT OUTER JOIN DistinctCountryForState on  stp_state = stc_state_c
	WHERE   --stp.ord_hdrnumber = @ordhdr and
	 stp_event NOT IN ('XDL','XDU')
	--ORDER BY stp_arrivaldate ASC 
	ORDER BY stp_sequence, stp_arrivaldate ASC -- PTS 61769 SGB
ELSE
  BEGIN
    IF @invoiceby = 'ORD'
      BEGIN
	    INSERT INTO @moves
		  SELECT DISTINCT mov_number FROM stops 
		  WHERE ord_hdrnumber = @ordhdr

	    SELECT @ordernumber ord_number, 
		  stops.stp_mfh_sequence, 
		  stops.stp_number, 
		  stops.stp_event,
		  isnull(stops.stp_ord_mileage,0) stp_ord_mileage,
		  ect.mile_typ_to_stop,  
		  ect.mile_typ_from_stop,
		  stops.stp_loadstatus,
		  stops.cmp_id,
		  stops.cmp_name,
		  stops.stp_city,
		  stops.stp_zipcode,
		  cty.cty_nmstct,
		  stops.stp_arrivaldate, 
		  stops.stp_departuredate, 
	  	0.0 loaded_miles,
	  	0.0 empty_miles,
	  	@ordnorecalcmiles ord_no_recalc_miles,
      stp_type,
      ect_billable,
      stops.ord_hdrnumber,
      for_ordhdr = @ordhdr,
      0.0 bill_miles,
      0.0 od_miles,
      0.0 rule_Miles,
      isnull(stc_country_c,@DomesticCountry) country,
      'N' hide_stop_flag
	    FROM @moves mv JOIN stops on mv.mov_number = stops.mov_number
			JOIN eventcodetable ect on stops.stp_event = ect.abbr
			JOIN city cty on stops.stp_city = cty.cty_code
            LEFT OUTER JOIN DistinctCountryForState on  stp_state = stc_state_c
	    WHERE ( stops.ord_hdrnumber = @ordhdr OR stops.ord_hdrnumber = 0 )
		--ORDER BY stp_arrivaldate ASC 
		ORDER BY stp_sequence, stp_arrivaldate ASC -- PTS 61769 SGB
      END
    ELSE
      BEGIN
      /* invoiceby = MOV */
        INSERT INTO @moves  -- should be only one when you invoice by MOV
		SELECT DISTINCT mov_number FROM stops 
		WHERE ord_hdrnumber = @ordhdr

	    SELECT @ordernumber ord_number, 
		  stops.stp_mfh_sequence, 
		  stops.stp_number, 
		  stops.stp_event,
		  isnull(stops.stp_ord_mileage,0) stp_ord_mileage,
		  ect.mile_typ_to_stop,  
		  ect.mile_typ_from_stop,
		  stops.stp_loadstatus,
		  stops.cmp_id,
		  stops.cmp_name,
		  stops.stp_city,
		  stops.stp_zipcode,
		  cty.cty_nmstct,
		  stops.stp_arrivaldate, 
		  stops.stp_departuredate, 
		  0.0 loaded_miles,
		  0.0 empty_miles,
		  @ordnorecalcmiles ord_no_recalc_miles,
      stp_type,
      ect_billable,
      stops.ord_hdrnumber,
      for_ordhdr = @ordhdr,
      0.0 bill_miles,
      0.0 od_miles,
      0.0 rule_Miles,
      isnull(stc_country_c,@DomesticCountry) country,
      'N' hide_stop_flag
	    FROM @moves mv JOIN stops on mv.mov_number = stops.mov_number
			JOIN eventcodetable ect on stops.stp_event = ect.abbr
			JOIN city cty on stops.stp_city = cty.cty_code
            LEFT OUTER JOIN DistinctCountryForState on  stp_state = stc_state_c
	    WHERE ( stops.ord_hdrnumber in (select ord_hdrnumber from @ords) OR stops.ord_hdrnumber = 0 )
		--ORDER BY stp_arrivaldate ASC 
		ORDER BY stp_sequence, stp_arrivaldate ASC -- PTS 61769 SGB    
	END
  END
GO
GRANT EXECUTE ON  [dbo].[d_loaded_empty_miles_sp] TO [public]
GO

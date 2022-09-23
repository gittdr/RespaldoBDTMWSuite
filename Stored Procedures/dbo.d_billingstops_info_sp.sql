SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 

 create proc [dbo].[d_billingstops_info_sp] @ord_hdrnumber int ,@validevents varchar(100)  
as  
/**
 *
 * NAME:
 * dbo.d_billingstops_info_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns information use for computing invoices
 *
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * 001 - cmp_id,
 * 002 - stp_city,
 * 003 - stp_event,
 * 004 - stp_reasonlate,
 * 005 - stp_type1,
 * 006 - stp_delayhours,
 * 007 - stp_ooa_stop,
 * 008 - stp_ooa_mileage,
 * 009 - fgt_carryins1,
 * 010 - fgt_carryins2,
 * 011 - stp_sequence,
 * 012 - stp_type,
 * 013 - StopoffFlag,
 * 014 - minsatstop,
 * 015 - stpminsallowance,
 * 016 - allowdetention
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber int
 * 002 - @validevents varchar(100)  
 *
 * REFERENCES:
 * 
 *
 * REVISION HISTORY:
 *
 * DPETE PTS18414 changed imbedded sql on dw to proc to add detention info to proc for   
 * DPETE 21389 change for auto detention type 001 to use bill to comp allowance as allowance for total time at all stops
 *  of the same type. If NULL,use min allowance from all stops of type. If null use INI default. If NULL set 999999 allowance  
 * vjh 25371 adding logic to detention and using temp table for more complex data massaging
 * 08/03/2005.01 - Vince Herman 28930 remove departure status from where clause
 * 08/18/2005.01 - Vince Herman 29413 Add Detention Requires Departure Actualization
 * 12/2/08 PTS43837 invoice by move
 * 2/13/09 PTS444417 allow invoice by move/consignee (CON)
 * 4/9/10 PTS51311 DPETE add stp_number to return set.
 * 12/21/10 PTS 51801 SGB add Free Stop blank column to return set
 * PTS 55342 SGB Add settings and functionality for using BOL dates 
*/  
CREATE TABLE #tempbillingstops (
	cmp_id varchar(8) null,   
	stp_city int null,
	stp_event char(6) null,
	stp_reasonlate varchar(6) null,
	stp_type1 varchar(6) null,
	stp_delayhours float null,
	stp_ooa_stop int null,
	stp_ooa_mileage float null,
	fgt_carryins1 float null,
	fgt_carryins2 float null,
	stp_sequence int null,
	stp_type varchar(6) null,
	StopoffFlag int null,
	minsatstop int null,
	stpminsallowance int null,
	allowdetention char(1) null,
	stp_departure_status varchar(6) null,
	stp_arrivaldate datetime null,
	stp_departuredate datetime null,
	stp_schdtearliest datetime null,
	detstart int null,
	detapplyiflate char(1) null,
	detapplyifearly char(1) null,
	stoparrivedlate char(1) null,
	stoparrivedearly char(1) null,
    stp_number int null,
   free_stop char(1) --PTS 51801 SGB 
)

DECLARE @PUPMinsAllowance int, @DRPMinsAllowance int, @billtocmp_PUPTimeAllowance  int, @billtocmp_DRPTimeAllowance  int
Declare @TotalPupMinsAllowance int, @TotalDRPMinsAllowance int, @allowdetention char(1),@autodetentiontype varchar(20)
	,@v_det_req_dep_act varchar(60) 
declare @invoiceby varchar(3),@movnumber int,@billto varchar(8)
declare @consignee varchar(8) 
-- PTS 55342 SGB 
declare @UseBolDetDates char(1)

/* 43837 Find out how this order is to be invoiced (check invoice first 
  if invoice does not yet exist check the order)    */
if exists (select 1 from invoiceheader where ord_hdrnumber = @ord_hdrnumber)
   Select @invoiceby = ivh_invoiceby,@movnumber = mov_number,@billto = ivh_billto ,@consignee = ivh_consignee
   from invoiceheader 
   where ivh_hdrnumber = (select min (ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @ord_hdrnumber)
else
   Select @invoiceby = cmp_invoiceby,@movnumber = mov_number,@billto = ord_billto ,@consignee = ord_consignee
   from orderheader join company on ord_billto = cmp_id 
   where ord_hdrnumber = @ord_hdrnumber

If @invoiceby is null
  select @invoiceby = cmp_invoiceby,@movnumber = mov_number,@billto = ord_billto
  from orderheader join company on ord_billto = cmp_id
  where ord_hdrnumber = @ord_hdrnumber

If @invoiceby is null
  select @invoiceby = 'ORD'
 
Select @autodetentiontype = gi_string1 From generalinfo Where gi_name = 'AutoDetentionType'
Select @autodetentiontype = IsNull(@autodetentiontype,'')

Select @PUPMinsAllowance  = 999999
 ,@DRPMinsAllowance=999999
 ,@TotalPupMinsAllowance=999999
 ,@TotalDRPMinsAllowance=999999

Select @allowdetention = IsNull(cmp_AllowDetCharges,'N')  From company Where cmp_id = (Select ord_billto From Orderheader
     Where ord_hdrnumber = @ord_hdrnumber)

--vjh 29413 Detention Requires Departure Actualization
Select @v_det_req_dep_act = gi_string1 From generalinfo Where gi_name = 'DetentionReqDepActualization'
Select @v_det_req_dep_act = upper(left(IsNull(@v_det_req_dep_act,'Y'),1))

-- PTS 55342 SGB substitute BOL dates for stops dates 
If (SELECT isnull(Upper(gi_string1),'N') FROM generalinfo WHERE gi_name = 'DetentionCheckBOLDates') = 'Y'
	BEGIN 
	Select @UseBolDetDates = UPPER(isnull(cmp_useboldates,'N')) From company Where cmp_id = (Select ord_billto From Orderheader
     Where ord_hdrnumber = @ord_hdrnumber)
	
	END
ELSE
	BEGIN
	Select @UseBolDetDates = 'N'
	END
--END PTS 55342

If (Select Upper(gi_string1) From generalinfo Where gi_name = 'AutoDetFeature') IN ( 'RATEONLY' ,'BOTH')
  And @allowdetention = 'Y' 
 Begin  --======================
  Select @PUPMinsAllowance = Convert(int,gi_string1)  
     From generalinfo Where gi_name = 'DetentionPUPMinsAllowance'  
  Select @DRPMinsAllowance = Convert(int,gi_string1)  
    From generalinfo Where gi_name = 'DetentionDRPMinsAllowance'  
  Select @PUPMinsAllowance = IsNull(@PUPMinsAllowance,999999)  
  Select @DRPMinsAllowance = IsNull(@DRPMinsAllowance,999999)  


  /* auto detention type 001 applies allowance from billto or min stop of type or INI to total pickup time */
  If @autodetentiontype = '001'
   Begin -----------------
     Select @TotalPUPMinsAllowance = cmp_PUPTimeAllowance,
           @TotalDRPMinsAllowance = cmp_DRPTimeAllowance 
     From company 
     Where cmp_id = (Select ord_billto from orderheader where ord_hdrnumber = @ord_hdrnumber)

     If @TotalPUPMinsAllowance is NULL
       Select @TotalPUPMinsAllowance = Min(cmp_PUPTimeAllowance )
       From company
       Where cmp_id In (Select distinct cmp_id From stops Where ord_hdrnumber = @ord_hdrnumber
                     and stp_type = 'PUP' and cmp_id <> 'UNKNOWN') and cmp_PUPTimeAllowance is not NULL

     If @TotalPUPMinsALlowance Is Null 
       Select @TotalPUPMinsAllowance = Convert(int,gi_string1)  
       From generalinfo Where gi_name = 'DetentionPUPMinsAllowance' 

     If @TotalPUPMinsAllowance Is Null
       Select @TotalPUPMinsAllowance = 999999

     If @TotalDRPMinsAllowance is NULL
       Select @TotalDRPMinsAllowance = Min(cmp_DRPTimeAllowance )
       From company
       Where cmp_id In (Select distinct cmp_id From stops Where ord_hdrnumber = @ord_hdrnumber
                     and stp_type = 'DRP' and cmp_id <> 'UNKNOWN')  and cmp_DRPTimeAllowance is Not NULL

     If @TotalDRPMinsALlowance is Null 
       Select @TotalDRPMinsAllowance = Convert(int,gi_string1)  
       From generalinfo Where gi_name = 'DetentionDRPMinsAllowance' 

     If @TotalDRPMinsALlowance is Null 
       Select @TotalDRPMinsALlowance = 999999

   End  --------------------
  If @autodetentiontype = 'DEP-ARV'
   Begin -----------------
     Select @billtocmp_PUPTimeAllowance = cmp_PUPTimeAllowance,
           @billtocmp_DRPTimeAllowance = cmp_DRPTimeAllowance 
     From company 
     Where cmp_id = (Select ord_billto from orderheader where ord_hdrnumber = @ord_hdrnumber)
   End  --------------------
 End  --=====================
Else
  Select @allowdetention = 'N'  
/*   ********** DEFAULT INVOICE BY ORDER   *******************  */
if @invoiceby = 'ORD'
  insert into #tempbillingstops
  SELECT  stops.cmp_id ,   
	stops.stp_city ,   
	stops.stp_event ,   
	stops.stp_reasonlate ,   
	stops.stp_type1 ,   
	stops.stp_delayhours ,   
	stops.stp_ooa_stop ,   
	stops.stp_ooa_mileage ,   
	fgt_carryins1 = IsNull(tfreight.carryins1,0),   
	fgt_carryins2 = IsNull(tfreight.carryins2,0),   
	stops.stp_sequence stp_sequence ,  
	stops.stp_type,  
	StopoffFlag = Case Charindex(','+Rtrim(LTrim(stp_event))+',',','+@validevents+',') When 0 Then 0 Else 1 End,  
	minsatstop =  0 ,  
	stpminsallowance = case @autoDetentionType
	  When 'DEP-ARV' Then
	     Case stp_type   
	     When 'PUP' Then (Case IsNull(@billtocmp_PUPTimeAllowance ,0) When 0 Then (Case IsNull(cmp_PUPTimeAllowance,0) When 0 Then @PUPMinsAllowance Else cmp_PUPTimeAllowance  End) ELSE @billtocmp_PUPTimeAllowance End)
	     When 'DRP' Then (Case IsNull(@billtocmp_DRPTimeAllowance ,0) When 0 Then (Case IsNull(cmp_DRPTimeAllowance,0) When 0 Then @DRPMinsAllowance Else cmp_DRPTimeAllowance  End) ELSE @billtocmp_DRPTimeAllowance End)
	     Else 0 End  
	  When '001' Then
	     Case stp_type  
	     When 'PUP' Then @TotalPUPMinsAllowance
	     When 'DRP' Then @TotalDRPMinsAllowance
	     Else 0 End
	  Else 999999
	  End,
	@allowdetention,
	stp_departure_status,
	stp_arrivaldate = case when (@UseBolDetDates = 'Y') Then case when sbd.bol_arrivaldate is NULL or sbd.bol_arrivaldate = '1950-01-01 00:00:00' Then stp_arrivaldate Else sbd.bol_arrivaldate End Else stp_arrivaldate End, --PTS 55342 SGB
	stp_departuredate = case when (@UseBolDetDates = 'Y') Then case when sbd.bol_departuredate is NULL or sbd.bol_departuredate = '2049-12-31 00:00:00' Then stp_departuredate Else sbd.bol_departuredate End Else stp_departuredate End, --PTS 55342 SGB
	stp_schdtearliest,
	detstart = ISNULL(
		(SELECT MIN(cmp_det_start) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_start 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			0
		)
	),
	detapplyiflate = ISNULL(
		(SELECT MIN(cmp_det_apply_if_late) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_apply_if_late 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	detapplyifearly = ISNULL(
		(SELECT MIN(cmp_det_apply_if_early) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_apply_if_early 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	stoparrivedlate = case when stp_arrivaldate>stp_schdtlatest then 'Y' else 'N' end,
	stoparrivedearly = case when stp_arrivaldate<stp_schdtearliest then 'Y' else 'N' end,
    stops.stp_number,
   'N' -- PTS 51801 SGB 
FROM	stops
	left outer join stops_bol_dates sbd on sbd.stp_number = stops.stp_number,    --PTS 55342 SGB   
	(Select s2.stp_number, carryins1 = sum(f2.fgt_carryins1),carryins2 = sum(f2.fgt_carryins2)   
	  From Stops s2, freightdetail f2 Where s2.ord_hdrnumber = @ord_hdrnumber  
	  and f2.stp_number = s2.stp_number group by s2.stp_number) tfreight ,   
	  company,  
	  eventcodetable
WHERE	stops.ord_hdrnumber = @ord_hdrnumber AND  
	stops.stp_number = tfreight.stp_number AND   
	stops.stp_event = eventcodetable.abbr AND   
	stops.cmp_id = company.cmp_id AND  
	eventcodetable.ect_billable = 'Y'
 order by stp_sequence 
/*   ******************  INVOICE BY MOVE   ************************** */ 
if @invoiceby = 'MOV'
  insert into #tempbillingstops
  SELECT  stops.cmp_id ,   
	stops.stp_city ,   
	stops.stp_event ,   
	stops.stp_reasonlate ,   
	stops.stp_type1 ,   
	stops.stp_delayhours ,   
	stops.stp_ooa_stop ,   
	stops.stp_ooa_mileage ,   
	fgt_carryins1 = IsNull(tfreight.carryins1,0),   
	fgt_carryins2 = IsNull(tfreight.carryins2,0),   
	stops.stp_sequence stp_sequence ,  
	stops.stp_type,  
	StopoffFlag = Case Charindex(','+Rtrim(LTrim(stp_event))+',',','+@validevents+',') When 0 Then 0 Else 1 End,  
	minsatstop =  0 ,  
	stpminsallowance = case @autoDetentionType
	  When 'DEP-ARV' Then
	     Case stp_type   
	     When 'PUP' Then (Case IsNull(@billtocmp_PUPTimeAllowance ,0) When 0 Then (Case IsNull(cmp_PUPTimeAllowance,0) When 0 Then @PUPMinsAllowance Else cmp_PUPTimeAllowance  End) ELSE @billtocmp_PUPTimeAllowance End)
	     When 'DRP' Then (Case IsNull(@billtocmp_DRPTimeAllowance ,0) When 0 Then (Case IsNull(cmp_DRPTimeAllowance,0) When 0 Then @DRPMinsAllowance Else cmp_DRPTimeAllowance  End) ELSE @billtocmp_DRPTimeAllowance End)
	     Else 0 End  
	  When '001' Then
	     Case stp_type  
	     When 'PUP' Then @TotalPUPMinsAllowance
	     When 'DRP' Then @TotalDRPMinsAllowance
	     Else 0 End
	  Else 999999
	  End,
	@allowdetention,
	stp_departure_status,
	stp_arrivaldate = case when (@UseBolDetDates = 'Y') Then case when sbd.bol_arrivaldate is NULL or sbd.bol_arrivaldate = '1950-01-01 00:00:00' Then stp_arrivaldate Else sbd.bol_arrivaldate End Else stp_arrivaldate End, --PTS 55342 SGB
	stp_departuredate = case when (@UseBolDetDates = 'Y') Then case when sbd.bol_departuredate is NULL or sbd.bol_departuredate = '2049-12-31 00:00:00' Then stp_departuredate Else sbd.bol_departuredate End Else stp_departuredate End, --PTS 55342 SGB
	stp_schdtearliest,
	detstart = ISNULL(
		(SELECT MIN(cmp_det_start) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_start 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			0
		)
	),
	detapplyiflate = ISNULL(
		(SELECT MIN(cmp_det_apply_if_late) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_apply_if_late 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	detapplyifearly = ISNULL(
		(SELECT MIN(cmp_det_apply_if_early) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_apply_if_early 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	stoparrivedlate = case when stp_arrivaldate>stp_schdtlatest then 'Y' else 'N' end,
	stoparrivedearly = case when stp_arrivaldate<stp_schdtearliest then 'Y' else 'N' end,
  stops.stp_number,
  'N' -- PTS 51801 SGB  
FROM	stops   
	left outer join stops_bol_dates sbd on sbd.stp_number = stops.stp_number,    --PTS 55342 SGB
	(Select s2.stp_number, carryins1 = sum(f2.fgt_carryins1),carryins2 = sum(f2.fgt_carryins2)   
	  From Stops s2, freightdetail f2 Where s2.mov_number = @movnumber  
	  and f2.stp_number = s2.stp_number group by s2.stp_number) tfreight ,   
	  company,  
	  eventcodetable,
      orderheader
WHERE	stops.mov_number = @movnumber AND  
	stops.stp_number = tfreight.stp_number AND   
	stops.stp_event = eventcodetable.abbr AND   
	stops.cmp_id = company.cmp_id AND  
	eventcodetable.ect_billable = 'Y' and
    stops.ord_hdrnumber = orderheader.ord_hdrnumber and
    stops.ord_hdrnumber > 0 and
    ord_billto = @billto
    order by stp_mfh_sequence
/*   ****************  INVOICE BY MOVE/CONSIGNEE  ******************* */
if @invoiceby = 'CON'
  insert into #tempbillingstops
  SELECT  stops.cmp_id ,   
	stops.stp_city ,   
	stops.stp_event ,   
	stops.stp_reasonlate ,   
	stops.stp_type1 ,   
	stops.stp_delayhours ,   
	stops.stp_ooa_stop ,   
	stops.stp_ooa_mileage ,   
	fgt_carryins1 = IsNull(tfreight.carryins1,0),   
	fgt_carryins2 = IsNull(tfreight.carryins2,0),   
	stops.stp_sequence stp_sequence ,  
	stops.stp_type,  
	StopoffFlag = Case Charindex(','+Rtrim(LTrim(stp_event))+',',','+@validevents+',') When 0 Then 0 Else 1 End,  
	minsatstop =  0 ,  
	stpminsallowance = case @autoDetentionType
	  When 'DEP-ARV' Then
	     Case stp_type   
	     When 'PUP' Then (Case IsNull(@billtocmp_PUPTimeAllowance ,0) When 0 Then (Case IsNull(cmp_PUPTimeAllowance,0) When 0 Then @PUPMinsAllowance Else cmp_PUPTimeAllowance  End) ELSE @billtocmp_PUPTimeAllowance End)
	     When 'DRP' Then (Case IsNull(@billtocmp_DRPTimeAllowance ,0) When 0 Then (Case IsNull(cmp_DRPTimeAllowance,0) When 0 Then @DRPMinsAllowance Else cmp_DRPTimeAllowance  End) ELSE @billtocmp_DRPTimeAllowance End)
	     Else 0 End  
	  When '001' Then
	     Case stp_type  
	     When 'PUP' Then @TotalPUPMinsAllowance
	     When 'DRP' Then @TotalDRPMinsAllowance
	     Else 0 End
	  Else 999999
	  End,
	@allowdetention,
	stp_departure_status,
	stp_arrivaldate = case when (@UseBolDetDates = 'Y') Then case when sbd.bol_arrivaldate is NULL or sbd.bol_arrivaldate = '1950-01-01 00:00:00' Then stp_arrivaldate Else sbd.bol_arrivaldate End Else stp_arrivaldate End, --PTS 55342 SGB
	stp_departuredate = case when (@UseBolDetDates = 'Y') Then case when sbd.bol_departuredate is NULL or sbd.bol_departuredate = '2049-12-31 00:00:00' Then stp_departuredate Else sbd.bol_departuredate End Else stp_departuredate End, --PTS 55342 SGB
	stp_schdtearliest,
	detstart = ISNULL(
		(SELECT MIN(cmp_det_start) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_start 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			0
		)
	),
	detapplyiflate = ISNULL(
		(SELECT MIN(cmp_det_apply_if_late) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_apply_if_late 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	detapplyifearly = ISNULL(
		(SELECT MIN(cmp_det_apply_if_early) 
			FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_apply_if_early 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	stoparrivedlate = case when stp_arrivaldate>stp_schdtlatest then 'Y' else 'N' end,
	stoparrivedearly = case when stp_arrivaldate<stp_schdtearliest then 'Y' else 'N' end,
  stops.stp_number,
  'N' -- PTS 51801 SGB  
FROM	stops   
	left outer join stops_bol_dates sbd on sbd.stp_number = stops.stp_number,    --PTS 55342 SGB
	(Select s2.stp_number, carryins1 = sum(f2.fgt_carryins1),carryins2 = sum(f2.fgt_carryins2)   
	  From Stops s2, freightdetail f2 Where s2.mov_number = @movnumber  
	  and f2.stp_number = s2.stp_number group by s2.stp_number) tfreight ,   
	  company,  
	  eventcodetable,
      orderheader
WHERE	stops.mov_number = @movnumber AND  
	stops.stp_number = tfreight.stp_number AND   
	stops.stp_event = eventcodetable.abbr AND   
	stops.cmp_id = company.cmp_id AND  
	eventcodetable.ect_billable = 'Y' and
    stops.ord_hdrnumber = orderheader.ord_hdrnumber and
    stops.ord_hdrnumber > 0 and
    ord_billto = @billto and 
    ord_consignee = @consignee   
    order by stp_mfh_sequence


update   #tempbillingstops
  set minsatstop = case detstart
    when 2 then DateDiff(mi,case when stoparrivedearly='Y' then stp_schdtearliest else stp_arrivaldate end,stp_departuredate)
    when 3 then DateDiff(mi,case when stoparrivedearly='Y' then stp_schdtearliest else stp_arrivaldate end,stp_departuredate)
    else DateDiff(mi,stp_arrivaldate,stp_departuredate)
  end
where
--vjh 28930 remove departurestatus reference (carried over inappropriately from PTSs 25371 26858)
--vjh 29413 put back in with a switch
  (stp_departure_status='DNE' OR @v_det_req_dep_act = 'N') and
  (detapplyiflate='Y' or (detapplyiflate='N' and stoparrivedlate='N') ) and
  (detapplyifearly='Y' or (detapplyifearly='N' and stoparrivedearly='N') ) and
  @allowdetention = 'Y'

select 
	cmp_id,
	stp_city,
	stp_event,
	stp_reasonlate,
	stp_type1,
	stp_delayhours,
	stp_ooa_stop,
	stp_ooa_mileage,
	fgt_carryins1,
	fgt_carryins2,
	stp_sequence,
	stp_type,
	StopoffFlag,
	minsatstop,
	stpminsallowance,
	allowdetention,
    stp_number,
    stp_arrivaldate,
    stp_departuredate,
   isnull(free_stop,'N') -- PTS 51801 SGB 
from #tempbillingstops
--  moved to select order by stp_sequence

GO
GRANT EXECUTE ON  [dbo].[d_billingstops_info_sp] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[d_order_stops_sp] @ord_hdrnumber int
as
/**
 *
 * NAME:
 * dbo.d_order_stops_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns stop information for an order
 *
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * 001 - ord_hdrnumber,   
 * 002 - stp_number,   
 * 003 - cmp_id,   
 * 004 - stp_city,   
 * 005 - stp_region1,   
 * 006 - stp_region2,   
 * 007 - stp_region3,   
 * 008 - stp_state,   
 * 009 - stp_schdtearliest,   
 * 010 - stp_arrivaldate,   
 * 011 - stp_origschdt,   
 * 012 - stp_departuredate,   
 * 013 - stp_schdtlatest,   
 * 014 - stp_sequence,   
 * 015 - stp_ord_mileage,   
 * 016 - mov_number,   
 * 017 - stp_weight,       
 * 018 - stp_weightunit,   
 * 019 - cmd_code,   
 * 020 - stp_description,   
 * 021 - stp_count  ,   
 * 022 - stp_countunit,   
 * 023 - stp_status,   
 * 024 - stp_volume  ,     
 * 025 - stp_volumeunit,
 * 026 - stp_type,
 * 027 - fgt_quantity,
 * 028 - fgt_unit,
 * 029 - stp_zipcode,
 * 030 - evt_driver1,
 * 031 - evt_driver2,
 * 032 - evt_tractor,
 * 033 - evt_trailer1,
 * 034 - evt_carrier,
 * 035 - ect_billable,
 * 036 - lgh_number, 
 * 037 - stp_event,
 * 038 - sumfgtweight,
 * 039 - sumfgtcount,
 * 040 - sumfgtvolume,
 * 041 - sumfgtcharge,
 * 042 - sumfgtloadingmeters,
 * 043 - stp_loadingmeters,
 * 044 - stp_loadingmetersunit,
 * 045 - minsatstop,
 * 046 - stpminsallowance,
 * 047 - allowdetention,
 * 048 - stp_ord_mileage_mtid,
 * 049 - stp_loadstatus,
 * 050 - stp_lgh_mileage, 
 * 051 - stp_lgh_mileage_mtid
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber int
 *	 The order header number of the order
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * DPETE PTS18414 add computed col for minutes at stop arive to depart and the allowance for detention from the company
 *     with a generalinfo table default if not specified at the company
 * 2/3/4 21389 DPETE change for auto detention type 001 to use bill to comp allowance as allowance for total time at all stops
 * of the same type. If NULL,use min allowance from all stops of type. If null use INI default. If NULL set 999999 allowance
 * 08/18/2005.01 ? PTS29413 - Vince Herman ? Add Detention Requires Departure Actualization
 * 08/22/2007.01 - PTS37029 - EMK - Add toll costs
 * 6/3/08 DPETE PTS 42827 Trimac has a GI setting that set bill miles on all stops (with order or with order=0), not just billable stops
 * 8/6/12 DPETE PTS 64219 Mindy suggested improvements for performance relatedto summing freight amounts
 */
 
 --PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
Set transaction isolation level read uncommitted
--end 62031

DECLARE @PUPMinsAllowance int, @DRPMinsAllowance int, @billtocmp_PUPTimeAllowance  int, @billtocmp_DRPTimeAllowance  int
Declare @TotalPupMinsAllowance int, @TotalDRPMinsAllowance int, @allowdetention char(1), @autodetentiontype varchar(20)
Declare @billto varchar(8), @v_det_req_dep_act varchar(60)
DECLARE @SetBillMilesOnNonBillableStops char(1)

declare @tempstops  table (
	ord_hdrnumber int NULL ,   
	stp_number int NULL ,   
	cmp_id varchar(8) NULL ,   
	stp_city int NULL,   
	stp_region1 varchar(6) NULL ,   
	stp_region2 varchar(6) NULL ,   
	stp_region3 varchar(6) NULL ,   
	stp_state char(6) NULL ,   
	stp_schdtearliest datetime NULL ,   
	stp_arrivaldate datetime NULL ,   
	stp_origschdt datetime NULL ,   
	stp_departuredate datetime NULL ,   
	stp_schdtlatest datetime NULL ,   
	stp_sequence int NULL ,   
	stp_ord_mileage int NULL ,   
	mov_number int NULL ,   
	stp_weight float NULL ,       
	stp_weightunit varchar(6) NULL ,   
	cmd_code varchar(8) NULL ,   
	stp_description varchar(60) null,   
	stp_count decimal(10) NULL ,
	stp_countunit varchar(10) NULL ,   
	stp_status varchar(6) NULL ,   
	stp_volume float NULL ,
	stp_volumeunit char(6) NULL ,
	stp_type varchar(6) NULL ,
	fgt_quantity float null,
	fgt_unit varchar(6) null,
	stp_zipcode varchar(10) NULL ,
	evt_driver1 varchar(8) NULL ,
	evt_driver2 varchar(8) NULL ,
	evt_tractor varchar(8) NULL ,
	evt_trailer1 varchar(13) NULL ,
	evt_carrier varchar(8) NULL ,
	ect_billable char(1) NULL ,
	lgh_number int NULL ,    
	stp_event char(6) null,
	sumfgtweight float null,
	sumfgtcount decimal(10,2) null,
	sumfgtvolume float null,
	sumfgtcharge money null,
	sumfgtloadingmeters decimal(12,4) null,
	stp_loadingmeters decimal(12,4) null,
	stp_loadingmetersunit varchar(6) null,
	minsatstop int null,
	stpminsallowance int null,
	allowdetention char(1) null,
	detstart int null,
	detapplyiflate char(1) null,
	detapplyifearly char(1) null,
	stoparrivedlate char(1) null,
	stoparrivedearly char(1) null,
	stp_departure_status varchar(6) Null,
	stp_ord_mileage_mtid integer null,
	stp_loadstatus varchar(3) null,
	stp_lgh_mileage integer null,
	stp_lgh_mileage_mtid integer null,
	stp_cod_currency VARCHAR(6) NULL,
	stp_cod_amount	MONEY NULL,
	stp_ord_toll_cost MONEY NULL
)


declare @stops table (stp_number int, totalweight float null, totalvolume float null, totalcount decimal(9,2) null
,totalcharge money, totalloadingmeters decimal(9,4) null )

INSERT INTO @stops
SELECT stops.stp_number
,SUM( isnull(fgt_weight,0) )
,SUM(isnull(fgt_volume,0))
,SUM(isnull(fgt_count,0))
,SUM(isnull(fgt_charge,0) )
,SUM(isnull(fgt_loadingmeters,0) )

FROM stops join freightdetail on stops.stp_number = freightdetail.stp_number
WHERE ord_hdrnumber = @ord_hdrnumber
and ord_hdrnumber > 0
group by stops.stp_number


SELECT @SetBillMilesOnNonBillableStops = substring(gi_string1,1,1) 
FROM generalinfo WHERE gi_name = 'SetBillMilesOnNonBillableStops'
SELECT @SetBillMilesOnNonBillableStops = isnull(@SetBillMilesOnNonBillableStops,'N') 

Select @PUPMinsAllowance = Convert(int,gi_string1)
  From generalinfo Where gi_name = 'DetentionPUPMinsAllowance'
Select @DRPMinsAllowance = Convert(int,gi_string1)
  From generalinfo Where gi_name = 'DetentionDRPMinsAllowance'
Select @PUPMinsAllowance = IsNull(@PUPMinsAllowance,999999)
Select @DRPMinsAllowance = IsNull(@DRPMinsAllowance,999999)
--
Select @autodetentiontype = gi_string1 From generalinfo Where gi_name = 'AutoDetentionType'
Select @autodetentiontype = IsNull(@autodetentiontype,'')

--vjh 29413 Detention Requires Departure Actualization
Select @v_det_req_dep_act = gi_string1 From generalinfo Where gi_name = 'DetentionReqDepActualization'
Select @v_det_req_dep_act = upper(left(IsNull(@v_det_req_dep_act,'Y'),1))

Select @TotalPupMinsAllowance=999999
 ,@TotalDRPMinsAllowance=999999

Select @allowdetention = 'N'

Select @billto = ord_billto From orderheader where ord_hdrnumber =  @ord_hdrnumber
Select @allowdetention = IsNull(cmp_AllowDetCharges,'N')  From company Where cmp_id = @billto

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
    If @autodetentiontype  = '001'
     Begin -----------------
       Select @TotalPUPMinsAllowance = cmp_PUPTimeAllowance,
	     @TotalDRPMinsAllowance = cmp_DRPTimeAllowance 
       From company 
       Where cmp_id = @billto

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

insert into @tempstops
  SELECT stops.ord_hdrnumber,   
	stops.stp_number,   
	stops.cmp_id,   
	stops.stp_city,   
	stops.stp_region1,   
	stops.stp_region2,   
	stops.stp_region3,   
	stops.stp_state,   
	stops.stp_schdtearliest,   
	stops.stp_arrivaldate,   
	stops.stp_origschdt,   
	stops.stp_departuredate,   
	stops.stp_schdtlatest,   
	stops.stp_sequence,   
	stops.stp_ord_mileage,   
	stops.mov_number,   
	stops.stp_weight,       
	stops.stp_weightunit,   
	stops.cmd_code,   
	stops.stp_description,   
	stops.stp_count  ,   
	stops.stp_countunit,   
	stops.stp_status,   
	stops.stp_volume  ,     
	stops.stp_volumeunit,
	stops.stp_type,
	freightdetail.fgt_quantity,  /* picked from sequence 1 freight detail- why ?? */
	freightdetail.fgt_unit,  /* picked from sequence 1 freight detail - why ?? */
	stops.stp_zipcode,
	event.evt_driver1,
	event.evt_driver2,
	event.evt_tractor,
	event.evt_trailer1,
	event.evt_carrier,
	eventcodetable.ect_billable,
	stops.lgh_number, 
	stops.stp_event,
--	sumfgtweight = (SELECT SUM(ISNULL(fgt_weight,0)) From freightdetail Where freightdetail.stp_number = stops.stp_number), 
--	sumfgtcount = (SELECT SUM(ISNULL(fgt_count,0)) From freightdetail Where freightdetail.stp_number = stops.stp_number),    
--	sumfgtvolume = (SELECT SUM(ISNULL(fgt_volume,0)) From freightdetail Where freightdetail.stp_number = stops.stp_number),    
--	sumfgtcharge = (SELECT SUM(ISNULL(fgt_charge,0)) From freightdetail Where freightdetail.stp_number = stops.stp_number),
--	sumfgtloadingmeters = (SELECT SUM(ISNULL(fgt_loadingmeters,0)) from freightdetail where freightdetail.stp_number = stops.stp_number),
    stp.totalweight,
    stp.totalcount,
    stp.totalvolume,
    stp.totalcharge,
    stp.totalloadingmeters,
	stops.stp_loadingmeters,
	stops.stp_loadingmetersunit,
	minsatstop =  0 ,
	stpminsallowance = Case @autoDetentionType
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
	allowdetention =  @allowdetention,
	detstart = ISNULL(
		(SELECT MIN(cmp_det_start) 
			FROM company where company.cmp_id = @billto), 
		ISNULL(
			(SELECT cmp_det_start 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			0
		)
	),
	detapplyiflate = ISNULL(
		(SELECT MIN(cmp_det_apply_if_late) 
			FROM company where company.cmp_id = @billto), 
		ISNULL(
			(SELECT cmp_det_apply_if_late 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	detapplyifearly = ISNULL(
		(SELECT MIN(cmp_det_apply_if_early) 
			FROM company where company.cmp_id = @billto), 
		ISNULL(
			(SELECT cmp_det_apply_if_early 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			'N'
		)
	),
	stoparrivedlate = case when stp_arrivaldate>stp_schdtlatest then 'Y' else 'N' end,
	stoparrivedearly = case when stp_arrivaldate<stp_schdtearliest then 'Y' else 'N' end,
	stp_departure_status
    ,stp_ord_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0)
 ,stp_loadstatus = IsNull(stops.stp_loadstatus,'LD')
 ,stp_lgh_mileage 
 ,stp_lgh_mileage_mtid = IsNull(stp_lgh_mileage_mtid,0),
	stp_cod_currency,
	stp_cod_amount,
	stp_ord_toll_cost --PTS 37029
    FROM @stops stp join stops on stp.stp_number = stops.stp_number
    join  freightdetail on stops.stp_number = freightdetail.stp_number and fgt_sequence = 1 
    join event on stops.stp_number = event.stp_number and evt_sequence = 1
    join eventcodetable on stops.stp_event = eventcodetable.abbr
    join company on stops.cmp_id = company.cmp_id
   WHERE --stops.ord_hdrnumber = @ord_hdrnumber and 
      @ord_hdrnumber  <> 0 
	 -- AND	stops.stp_number = freightdetail.stp_number
	  --AND freightdetail.fgt_sequence = 1
	 -- AND event.stp_number = stops.stp_number
	 -- AND stops.stp_event = eventcodetable.abbr 
	 -- AND event.evt_sequence = 1
     --AND company.cmp_id = stops.cmp_id
  
if @SetBillMilesOnNonBillableStops = 'Y'
  insert into @tempstops
  SELECT stops.ord_hdrnumber,   
	stops.stp_number,   
	stops.cmp_id,   
	stops.stp_city,   
	stops.stp_region1,   
	stops.stp_region2,   
	stops.stp_region3,   
	stops.stp_state,   
	stops.stp_schdtearliest,   
	stops.stp_arrivaldate,   
	stops.stp_origschdt,   
	stops.stp_departuredate,   
	stops.stp_schdtlatest,   
	stops.stp_sequence,   
	stops.stp_ord_mileage,   
	stops.mov_number,   
	stops.stp_weight,       
	stops.stp_weightunit,   
	stops.cmd_code,   
	stops.stp_description,   
	stops.stp_count  ,   
	stops.stp_countunit,   
	stops.stp_status,   
	stops.stp_volume  ,     
	stops.stp_volumeunit,
	stops.stp_type,
	0.0 fgt_quantity,
	' UNK' fgt_unit,
	stops.stp_zipcode,
	event.evt_driver1,
	event.evt_driver2,
	event.evt_tractor,
	event.evt_trailer1,
	event.evt_carrier,
	 'N' ect_billable,
	stops.lgh_number, 
	stops.stp_event,
	sumfgtweight = 0,
	sumfgtcount = 0,
	sumfgtvolume = 0,
	sumfgtcharge = 0,
	sumfgtloadingmeters = 0,
	stops.stp_loadingmeters,
	stops.stp_loadingmetersunit,
	minsatstop =  0 ,
	stpminsallowance =  999999,
	allowdetention =  @allowdetention,
	detstart = 0,
	detapplyiflate = 'N',
	detapplyifearly = 'N',
	stoparrivedlate =  'N' ,
	stoparrivedearly =  'N' ,
	stp_departure_status
    ,stp_ord_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0)
 ,stp_loadstatus = IsNull(stops.stp_loadstatus,'LD')
 ,stp_lgh_mileage 
 ,stp_lgh_mileage_mtid = IsNull(stp_lgh_mileage_mtid,0),
	stp_cod_currency,
	stp_cod_amount,
	stp_ord_toll_cost --PTS 37029
    FROM orderheader
    join stops on orderheader.mov_number = stops.mov_number
    join  event on stops.stp_number = event.stp_number
    join  company on stops.cmp_id = company.cmp_id
   WHERE orderheader.ord_hdrnumber = @ord_hdrnumber
      and stops.ord_hdrnumber =  0 
	  AND event.evt_sequence = 1


if @billto is not null begin
	update   @tempstops
	  set minsatstop = case detstart
	    when 2 then DateDiff(mi,case when stoparrivedearly='Y' then stp_schdtearliest else stp_arrivaldate end,stp_departuredate)
	    when 3 then DateDiff(mi,case when stoparrivedearly='Y' then stp_schdtearliest else stp_arrivaldate end,stp_departuredate)
	    else DateDiff(mi,stp_arrivaldate,stp_departuredate)
	  end
	--vjh 29413
	where (stp_departure_status='DNE' OR @v_det_req_dep_act = 'N') and
	  (detapplyiflate='Y' or (detapplyiflate='N' and stoparrivedlate='N') ) and
	  (detapplyifearly='Y' or (detapplyifearly='N' and stoparrivedearly='N') ) and
	  @allowdetention = 'Y'
end

SELECT ord_hdrnumber,   
	stp_number,   
	cmp_id,   
	stp_city,   
	stp_region1,   
	stp_region2,   
	stp_region3,   
	stp_state,   
	stp_schdtearliest,   
	stp_arrivaldate,   
	stp_origschdt,   
	stp_departuredate,   
	stp_schdtlatest,   
	stp_sequence,   
	stp_ord_mileage,   
	mov_number,   
	stp_weight,       
	stp_weightunit,   
	cmd_code,   
	stp_description,   
	stp_count  ,   
	stp_countunit,   
	stp_status,   
	stp_volume  ,     
	stp_volumeunit,
	stp_type,
	fgt_quantity,
	fgt_unit,
	stp_zipcode,
	evt_driver1,
	evt_driver2,
	evt_tractor,
	evt_trailer1,
	evt_carrier,
	ect_billable,
	lgh_number, 
	stp_event,
	sumfgtweight,
	sumfgtcount,
	sumfgtvolume,
	sumfgtcharge,
	sumfgtloadingmeters,
	stp_loadingmeters,
	stp_loadingmetersunit,
	minsatstop,
	stpminsallowance,
	allowdetention,
	stp_ord_mileage_mtid,
	stp_loadstatus,
 	stp_lgh_mileage, 
 	stp_lgh_mileage_mtid,
 	stp_departure_status,
 	stp_cod_currency,
 	stp_cod_amount,
	stp_ord_toll_cost  --PTS 37029
from @tempstops
order by stp_arrivaldate

GO
GRANT EXECUTE ON  [dbo].[d_order_stops_sp] TO [public]
GO

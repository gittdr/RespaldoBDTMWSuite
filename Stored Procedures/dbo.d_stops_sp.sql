SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[d_stops_sp] (@stringparm varchar(13),
			@numberparm int,
			@retrieve_by varchar(8))
as
/**
 *
 * NAME:
 * dbo.d_stops_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns stops data
 *
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * 001 - stp_event
 * 002 - cmp_id
 * 003 - cmp_name
 * 004 - cty_nmstct
 * 005 - stp_schdtearliest
 * 006 - stp_schdtlatest
 * 007 - stp_arrivaldate
 * 008 - stp_departuredate
 * 009 - stp_count
 * 010 - stp_countunit
 * 011 - cmd_code
 * 012 - stp_description
 * 013 - stp_weight
 * 014 - stp_reftype
 * 015 - stp_refnum
 * 016 - stp_ord_mileage
 * 017 - ord_hdrnumber
 * 018 - stp_number
 * 019 - stp_region1
 * 020 - stp_region2
 * 021 - stp_region3
 * 022 - stp_city
 * 023 - stp_state
 * 024 - stp_origschdt
 * 025 - stp_reasonlate
 * 026 - lgh_number
 * 027 - mfh_number
 * 028 - stp_type
 * 029 - stp_paylegpt
 * 030 - stp_sequence
 * 031 - stp_region4
 * 032 - stp_lgh_sequence
 * 033 - stp_mfh_sequence
 * 034 - stp_lgh_mileage
 * 035 - stp_mfh_mileage
 * 036 - mov_number
 * 037 - stp_loadstatus
 * 038 - stp_weightunit
 * 039 - stp_status
 * 040 - evt_driver1
 * 041 - evt_driver2
 * 042 - evt_tractor
 * 043 - lgh_primary_trailer
 * 044 - evt_carrier
 * 045 - lgh_outstatus
 * 046 - cmd_count 
 * 047 - event_count
 * 048 - ref_count
 * 049 - sch_done
 * 050 - sch_opn
 * 051 - mile_typ_to_stop
 * 052 - mile_typ_from_stop
 * 053 - drv_pay_event
 * 054 - ect_payondepart
 * 055 - stp_reasonlate_depart
 * 056 - stp_screenmode
 * 057 - lgh_primary_pup
 * 058 - stp_volume
 * 059 - stp_volumeunit
 * 060 - stp_comment
 * 061 - ect_billable
 * 062 - stp_delayhours
 * 063 - stp_ooa_mileage
 * 064 - stp_type1
 * 065 - stp_redeliver
 * 066 - stp_osd
 * 067 - stp_pudelpref
 * 068 - stp_phonenumber
 * 069 - stp_zipcode
 * 070 - stp_OOA_stop
 * 071 - stp_custpickupdate
 * 072 - stp_custdeliverydate
 * 073 - cmp_geoloc
 * 074 - tmp_evt_number
 * 075 - tmp_fgt_number
 * 076 - stp_address
 * 077 - stp_address2
 * 078 - stp_phonenumber2
 * 079 - stp_contact
 * 080 - stp_country
 * 081 - stp_loadingmeters
 * 082 - stp_loadingmetersunit
 * 083 - stp_cod_amount
 * 084 - stp_cod_currency
 * 085 - minsatstop
 * 086 - stpminsallowance
 * 087 - allowdetention
 * 088 - stp_departure_status
 * 089 - stp_count2
 * 090 - stp_countunit2
 * 091 - stp_ord_toll_cost
 * 092 - servicezone
 * 093 - servicezone_t
 * 094 - servicearea
 * 095 - servicearea_t
 * 096 - servicecenter
 * 097 - servicecenter_t
 * 098 - serviceregion
 * 099 - serviceregion_t
 * 101 - stp_ord_mileage_mtid
 * 102 - stp_lgh_mileage_mtid
 * 103 - stp_ooa_mileage_mtid
 * 104 - evt_trailer1 		 
 * 105 - evt_trailer2  
 * 106 - stp_firm_appt_flag	--gap 47  PTS 41569/43583  5/15/2008 jswindell
 * 107 - stp_delay_eligible	--gap 47  PTS 41569/43583  7/21/2008 jswindell
 * 108 - ud_column1					PTS 51911/59157 SGB User Defined column default will be for Timezone
 * 109 - ud_column1_t				PTS 51911/59157 SGB User Defined column header
 * 110 - ud_column2					PTS 51911/59157 SGB User Defined column
 * 111 - ud_column2_t				PTS 51911/59157 SGB User Defined column header
 * 112 - ud_column3					PTS 51911/59157 SGB User Defined column default will be for Timezone
 * 113 - ud_column3_t				PTS 51911/59157 SGB User Defined column header
 * 114 - ud_column4					PTS 51911/59157 SGB User Defined column
 * 115 - ud_column4_t				PTS 51911/59157 SGB User Defined column header
 * 116 - cmd_class2		--PTS52530 MBR 06/14/13
 * 117 - stp_rpt_miles
 * 118 - stp_rpt_miles_mtid
 * PARAMETERS:
 * 001 - @stringparm varchar(13)
 * 002 - @numberparm int
 * 003 - @retrieve_by varchar(8)
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 *	******  IF YOU ADD A COLUMN AND WANT IT TO COPY IN ORDER ENTRY, ADD COL ALSO TO cloneorderwithoptions proc *******
 *	lor	pts3913	add volume and volumeunit to the stops table	
 *	DJM	PTS 8696 - Removed use of Temp table to improve performance 
 *	dpete pts 12599 12/9/01 return cmp_geoloc
 *	Vern Jewett	PTS 12544	04/01/2002	Label=vmj1	Retrieve address-related columns, so values may be inserted/updated..
 *	DPETE 18414 add mintues at stop for detention determination
 *	DPETE 21389 change for auto detention type 001 to use bill to comp allowance as allowance for total time at all stops
 * 	of the same type. If NULL,use min allowance from all stops of type. If null use INI default. If NULL set 999999 allowance
 *	VJH 25371 adding to detention logic, going to temp table to allow more complex data massaging.
 *	DJM	PTS 27017	- Added the NULL statement for the stp_departure_status column definition in
 *		the temp table.  Without this, users that did not have the ansi_nulls_dflt_on connection
 *		property ON would receive errors.
 *	PTS 25713 add toll costs
 *	PTS 26791 - DJM - Recode of custom Localization processing from PTS 20302.
 * 08/18/2005.01 ? PTS29413 - Vince Herman ? Add Detention Requires Departure Actualization
 * 11/07/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * PAULS DPETE 24631 ad evt_triler1 and 2 put isnull on evt_tractor (PH Integration)
 * PTS 41569 / 43583 gap 47  5/15/2008 jswindell add stp_firm_appt_flag
 * PTS 43583 / { 41569/43583/43804 } gap 47 add stp_delay_eligible col to oe 7-21-2008 jswindell - DJM handled in 41569.sql on main source checkin.	
 * PTS 44864 PMILL changed definition of stp_count from decimal (10) to float
 * PTS 51911/59157 Added 4 user defined columns and headers column1 will default to Timezone
 * PTS 70513 SGB Made change to parameters for call to ud_company_shell_FN and UD_STOP_LEG_SHELL_FN to distinuish Trip Folder from OE
 */

create table #stopstempmov (
	stp_event char(6) NULL ,
	cmp_id varchar(8) NULL ,
	cmp_name varchar(30) NULL ,
	cty_nmstct varchar(30) NULL ,
	stp_schdtearliest datetime NULL ,
	stp_schdtlatest datetime NULL ,
	stp_arrivaldate datetime NULL ,
	stp_departuredate datetime NULL ,
	stp_count float NULL ,  --44864 pmill changed from decimal(10) to float
	stp_countunit varchar(10) NULL ,
	cmd_code varchar(8) NULL ,
	stp_description varchar(60) NULL ,
	stp_weight float NULL ,
	stp_reftype varchar(6) NULL ,
	stp_refnum varchar(30) NULL ,
	stp_ord_mileage int NULL ,
	ord_hdrnumber int NOT NULL ,
	stp_number int NOT NULL ,
	stp_region1 varchar(6) NULL ,
	stp_region2 varchar(6) NULL ,
	stp_region3 varchar(6) NULL ,
	stp_city int NOT NULL ,
	stp_state char(6) NULL ,
	stp_origschdt datetime NULL ,
	stp_reasonlate varchar(6) NULL ,
	lgh_number int NULL ,
	mfh_number int NULL ,
	stp_type varchar(6) NULL ,
	stp_paylegpt char(1) NULL ,
	stp_sequence int NULL ,
	stp_region4 varchar(6) NULL ,
	stp_lgh_sequence int NULL ,
	stp_mfh_sequence int NULL ,
	stp_lgh_mileage int NULL ,
	stp_mfh_mileage int NULL ,
	mov_number int NULL ,
	stp_loadstatus char(3) NULL ,
	stp_weightunit varchar(6) NULL ,
	stp_status varchar(6) NULL ,
	evt_driver1 varchar(8) NULL ,
	evt_driver2 varchar(8) NULL ,
	evt_tractor varchar(8) NULL ,
	lgh_primary_trailer varchar(13) NULL ,
	evt_carrier varchar(8) NULL ,
	lgh_outstatus varchar(6) NULL ,
	cmd_count int NOT NULL ,
	event_count int NOT NULL ,
	ref_count int NOT NULL ,
	sch_done int NOT NULL ,
	sch_opn int NOT NULL ,
	mile_typ_to_stop varchar(6) NULL ,
	mile_typ_from_stop varchar(6) NULL ,
	drv_pay_event varchar(6) NULL ,
	ect_payondepart char(1) NULL ,
	stp_reasonlate_depart varchar(6) NULL ,
	stp_screenmode varchar(6) NULL ,
	lgh_primary_pup varchar(13) NULL ,
	stp_volume float NULL ,
	stp_volumeunit char(6) NULL ,
	stp_comment varchar(254) NULL ,
	ect_billable char(1) NULL ,
	stp_delayhours float NULL ,
	stp_ooa_mileage float NULL ,
	stp_type1 varchar(6) NULL ,
	stp_redeliver varchar(1) NULL ,
	stp_osd varchar(1) NULL ,
	stp_pudelpref varchar(10) NULL ,
	stp_phonenumber varchar(20) NULL ,
	stp_zipcode varchar(10) NULL ,
	stp_OOA_stop int NULL ,
	stp_custpickupdate datetime NULL ,
	stp_custdeliverydate datetime NULL ,
	cmp_geoloc varchar(50)NULL,
	tmp_evt_number int null,
	tmp_fgt_number int null,
	stp_address varchar(40) null,
	stp_address2 varchar(40) null,
	stp_phonenumber2 varchar(20) null,
	stp_contact varchar(30) null,
	stp_country varchar(50) null,
	stp_loadingmeters decimal(10,4) null,
	stp_loadingmetersunit varchar(6) null,
	stp_cod_amount decimal(8,2) null,
	stp_cod_currency varchar(6) null,
    	minsatstop int NULL,
    	stpminsallowance int NULL,
   	allowdetention char(1) NULL,
	stp_departure_status varchar(6) NULL,  
	stp_count2 decimal(10,2) NULL,
	stp_countunit2 varchar(10) NULL,
	detstart int null,
	detapplyiflate char(1) null,
	detapplyifearly char(1) null,
	stoparrivedlate char(1) null,
	stoparrivedearly char(1) null,
	stp_ord_toll_cost money NULL,
	servicezone	varchar(20)	null,
	servicezone_t	varchar(20)	null,
	servicearea	varchar(20)	null,
	servicearea_t	varchar(20)	null,
	servicecenter	varchar(20)	null,
	servicecenter_t	varchar(20)	null,
	serviceregion	varchar(20)	null,
	serviceregion_t	varchar(20)	null,
	stp_ord_mileage_mtid integer null,
	stp_lgh_mileage_mtid integer null,
	stp_ooa_mileage_mtid integer null,
	evt_trailer1 varchar(13) null,		 
	evt_trailer2 varchar(13) null,
	stp_firm_appt_flag char(1) null, -- PTS 41569/43583 gap 47 JSwindell 5-15-2008
	stp_delay_eligible char(1) null, -- PTS 41569/43583/43804 gap 47 JSwindell 7-21-2008
	ud_column1	varchar(255),		 -- PTS 51911/59157 SGB User Defined column
	ud_column1_t varchar(30),		 --	PTS 51911/59157 SGB User Defined column header
	ud_column2	varchar(255),		 -- PTS 51911/59157 SGB User Defined column
	ud_column2_t varchar(30),		 --	PTS 51911/59157 SGB User Defined column header
	ud_column3	varchar(255),		 -- PTS 51911/59157 SGB User Defined column
	ud_column3_t varchar(30),		 --	PTS 51911/59157 SGB User Defined column header
	ud_column4	varchar(255),		 -- PTS 51911/59157 SGB User Defined column
	ud_column4_t varchar(30),		 --	PTS 51911/59157 SGB User Defined column header
	cmd_class2	VARCHAR(8) NULL ,	 --PTS52530 MBR 06/14/13
	stp_rpt_miles decimal (7,2),
	stp_rpt_miles_mtid integer
	)		 


declare @mov_number int,
	@lgh_number int,
	@workcount int
DECLARE @PUPMinsAllowance int, @DRPMinsAllowance int  , @billtocmp_PUPTimeAllowance  int, @billtocmp_DRPTimeAllowance  int
Declare @TotalPupMinsAllowance int, @TotalDRPMinsAllowance int, @allowdetention char(1), @autodetentiontype varchar(20)
Declare @Rby varchar(20),@nparm int,@billto varchar(8)
Declare	@detstart int,
	@detapplyiflate char(1),
	@detapplyifearly char(1),
	@detsendalert char(1),
	@stpearliest datetime,
	@stplatest datetime,
	@stopislate char(1),
	@stopisearly char(1),
	@localization char(1),
	@v_det_req_dep_act varchar(60),
	@ud_column1 char(1), --PTS 51911 SGB
	@ud_column2 char(1),  --PTS 51911 SGB
	@ud_column3 char(1), --PTS 51911 SGB
	@ud_column4 char(1),  --PTS 51911 SGB	
	@procname varchar(255), --PTS 51911 SGB
	@udheader varchar(30) --PTS 51911 SGB
	
Select @rby = @retrieve_by,@nparm = @numberparm

Select @autodetentiontype = gi_string1 From generalinfo Where gi_name = 'AutoDetentionType'
Select @autodetentiontype = IsNull(@autodetentiontype,'')

--vjh 29413 Detention Requires Departure Actualization
Select @v_det_req_dep_act = gi_string1 From generalinfo Where gi_name = 'DetentionReqDepActualization'
Select @v_det_req_dep_act = upper(left(IsNull(@v_det_req_dep_act,'Y'),1))

/* PTS 26791 (20302) - DJM - display the localization settings for the Origin and Desitinations	*/
Declare @o_servicezone_labelname varchar(20),
	@o_servicecenter_labelname varchar(20),
	@o_serviceregion_labelname varchar(20),
	@o_sericearea_labelname varchar(20),
	@service_revtype	varchar(10),
	@space			varchar(20)

select @o_servicezone_labelname = (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )
select @o_servicecenter_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )
select @o_serviceregion_labelname = (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
select @o_sericearea_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'
Select @space = 'UNKNOWN'
			



Select @PUPMinsAllowance  = 999999
 ,@DRPMinsAllowance=999999
 ,@TotalPupMinsAllowance=999999
 ,@TotalDRPMinsAllowance=999999

Select @allowdetention = 'N'
If @rby = 'ORDHDR' and @nparm > 0  /* Order entry retrieves like this */
 Begin --+++++++++++++++++++++++++
  Select @billto = ord_billto From orderheader where ord_hdrnumber = @nparm
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
         Where cmp_id In (Select distinct cmp_id From stops Where ord_hdrnumber = @nparm
                       and stp_type = 'PUP' and cmp_id <> 'UNKNOWN') and cmp_PUPTimeAllowance is not NULL

       If @TotalPUPMinsALlowance Is Null 
         Select @TotalPUPMinsAllowance = Convert(int,gi_string1)  
         From generalinfo Where gi_name = 'DetentionPUPMinsAllowance' 

       If @TotalPUPMinsAllowance Is Null
         Select @TotalPUPMinsAllowance = 999999

       If @TotalDRPMinsAllowance is NULL
         Select @TotalDRPMinsAllowance = Min(cmp_DRPTimeAllowance )
         From company
         Where cmp_id In (Select distinct cmp_id From stops Where ord_hdrnumber = @nparm
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
       Where cmp_id = @billto
     End  --------------------
   End  --=====================
 Else
      Select @allowdetention = 'N'  
 End --+++++++++++++++++++++++

			
			

/* LOOK UP BY DRIVER, TRACTOR, TRAILER, CARRIER */
IF (@retrieve_by = 'DRV' or @retrieve_by = 'TRC' or @retrieve_by = 'TRL' or @retrieve_by = 'CAR')
	BEGIN
	
	execute @numberparm = cur_activity  @retrieve_by, @stringparm, @lgh_number
	
	/* NUMBER PARM WILL REMAIN -1 IF ORDERNUMBER IS INVALID */
	IF (@numberparm > 0 ) 
		SELECT @retrieve_by = 'MOVE'
	else
		select @retrieve_by = 'NODATA'
	END


/* LOOK UP BY ORDER NUMBER */
IF (@retrieve_by = 'ORDNUM')
	BEGIN

	SELECT @numberparm = -1 
	
	SELECT @numberparm = mov_number 
		FROM orderheader
		WHERE ord_number = @stringparm
	
	/* NUMBER PARM WILL REMAIN -1 IF ORDERNUMBER IS INVALID */
	IF (@numberparm = -1 ) 
		select @retrieve_by = 'NODATA'
	ELSE
		select @retrieve_by = 'MOVE'
	END      

/* LOOK UP BY LGH NUMBER */
IF (@retrieve_by = 'LGHNUM')
	BEGIN
		
	SELECT @mov_number = -1

	SELECT DISTINCT @mov_number = stops.mov_number  
		FROM stops
		WHERE stops.lgh_number = @numberparm

	/* NUMBER PARM WILL REMAIN -1 IF ORDERNUMBER IS INVALID */
	IF (@numberparm = -1 ) 
		select @retrieve_by = 'NODATA'
	ELSE
		begin
		select @retrieve_by = 'MOVE'
		select @numberparm = @mov_number
		end
	END

/* EMPTY RETURN SET FOR INVALID ORDER NUMBERS*/
if (@retrieve_by = 'NODATA') 
	BEGIN   
-- vjh use the select at the end
--	SELECT * from #stopstempmov
--		WHERE 1 = 2

	GOTO THEEND
	END


IF (@retrieve_by = 'MOVE')
	BEGIN
		insert into #stopstempmov
		SELECT stops.stp_event, 
			stops.cmp_id, 
			stops.cmp_name, 
			city.cty_nmstct, 
			stops.stp_schdtearliest, 
			stops.stp_schdtlatest, 
			stops.stp_arrivaldate, 
			stops.stp_departuredate, 
			stops.stp_count, 
			stops.stp_countunit, 
			stops.cmd_code, 
			stops.stp_description,
			stops.stp_weight, 
			stops.stp_reftype, 
			stops.stp_refnum, 
			stops.stp_ord_mileage, 
			stops.ord_hdrnumber, 
			stops.stp_number, 
			stops.stp_region1, 
			stops.stp_region2, 
			stops.stp_region3, 
			stops.stp_city, 
			stops.stp_state, 
			stops.stp_origschdt, 
			stops.stp_reasonlate, 
			stops.lgh_number, 
			stops.mfh_number, 
			stops.stp_type, 
			stops.stp_paylegpt,
			stops.stp_sequence, 
			stops.stp_region4, 
			stops.stp_lgh_sequence, 
			stops.stp_mfh_sequence, 
			stops.stp_lgh_mileage, 
			stops.stp_mfh_mileage, 
			stops.mov_number, 
			stops.stp_loadstatus, 
			stops.stp_weightunit, 
			stops.stp_status, 
			event.evt_driver1, 
			event.evt_driver2, 
			event.evt_tractor, 
			legheader.lgh_primary_trailer, 
			event.evt_carrier, 
			legheader.lgh_outstatus , 
			(SELECT COUNT(*) 
				FROM freightdetail
				WHERE freightdetail.stp_number = stops.stp_number) cmd_count, 
			(SELECT COUNT(*) 
				FROM event 
				WHERE event.stp_number = stops.stp_number) event_count, 
			(SELECT COUNT(*) 
				FROM referencenumber r 
				WHERE r.ref_table = 'stops' AND r.ref_tablekey = stops.stp_number) ref_count, 
			(SELECT COUNT(*) 
				FROM event e
				WHERE e.evt_eventcode = 'SAP' AND 
					e.evt_status = 'DNE' AND 
					e.stp_number = stops.stp_number) sch_done, 
			(SELECT COUNT(*) 
				FROM event ev 
				WHERE ev.evt_eventcode = 'SAP' AND 
					ev.evt_status = 'OPN' and 
					ev.stp_number = stops.stp_number) sch_opn,
			eventcodetable.mile_typ_to_stop,   
			eventcodetable.mile_typ_from_stop,
			eventcodetable.drv_pay_event,
			eventcodetable.ect_payondepart,
			stops.stp_reasonlate_depart,
			stops.stp_screenmode,
			legheader.lgh_primary_pup,
			stops.stp_volume,
			stops.stp_volumeunit,
			stops.stp_comment,
			eventcodetable.ect_billable,
			stops.stp_delayhours,
			stops.stp_ooa_mileage, 
			stops.stp_type1, 
			stops.stp_redeliver, 
			stops.stp_osd, 
			stops.stp_pudelpref, 
			stops.stp_phonenumber, 
			stops.stp_zipcode, 
			stops.stp_OOA_stop,
			stops.stp_custpickupdate,
			stops.stp_custdeliverydate ,
			ISNULL(cmp_geoloc,'') cmp_geoloc,
			-- RE - 02/12/02 - PTS #13312 Start
			stops.tmp_evt_number,
			stops.tmp_fgt_number,
			-- RE - 02/12/02 - PTS #13312 End
			--vmj1+
			stops.stp_address,
			stops.stp_address2,
			stops.stp_phonenumber2,
			stops.stp_contact,
			--vmj1-
			-- JET - 11/18/2002 - PTS #16016
			stops.stp_country,
			-- PTS16029 MBR 12/12/02
			stops.stp_loadingmeters,
			stops.stp_loadingmetersunit,
			--KPM pts 16028
			stops.stp_cod_amount,
			stops.stp_cod_currency ,
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
				@allowdetention allowdetention,
			--PTS# 20382 ILB 07/29/2003
			stp_departure_status
			--PTS# 20382 ILB 07/29/2003
			,stp_count2
			,stp_countunit2,
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
			stp_ord_toll_cost,
			@space servicezone,
			@o_servicezone_labelname servicezone_t,
			@space servicearea,
			@o_sericearea_labelname servicearea_t,
			@space servicecenter,
			@o_servicecenter_labelname servicecenter_t,
			@space serviceregion,
			@o_serviceregion_labelname serviceregion_t
			,stp_ord_mileage_mtid= IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205
			,stp_lgh_mileage_mtid= IsNull(stops.stp_lgh_mileage_mtid,0) -- RE - PTS #28205
			,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0) -- RE - PTS #28205
			,evt_trailer1 = IsNull(event.evt_trailer1,'UNKNOWN')	--PH Integration 40259
			,evt_trailer2 = IsNull(event.evt_trailer2,'UNKNOWN')	--PH Integration 40259
			,stp_firm_appt_flag --= IsNull(stops.stp_firm_appt_flag,'N') -- gap 47  PTS 41569/43583  5/15/2008 jswindell
			,stp_delay_eligible --  PTS 41569/43583/43804 gap 47 JSwindell 7-21-2008
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column1' 	--	PTS 51911/59157 SGB User Defined column header
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column2'		--	PTS 51911/59157 SGB User Defined column header
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column3' 	--	PTS 51911/59157 SGB User Defined column header
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column4',		--	PTS 51911/59157 SGB User Defined column header
			ISNULL(commodity.cmd_class2, 'UNKNOWN') cmd_class2
			, stp_rpt_miles, stp_rpt_miles_mtid
		FROM stops LEFT OUTER JOIN eventcodetable ON stops.stp_event = eventcodetable.abbr, 
			city, event, legheader,  company, commodity
		WHERE   ( stops.stp_city = city.cty_code ) and 
				( event.stp_number = stops.stp_number ) and 
				( stops.lgh_number = legheader.lgh_number ) and 
				( stops.mov_number = @numberparm ) AND 
				(stops.cmp_id = company.cmp_id)and
				( event.evt_sequence = 1 ) AND
				( stops.stp_event NOT IN ( 'XDL', 'XDU' )) AND
				(stops.cmd_code = commodity.cmd_code)

	END




IF (@retrieve_by = 'ORDHDR')
	BEGIN

		/*make sure not to retrieve ord_hdr =0 stops*/
		if @numberparm = 0 
			select @numberparm = -9999
	
		insert into #stopstempmov
		SELECT stops.stp_event, 
			stops.cmp_id, 
			stops.cmp_name, 
			city.cty_nmstct, 
			stops.stp_schdtearliest, 
			stops.stp_schdtlatest, 
			stops.stp_arrivaldate, 
			stops.stp_departuredate, 
			stops.stp_count, 
			stops.stp_countunit, 
			stops.cmd_code, 
			stops.stp_description,
			stops.stp_weight, 
			stops.stp_reftype, 
			stops.stp_refnum, 
			stops.stp_ord_mileage, 
			stops.ord_hdrnumber, 
			stops.stp_number, 
			stops.stp_region1, 
			stops.stp_region2, 
			stops.stp_region3, 
			stops.stp_city, 
			stops.stp_state, 
			stops.stp_origschdt, 
			stops.stp_reasonlate, 
			stops.lgh_number, 
			stops.mfh_number, 
			stops.stp_type, 
			stops.stp_paylegpt, 
			stops.stp_sequence, 
			stops.stp_region4, 
			stops.stp_lgh_sequence, 
			stops.stp_mfh_sequence, 
			stops.stp_lgh_mileage, 
			stops.stp_mfh_mileage, 
			stops.mov_number, 
			stops.stp_loadstatus, 
			stops.stp_weightunit, 
			stops.stp_status, 
			event.evt_driver1, 
			event.evt_driver2, 
			event.evt_tractor, 
			legheader.lgh_primary_trailer, 
			event.evt_carrier, 
			legheader.lgh_outstatus , 
			(SELECT COUNT(*) 
			FROM freightdetail
			WHERE freightdetail.stp_number = stops.stp_number) cmd_count, 
			(SELECT COUNT(*) 
			FROM event 
			WHERE event.stp_number = stops.stp_number) event_count, 
			(SELECT COUNT(*) 
			FROM referencenumber r
			WHERE r.ref_table = 'stops' AND r.ref_tablekey = stops.stp_number) ref_count, 
			(SELECT COUNT(*) 
			FROM event e 
			WHERE e.evt_eventcode = 'SAP' AND 
			e.evt_status = 'DNE' AND 
			e.stp_number = stops.stp_number) sch_done, 
			(SELECT COUNT(*) 
			FROM event ev   
			WHERE ev.evt_eventcode = 'SAP' AND 
			ev.evt_status = 'OPN' and 
			ev.stp_number = stops.stp_number) sch_opn,
			eventcodetable.mile_typ_to_stop,   
			eventcodetable.mile_typ_from_stop,
			eventcodetable.drv_pay_event,
			eventcodetable.ect_payondepart,
			stops.stp_reasonlate_depart,
			stops.stp_screenmode,
			legheader.lgh_primary_pup,
			stops.stp_volume,
			stops.stp_volumeunit,
			stops.stp_comment,
			eventcodetable.ect_billable,
			stops.stp_delayhours,
			stops.stp_ooa_mileage, 
			stops.stp_type1, 
			stops.stp_redeliver, 
			stops.stp_osd, 
			stops.stp_pudelpref, 
			stops.stp_phonenumber, 
			stops.stp_zipcode, 
			stops.stp_OOA_stop,
			stops.stp_custpickupdate,
			stops.stp_custdeliverydate ,
			ISNULL(cmp_geoloc,'') cmp_geoloc,
			-- RE - 02/12/02 - PTS #13312 Start
			stops.tmp_evt_number,
			stops.tmp_fgt_number,
			-- RE - 02/12/02 - PTS #13312 End
			--vmj1+
			stops.stp_address,
			stops.stp_address2,
			stops.stp_phonenumber2,
			stops.stp_contact,
			--vmj1-
			-- JET - 11/18/2002 - PTS #16016
			stops.stp_country,
			-- PTS16029 MBR 12/12/02
			stops.stp_loadingmeters,
			stops.stp_loadingmetersunit,
			--KPM pts 16028
			stops.stp_cod_amount,
			stops.stp_cod_currency ,
			--vjh 29413 insert zero.  Minutes are updated later using all applicable logic
			--minsatstop =  DateDiff(mi,stp_arrivaldate,stp_departuredate) ,
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
			@allowdetention allowdetention,
			--PTS# 20382 ILB 07/29/2003
			stp_departure_status
			--PTS# 20382 ILB 07/29/2003
			,stp_count2
			,stp_countunit2,
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
			stp_ord_toll_cost,
			@space servicezone,
			@o_servicezone_labelname servicezone_t,
			@space servicearea,
			@o_sericearea_labelname servicearea_t,
			@space servicecenter,
			@o_servicecenter_labelname servicecenter_t,
			@space serviceregion,
			@o_serviceregion_labelname serviceregion_t
			,stp_ord_mileage_mtid= IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205
			,stp_lgh_mileage_mtid= IsNull(stops.stp_lgh_mileage_mtid,0) -- RE - PTS #28205
			,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0) -- RE - PTS #28205
			,evt_trailer1 = IsNull(event.evt_trailer1,'UNKNOWN')	--PH Integration 40259
			,evt_trailer2 = IsNull(event.evt_trailer2,'UNKNOWN')	--PH Integration 40259
			,stp_firm_appt_flag --= IsNull(stops.stp_firm_appt_flag,'N') -- gap 47  PTS 41569/43583  5/15/2008 jswindell
			,stp_delay_eligible --  PTS 41569/43583/43804 gap 47 JSwindell 7-21-2008
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column1' 	--	PTS 51911/59157 SGB User Defined column header
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column2'		--	PTS 51911/59157 SGB User Defined column header	
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column3' 	--	PTS 51911/59157 SGB User Defined column header
			,'UNKNOWN' 	-- PTS 51911/59157 SGB User Defined column
			,'UD Column4',		--	PTS 51911/59157 SGB User Defined column header
			ISNULL(commodity.cmd_class2, 'UNKNOWN')					
			, stp_rpt_miles, stp_rpt_miles_mtid
		FROM	stops  LEFT OUTER JOIN  eventcodetable  ON  stops.stp_event  = eventcodetable.abbr   
						LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number ,
				city,
				event,
				company,
				commodity 
		WHERE  ( stops.stp_city = city.cty_code ) and 
				( event.stp_number = stops.stp_number ) and 
				(stops.cmp_id = company.cmp_id) and
	-- PTS 7505 sub next line ( stops.mov_number = @numberparm ) AND 
				( stops.ord_hdrnumber = @numberparm ) AND 
				( event.evt_sequence = 1 ) AND
				( stops.stp_event NOT IN ( 'XDL', 'XDU' ))AND
		       		(stops.cmd_code = commodity.cmd_code)

	END

if @billto is not null and @allowdetention = 'Y' begin
	update   #stopstempmov
	  set minsatstop = case detstart
	    when 2 then DateDiff(mi,case when stoparrivedearly='Y' then stp_schdtearliest else stp_arrivaldate end,stp_departuredate)
	    when 3 then DateDiff(mi,case when stoparrivedearly='Y' then stp_schdtearliest else stp_arrivaldate end,stp_departuredate)
	    else DateDiff(mi,stp_arrivaldate,stp_departuredate)
	  end
	-- vjh 29413
	where   (stp_departure_status='DNE' OR @v_det_req_dep_act = 'N') and
	  (detapplyiflate='Y' or (detapplyiflate='N' and stoparrivedlate='N') ) and
	  (detapplyifearly='Y' or (detapplyifearly='N' and stoparrivedearly='N') )
end

/* PTS 23791 - DJM - Check setting used control use of the Localization values in the Tripfolder. 
*/
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'

-- Only perform the following logic if the Feature is on.
if @localization = 'Y'
Begin
	-- PTS 26791 - DJM - Set the Localization fields	
	Update #stopstempmov
	set servicezone = isNull((select cz_zone from cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct and #stopstempmov.stp_zipcode = cityzip.zip),'UNK'),
		servicearea = isNull((select cz_area from cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct and #stopstempmov.stp_zipcode = cityzip.zip),'UNK'),
		servicecenter = isNull((select Case isNull(@service_revtype,'UNK')
				when 'REVTYPE1' then
					(select max(svc_center) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_center) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_center) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_center) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
				else 'UNKNOWN'
				End),'UNKNOWN'),
		serviceregion = isNull((select Case isNull(@service_revtype,'UNK')
				when 'REVTYPE1' then
					(select max(svc_region) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_region) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_region) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_region) from serviceregion sc, cityzip where #stopstempmov.cty_nmstct = cityzip.cty_nmstct AND #stopstempmov.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
				else
				 	'UNKNOWN'
				End),'UNKNOWN')
	From Orderheader
	where orderheader.ord_hdrnumber = #stopstempmov.ord_hdrnumber

End 

--PTS 51911/59157 SGB Only run when setting turned on 
Select @ud_column1 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_COMPANY_COLUMNS'
Select @ud_column2 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_COMPANY_COLUMNS'
Select @ud_column3 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column4 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'

IF @ud_column1 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_COMPANY_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				
			-- PTS 70513 SGB 
			--SELECT 	@udheader = dbo.ud_company_shell_FN ('','H',1)
			SELECT 	@udheader = dbo.ud_company_shell_FN ('','HO',1)
			UPDATE #stopstempmov
			-- PTS 70513 SGB 
			--set ud_column1 = dbo.ud_company_shell_FN (s.cmp_id,'CO',1),
			set ud_column1 = dbo.ud_company_shell_FN (s.cmp_id,'C2',1),
			ud_column1_t = @udheader
			from #stopstempmov s

		END
 
END 

IF @ud_column2 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_COMPANY_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				
			-- PTS 70513 SGB
			--SELECT 	@udheader = dbo.ud_company_shell_FN ('','H',2)
			SELECT 	@udheader = dbo.ud_company_shell_FN ('','HO',2)
			UPDATE #stopstempmov
			-- PTS 70513 SGB
			--set ud_column2 = dbo.ud_company_shell_FN (s.cmp_id,'CO',2),
			set ud_column2 = dbo.ud_company_shell_FN (s.cmp_id,'C2',2),
			ud_column2_t = @udheader
			from #stopstempmov s

		END
 
END 

IF @ud_column3 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				
			-- PTS 70513 SGB
			--SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',1)
			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','HO',1)
			UPDATE #stopstempmov
			-- PTS 70513 SGB
			--set ud_column3 = DBO.UD_STOP_LEG_SHELL_FN (s.stp_number,'S',1),
			set ud_column3 = DBO.UD_STOP_LEG_SHELL_FN (s.stp_number,'SO',1),
			ud_column3_t = @udheader
			from #stopstempmov s

		END
 
END 

IF @ud_column4 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				
			-- PTS 70513 SGB
			--SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',2)
			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','HO',2)
			UPDATE #stopstempmov
			-- PTS 70513 SGB
			--set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (s.stp_number,'S',2),
			set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (s.stp_number,'SO',2),
			ud_column4_t = @udheader
			from #stopstempmov s

		END
 
END 

THEEND:

select 
	stp_event,
	cmp_id,
	cmp_name,
	cty_nmstct,
	stp_schdtearliest,
	stp_schdtlatest,
	stp_arrivaldate,
	stp_departuredate,
	stp_count,
	stp_countunit,
	cmd_code,
	stp_description,
	stp_weight,
	stp_reftype,
	stp_refnum,
	stp_ord_mileage,
	ord_hdrnumber,
	stp_number,
	stp_region1,
	stp_region2,
	stp_region3,
	stp_city,
	stp_state,
	stp_origschdt,
	stp_reasonlate,
	lgh_number,
	mfh_number,
	stp_type,
	stp_paylegpt,
	stp_sequence,
	stp_region4,
	stp_lgh_sequence,
	stp_mfh_sequence,
	stp_lgh_mileage,
	stp_mfh_mileage,
	mov_number,
	stp_loadstatus,
	stp_weightunit,
	stp_status,
	evt_driver1,
	evt_driver2,
	evt_tractor,
	lgh_primary_trailer,
	evt_carrier,
	lgh_outstatus,
	cmd_count ,
	event_count,
	ref_count,
	sch_done,
	sch_opn,
	mile_typ_to_stop,
	mile_typ_from_stop,
	drv_pay_event,
	ect_payondepart,
	stp_reasonlate_depart,
	stp_screenmode,
	lgh_primary_pup,
	stp_volume,
	stp_volumeunit,
	stp_comment,
	ect_billable,
	stp_delayhours,
	stp_ooa_mileage,
	stp_type1,
	stp_redeliver,
	stp_osd,
	stp_pudelpref,
	stp_phonenumber,
	stp_zipcode,
	stp_OOA_stop,
	stp_custpickupdate,
	stp_custdeliverydate,
	cmp_geoloc,
	tmp_evt_number,
	tmp_fgt_number,
	stp_address,
	stp_address2,
	stp_phonenumber2,
	stp_contact,
	stp_country,
	stp_loadingmeters,
	stp_loadingmetersunit,
	stp_cod_amount,
	stp_cod_currency,
    	minsatstop,
    	stpminsallowance,
   	allowdetention,
	stp_departure_status,
	stp_count2,
	stp_countunit2,
	stp_ord_toll_cost,
	servicezone,
	servicezone_t,
	servicearea,
	servicearea_t,
	servicecenter,
	servicecenter_t,
	serviceregion,
	serviceregion_t
	,stp_ord_mileage_mtid -- RE - PTS #28205
	,stp_lgh_mileage_mtid -- RE - PTS #28205
	,stp_ooa_mileage_mtid -- RE - PTS #28205
	,evt_trailer1 --PH Integration 40257
	,evt_trailer2 --PH Integration 40257
	,stp_firm_appt_flag --- PTS 41569/43583 gap 47 JSwindell 5-15-2008
	,stp_delay_eligible --  PTS 41569/43583/43804 gap 47 JSwindell 7-21-2008
	,ud_column1			 -- PTS 51911/59157 SGB User Defined column
	,ud_column1_t		 --	PTS 51911/59157 SGB User Defined column header
	,ud_column2			 -- PTS 51911/59157 SGB User Defined column
	,ud_column2_t 		 --	PTS 51911/59157 SGB User Defined column header
	,ud_column3			 -- PTS 51911/59157 SGB User Defined column
	,ud_column3_t		 --	PTS 51911/59157 SGB User Defined column header
	,ud_column4			 -- PTS 51911/59157 SGB User Defined column
	,ud_column4_t, 		 --	PTS 51911/59157 SGB User Defined column header
	cmd_class2	
	, stp_rpt_miles, stp_rpt_miles_mtid
from #stopstempmov

return

GO
GRANT EXECUTE ON  [dbo].[d_stops_sp] TO [public]
GO

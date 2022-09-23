SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- creates procedure
CREATE PROCEDURE [dbo].[d_available_trips_ltsl_sp_dotnet]
	@p_revType1       	varchar(256), 
	@p_revType2       	varchar(256), 
	@p_revType3       	varchar(256), 
	@p_revType4       	varchar(256), 
	@p_trltype1       	varchar(256), 
	@p_company        	varchar(256), 
	@p_oStates         	varchar(256), 
	@p_oCmpIds         	varchar(256), 
	@p_oReg1           	varchar(256), 
	@p_oReg2           	varchar(256), 
	@p_oReg3           	varchar(256), 
	@p_oReg4           	varchar(256), 
	@p_oCity           	int, 
	@p_hoursBack      	int, 
	@p_hoursOut       	int, 
	@p_status         	varchar(256), 
	@p_bookedBy       	varchar(256), 
	@p_refType        	varchar(6), 
	@p_teamLeader     	varchar(256), 
	@p_dStates        	varchar(256), 
	@p_dCmpIDs			varchar(256), 
	@p_dReg1          	varchar(256), 
	@p_dReg2          	varchar(256), 
	@p_dReg3          	varchar(256), 
	@p_dReg4          	varchar(256), 
	@p_dCity          	int, 
	@p_includeDrvPlan 	varchar(3), 
	@p_milesMin       	int, 
	@p_milesMax        	int, 
	@p_tmStatus       	varchar(256), 
	@p_lghType1       	varchar(256), 
	@p_lghType2       	varchar(256), 
	@p_billTo         	varchar(256), 
	@p_HzdCmdClasses	varchar(256), 
	@p_orderedBy      	varchar(256), 
	@p_oServiceArea   	varchar(256), 
	@p_oServiceZone   	varchar(256), 
	@p_oServiceCenter 	varchar(256), 
	@p_oServiceRegion 	varchar(256), 
	@p_dServiceArea   	varchar(256), 
	@p_dServiceZone   	varchar(256), 
	@p_dServiceCenter 	varchar(256), 
	@p_dServiceRegion 	varchar(256), 
	@p_route          	varchar(256), 
	@p_bookedRevtype  	varchar(256),
	@p_permitStatus		varchar(256)
AS

/*******************************************************************************************************************  
  Object Description: [d_available_trips_ltsl_sp_dotnet]
  proc is called to retrieve orders to the EDI tab of the planning worksheet
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ------------------------------------------------------------------------
  08/4/2016    David Wilks      97838       d_available_trips_ltsl_sp_dotnet support for higher weight totals
  10/24/2017   David Wilks      INT-200603  filter out 204s that are currently being processed
********************************************************************************************************************/

Set NOCOUNT ON

set transaction isolation level read uncommitted -- PTS 62998

DECLARE 
	@v_char1          		char(1), 
	@v_char10          		char(10), 
	@v_char2          		char(2), 
	@v_char20         		char(20), 
	@v_char30         		char(30), 
	@v_char25         		char(25), 
	@v_char40         		char(40), 
	@v_char8          		char(8), 
	@v_cmdCount       		int, 
	@v_dttm           		datetime, 
	@v_giString1      		varchar(60), 
	@v_hoursBackDate  		datetime, 
	@v_hoursOutDate   		datetime, 
	@v_lateWarnMode    		varchar(60), 
	@v_localization    		char(1), 
	@v_maxStop        		int, 
	@v_minStop        		int, 
	@v_extraInfoLocation	varchar(20), 
	@v_retVarchar        	varchar(3), 
	@v_runPups        		char(1), 
	@v_runDrops       		char(1), 
	@v_varchar45      		varchar(45), 
	@v_varchar6       		varchar(6), 
    @v_expireWarn			tinyint, 
    @v_expireCritical		tinyint,
	@v_displaydecisionsonly	char(1),
	@v_displaypending990s	char(1),
	@v_displayoverrides		varchar(60),
	@v_includecompleted		varchar(6),
  	@ud_column1				char(1), --PTS 51911 SGB
	@ud_column2				char(1),  --PTS 51911 SGB
	@ud_column3				char(1), --PTS 51911 SGB
	@ud_column4				char(1),  --PTS 51911 SGB
	@procname				varchar(255), --PTS 51911 SGB
	@udheader				varchar(30) --PTS 51911 SGB
	
Declare @ttbl1 Table (
	lgh_number				int				NULL,
	o_cmpid					varchar(12)		NULL,
	o_cmpname				varchar(100)	NULL,--62998
	o_ctyname				varchar(30)		NULL, --62998
	d_cmpid					varchar(12)		NULL,
	d_cmpname				varchar(100)	NULL,--62998
	d_ctyname				varchar(30)		NULL, --62998
	f_cmpid					varchar(8)		NULL,
	f_cmpname				varchar(100)	NULL,--62998
	f_ctyname				varchar(25)		NULL,
	l_cmpid					varchar(8)		NULL,
	l_cmpname				varchar(100)	NULL,--62998
	l_ctyname				varchar(25)		NULL,
	lgh_startdate			datetime		NULL,
	lgh_enddate				datetime		NULL,
	o_state					varchar(6)		NULL,
	d_state					varchar(6)		NULL,
	lgh_schdtearliest		datetime		NULL,
	lgh_schdtlatest			datetime		NULL,
	cmd_code				varchar(8)		NULL,
	cmd_description			varchar(60)		NULL,	
	cmd_count				int				NULL,
	ord_hdrnumber			int				NULL,
	driver1_name			varchar(85)		NULL,
	driver2_name			varchar(85)		NULL,
	tractor					varchar(8)		NULL,
	primary_trailer			varchar(13)		NULL,
	trl_type1				varchar(6)		NULL,
	carrier_id				varchar(8)		NULL,
	mov_number				int				NULL,
	ord_availabledate		datetime		NULL,
	ord_stopcount			int				NULL,
	ord_totalcharge			money			NULL,
	ord_totalweight			decimal(15,2)	NULL,
	ord_length				decimal(8,2)	NULL,
	ord_width				decimal(8,2)	NULL,
	ord_height				decimal(8,2)	NULL,
	ord_totalmiles			decimal(8,1)	NULL,
	ord_number				char(12)		NULL,
	o_city					int				NULL,
	d_city					int				NULL,
	[priority]				varchar(6)		NULL,
	[status]				varchar(20)		NULL,
	lgh_instatus			varchar(20)		NULL,
	priority_name			varchar(20)		NULL,
	subcompany_name			varchar(20)		NULL,
	trl_type1_name			varchar(20)		NULL,
	revtype1				varchar(20)		NULL,
	revtype2				varchar(20)		NULL,
	revtype3				varchar(20)		NULL,
	revtype4				varchar(20)		NULL,
	subcompany_label		varchar(20)		NULL,
	trltype1_label			varchar(20)		NULL,
	revtype1_label			varchar(20)		NULL,
	revtype2_label			varchar(20)		NULL,
	revtype3_label			varchar(20)		NULL,
	revtype4_label			varchar(20)		NULL,
	ord_bookedby			char(20)		NULL,
	dw_rowstatus			char(10)		NULL,
	lgh_primary_pup			varchar(13)		NULL,
	triptime				int				NULL,
	ord_totalweightunits	varchar(6)		NULL,
	ord_lengthunit			varchar(6)		NULL,
	ord_widthunit			varchar(6)		NULL,
	ord_heightunit			varchar(6)		NULL,
	loadtime				int				NULL,
	unloadtime				int				NULL,
	unloaddttm				datetime		NULL,
	unloaddttm_early		datetime		NULL,
	unloaddttm_late			datetime		NULL,
	ord_totalvolume			decimal(12,4)	NULL,
	ord_totalvolumeunits	varchar(6)		NULL,
	washstatus				char(1)			NULL,
	f_state					varchar(6)		NULL,
	l_state					varchar(6)		NULL,
	evt_driver1_id			varchar(8)		NULL,
	evt_driver2_id			varchar(8)		NULL,
	ref_type				varchar(6)		NULL,
	ref_number				varchar(100)	NULL,
	d_address1				varchar(100)	NULL, --62998
	d_address2				varchar(100)	NULL, --62998
	ord_remark				varchar(256)	NULL,
	mpp_teamleader			varchar(20)		NULL,
	lgh_dsp_date			datetime		NULL,
	lgh_geo_date			datetime		NULL,
	ordercount				int				NULL,
	npup_cmpid				varchar(8)		NULL,
	npup_cmpname			varchar(100)	NULL, --62998
	npup_ctyname			varchar(30)		NULL,
	npup_state				varchar(6)		NULL,
	npup_arrivaldate		datetime		NULL,
	ndrp_cmpid				varchar(8)		NULL,
	ndrp_cmpname			varchar(100)	NULL, --62998
	ndrp_ctyname			varchar(30)		NULL,
	ndrp_state				varchar(6)		NULL,
	ndrp_arrivaldate		datetime		NULL,
	can_ld_expires			datetime		NULL,
	xdock					int				NULL,
	feetavailable			decimal(12,2)	NULL,
	opt_trc_type4			varchar(6)		NULL,
	opt_trc_type4_label		varchar(20)		NULL,
	opt_trl_type4			varchar(6)		NULL,
	opt_trl_type4_label		varchar(20)		NULL,
	o_region1				varchar(6)		NULL,
	o_region2				varchar(6)		NULL,
	o_region3				varchar(6)		NULL,
	o_region4				varchar(6)		NULL,
	d_region1				varchar(6)		NULL,
	d_region2				varchar(6)		NULL,
	d_region3				varchar(6)		NULL,
	d_region4				varchar(6)		NULL,
	nextpupdeparturedate	datetime		NULL,
	nextdrpdeparturedate	datetime		NULL,
	ord_fromorder			varchar(12)		NULL,
	lghtype1_name			varchar(20)		NULL,
	lgh_type1_label			varchar(20)		NULL,
	lghtype2_name			varchar(20)		NULL,
	lgh_type2_label			varchar(20)		NULL,
	tm_status				varchar(6)		NULL,
	tour_number				int				NULL,
	extrainfo1				varchar(255)	NULL,
	extrainfo2				varchar(255)	NULL,
	extrainfo3				varchar(255)	NULL,
	extrainfo4				varchar(255)	NULL,
	extrainfo5				varchar(255)	NULL,
	extrainfo6				varchar(255)	NULL,
	extrainfo7				varchar(255)	NULL,
	extrainfo8				varchar(255)	NULL,
	extrainfo9				varchar(255)	NULL,
	extrainfo10				varchar(255)	NULL,
	extrainfo11				varchar(255)	NULL,
	extrainfo12				varchar(255)	NULL,
	extrainfo13				varchar(255)	NULL,
	extrainfo14				varchar(255)	NULL,
	extrainfo15				varchar(255)	NULL,
	o_cmp_geoloc			varchar(50)		NULL,
	d_cmp_geoloc			varchar(50)		NULL,
	mppfleet				varchar(6)		NULL,
	mppfleet_name			varchar(20)		NULL,
	next_stp_event_code		varchar(6)		NULL,
	next_stop_of_total		varchar(6)		NULL,
	lgh_comment				varchar(256)	NULL,
	lgh_earliest_pu			datetime		NULL,
	lgh_latest_pu			datetime		NULL,
	lgh_earliest_unl		datetime		NULL,
	lgh_latest_unl			datetime		NULL,
	lgh_miles				decimal(8,1)	NULL,
	linehaul				money			NULL,
	latedate				datetime		NULL,
	lgh_ord_charge			money			NULL,
	lgh_act_weight			decimal(15, 4)	NULL,
	lgh_est_weight			decimal(15, 4)	NULL,
	lgh_tot_weight			decimal(15, 4)	NULL,
	outstatus				varchar(6)		NULL,
	maxweightexceeded		char(1)			NULL,
	lghreftype				varchar(20)		NULL,
	lghrefnumber			varchar(100)	NULL, --62998
	trctype1				varchar(20)		NULL,
	trc_type1name			varchar(20)		NULL,
	trctype2				varchar(20)		NULL,
	trctype2name			varchar(20)		NULL,
	trctype3				varchar(20)		NULL,
	trctype3name			varchar(20)		NULL,
	trctype4				varchar(20)		NULL,
	trctype4name			varchar(20)		NULL,
	etaalert1				char(1)			NULL,
	detstatus				int				NULL,
	tmstatusname			varchar(20)		NULL,
	ord_billto				varchar(8)		NULL,
	cmp_name				varchar(100)	NULL,
	lgh_carrier				varchar(64)		NULL,
	TotalCarrierPay			money			NULL,
	hzdcmdclass				varchar(8)		NULL,
	washplan				varchar(20)		NULL,
	fgt_length				decimal(8, 2)	NULL,
	fgt_width				decimal(8, 2)	NULL,
	fgt_height				decimal(8, 2)	NULL,
	o_zip					varchar(10)		NULL,
	d_zip					varchar(10)		NULL,
	ord_company				varchar(12)		NULL,
	origin_servicezone		varchar(20)		NULL,
	o_servicezone_t			varchar(20)		NULL,
	origin_servicearea		varchar(20)		NULL,
	o_servicearea_t			varchar(20)		NULL,
	origin_servicecenter	varchar(20)		NULL,
	o_servicecenter_t		varchar(20)		NULL,
	origin_serviceregion	varchar(20)		NULL,
	o_serviceregion_t		varchar(20)		NULL,
	dest_servicezone		varchar(20)		NULL,
	dest_servicezone_t		varchar(20)		NULL,
	dest_servicearea		varchar(20)		NULL,
	dest_servicearea_t		varchar(20)		NULL,
	dest_servicecenter		varchar(20)		NULL,
	dest_servicecenter_t	varchar(20)		NULL,
	dest_serviceregion		varchar(20)		NULL,
	dest_serviceregion_t	varchar(20)		NULL,
	lgh_204status			varchar(30)		NULL,
	origin_cmp_lat			decimal(12,4)	NULL,
	origin_cmp_long			decimal(12,4)	NULL,
	origin_cty_lat			decimal(12,4)	NULL,
	origin_cty_long			decimal(12,4)	NULL,
	lgh_route				varchar(15)		NULL,
	lgh_booked_revtype1		varchar(12)		NULL,
	ord_edipurpose			varchar(1)		NULL,
	ord_ediuseraction		varchar(1)		NULL,
	ord_edistate			int				NULL,
	esc_useractionrequired	char(1)			NULL,
	expireswarn				int				NULL,
	expirescritical			int				NULL,
	ord_editradingpartner	varchar(20)		NULL,
	ord_edideclinereason	varchar(30)		NULL,	
	tpm_RequireReason		int				NULL,
	tpm_AllowReasonEditing	int				NULL,
	tpm_AllowReasonFreeForm	int				NULL,
	tpm_DefaultReason		varchar(30)		NULL,
	ord_bookdate			datetime		NULL,
	ord_order_source		varchar(6)		NULL,		/* 08/19/2010 MDH PTS 52714: Added */
	lh_lgh_priority			varchar(6)		NULL,		
	ord_revtype1			varchar(6)		NULL,		
	ord_revtype2			varchar(6)		NULL,		
	ord_revtype3			varchar(6)		NULL,		
	ord_revtype4			varchar(6)		NULL,		
	ud_column1				varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column1_t 			varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column2				varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column2_t 			varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column3				varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column3_t 			varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column4				varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column4_t 			varchar(30),		 --	PTS 51911 SGB User Defined column header
    ord_invoicestatus       varchar(6)      NULL,
    pd_paydetailcount       int             NULL
)	



DECLARE
	@v_trctype1			varchar(20),
	@v_trctype2			varchar(20),
	@v_trctype3			varchar(20),
	@v_trctype4			varchar(20),
	@v_lghtype1_label	varchar(20),
	@v_lghtype2_label	varchar(20),
	@v_trltype1_label	varchar(20),
	@v_revtype1_label	varchar(20),
	@v_revtype2_label	varchar(20),
	@v_revtype3_label	varchar(20),
	@v_revtype4_label	varchar(20)

SELECT	@v_trctype1 =		trctype1,
		@v_trctype2 =		trctype2,
		@v_trctype3 =		trctype3,
		@v_trctype4 =		trctype4,
		@v_lghtype1_label = lghtype1,
		@v_lghtype2_label = lghtype2,
		@v_trltype1_label = trltype1,
		@v_revtype1_label = revtype1,
		@v_revtype2_label = revtype2,
		@v_revtype3_label = revtype3,
		@v_revtype4_label = revtype4
  FROM	labelfile_headers

SELECT	@v_expireWarn =		gi_integer1, 
       	@v_expireCritical = gi_integer2 
  FROM	generalinfo 
 WHERE	gi_name = 'LTSLExpires'

SELECT  @v_displaydecisionsonly = isnull(gi_string1,'N'),
	@v_displaypending990s = isnull(gi_string2,'N'),
	@v_displayoverrides = ',' + isnull(gi_string3,'') + ','
  FROM  generalinfo
 WHERE  gi_name = 'LTSLWrkshtOverrides'
 
IF @v_expireWarn IS NULL 
   SET @v_expireWarn = 60
IF @v_expireCritical IS NULL 
   SET @v_expireCritical = 30

--FMM PTS 36627 begin
IF @v_displaydecisionsonly = 'Y'
   SET @v_includecompleted = 'CMP'
ELSE
   SET @v_includecompleted = 'XXX'
--FMM PTS 36627 end

-- default max hours back
IF @p_hoursBack = 0
   SELECT @p_hoursBack= 1000000
-- compute date relative to max hours back
SELECT @v_hoursBackDate = DATEADD(hour, -@p_hoursBack, GETDATE())
-- default max hours out
IF @p_hoursOut = 0
   SELECT @p_hoursOut = 1000000
-- compute date relative to max hours out
SELECT @v_hoursOutDate = DATEADD(hour,  @p_hoursOut, GETDATE())
-- RE - 10/15/02 - PTS #15024
SELECT @v_lateWarnMode = gi_string1 FROM generalinfo WHERE gi_name = 'PlnWrkshtLateWarnMode'
-- PTS 25895 JLB need to add the ability to determine where extrainfo comes from
SELECT @v_extraInfoLocation = UPPER(ISNULL(gi_string1, 'ORDERHEADER'))
  FROM generalinfo
 WHERE gi_name = 'PWExtraInfoLocation'
-- PTS 23162 CGK 9/1/2004
IF @p_HzdCmdClasses IS NULL OR @p_HzdCmdClasses = ''
   SELECT @p_HzdCmdClasses = 'UNK'
-- default booked revtype variable to an empty string
IF @p_bookedRevtype IS NULL OR @p_bookedRevtype = ''
   SELECT @p_bookedRevtype = 'UNK'
-- default booked by variable to ALL
IF @p_bookedBy = '' OR @p_bookedBy IS NULL
   SELECT @p_bookedBy = 'ALL'
-- default status variable to an empty string
IF @p_status IS NULL
   SELECT @p_status = ''
-- default minimum miles variable
IF @p_milesMin = 0
   SELECT @p_milesMin = -1000
-- default origin city variable to 0
IF @p_oCity IS NULL
   SELECT @p_oCity = 0
-- default origin state variable to an empty string
IF @p_oStates IS NULL
   SELECT @p_oStates = ''
-- default origin region 1 variable to UNK
IF @p_oReg1 IS NULL OR @p_oReg1 = ''
   SELECT @p_oReg1 = 'UNK'
-- default origin region 2 variable to UNK
IF @p_oReg2 IS NULL OR @p_oReg2 = ''
   SELECT @p_oReg2 = 'UNK'
-- default origin region 3 variable to UNK
IF @p_oReg3 IS NULL OR @p_oReg3 = ''
   SELECT @p_oReg3 = 'UNK'
-- default origin region 4 variable to UNK
IF @p_oReg4 IS NULL OR @p_oReg4 = ''
   SELECT @p_oReg4 = 'UNK'
-- default destination city variable to 0
IF @p_dCity IS NULL
   SELECT @p_dCity = 0
-- default destination state variable to an empty string
IF @p_dStates IS NULL
   SELECT @p_dStates = ''
-- default origin region 1 variable to UNK
IF @p_dReg1 IS NULL OR @p_dReg1 = ''
   SELECT @p_dReg1 = 'UNK'
-- default origin region 2 variable to UNK
IF @p_dReg2 IS NULL OR @p_dReg2 = ''
   SELECT @p_dReg2 = 'UNK'
-- default origin region 3 variable to UNK
IF @p_dReg3 IS NULL OR @p_dReg3 = ''
   SELECT @p_dReg3 = 'UNK'
-- default origin region 4 variable to UNK
IF @p_dReg4 IS NULL OR @p_dReg4 = ''
   SELECT @p_dReg4 = 'UNK'
-- wrap all the following variable with ,..., in order to make sure the CHARINDEX function returns an exact match
SELECT @p_revType1 = ',' + LTRIM(RTRIM(ISNULL(@p_revType1, ''))) + ',' 
SELECT @p_revType2 = ',' + LTRIM(RTRIM(ISNULL(@p_revType2, '')))  + ',' 
SELECT @p_revType3 = ',' + LTRIM(RTRIM(ISNULL(@p_revType3, '')))  + ',' 
SELECT @p_revType4 = ',' + LTRIM(RTRIM(ISNULL(@p_revType4, '')))  + ',' 
SELECT @p_trltype1 = ',' + LTRIM(RTRIM(ISNULL(@p_trltype1, '')))  + ',' 
SELECT @p_bookedRevtype = ',' + LTRIM(RTRIM(ISNULL(@p_bookedRevtype, '')))  + ',' 
SELECT @p_bookedBy = ',' + LTRIM(RTRIM(ISNULL(@p_bookedBy, ''))) + ',' 
SELECT @p_billTo = ',' + LTRIM(RTRIM(ISNULL(@p_billTo, '')))  + ',' 
SELECT @p_route = ',' + LTRIM(RTRIM(ISNULL(@p_route, '')))  + ',' 
SELECT @p_teamLeader = ',' + LTRIM(RTRIM(ISNULL(@p_teamLeader, '')))  + ',' 
SELECT @p_company = ',' + LTRIM(RTRIM(ISNULL(@p_company, '')))  + ',' 
SELECT @p_oCmpIds = ',' + LTRIM(RTRIM(ISNULL(@p_oCmpIds, '')))  + ',' 
SELECT @p_oReg1 = ',' + LTRIM(RTRIM(ISNULL(@p_oReg1, '')))  + ',' 
SELECT @p_oReg2 = ',' + LTRIM(RTRIM(ISNULL(@p_oReg2, '')))  + ',' 
SELECT @p_oReg3 = ',' + LTRIM(RTRIM(ISNULL(@p_oReg3, '')))  + ',' 
SELECT @p_oReg4 = ',' + LTRIM(RTRIM(ISNULL(@p_oReg4, '')))  + ',' 
SELECT @p_dCmpIDs = ',' + LTRIM(RTRIM(ISNULL(@p_dCmpIDs, '')))  + ',' 
SELECT @p_dReg1 = ',' + LTRIM(RTRIM(ISNULL(@p_dReg1, '')))  + ',' 
SELECT @p_dReg2 = ',' + LTRIM(RTRIM(ISNULL(@p_dReg2, '')))  + ',' 
SELECT @p_dReg3 = ',' + LTRIM(RTRIM(ISNULL(@p_dReg3, '')))  + ',' 
SELECT @p_dReg4 = ',' + LTRIM(RTRIM(ISNULL(@p_dReg4, '')))  + ',' 
SELECT @p_tmStatus = ',' + LTRIM(RTRIM(ISNULL(@p_tmStatus, '')))  + ',' 
SELECT @p_lghType1 = ',' + LTRIM(RTRIM(ISNULL(@p_lghType1, '')))  + ',' 
SELECT @p_lghType2 = ',' + LTRIM(RTRIM(ISNULL(@p_lghType2, '')))  + ',' 
SELECT @p_HzdCmdClasses = ',' + LTRIM(RTRIM(ISNULL(@p_HzdCmdClasses, '')))  + ',' 
SELECT @p_orderedby = ',' + LTRIM(RTRIM(ISNULL(@p_orderedby, ''))) + ','  --FMM PTS 42878

--was missing
SELECT @p_status = ',' + LTRIM(RTRIM(ISNULL(@p_status, ''))) + ',' 

DECLARE @pseudolegheaders TABLE
	(leghdr int NOT NULL, ordhdr int NOT NULL primary key)  --FMM PTS 35327 changes leghdr from NOT NULL to NULL
	
Declare @sql nvarchar(max)-- PTS 62998 per Mindy Curnutt	

SET @sql = N'SELECT s.lgh_number, oh.ord_hdrnumber FROM orderheader oh WITH (NOLOCK) INNER JOIN manpowerprofile mpp1 with (nolock) ON oh.ord_driver1 = mpp1.mpp_id '
SET @sql = @sql + N'LEFT OUTER JOIN edi_orderstate edi  with (nolock) ON oh.ord_edistate = edi.esc_code LEFT OUTER JOIN edi_trading_partner_master tpm  with (nolock) '
SET @sql = @sql + N'ON oh.ord_editradingpartner = tpm.tpm_TradingPartnerID '
SET @sql = @sql + N'INNER JOIN stops s on oh.ord_hdrnumber = s.ord_hdrnumber '
SET @sql = @sql + N'LEFT JOIN dx_xref on dx_trpid = oh.ord_editradingpartner and dx_entitytype = ''TPSettings'' and dx_entityname = ''NoMaritimeQueProcessing'' '
SET @sql = @sql + N'LEFT JOIN dx_lookup dlm on dlm.dx_lookuptable = ''LtslSettings'' and dlm.dx_lookuprawdatavalue = ''MaritimeValidation'' '
SET @sql = @sql + N'LEFT JOIN dx_lookup dlu on dlu.dx_lookuptable = ''LtslSettings'' and dlu.dx_lookuprawdatavalue = ''UpdateValidation'' '
SET @sql = @sql + N'WHERE s.stp_sequence = 1 AND ord_order_source = ''EDI'' AND s.lgh_number is NOT NULL AND '
SET @sql = @sql + N'ord_status IN (''PND'', ''AVL'', ''DSP'', ''PLN'', ''STD'', ''MPN'', ''CAN'', ''' + @v_includecompleted + ''') '
SET @sql = @sql + N' AND ord_startdate >= ''' + convert(varchar(20),@v_hoursBackDate) + ''' AND ord_startdate <= ''' + convert(varchar(20),@v_hoursOutDate) + ''' ' 
SET @sql = @sql + N' AND ord_totalmiles BETWEEN ' + convert(varchar(10),@p_milesMin) + ' AND ' +  convert(varchar(10),@p_milesMax) + ' '
SET @sql = @sql + N' AND oh.ord_hdrnumber not in (select dx_orderhdrnumber from dx_archive_header (nolock) where dx_processed = ''RESERV'') '

If @p_oCity <> 0
SET @sql = @sql + N'AND ord_origincity = ' + convert(varchar(10),@p_oCity) + ' '

If @p_dCity <> 0
SET @sql = @sql + N'AND ord_destcity = ' + convert(varchar(10),@p_dCity) + ' '

If @p_oReg1 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_originregion1 + '','', ''' + @p_oReg1 + ''') > 0 '

If @p_billTo <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_billto + '','', ''' + @p_billTo + ''') > 0 ' 

If @p_bookedBy <> ',ALL,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_bookedby + '','', ''' + @p_bookedBy + ''') > 0 ' 

If @p_oReg1 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_originregion1 + '','', ''' + @p_oReg1 + ''') > 0 ' 

If @p_oReg2 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_originregion2 + '','', ''' + @p_oReg2 + ''') > 0 ' 

If @p_oReg3 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_originregion3 + '','', ''' + @p_oReg3 + ''') > 0 ' 

If @p_oReg4 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_originregion4 + '','', ''' + @p_oReg4 + ''') > 0 ' 

If @p_dReg1 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_destregion1 + '','', ''' + @p_dReg1 + ''') > 0 ' 

If @p_dReg2 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_destregion2 + '','', ''' + @p_dReg2 + ''') > 0 ' 

If @p_dReg3 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_destregion3 + '','', ''' + @p_dReg3 + ''') > 0 ' 

If @p_dReg4 <> ',UNK,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_destregion4 + '','', ''' + @p_dReg4 + ''') > 0 ' 

If @p_revType1 <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_revtype1 + '','', ''' + @p_revType1 + ''') > 0 ' 

If @p_revType2 <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_revtype2 + '','', ''' + @p_revType2 + ''') > 0 ' 

If @p_revType3 <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_revtype3 + '','', ''' + @p_revType3 + ''') > 0 ' 

If @p_revType4 <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_revtype4 + '','', ''' + @p_revType4 + ''') > 0 ' 

If @p_oCmpIds <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_originpoint + '','', ''' + @p_oCmpIds + ''') > 0 ' 

If @p_dCmpIDs <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_destpoint + '','', ''' + @p_dCmpIDs + ''') > 0 ' 

If @p_status <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + RTRIM(ord_status) + '','', ''' + @p_status + ''') > 0 ' 

If @p_oStates <> ''
SET @sql = @sql + N'AND CHARINDEX('','' + RTRIM(ISNULL(ord_originstate,'''')) + '','', ''' + @p_oStates + ''') > 0 ' 

If @p_dStates <> ''
SET @sql = @sql + N'AND CHARINDEX('','' + RTRIM(ISNULL(ord_deststate,'''')) + '','', ''' + @p_dStates + ''') > 0 ' 

If @p_company <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_subcompany + '','', ''' + @p_company + ''') > 0 ' 

If @p_trltype1 <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + trl_type1 + '','', ''' + @p_trltype1 + ''') > 0 ' 

If @p_orderedby <> ',,'
SET @sql = @sql + N'AND CHARINDEX('','' + ord_company + '','', ''' + @p_orderedby + ''') > 0 ' 

If @p_route <> ',,'
SET @sql = @sql + N'AND (CHARINDEX('','' + ord_route + '','', ''' + @p_route + ''') > 0  OR ord_route is null) ' 

If @p_bookedRevtype <> ',UNK,'
SET @sql = @sql + N'AND (CHARINDEX('','' + ord_booked_revtype1 + '','', ''' + @p_bookedRevtype + ''') > 0  OR ord_booked_revtype1 is null) ' 

If @p_teamleader <> ',,'
SET @sql = @sql + N'AND (CHARINDEX('','' + mpp1.mpp_teamleader + '','', ''' + @p_teamleader + ''') > 0  OR oh.ord_driver1 = ''UNKNOWN'') ' 

	If @v_displaydecisionsonly = 'Y' 
	BEGIN
		set @sql = @sql + N'AND ('

		If @v_displaydecisionsonly = 'Y'
			BEGIN
			set @sql = @sql + N'ISNULL(edi.esc_useractionrequired,''N'') = ''Y'' and ((dlu.dx_lookuptranslatedvalue <> ''1'' and (dlm.dx_lookuptranslatedvalue <> ''1'' or IsNull(dx_xref.dx_xrefkey, 0) = 1) Or ISNULL(ord_edistate,0) not in (40,41,42,43,45))) ' 
				If @v_displaypending990s = 'Y' or @v_displayoverrides <> ',,'
					set @sql = @sql + N'OR '
			END
		if @v_displayoverrides <> ',,'
			begin
				set @sql = @sql + N'CHARINDEX(CONVERT(varchar,ISNULL(ord_edistate,0)), ''' + @v_displayoverrides + ''') > 0  '
				If @v_displaypending990s = 'Y' 
					set @sql = @sql + N'OR '
			end
		If @v_displaypending990s = 'Y'
		begin
		set @sql = @sql + N'(ISNULL(ord_edistate,0) = 20 AND ISNULL(tpm.tpm_990DeclineRequired,0) = 1) '
		set @sql = @sql + N'OR (ISNULL(ord_edistate,0) = 30 AND ISNULL(tpm.tpm_990DeclineRequired,0) = 1) '
		end

		set @sql = @sql + N')'
	END
	set @sql = @sql + ' group by s.lgh_number, oh.ord_hdrnumber'
INSERT INTO @pseudolegheaders (leghdr, ordhdr)  
EXEC sp_executesql @sql;

--print @sql
--return

-- END PTS 62998 per Mindy Curnutt

--Remove records that should not be seen due to Row Security
DECLARE @rowsecurity char(1)

SELECT	@rowsecurity = UPPER(LEFT(gi_string1,1)) 
FROM	generalinfo 
WHERE	gi_name = 'RowSecurity'

IF ISNULL(@rowsecurity,'') = 'Y' BEGIN
		DELETE	@pseudolegheaders
		FROM	@pseudolegheaders edi inner join orderheader ord with (NOLOCK) on edi.ordhdr = ord.ord_hdrnumber
		WHERE	NOT EXISTS	(	SELECT	*  
								FROM	RowRestrictValidAssignments_orderheader_fn() rsva 
								WHERE	ord.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
							)
END

--PTS 51911 SGB
Insert Into @ttbl1
SELECT lgh_number = p.leghdr, 
       o_cmpid = oh.ord_originpoint,
       o_cmpname = ocomp.cmp_name,
       o_ctyname = octy.cty_nmstct, 
       d_cmpid = oh.ord_destpoint, 
       d_cmpname = dcomp.cmp_name, 
       d_ctyname = dcty.cty_nmstct, 
       f_cmpid = oh.ord_shipper, 
       f_cmpname = fcomp.cmp_name, 
       f_ctyname = fcty.cty_name, 
       l_cmpid = oh.ord_consignee, 
       l_cmpname = lcomp.cmp_name, 
       l_ctyname = lcty.cty_name, 
       startdate = oh.ord_startdate, 
       enddate = oh.ord_completiondate, 
       o_state = octy.cty_state, 
       d_state = dcty.cty_state, 
       schdtearliest = oh.ord_origin_earliestdate, 
       schdtlatest = oh.ord_origin_latestdate, 
       oh.cmd_code, 
       cmd_description = convert(varchar(60), oh.ord_description), 
       cmd_count = (SELECT COUNT(DISTINCT cmd_code) FROM stops with (nolock) WHERE stops.ord_hdrnumber = oh.ord_hdrnumber AND stops.cmd_code <> 'UNK'), 
       oh.ord_hdrnumber, 
       driver1_name = convert(varchar(85), mpp1.mpp_lastfirst), 
       driver2_name = (SELECT convert(varchar(85), mpp_lastfirst) FROM manpowerprofile  with (NOLOCK) WHERE mpp_id = oh.ord_driver2), 
       tractor = oh.ord_tractor, 
       primary_trailer = oh.ord_trailer, 
       trl_type1 = oh.trl_type1, 
       carrier_id = ISNULL(oh.ord_carrier, 'UNKNOWN'),
       oh.mov_number, 
       oh.ord_availabledate, 
       ord_stopcount = convert(int, oh.ord_stopcount), 
       ord_totalcharge = convert(money, oh.ord_totalcharge), 
       ord_totalweight = convert(decimal(15, 2), oh.ord_totalweight), 
       ord_length = convert(decimal(8, 2), oh.ord_length), 
       ord_width = convert(decimal(8, 2), oh.ord_width), 
       ord_height = convert(decimal(8, 2), oh.ord_height), 
       ord_totalmiles = convert(decimal(8, 1), oh.ord_totalmiles), 
       oh.ord_number, 
       o_city = oh.ord_origincity, 
       d_city = oh.ord_destcity, 
       priority = oh.ord_priority, 
       status = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'DispStatus' AND abbr = oh.ord_status), 
       lgh_instatus = convert(varchar(20), 'UNP'), 
       priority_name = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'OrderPriority' AND abbr = oh.ord_priority), 
       subcompany_name = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'Company' AND abbr = oh.ord_subcompany), 
       trltype1_name = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'TrlType1' AND abbr = oh.trl_type1), 
       revtype1 = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'RevType1' AND abbr = oh.ord_revtype1), 
       revtype2 = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'RevType2' AND abbr = oh.ord_revtype2), 
       revtype3 = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'RevType3' AND abbr = oh.ord_revtype3), 
       revtype4 = (SELECT [name] FROM labelfile  with (NOLOCK) WHERE labeldefinition = 'RevType4' AND abbr = oh.ord_revtype4), 
       subcompany_label = convert(varchar(20), null), 
       trltype1_label = @v_trltype1_label,
       revtype1_label = @v_revtype1_label, 
       revtype2_label = @v_revtype2_label,
       revtype3_label = @v_revtype3_label, 
       revtype4_label = @v_revtype4_label, 
       ord_bookedby = convert(varchar(20), oh.ord_bookedby), 
       dw_rowstatus = @v_char10, 
       lgh_primary_pup = oh.ord_trailer2, 
       triptime = convert(int, ISNULL(oh.ord_loadtime,0) + ISNULL(oh.ord_unloadtime,0) + ISNULL(oh.ord_drivetime,0)), 
       oh.ord_totalweightunits, 
       oh.ord_lengthunit, 
       oh.ord_widthunit, 
       oh.ord_heightunit, 
       loadtime = convert(int, oh.ord_loadtime), 
       unloadtime = convert(int, oh.ord_unloadtime), 
       unloaddttm = oh.ord_completiondate, 
       unloaddttm_early = oh.ord_dest_earliestdate, 
       unloaddttm_late = oh.ord_dest_latestdate, 
       ord_totalvolume = convert(decimal(12, 4), oh.ord_totalvolume), 
       oh.ord_totalvolumeunits, 
       washstatus = convert(char(1), 'N'), 
       f_state = fcty.cty_state, 
       l_state = lcty.cty_state, 
       driver1_id = oh.ord_driver1, 
       driver2_id = oh.ord_driver2, 
       reftype = oh.ord_reftype, 
       refnumber = convert(varchar(100), oh.ord_refnum), 
       d_address1 = dcomp.cmp_address1, 
       d_address2 = dcomp.cmp_address2, 
       ord_remark = convert(varchar(256), oh.ord_remark), 
       teamleader = convert(varchar(20), mpp1.mpp_teamleader), 
       lh.lgh_dsp_date,
       lh.lgh_geo_date, 
       ordercount = convert(int, 1), 
       nextpupcmpid = oh.ord_shipper, 
       nextpupcmpname = fcomp.cmp_name, 
       nextpupctyname = convert(varchar(30), fcty.cty_name), 
       nextpupstate = fcty.cty_state, 
       nextpuparrivaldate = oh.ord_startdate, 
       nextdrpcmpid = oh.ord_consignee,
       nextdrpcmpname = lcomp.cmp_name, 
       nextdrpctyname = convert(varchar(30), lcty.cty_name), 
       nextdrpstate = lcty.cty_state, 
       nextdrparrivaldate = oh.ord_completiondate, 
       can_ld_expires = isnull(lh.can_ld_expires, '19000101'),
       xdock = convert(int, null), 
       feetavailable = convert(decimal(12, 2), lh.lgh_feetavailable), 
       oh.opt_trc_type4, 
       opt_trc_type4_label = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TrcType4' AND abbr = oh.opt_trc_type4), 
       oh.opt_trl_type4, 
       opt_trl_type4_label = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TrlType4' AND abbr = oh.opt_trl_type4), 
       o_region1 = oh.ord_originregion1, 
       o_region2 = oh.ord_originregion2, 
       o_region3 = oh.ord_originregion3, 
       o_region4 = oh.ord_originregion4, 
       d_region1 = oh.ord_destregion1, 
       d_region2 = oh.ord_destregion2, 
       d_region3 = oh.ord_destregion3, 
       d_region4 = oh.ord_destregion4, 
       nextpupdeparturedate = convert(datetime, null), 
       nextdrpdeparturedate = convert(datetime, null), 
       oh.ord_fromorder, 
       lghtype1_name = CASE lh.lgh_type1 WHEN null THEN convert(varchar(20), 'UNKNOWN') ELSE (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'LghType1' and abbr = lh.lgh_type1) END, 
       lghtype1_label = @v_lghtype1_label, 
       lghtype2_name = CASE lh.lgh_type2 WHEN null THEN convert(varchar(20), 'UNKNOWN') ELSE (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'LghType2' and abbr = lh.lgh_type2) END,
       lghtype2_label = @v_lghtype2_label, 
       tm_status = lh.lgh_tm_status,
       tour_number = lh.lgh_tour_number,
       extrainfo1 = oh.ord_extrainfo1, 
       extrainfo2 = oh.ord_extrainfo2, 
       extrainfo3 = oh.ord_extrainfo3, 
       extrainfo4 = oh.ord_extrainfo4, 
       extrainfo5 = oh.ord_extrainfo5, 
       extrainfo6 = oh.ord_extrainfo6, 
       extrainfo7 = oh.ord_extrainfo7, 
       extrainfo8 = oh.ord_extrainfo8, 
       extrainfo9 = oh.ord_extrainfo9, 
       extrainfo10 = oh.ord_extrainfo10, 
       extrainfo11 = oh.ord_extrainfo11, 
       extrainfo12 = oh.ord_extrainfo12, 
       extrainfo13 = oh.ord_extrainfo13, 
       extrainfo14 = oh.ord_extrainfo14, 
       extrainfo15 = oh.ord_extrainfo15, 
       o_cmp_geoloc = ocomp.cmp_geoloc, 
       d_cmp_geoloc = dcomp.cmp_geoloc, 
       mppfleet = mpp1.mpp_fleet, 
       mppfleet_name = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'Fleet' AND abbr = mpp1.mpp_fleet), 
       nextstpeventcode = convert(varchar(6), null),
       nextstopoftotal = convert(varchar(6), null), 
       comment = convert(varchar(256), lh.lgh_comment), 
       earliest_pu = convert(datetime, null), 
       latest_pu = convert(datetime, null), 
       earliest_unl = convert(datetime, null), 
       latest_unl = convert(datetime, null), 
       lgh_miles = convert(decimal(8, 1), ISNULL(lh.lgh_miles, oh.ord_totalmiles)),
       linehaul = convert(money, lh.lgh_linehaul),
       latedate = ISNULL((SELECT exp_expirationdate FROM expiration  with (nolock) WHERE exp_idtype = 'ORD' AND exp_id = oh.ord_number AND exp_completed = 'N'), '20491231 23:59'),
       lgh_ord_charge = convert(money, oh.ord_charge),
       act_weight = convert(decimal(15, 4), lh.lgh_act_weight),
       est_weight = convert(decimal(15, 4), lh.lgh_est_weight),
       tot_weight = convert(decimal(15, 4), oh.ord_totalweight), 
       outstatus = oh.ord_status, 
       maxweightexceeded = convert(char(1), lh.lgh_max_weight_exceeded),
       lghreftype = convert(varchar(20), lh.lgh_reftype),
       lghrefnumber = convert(varchar(100), lh.lgh_refnum),
       trctype1 = @v_trctype1, 
	   trctype1name = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TrcType1' AND abbr = trc.trc_type1), 
       trctype2 = @v_trctype2, 
       trctype2name = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TrcType2' AND abbr = trc.trc_type2), 
       trctype3 = @v_trctype3, 
       trctype3name = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TrcType3' AND abbr = trc.trc_type3), 
       trctype4 = @v_trctype4, 
       trctype4name = (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TrcType4' AND abbr = trc.trc_type4), 
       etaalert1 = convert(char(1), lh.lgh_etaalert1),
       detstatus = convert(tinyint, ISNULL(lh.lgh_detstatus, 0)), 
       tmstatusname = CASE lh.lgh_tm_status WHEN null THEN null ELSE (SELECT [name] FROM labelfile with (NOLOCK) WHERE labeldefinition = 'TotalMailStatus' AND abbr = lh.lgh_tm_status) END, 
       billto = oh.ord_billto, 
       billtoname = (SELECT cmp_name FROM company with (nolock) WHERE company.cmp_id = oh.ord_billto), 
       carrier_name = CASE oh.ord_carrier WHEN null THEN convert(varchar(100), 'UNKNOWN') ELSE (SELECT car_name FROM carrier WHERE carrier.car_id = oh.ord_carrier) END, 
       totalcarrierpay = convert(money, 0),
       hzdcmdclass = lh.lgh_hzd_cmd_class, 
       washplan = lh.lgh_washplan, 
	  fgt_length = convert(decimal(8,2),fdsizes.fgt_length),
	  fgt_width = convert(decimal(8,2),fdsizes.fgt_width),
	  fgt_height = convert(decimal(8,2),fdsizes.fgt_height),
       o_zip = ocomp.cmp_zip, 
       d_zip = dcomp.cmp_zip, 
       ord_company = convert(varchar(12), oh.ord_company), 
       o_servicezone = convert(varchar(20), 'UNKNOWN'), 
       o_servicezone_t = convert(varchar(20), 'ServiceZone'), 
       o_servicearea = convert(varchar(20), 'UNKNOWN'), 
       o_servicearea_t = convert(varchar(20), 'ServiceArea'), 
       o_servicecenter = convert(varchar(20), 'UNKNOWN'), 
       o_servicecenter_t = convert(varchar(20), 'ServiceCenter'), 
       o_serviceregion = convert(varchar(20), 'UNKNOWN'), 
       o_serviceregion_t = convert(varchar(20), 'ServiceRegion'), 
       d_servicezone = convert(varchar(20), 'UNKNOWN'), 
       d_servicezone_t = convert(varchar(20), 'ServiceZone'), 
       d_servicearea = convert(varchar(20), 'UNKNOWN'), 
       d_servicearea_t = convert(varchar(20), 'ServiceArea'), 
       d_servicecenter = convert(varchar(20), 'UNKNOWN'), 
       d_servicecenter_t = convert(varchar(20), 'ServiceCenter'), 
       d_serviceregion = convert(varchar(20), 'UNKNOWN'), 
       d_serviceregion_t = convert(varchar(20), 'ServiceRegion'), 
       status204 = convert(varchar(30), lh.lgh_204status), 
       o_cmp_lat = convert(decimal(12, 4), ROUND(ISNULL(ocomp.cmp_latseconds, 0.000)/3600.000, 4)), 
       o_cmp_long = convert(decimal(12, 4), ROUND(ISNULL(ocomp.cmp_longseconds, 0.000)/3600.000, 4)), 
       o_cty_lat = convert(decimal(12, 4), ROUND(ISNULL(octy.cty_latitude, 0.000), 4)), 
       o_cty_long = convert(decimal(12, 4), ROUND(ISNULL(octy.cty_longitude, 0.000), 4)), 
       route = oh.ord_route, 
       bookedrevtype = oh.ord_booked_revtype1, 
       ord_edipurpose = convert(char(1), oh.ord_edipurpose), 
       ord_ediuseraction = convert(char(1), oh.ord_ediuseraction), 
       oh.ord_edistate, 
       esc_useractionrequired = ISNULL((SELECT convert(char(1), esc_useractionrequired) FROM edi_orderstate with (NOLOCK) WHERE esc_code = oh.ord_edistate), convert(char(1), 'N')),
       expireswarn = @v_expireWarn, 
       expirescritical = @v_expireCritical,
       oh.ord_editradingpartner,  --FMM PTS 30821
       oh.ord_edideclinereason,  --FMM PTS 30821
       tpm_RequireReason = convert(int, isnull(tpm.tpm_990RequireReason, 0)),
       tpm_AllowReasonEditing = convert(int, isnull(tpm.tpm_990AllowReasonEditing, 0)),
       tpm_AllowReasonFreeForm = convert(int, isnull(tpm.tpm_990AllowReasonFreeForm, 0)),
       tpm_DefaultReason = case isnull(tpm.dx_990DefaultReason, '0') when '0' then convert(varchar(30), '') else convert(varchar(30), tpm.dx_990DefaultReason) end,
       oh.ord_bookdate,  --FMM PTS 36627
       oh.ord_order_source, 		/* 08/19/2010 MDH PTS 52714: Added */
       lh.lgh_priority,
       oh.ord_revtype1,
       oh.ord_revtype2,
       oh.ord_revtype3,
       oh.ord_revtype4
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column1' 	--	PTS 51911 SGB User Defined column header
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column2'		--	PTS 51911 SGB User Defined column header
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column3' 	--	PTS 51911 SGB User Defined column header
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column4',		--	PTS 51911 SGB User Defined column header       
       oh.ord_invoicestatus,
       pd_paydetailcount = (select count(*) from dbo.paydetail pd where pd.mov_number = oh.mov_number)
		FROM @pseudolegheaders p

		INNER JOIN orderheader oh with (NOLOCK)
		ON oh.ord_hdrnumber = p.ordhdr

		INNER JOIN company ocomp  with (nolock)	
		ON ocomp.cmp_id = oh.ord_originpoint

		INNER JOIN city octy  with (nolock)		 
		ON octy.cty_code = oh.ord_origincity

		INNER JOIN company dcomp  with (nolock)	
		ON dcomp.cmp_id = oh.ord_destpoint

		INNER JOIN city dcty  with (nolock) 		
		ON dcty.cty_code = oh.ord_destcity

		INNER JOIN company fcomp  with (nolock)
		ON fcomp.cmp_id = oh.ord_shipper

		INNER JOIN city fcty  with (nolock)		
		ON fcty.cty_code = fcomp.cmp_city

		INNER JOIN company lcomp  with (nolock)	
		ON lcomp.cmp_id = oh.ord_consignee

		INNER JOIN city lcty  with (nolock)		
		ON lcty.cty_code = lcomp.cmp_city

		INNER JOIN manpowerprofile mpp1  with (nolock)
		ON mpp1.mpp_id = oh.ord_driver1

		INNER JOIN tractorprofile trc  with (nolock)
		ON trc.trc_number = oh.ord_tractor

		LEFT OUTER JOIN edi_trading_partner_master tpm  with (nolock)
		ON tpm.tpm_TradingPartnerID = oh.ord_editradingpartner

		LEFT OUTER JOIN legheader lh  with (nolock)
		ON lh.lgh_number = p.leghdr
		left join 
		(
			   select s.ord_hdrnumber, max(fgt_length) as fgt_length, max(fgt_height) as fgt_height, max(fgt_width) as fgt_width
			   from stops s inner join freightdetail f on s.stp_number = f.stp_number
			   inner join @pseudolegheaders p2 on p2.ordhdr = s.ord_hdrnumber
			   group by s.ord_hdrnumber
		) as fdsizes on p.ordhdr = fdsizes.ord_hdrnumber

		 
		--PTS 51911 SGB Only run when setting turned on 
Select @ud_column1 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column2 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column3 = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column4 = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'

IF @ud_column1 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','HS',1)
			UPDATE @ttbl1
			set ud_column1 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'LS',1),
			ud_column1_t = @udheader
			from @ttbl1 t

		END
 
END 

IF @ud_column2 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','HE',2)
			UPDATE @ttbl1
			set ud_column2 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'LE',2),
			ud_column2_t = @udheader
			from @ttbl1 t

		END
 
END 

IF @ud_column3 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',3)
			UPDATE @ttbl1
			set ud_column3 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',3),
			ud_column3_t = @udheader
			from @ttbl1 t

		END
 
END 

IF @ud_column4 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',4)
			UPDATE @ttbl1
			set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',4),
			ud_column4_t = @udheader
			from @ttbl1 t

		END
 
END 

SELECT 
	lgh_number,
	o_cmpid,
	o_cmpname,
	o_ctyname,
	d_cmpid,
	d_cmpname,
	d_ctyname,
	f_cmpid,
	f_cmpname,
	f_ctyname,
	l_cmpid,
	l_cmpname,
	l_ctyname,
	lgh_startdate,
	lgh_enddate,
	o_state,
	d_state,
	lgh_schdtearliest,
	lgh_schdtlatest,
	cmd_code,
	cmd_description,
	cmd_count,
	ord_hdrnumber,
	driver1_name,
	driver2_name,
	tractor,
	primary_trailer,
	trl_type1,
	carrier_id,
	mov_number,
	ord_availabledate,
	ord_stopcount,
	ord_totalcharge,
	ord_totalweight,
	ord_length,
	ord_width,
	ord_height,
	ord_totalmiles,
	ord_number,
	o_city,
	d_city,
	[priority],
	[status],
	lgh_instatus,
	priority_name,
	subcompany_name,
	trl_type1_name,
	revtype1,
	revtype2,
	revtype3,
	revtype4,
	subcompany_label,
	trltype1_label,
	revtype1_label,
	revtype2_label,
	revtype3_label,
	revtype4_label,
	ord_bookedby,
	dw_rowstatus,
	lgh_primary_pup,
	triptime,
	ord_totalweightunits,
	ord_lengthunit,
	ord_widthunit,
	ord_heightunit,
	loadtime,
	unloadtime,
	unloaddttm,
	unloaddttm_early,
	unloaddttm_late,
	ord_totalvolume,
	ord_totalvolumeunits,
	washstatus,
	f_state,
	l_state,
	evt_driver1_id,
	evt_driver2_id,
	ref_type,
	ref_number,
	d_address1,
	d_address2,
	ord_remark,
	mpp_teamleader,
	lgh_dsp_date,
	lgh_geo_date,
	ordercount,
	npup_cmpid,
	npup_cmpname,
	npup_ctyname,
	npup_state,
	npup_arrivaldate,
	ndrp_cmpid,
	ndrp_cmpname,
	ndrp_ctyname,
	ndrp_state,
	ndrp_arrivaldate,
	can_ld_expires,
	xdock,
	feetavailable,
	opt_trc_type4,
	opt_trc_type4_label,
	opt_trl_type4,
	opt_trl_type4_label,
	o_region1,
	o_region2,
	o_region3,
	o_region4,
	d_region1,
	d_region2,
	d_region3,
	d_region4,
	nextpupdeparturedate,
	nextdrpdeparturedate,
	ord_fromorder,
	lghtype1_name,
	lgh_type1_label,
	lghtype2_name,
	lgh_type2_label,
	tm_status,
	tour_number,
	extrainfo1,
	extrainfo2,
	extrainfo3,
	extrainfo4,
	extrainfo5,
	extrainfo6,
	extrainfo7,
	extrainfo8,
	extrainfo9,
	extrainfo10,
	extrainfo11,
	extrainfo12,
	extrainfo13,
	extrainfo14,
	extrainfo15,
	o_cmp_geoloc,
	d_cmp_geoloc,
	mppfleet,
	mppfleet_name,
	next_stp_event_code,
	next_stop_of_total,
	lgh_comment,
	lgh_earliest_pu,
	lgh_latest_pu,
	lgh_earliest_unl,
	lgh_latest_unl,
	lgh_miles,
	linehaul,
	latedate,
	lgh_ord_charge,
	lgh_act_weight,
	lgh_est_weight,
	lgh_tot_weight,
	outstatus,
	maxweightexceeded,
	lghreftype,
	lghrefnumber,
	trctype1,
	trc_type1name,
	trctype2,
	trctype2name,
	trctype3,
	trctype3name,
	trctype4,
	trctype4name,
	etaalert1,
	detstatus,
	tmstatusname,
	ord_billto,
	cmp_name,
	lgh_carrier,
	TotalCarrierPay,
	hzdcmdclass,
	washplan,
	fgt_length,
	fgt_width,
	fgt_height,
	o_zip,
	d_zip,
	ord_company,
	origin_servicezone,
	o_servicezone_t,
	origin_servicearea,
	o_servicearea_t,
	origin_servicecenter,
	o_servicecenter_t,
	origin_serviceregion,
	o_serviceregion_t,
	dest_servicezone,
	dest_servicezone_t,
	dest_servicearea,
	dest_servicearea_t,
	dest_servicecenter,
	dest_servicecenter_t,
	dest_serviceregion,
	dest_serviceregion_t,
	lgh_204status,
	origin_cmp_lat,
	origin_cmp_long,
	origin_cty_lat,
	origin_cty_long,
	lgh_route,
	lgh_booked_revtype1,
	ord_edipurpose,
	ord_ediuseraction,
	ord_edistate,
	esc_useractionrequired,
	expireswarn,
	expirescritical,
	ord_editradingpartner,
	ord_edideclinereason,
	tpm_RequireReason,
	tpm_AllowReasonEditing,
	tpm_AllowReasonFreeForm,
	tpm_DefaultReason,
	ord_bookdate,
	ord_order_source,
	lh_lgh_priority,
	ord_revtype1,
	ord_revtype2,
	ord_revtype3,
	ord_revtype4,
	ud_column1,
	ud_column1_t,
	ud_column2,
	ud_column2_t,
	ud_column3,
	ud_column3_t,
	ud_column4,
	ud_column4_t,
    ord_invoicestatus,
    pd_paydetailcount
from @ttbl1

GO
GRANT EXECUTE ON  [dbo].[d_available_trips_ltsl_sp_dotnet] TO [public]
GO

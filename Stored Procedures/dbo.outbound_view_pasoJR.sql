SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[outbound_view_pasoJR]
	@revtype1	varchar (254),
	@revtype2	varchar (254),
	@revtype3	varchar (254),
	@revtype4	varchar (254),
	@trltype1	varchar (254),
	@company	varchar (254),
	@states		varchar (254),
	@cmpids		varchar (254),
	@reg1		varchar (254),
	@reg2		varchar (254),
	@reg3		varchar (254),
	@reg4		varchar (254),
	@city		int,
	@hoursback	int,
	@hoursout	int,
	@status		char (254),
	@bookedby	varchar (254),
	@ref_type	varchar(6),
	@teamleader	varchar(254),
	@d_states	varchar (254),
	@d_cmpids	varchar (254),
	@d_reg1		varchar (254),
	@d_reg2		varchar (254),
	@d_reg3		varchar (254),
	@d_reg4		varchar (254),
	@d_city		int,
	@includedrvplan varchar(3),
	@miles_min	int,
	@miles_max	int,
	@tm_status	varchar(254),
	@lgh_type1	varchar(254),
	@lgh_type2	varchar(254),
	@billto		varchar(254),
	@lgh_hzd_cmd_classes varchar (255),
	@orderedby	varchar(254),
	@o_servicearea		varchar(256),
	@o_servicezone		varchar(256),
	@o_servicecenter	varchar(256),
	@o_serviceregion	varchar(256),
	@dest_servicearea	varchar(256),
	@dest_servicezone	varchar(256),
	@dest_servicecenter	varchar(256),
	@dest_serviceregion	varchar(256),
	@lgh_route			varchar(256),
	@lgh_booked_revtype1 varchar(256),
	@lgh_permit_status	varchar(256),
	@cmp_othertype1		varchar(256),	/* 02/25/2008 MDH PTS 39077: Added */
	@d_cmp_othertype1	varchar(256)	/* 02/25/2008 MDH PTS 39077: Added */
AS

/****** Object:  Stored Procedure dbo.outbound_view    Script Date: 6/24/98 10:15:30 AM ******/
/* MF 11/12/97 PTS 3215 changed to use newly populated fields on LGH including lgh_active */
/* LOR 5/12/98 PTS# 3905 add shipper/consignee states, drivers' id's */
/* LOR 5/12/98 PTS# 3908 add ref type and number */
/* JET 6/3/98 PTS# 3991 modified lgh_schdtearliest, lgh_schdtlatest to reflect ord_origin_earliestdate andord_origin_latestdate*/
/* MF 10/22/98 pts 4175 add extra cols*/
/* JET 10/20/99 PTS #6490 changed the where clause on the select */
/* DSK 3/20/00 PTS 7566  add columns for total orders, total count, total weight, total volume */
/* KMM 7/10/00 PTS 8339  allow MPN records to be returned */
/* RJE 7/14/00 added ld_can_expires for CAN */
/* DPETE 12599 add origin and dest company geoloc feilds to return set fro Gibsons SR */
/* Vern Jewett PTS 15033 07/31/2002 (label=vmj1) Add lgh_comments column. */
/* Vern Jewett PTS 18417 09/02/2003 (label=vmj2) Add lgh_etaalert1 column. */
/* PTS 26776 DJM  03/30/05 Recode changes made for Eagle in PTS number 19028, 22601,20302 into main source
    These Eagle enhancements will only work on  SQL Server 2000 specific code. The
    SQL 7 compliant version MUST have the same columns and parameters, but nothing
    will be done with them. I.E. View retrictions will not be applied in the SQL 7
    version*/
/* PTS 26791 - DJM - Corrected display of Localization values.    */
/* BDH 9/12/06 PTS 33890  Returning next_ndrp_cmpid, next_ndrp_cmpname, next_ndrp_ctyname, next_ndrp_state, next_ndrp_arrivaldate from legheader_active */
/* EMK 10/3/06 PTS 33913  Returning ord_bookdate */
/* EMK 10/11/06 PTS 33913   Changed _2000 to PROVIDES statement. */
/* vjh 02/09/07 PTS 36608 Added Manual Check Call times. */
/* DPETE 35747 allow for GI option of alltimes in local time zone support
       return a minutes offset in each row to apply to Today()in datawindow for comparison (see attachemnt to PTS for how this works)*/
-- LOR PTS# 35761 added evt_earlydate and ARRIVALDEPARTURE value to @LateWarnMode
/* BDH  36717 5/14/07  Added lockedby and sessiondate columns as part of Command recode and changed joins to ansi.  */
-- vjh 05/22/07 PTS 37626 use Apocalypse if order event or check minutes are zero
-- vjh 05/30/07 PTS 37657 make the check call time time zone aware (when based on stop time, but not when based on check calls)
-- vjh 38226 TZ shift the departure date before comparison
-- vjh 38677 redefine ord_manualeventcallminutes
-- SLM 08/31/2007 PTS 39133 Based on General Info Setting 'PWSumOrdExtraInfo' use lgh_extrainfo1
-- DJM 38765 09/26/2007 - Added fields to planning worksheet.
-- DJM 42829 - Added trc_lastpos_lat and trc_lastpos_long fields.
-- JJF 41795 20080506

DECLARE
	@char8		varchar(8),
	@char1		varchar(1),
	@char30		varchar(30),
	@char20		varchar(20),
	@char25		varchar(25),
	@char40		varchar(40),
	@cmdcount	int,
	@floa		float,
	@hoursbackdate	datetime,
	@hoursoutdate	datetime,
	@gistring1	varchar(60),
	@dttm		datetime,
	@char2		char(2),
	@varchar45	varchar(45),
	@varchar6	varchar(6),
	@runpups	char(1),
	@rundrops	char(1),
	@retvarchar	varchar(3),
	@LateWarnMode				VARCHAR(60),
	@PWExtraInfoLocation		varchar(20),
	@o_servicezone_labelname	varchar(20),
	@o_servicecenter_labelname	varchar(20),
	@o_serviceregion_labelname	varchar(20),
	@o_sericearea_labelname		varchar(20),
	@dest_servicezone_labelname varchar(20),
	@dest_servicecenter_labelname varchar(20),
	@dest_serviceregion_labelname varchar(20),
	@dest_sericearea_labelname	varchar(20),
	@service_revtype			varchar(10),
	@localization				char(1),
	@pending_statuses			varchar(60),
	@UseShowAsShipperConsignee	CHAR(1),
	@v_LghActiveUntilDepCompNBC char(1),
	@ManualCheckCall			char(1),
--35747
	@V_GILocalTImeOption		varchar(20),
	@v_LocalCityTZAdjFactor		int,
	@InDSTFactor				int,
	@DSTCountryCode				int ,
	@V_LocalGMTDelta			smallint,
	@v_LocalDSTCode				smallint,
	@V_LocalAddnlMins			smallint,
--35747 end
-- PTS 37075 SGB Added variable for column Label
	@SubCompanyLabel			varchar(20),
	@Apocalypse					datetime,
	@PlnWrkshtRefStr1			varchar(60),	--vjh pts 38986
	@PlnWrkshtRefStr2			varchar(60),	--vjh pts 38986
	@PlnWrkshtRefStr3			varchar(60)	--vjh pts 38986

--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
declare @tmwuser varchar(255)
--END PTS 40155 JJF 20071128

--PTS 41795 JJF 20080506
declare @FSCChargeTypeList			varchar(60)
--END PTS 41795 JJF 20080506

declare @IncludeRefNumbers varchar (1) /* 08/27/2008 MDH PTS 42301: Added */

Declare @ttbl1 Table(
	lgh_number			int			NULL,
	o_cmpid				varchar(12)	NULL,
	o_cmpname			varchar(30)	NULL,
	o_ctyname			varchar(25)	NULL,
	d_cmpid				varchar(12)	NULL,
	d_cmpname			varchar(30)	NULL,
	d_ctyname			varchar(25)	NULL,
	f_cmpid				varchar(8)	NULL,
	f_cmpname			varchar(30)	NULL,
	f_ctyname			varchar(25)	NULL,
	l_cmpid				varchar(8)	NULL,
	l_cmpname			varchar(30)	NULL,
	l_ctyname			varchar(25)	NULL,
	lgh_startdate		datetime	NULL,
	lgh_enddate			datetime	NULL,
	o_state				varchar(6)	NULL,
	d_state				varchar(6)	NULL,
	lgh_schdtearliest	datetime	NULL,
	lgh_schdtlatest		datetime	NULL,
	cmd_code			varchar(8)	NULL,
	fgt_description		varchar(60)	NULL,	
	cmd_count			int			NULL,
	ord_hdrnumber		int			NULL,
	evt_driver1			varchar(45)	NULL,
	evt_driver2			varchar(45)	NULL,
	evt_tractor			varchar(8)	NULL,
	lgh_primary_trailer	varchar(13)	NULL,
	trl_type1			varchar(6)	NULL,
	evt_carrier			varchar(8)	NULL,
	mov_number			int			NULL,
	ord_availabledate	datetime	NULL,
	ord_stopcount		tinyint		NULL,
	ord_totalcharge		float		NULL,
	ord_totalweight		int			NULL,
	ord_length			money		NULL,
	ord_width			money		NULL,
	ord_height			money		NULL,
	ord_totalmiles		int			NULL,
	ord_number			char(12)	NULL,
	o_city				int			NULL,
	d_city				int			NULL,
	lgh_priority		varchar(6)	NULL,
	lgh_outstatus		varchar(20)	NULL,
	lgh_instatus		varchar(20)	NULL,
	lgh_priority_name	varchar(20)	NULL,
	ord_subcompany		varchar(20)	NULL,
	trl_type1_name		varchar(20)	NULL,
	lgh_class1			varchar(20)	NULL,
	lgh_class2			varchar(20)	NULL,
	lgh_class3			varchar(20)	NULL,
	lgh_class4			varchar(20)	NULL,
	--PTS 37075 SGB changed from varchar(7) to (20) and changed name for clarification
	--Company			varchar(7)	NULL
	SubCompanyLabel		varchar(20)	NULL,
	trllabel1			varchar(20)	NULL,
	revlabel1			varchar(20)	NULL,
	revlabel2			varchar(20)	NULL,
	revlabel3			varchar(20)	NULL,
	revlabel4			varchar(20)	NULL,
	ord_bookedby		char(20)	NULL,
	dw_rowstatus		char(10)	NULL,
	lgh_primary_pup		varchar(13)	NULL,
	triptime			float		NULL,
	ord_totalweightunits	varchar(6)	NULL,
	ord_lengthunit		varchar(6)	NULL,
	ord_widthunit		varchar(6)	NULL,
	ord_heightunit		varchar(6)	NULL,
	loadtime			float		NULL,
	unloadtime			float		NULL,
	unloaddttm			datetime	NULL,
	unloaddttm_early	datetime	NULL,
	unloaddttm_late		datetime	NULL,
	ord_totalvolume		int			NULL,
	ord_totalvolumeunits	varchar(6)	NULL,
	washstatus			varchar(1)	NULL,
	f_state				varchar(6)	NULL,
	l_state				varchar(6)	NULL,
	evt_driver1_id		varchar(8)	NULL,
	evt_driver2_id		varchar(8)	NULL,
	ref_type			varchar(6)	NULL,
	ref_number			varchar(30)	NULL,
	d_address1			varchar(40)	NULL,
	d_address2			varchar(40)	NULL,
	ord_remark			varchar(254)	NULL,
	mpp_teamleader		varchar(6)	NULL,
	lgh_dsp_date		datetime	NULL,
	lgh_geo_date		datetime	NULL,
	ordercount			smallint	NULL,
	npup_cmpid			varchar(8)	NULL,
	npup_cmpname		varchar(30)	NULL,
	npup_ctyname		varchar(25)	NULL,
	npup_state			varchar(6)	NULL,
	npup_arrivaldate	datetime	NULL,
	ndrp_cmpid			varchar(8)	NULL,
	ndrp_cmpname		varchar(30)	NULL,
	ndrp_ctyname		varchar(25)	NULL,
	ndrp_state			varchar(6)	NULL,
	ndrp_arrivaldate	datetime	NULL,
	can_ld_expires		datetime	NULL,
	xdock				int			NULL,
	feetavailable		smallint	NULL,
	opt_trc_type4		varchar(6)	NULL,
	opt_trc_type4_label	varchar(20)	NULL,
	opt_trl_type4		varchar(6)	NULL,
	opt_trl_type4_label	varchar(20)	NULL,
	ord_originregion1	varchar(6)	NULL,
	ord_originregion2	varchar(6)	NULL,
	ord_originregion3	varchar(6)	NULL,
	ord_originregion4	varchar(6)	NULL,
	ord_destregion1		varchar(6)	NULL,
	ord_destregion2		varchar(6)	NULL,
	ord_destregion3		varchar(6)	NULL,
	ord_destregion4		varchar(6)	NULL,
	npup_departuredate	datetime	NULL,
	ndrp_departuredate	datetime	NULL,
	ord_fromorder		varchar(12)	NULL,
	c_lgh_type1			varchar(20)	NULL,
	lgh_type1_label		varchar(20)	NULL,
	c_lgh_type2			varchar(20)	NULL,
	lgh_type2_label		varchar(20)	NULL,
	lgh_tm_status		varchar(6)	NULL,
	lgh_tour_number		int			NULL,
	extrainfo1			varchar(255)	NULL,
	extrainfo2			varchar(255)	NULL,
	extrainfo3			varchar(255)	NULL,
	extrainfo4			varchar(255)	NULL,
	extrainfo5			varchar(255)	NULL,
	extrainfo6			varchar(255)	NULL,
	extrainfo7			varchar(255)	NULL,
	extrainfo8			varchar(255)	NULL,
	extrainfo9			varchar(255)	NULL,
	extrainfo10			varchar(255)	NULL,
	extrainfo11			varchar(255)	NULL,
	extrainfo12			varchar(255)	NULL,
	extrainfo13			varchar(255)	NULL,
	extrainfo14			varchar(255)	NULL,
	extrainfo15			varchar(255)	NULL,
	o_cmp_geoloc		varchar(50)	NULL,
	d_cmp_geoloc		varchar(50)	NULL,
	mpp_fleet			varchar(6)	NULL,
	mpp_fleet_name		varchar(20)	NULL,
	next_stp_event_code	varchar(6)	NULL,
	next_stop_of_total	varchar(10)	NULL,
	lgh_comment			varchar(255)	NULL,
	lgh_earliest_pu		datetime	NULL,
	lgh_latest_pu		datetime	NULL,
	lgh_earliest_unl	datetime	NULL,
	lgh_latest_unl		datetime	NULL,
	lgh_miles			int			NULL,
	lgh_linehaul		float		NULL,
	evt_latedate		datetime	NULL,
	lgh_ord_charge		float		NULL,
	lgh_act_weight		float		NULL,
	lgh_est_weight		float		NULL,
	lgh_tot_weight		float		NULL,
	lgh_outstat			varchar(6)	NULL,
	lgh_max_weight_exceeded	char(1)	NULL,
	lgh_reftype				varchar(6)	NULL,
	lgh_refnum				varchar(30)	NULL,
	trctype1				varchar(20)	NULL,
	trc_type1name			varchar(20)	NULL,
	trctype2				varchar(20)	NULL,
	trc_type2name			varchar(20)	NULL,
	trctype3				varchar(20)	NULL,
	trc_type3name			varchar(20)	NULL,
	trctype4				varchar(20)	NULL,
	trc_type4name			varchar(20)	NULL,
	lgh_etaalert1			char(1)		NULL,
	lgh_detstatus			int			NULL,
	lgh_tm_statusname		varchar(20)	NULL,
	ord_billto				varchar(8)	NULL,
	cmp_name				varchar(100)	NULL,
	lgh_carrier				varchar(64)	NULL,
	TotalCarrierPay			money		NULL,
	lgh_hzd_cmd_class		varchar(8)	NULL,
	lgh_washplan			varchar(20)	NULL,
	fgt_length				float		NULL,
	fgt_width				float		NULL,
	fgt_height				float		NULL,
	lgh_originzip			varchar(10)	NULL,
	lgh_destzip				varchar(10)	NULL,
	ord_company				varchar(12)	NULL,
	origin_servicezone		varchar(20)	NULL,
	o_servicezone_t			varchar(20)	NULL,
	origin_servicearea		varchar(20)	NULL,
	o_servicearea_t			varchar(20)	NULL,
	origin_servicecenter	varchar(20)	NULL,
	o_servicecenter_t		varchar(20)	NULL,
	origin_serviceregion	varchar(20)	NULL,
	o_serviceregion_t		varchar(20)	NULL,
	dest_servicezone		varchar(20)	NULL,
	dest_servicezone_t		varchar(20)	NULL,
	dest_servicearea		varchar(20)	NULL,
	dest_servicearea_t		varchar(20)	NULL,
	dest_servicecenter		varchar(20)	NULL,
	dest_servicecenter_t	varchar(20)	NULL,
	dest_serviceregion		varchar(20)	NULL,
	dest_serviceregion_t	varchar(20)	NULL,
	lgh_204status			varchar(30)	NULL,
 -- PTS 29347 -- BL (start)
	origin_cmp_lat			decimal(12,4)	NULL,
	origin_cmp_long			decimal(12,4)	NULL,
	origin_cty_lat			decimal(12,4)	NULL,
	origin_cty_long			decimal(12,4)	NULL,
 -- PTS 29347 -- BL (end)
	lgh_route				varchar(15)		NULL,
	lgh_booked_revtype1		varchar(12)		NULL,
	lgh_permit_status		varchar(6)		NULL,
	lgh_permit_status_t		varchar(20)		NULL,
	lgh_204date				datetime		NULL,
 -- PTS 33890 BDH 9/13/06 start
	next_ndrp_cmpid			varchar(8)		null,
	next_ndrp_cmpname		varchar(30)		null,
	next_ndrp_ctyname		varchar(25)		null,
	next_ndrp_state			varchar(6)		null,
	next_ndrp_arrivaldate	datetime		null,
 -- PTS 33890 BDH 9/13/06 start
 -- PTS 33913 EMK 10/03/06 start
	ord_bookdate			datetime		null,
 -- PTS 33913 EMK 10/03/06 end
	lgh_ace_status_name		varchar(20)		null, --PTS 35199 AROSS
	manualcheckcalltime		datetime		null, --PTS 35708 vjh
	evt_earlydate			datetime		null,
	TimeZoneAdjMins			int				null,  --PTS35747
	locked_by				varchar(20)		null,  -- 36717
	session_date			datetime		null,	-- 36717
	ord_cbp					char(1)			null,	-- PTS 38765
	lgh_ace_status			varchar(6)		null,
	trc_latest_ctyst	    varchar(30)		null,
	trc_latest_cmpid			varchar(8)	null,
	trc_last_mobcomm_received	datetime	null,
	trc_mobcomm_type			varchar(20)	null,
	trc_nearest_mobcomm_nmstct	varchar(20)	null,	-- PTS 38765
	next_stop_ref_number		varchar(30) null,	--PTS 38138 JJF 20080122
	compartment_loaded			int			null,	--PTS29383 MBR 08/17/05 40762
	trc_lastpos_lat			float			null,	-- PTS 42829 - DJM
	trc_lastpos_long		float			null,	-- PTS 42829 - DJM
	fsc_fuel_surcharge		money			null,	--PTS 41795 JJF 20080506
/* 08/27/2008 MDH PTS 42301: <<BEGIN>> */
	ord_ref_type_2			varchar (6)		null,
	ord_ref_number_2		varchar (30)	null,
	ord_ref_type_3			varchar (6)		null,
	ord_ref_number_3		varchar (30)	null,
	ord_ref_type_4			varchar (6)		null,
	ord_ref_number_4		varchar (30)	null,
	ord_ref_type_5			varchar (6)		null,
	ord_ref_number_5		varchar (30)	null
/* 08/27/2008 MDH PTS 42301: <<END>> */
)	



select @Apocalypse = convert(datetime,'20491231 23:59:59')

IF @hoursback = 0
 SELECT @hoursback= 1000000

IF @hoursout = 0
 SELECT @hoursout = 1000000
/* Get the hoursback and  hoursout into variables
   Avoid doing this in the query --Jude */
SELECT @hoursbackdate = DATEADD(hour, -@hoursback, GETDATE())
SELECT @hoursoutdate = DATEADD(hour,  @hoursout, GETDATE())

-- RE - 10/15/02 - PTS #15024
SELECT @LateWarnMode = gi_string1 FROM generalinfo WHERE gi_name = 'PlnWrkshtLateWarnMode'

-- PTS 25895 JLB need to add the ability to determine where extrainfo comes from
Select @PWExtraInfoLocation = UPPER(isnull(gi_string1,'ORDERHEADER'))
  from generalinfo
 where gi_name = 'PWExtraInfoLocation'

-- LOR PTS# 28465
select @pending_statuses = IsNull(Upper(RTRIM(LTRIM(gi_string2))), '')
from generalinfo
where gi_name = 'DisplayPendingOrders' and gi_string1 = 'Y'

-- LOR
If @miles_min = 0 select @miles_min = -1000

/* 35747 Is local time option set (GI integer1 is the city code of the dispatch office) */
select @V_GILocalTimeOption = Upper(isnull(gi_string1,''))
from generalinfo where gi_name = 'LocalTimeOption'
Select @V_GILocalTimeOption = isnull(@V_GILocalTimeOption,'')
select @v_LocalCityTZAdjFactor = 0
If @V_GILocalTimeOption = 'LOCAL'
  BEGIN
    /* if server is in different time zone that dipatch office there may be a few hours of error going in and out of DST */
    select @DSTCountryCode = 0 /* if you want to work outside North America, set this value see proc ChangeTZ */
    select @InDSTFactor = case dbo.InDst(getdate(),@DSTCountryCode) when 'Y' then 1 else 0 end
    select @v_LocalCityTZAdjFactor = 0

     exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
     select @v_LocalCityTZAdjFactor =
       ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
  END
/* 35747 end */

--PTS 37075 SGB Added select to get label name for company label
select @SubCompanyLabel = (Select DISTINCT userlabelname from labelfile where  labeldefinition = 'Company')

--PTS32875 MBR 05/16/06
SELECT @UseShowAsShipperConsignee = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
  FROM generalinfo
 WHERE gi_name = 'UseShowAsShipperConsignee'

--PTS38986 vjh 09/07/07
SELECT @PlnWrkshtRefStr1 = ISNULL(LEFT(UPPER(gi_string1), 1), 'N'), @PlnWrkshtRefStr2 = ISNULL(gi_string2, 'stops'), @PlnWrkshtRefStr3 = ISNULL(gi_string3, 'REF')
  FROM generalinfo
 WHERE gi_name = 'PlnWrkshtRef'

if @PlnWrkshtRefStr1 is null select @PlnWrkshtRefStr1 = 'N'
if @PlnWrkshtRefStr2 is null select @PlnWrkshtRefStr2 = 'stops'
if @PlnWrkshtRefStr3 is null select @PlnWrkshtRefStr3 = 'REF'

IF @city IS NULL
   SELECT @city = 0
IF @reg1 IS NULL OR @reg1 = ''
   SELECT @reg1 = 'UNK'
IF @reg2 IS NULL OR @reg2 = ''
   SELECT @reg2 = 'UNK'
IF @reg3 IS NULL OR @reg3 = ''
   SELECT @reg3 = 'UNK'
IF @reg4 IS NULL OR @reg4 = ''
   SELECT @reg4 = 'UNK'
IF @status IS NULL
   SELECT @status = ''
IF @states IS NULL
   SELECT @states = ''
IF @bookedby = '' OR @bookedby IS NULL
   SELECT @bookedby = 'ALL'
IF @d_city IS NULL
   SELECT @d_city = 0
IF @d_reg1 IS NULL OR @d_reg1 = ''
   SELECT @d_reg1 = 'UNK'
IF @d_reg2 IS NULL OR @d_reg2 = ''
   SELECT @d_reg2 = 'UNK'
IF @d_reg3 IS NULL OR @d_reg3 = ''
   SELECT @d_reg3 = 'UNK'
IF @d_reg4 IS NULL OR @d_reg4 = ''
   SELECT @d_reg4 = 'UNK'
IF @d_states IS NULL
   SELECT @d_states = ''
/*PTS 23162 CGK 9/1/2004*/
IF @lgh_hzd_cmd_classes IS NULL OR @lgh_hzd_cmd_classes = ''
   SELECT @lgh_hzd_cmd_classes = 'UNK'
if @lgh_booked_revtype1 IS NULL or @lgh_booked_revtype1 = ''
   SELECT @lgh_booked_revtype1 = 'UNK'

IF @lgh_permit_status IS NULL OR @lgh_permit_status = ''
 SELECT @lgh_permit_status = 'UNK'
SELECT @lgh_permit_status = ',' + LTRIM(RTRIM(ISNULL(@lgh_permit_status, ''))) + ','

/* 02/25/2008 MDH PTS 39077: Added code to default cmp_othertype1 fields <<BEGIN>> */
IF @cmp_othertype1 IS NULL OR @cmp_othertype1 = ''
   SELECT @cmp_othertype1 = 'UNK'
IF @d_cmp_othertype1 IS NULL OR @d_cmp_othertype1 = ''
   SELECT @d_cmp_othertype1 = 'UNK'
SELECT @cmp_othertype1 = ',' + LTRIM(RTRIM(ISNULL(@cmp_othertype1, '')))  + ','
SELECT @d_cmp_othertype1 = ',' + LTRIM(RTRIM(ISNULL(@d_cmp_othertype1, '')))  + ','
/* 02/25/2008 MDH PTS : <<END>> */

--JLB PTS 33012
select @v_LghActiveUntilDepCompNBC = left(isnull(gi_string1, 'N'), 1)
  from generalinfo
 where gi_name = 'LghActiveUntilDepCompNBC'

SELECT @bookedby = ',' + LTRIM(RTRIM(ISNULL(@bookedby, ''))) + ','
SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, '')))  + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, '')))  + ','
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, '')))  + ','
SELECT @cmpids = ',' + LTRIM(RTRIM(ISNULL(@cmpids, '')))  + ','
SELECT @d_cmpids = ',' + LTRIM(RTRIM(ISNULL(@d_cmpids, '')))  + ','
SELECT @teamleader = ',' + LTRIM(RTRIM(ISNULL(@teamleader, '')))  + ','
SELECT @company = ',' + LTRIM(RTRIM(ISNULL(@company, '')))  + ','
SELECT @trltype1 = ',' + LTRIM(RTRIM(ISNULL(@trltype1, '')))  + ','
--LOR
SELECT @reg1 = ',' + LTRIM(RTRIM(ISNULL(@reg1, '')))  + ','
SELECT @reg2 = ',' + LTRIM(RTRIM(ISNULL(@reg2, '')))  + ','
SELECT @reg3 = ',' + LTRIM(RTRIM(ISNULL(@reg3, '')))  + ','
SELECT @reg4 = ',' + LTRIM(RTRIM(ISNULL(@reg4, '')))  + ','
SELECT @d_reg1 = ',' + LTRIM(RTRIM(ISNULL(@d_reg1, '')))  + ','
SELECT @d_reg2 = ',' + LTRIM(RTRIM(ISNULL(@d_reg2, '')))  + ','
SELECT @d_reg3 = ',' + LTRIM(RTRIM(ISNULL(@d_reg3, '')))  + ','
SELECT @d_reg4 = ',' + LTRIM(RTRIM(ISNULL(@d_reg4, '')))  + ','
SELECT @tm_status = ',' + LTRIM(RTRIM(ISNULL(@tm_status, '')))  + ','
SELECT @lgh_type1 = ',' + LTRIM(RTRIM(ISNULL(@lgh_type1, '')))  + ','
SELECT @lgh_type2 = ',' + LTRIM(RTRIM(ISNULL(@lgh_type2, '')))  + ','
SELECT @billto = ',' + LTRIM(RTRIM(ISNULL(@billto, '')))  + ',' --vjh 21520
SELECT @lgh_route = ',' + LTRIM(RTRIM(ISNULL(@lgh_route, '')))  + ','
SELECT @lgh_booked_revtype1 = ',' + LTRIM(RTRIM(ISNULL(@lgh_booked_revtype1, '')))  + ','

/*PTS 23162 CGK 9/1/2004*/
SELECT @lgh_hzd_cmd_classes = ',' + LTRIM(RTRIM(ISNULL(@lgh_hzd_cmd_classes, '')))  + ','

-- 19028
SELECT @orderedby = ',' + LTRIM(RTRIM(ISNULL(@orderedby, ''))) + ','

/* PTS 26766 - DJM - Check setting used control use of the Localization values in the Planning
 worksheet and Tripfolder. To eliminate potential performance issues for customers
 not using this feature - SQL 2000 ONLY
*/
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'
/* PTS 36608 - vjh - Check setting used control use of the manual check call times in the Planning
 worksheet and Tripfolder. To eliminate potential performance issues for customers
 not using this feature - SQL 2000 ONLY
*/
select @ManualCheckCall = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ManualCheckCall'

/* 08/27/2008 MDH PTS 42301: Check if we're to have 5 reference number columns <<BEGIN>> */
SELECT @IncludeRefNumbers = IsNull (Upper (RTRIM(LEFT(gi_String1, 1))),'')
	FROM generalinfo
	WHERE gi_name = 'OutboundRefNumbers'
	
/* 08/27/2008 MDH PTS 42301: <<END>> */

/* Retrieve the data
*/
Insert Into @ttbl1
	SELECT	legheader.lgh_number,
			legheader.cmp_id_start o_cmpid,
			o_cmpname,
			lgh_startcty_nmstct o_ctyname,
			legheader.cmp_id_end d_cmpid,
			d_cmpname,
			lgh_endcty_nmstct d_ctyname,
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showshipper <> ord_shipper AND ord_showshipper <> 'UNKNOWN' AND ord_Showshipper IS NOT NULL THEN
					ord_showshipper
				ELSE f_cmpid END,
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showshipper <> ord_shipper AND ord_showshipper <> 'UNKNOWN' AND ord_showshipper IS NOT NULL THEN
					(SELECT cmp_name FROM company WHERE cmp_id = ord_showshipper)
				ELSE f_cmpname END,
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showshipper <> ord_shipper AND ord_showshipper <> 'UNKNOWN' AND ord_showshipper IS NOT NULL THEN
					(SELECT cty_nmstct FROM company where cmp_id = ord_showshipper)
				ELSE f_ctyname END,
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showcons <> ord_consignee AND ord_showcons <> 'UNKNOWN' AND ord_Showcons IS NOT NULL THEN
			    	ord_showcons
				ELSE l_cmpid END,
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showcons <> ord_consignee AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN
					(SELECT cmp_name FROM company WHERE cmp_id = ord_showcons)
				ELSE l_cmpname END,
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showcons <> ord_consignee AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN
					(SELECT cty_nmstct FROM company where cmp_id = ord_showcons)
				ELSE l_ctyname END,
			legheader.lgh_startdate,
			legheader.lgh_enddate,
			lgh_startstate o_state,
			lgh_endstate d_state,
			orderheader.ord_origin_earliestdate lgh_schdtearliest,
			orderheader.ord_origin_latestdate lgh_schdtlatest,
			legheader.cmd_code,
			legheader.fgt_description,
			cmd_count,
			legheader.ord_hdrnumber,
			evt_driver1_name evt_driver1,
			evt_driver2_name evt_driver2,
			lgh_tractor evt_tractor,
			legheader.lgh_primary_trailer,
			orderheader.trl_type1,
			lgh_carrier evt_carrier,
			legheader.mov_number,
			orderheader.ord_availabledate,
			legheader.ord_stopcount,
			orderheader.ord_totalcharge,
			legheader.ord_totalweight,
			orderheader.ord_length,
			orderheader.ord_width,
			orderheader.ord_height,
			--PTS13149 MBR 1/29/02
			legheader.ord_totalmiles ord_totalmiles,
			case isnull(upper(lgh_split_flag),'N')
				when 'S' then substring(rtrim(orderheader.ord_number)+'*',1,12)
				when 'F' then substring(rtrim(orderheader.ord_number)+'*',1,12)
				else orderheader.ord_number
				end ord_number,
			legheader.lgh_startcity o_city,
			legheader.lgh_endcity d_city,
			legheader.lgh_priority,
			lgh_outstatus_name lgh_outstatus,
			lgh_instatus_name lgh_instatus,
			lgh_priority_name,
			(select name from labelfile where legheader.ord_ord_subcompany = abbr AND labeldefinition = 'Company')  ord_subcompany,
			trl_type1_name,
			lgh_class1_name lgh_class1,
			lgh_class2_name lgh_class2,
			lgh_class3_name lgh_class3,
			lgh_class4_name lgh_class4,
			--'Company' 'Company', PTS 37075 SGB remove hardcoded Company with variable
			@SubcompanyLabel SubCompanyLabel,
			labelfile_headers.TrlType1 trllabel1,
			labelfile_headers.RevType1 revlabel1,
			labelfile_headers.RevType2 revlabel2,
			labelfile_headers.RevType3 revlabel3,
			labelfile_headers.RevType4 revlabel4,
			orderheader.ord_bookedby,
			convert(char(10), '') dw_rowstatus,
			lgh_primary_pup,
			IsNull(ord_loadtime, 0) + IsNull(ord_unloadtime, 0) + IsNull(ord_drivetime, 0) triptime,
			ord_totalweightunits,
			ord_lengthunit,
			ord_widthunit,
			ord_heightunit,
			ord_loadtime loadtime,
			ord_unloadtime unloadtime,
			ord_completiondate unloaddttm,
			ord_dest_earliestdate unloaddttm_early,
			ord_dest_latestdate unloaddttm_late,
			legheader.ord_totalvolume,
			ord_totalvolumeunits,
			washstatus,
			f_state,
			l_state,
			legheader.lgh_driver1 evt_driver1_id,
			legheader.lgh_driver2 evt_driver2_id,
			legheader.ref_type,
			legheader.ref_number,
			d_address1,
			d_address2,
			ord_remark,
			legheader.mpp_teamleader,
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
			isnull(legheader.can_ld_expires,'19000101') can_ld_expires,
			xdock,
			lgh_feetavailable feetavailable,
			opt_trc_type4,
			opt_trc_type4_label,
			opt_trl_type4,
			opt_trl_type4_label,
			lgh_startregion1 ord_originregion1,
			lgh_startregion2 ord_originregion2,
			lgh_startregion3 ord_originregion3,
			lgh_startregion4 ord_originregion4,
			lgh_endregion1 ord_destregion1,
			lgh_endregion2 ord_destregion2,
			lgh_endregion3 ord_destregion3,
			lgh_endregion4 ord_destregion4,
			npup_departuredate,
			ndrp_departuredate,
			ord_fromorder,
			c_lgh_type1,
			labelfile_headers.LghType1 lgh_type1_label,
			c_lgh_type2,
			labelfile_headers.LghType2 lgh_type2_label,
			lgh_tm_status,
			lgh_tour_number,
			--JLB PTS 25895
			-- BEGIN SLM PTS 39133 8/31/2007
			(CASE WHEN @PWExtraInfoLocation = 'ORDERHEADER' AND (select Upper(isnull(gi_string1,'N')) from generalinfo where gi_name = 'PWSumOrdExtraInfo') <> 'Y' THEN ord_extrainfo1 ELSE lgh_extrainfo1 END) extrainfo1,
			-- (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo1 ELSE lgh_extrainfo1 END) extrainfo1,
			-- END SLM PTS 39133 8/31/2007
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo2 ELSE lgh_extrainfo2 END) extrainfo2,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo3 ELSE lgh_extrainfo3 END) extrainfo3,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo4 ELSE lgh_extrainfo4 END) extrainfo4,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo5 ELSE lgh_extrainfo5 END) extrainfo5,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo6 ELSE lgh_extrainfo6 END) extrainfo6,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo7 ELSE lgh_extrainfo7 END) extrainfo7,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo8 ELSE lgh_extrainfo8 END) extrainfo8,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo9 ELSE lgh_extrainfo9 END) extrainfo9,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo10 ELSE lgh_extrainfo10 END) extrainfo10,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo11 ELSE lgh_extrainfo11 END) extrainfo11,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo12 ELSE lgh_extrainfo12 END) extrainfo12,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo13 ELSE lgh_extrainfo13 END) extrainfo13,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo14 ELSE lgh_extrainfo14 END) extrainfo14,
			(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo15 ELSE lgh_extrainfo15 END) extrainfo15,
			  --end 25895
			o_cmp_geoloc,
			d_cmp_geoloc,
			legheader.mpp_fleet,
			mpp_fleet_name,
			next_stp_event_code,
			next_stop_of_total,
			--vmj1+
			legheader.lgh_comment,
			--vmj1-
			s1.stp_schdtearliest   lgh_earliest_pu,
			s1.stp_schdtlatest   lgh_latest_pu,
			s2.stp_schdtearliest   lgh_earliest_unl,
			s2.stp_schdtlatest   lgh_latest_unl,
			-- RE - 03/22/04 - PTS #22373
			--lgh_miles,
			(SELECT SUM(stp_lgh_mileage) FROM stops s WHERE s.lgh_number = legheader.lgh_number) lgh_miles,
			lgh_linehaul,
			-- RE - 10/15/02 - PTS #15024
			-- LOR PTS# 35761 add ARRIVALDEPARTURE
			-- CASE
			--  WHEN @LateWarnMode <> 'EVENT' THEN NULL
			--  ELSE ISNULL((SELECT MIN(evt_latedate)
			--        FROM event e,
			--       stops s
			--       WHERE e.stp_number = s.stp_number AND
			--       s.lgh_number = legheader.lgh_number AND
			--       e.evt_status = 'OPN'), '20491231')
			CASE @LateWarnMode
				WHEN 'EVENT' THEN
			  		ISNULL((SELECT MIN(evt_latedate)
			    			FROM event e, stops s
			    			WHERE e.stp_number = s.stp_number AND
			    			  s.lgh_number = legheader.lgh_number AND
			    			  e.evt_status = 'OPN'), '20491231')
			 	WHEN 'ARRIVALDEPARTURE' THEN
			  		ISNULL((SELECT MIN(evt_latedate)
			  		  		FROM event e, stops s
			  		  		WHERE e.stp_number = s.stp_number AND
			  		  		  s.lgh_number = legheader.lgh_number AND
			  		  		  IsNull(e.evt_departure_status, 'OPN') = 'OPN'), '20491231')
			 	ELSE Null
				END evt_latedate,
			lgh_ord_charge,
			lgh_act_weight,
			lgh_est_weight,
			lgh_tot_weight,
			lgh_outstatus lgh_outstat,
			legheader.lgh_max_weight_exceeded,
			lgh_reftype,
			lgh_refnum,
			labelfile_headers.trctype1,
			legheader.trc_type1name,
			labelfile_headers.trctype2,
			legheader.trc_type2name,
			labelfile_headers.trctype3,
			legheader.trc_type3name,
			labelfile_headers.trctype4,
			legheader.trc_type4name,
			--vmj2+
			legheader.lgh_etaalert1,
			--vmj2-
			isnull(lgh_detstatus,0) lgh_detstatus, --vjh 22914
			legheader.lgh_tm_statusname  ,
			legheader.ord_billto,
			--DPH PTS 22793
			company.cmp_name,
			(select car_name from carrier where car_id = legheader.lgh_carrier) lgh_carrier,
			IsNull((SELECT SUM(pyd_amount) FROM paydetail
					WHERE paydetail.asgn_id = legheader.lgh_carrier
					AND paydetail.asgn_type = 'CAR'
					AND paydetail.lgh_number = legheader.lgh_number
					AND paydetail.mov_number = legheader.mov_number),0) TotalCarrierPay,
			--DPH PTS 22793
			lgh_hzd_cmd_class, /*PTS 23162 CGK 9/1/2004*/
			legheader.lgh_washplan, --MRH PTS 22661
			(select max(fgt_length)
			 	 from freightdetail, stops
			  	where freightdetail.stp_number = stops.stp_number
			      and legheader.lgh_number = stops.lgh_number) as fgt_length,
			(select max(fgt_width)
			 	 from freightdetail, stops
			  	where freightdetail.stp_number = stops.stp_number
			      and legheader.lgh_number = stops.lgh_number) as fgt_width,
			(select max(fgt_height)
			 	from freightdetail, stops
			   where freightdetail.stp_number = stops.stp_number
			     and legheader.lgh_number = stops.lgh_number) as fgt_height,
			lgh_originzip,
			lgh_destzip,
			legheader.ord_company,
			'UNKNOWN' origin_servicezone,
			'ServiceZone' o_servicezone_t,
			'UNKNOWN' origin_servicearea,
			'ServiceArea' o_servicearea_t,
			'UNKNOWN' origin_servicecenter,
			'ServiceCenter' o_servicecenter_t,
			'UNKNOWN' origin_serviceregion,
			'ServiceRegion' o_serviceregion_t,
			'UNKNOWN' dest_servicezone,
			'ServiceZone' dest_servicezone_t,
			'UNKNOWN' dest_servicearea,
			'ServiceArea' dest_servicearea_t,
			'UNKNOWN' dest_servicecenter,
			'ServiceCenter' dest_servicecenter_t,
			'UNKNOWN' dest_serviceregion,
			'ServiceRegion' dest_serviceregion_t,
			legheader.lgh_204status,  --DPH PTS 27644
			round(isnull(ocomp.cmp_latseconds,0.000)/3600.000,4) as origin_cmp_lat,
			round(isnull(ocomp.cmp_longseconds,0.000)/3600.000,4) as origin_cmp_long,
			round(isnull(octy.cty_latitude,0.000),4) as origin_cty_lat,
			round(isnull(octy.cty_longitude,0.000),4) as origin_cty_long,
			lgh_route,
			lgh_booked_revtype1,
			ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
			labelfile_headers.LghPermitStatus lgh_permit_status_t,
			legheader.lgh_204date,
			-- 33890 BDH 9/12/06 start
			next_ndrp_cmpid,
			next_ndrp_cmpname,
			next_ndrp_ctyname,
			next_ndrp_state,
			next_ndrp_arrivaldate,
			-- 33890 BDH 9/12/06 end
			-- PTS 33913 EMK 10/03/06 start
			ord_bookdate,
			-- PTS 33913 EMK 10/03/06 start
			lgh_ace_status_name,
			--PTS 35199 AROSS 1/4/07
			null,
			-- LOR PTS# 35761
			CASE
				When @LateWarnMode <> 'ARRIVALDEPARTURE' THEN Null
			 	Else ISNULL((SELECT MIN(evt_earlydate)
			    			FROM event e, stops s
			    			WHERE e.stp_number = s.stp_number AND
			    			  s.lgh_number = legheader.lgh_number AND
			    			  e.evt_status = 'OPN'), '20491231')
				END evt_earlydate,
			-- LOR
			--Into  #out_test1
			0 TimeZoneAdjMins,   									--35747
			IsNull(recordlock.locked_by,''),  						-- 36717
			IsNull(session_date, '01/01/1950 00:00:00'),  			--36717
			IsNull(orderheader.ord_cbp,'N') 'CBPOrder',				-- PTS 38765
			IsNull(legheader.lgh_ace_status,'UNK') 'ACE_Status',	-- PTS 38765
			'' trc_latest_ctyst,									-- PTS 38765
			'' trc_latest_cmpid,
			'' trc_last_mobcomm_received,
			'' trc_mobcomm_type,
			'' trc_nearest_mobcomm_nmstct,							-- PTS 38765
			'' next_stop_ref_number,								--PTS 38138 JJF 20080123
			--PTS29383 MBR 08/17/05 40762
			CASE 
				WHEN (SELECT COUNT(*) --ISNULL(SUM(fbc_weight), 0) + ISNULL(SUM(fbc_volume), 0) 
						FROM freight_by_compartment
					   WHERE freight_by_compartment.mov_number = legheader.mov_number AND
							(freight_by_compartment.fbc_weight > 0 or freight_by_compartment.fbc_volume > 0)) > 0 THEN 1
				ELSE 0 END compartment_loaded,
			0 trc_lastpos_lat,										-- PTS 41007 - DJM
			0 trc_lastpos_long,										-- PTS 41007 - DJM
			0 fsc_fuel_surcharge, 	--PTS 41795 JJF 20080506
			/* 08/27/2008 MDH PTS 42301: Reference numbers <<BEGIN>> */
			ref2.ref_type ord_ref_type_2,                  /* 230 */
			ref2.ref_number ord_ref_number_2,              /* 231 */
			ref3.ref_type ord_ref_type_3,                  /* 232 */
			ref3.ref_number ord_ref_number_3,              /* 233 */
			ref4.ref_type ord_ref_type_4,                  /* 234 */
			ref4.ref_number ord_ref_number_4,              /* 235 */
			ref5.ref_type ord_ref_type_5,                  /* 236 */
			ref5.ref_number ord_ref_number_5               /* 237 */
			/* 08/27/2008 MDH PTS 42301: Reference numbers <<END>> */
		FROM legheader_active legheader (nolock)
			-- orderheader,
			left outer join orderheader (nolock) on legheader.ord_hdrnumber = orderheader.ord_hdrnumber --36717
			left outer join recordlock (nolock) on (legheader.mov_number = recordlock.ord_hdrnumber and
			                                        recordlock.session_date = (SELECT MAX(rm.session_date) FROM recordlock rm (nolock) WHERE rm.ord_hdrnumber = legheader.mov_number)) --36717
			left outer join referencenumber ref2 (nolock) on (legheader.ord_hdrnumber = ref2.ref_tablekey and ref2.ref_table = 'orderheader' and ref2.ref_sequence = 2 and @IncludeRefNumbers = 'Y') /* 08/27/2008 MDH PTS 42301: Added */
			left outer join referencenumber ref3 (nolock) on (legheader.ord_hdrnumber = ref3.ref_tablekey and ref3.ref_table = 'orderheader' and ref3.ref_sequence = 3 and @IncludeRefNumbers = 'Y') /* 08/27/2008 MDH PTS 42301: Added */
			left outer join referencenumber ref4 (nolock) on (legheader.ord_hdrnumber = ref4.ref_tablekey and ref4.ref_table = 'orderheader' and ref4.ref_sequence = 4 and @IncludeRefNumbers = 'Y') /* 08/27/2008 MDH PTS 42301: Added */
			left outer join referencenumber ref5 (nolock) on (legheader.ord_hdrnumber = ref5.ref_tablekey and ref5.ref_table = 'orderheader' and ref5.ref_sequence = 5 and @IncludeRefNumbers = 'Y'), /* 08/27/2008 MDH PTS 42301: Added */
			labelfile_headers (nolock),
			stops s1 (nolock),
			stops s2 (nolock),
			company (nolock),
			company ocomp (nolock),
			city octy (nolock) --DPH PTS 22793
			-- PTS 30191 -- BL (start)
			--WHERE company.cmp_id = legheader.ord_billto
		WHERE company.cmp_id = isnull(legheader.ord_billto, 'UNKNOWN')
			-- PTS 30191 -- BL (end)
		  AND    ocomp.cmp_id = legheader.cmp_id_start
		  AND octy.cty_code = legheader.lgh_startcity
		  AND lgh_startdate >= @hoursbackdate
		  AND lgh_startdate <= @hoursoutdate
		  --AND legheader.ord_hdrnumber *= orderheader.ord_hdrnumber  --BDH 36717
		  AND (@city = 0 OR legheader.lgh_startcity = @city)
		  AND (@includedrvplan='Y' or legheader.drvplan_number is null or legheader.drvplan_number = 0)
		  AND (@d_city = 0 OR legheader.lgh_endcity = @d_city)
		  AND (@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_startregion1 + ',', @reg1) > 0)
		  AND (@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_startregion2 + ',', @reg2) > 0)
		  AND (@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_startregion3 + ',', @reg3) > 0)
		  AND (@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_startregion4 + ',', @reg4) > 0)
		  AND (@cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + isNull ((SELECT cmp_othertype1 FROM company WHERE company.cmp_id = legheader.cmp_id_start), 'UNK') + ',', @cmp_othertype1) > 0)
		  AND (@d_reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @d_reg1) > 0)
		  AND (@d_reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @d_reg2) > 0)
		  AND (@d_reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @d_reg3) > 0)
		  AND (@d_reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @d_reg4) > 0)
		  AND (@d_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + isNull ((SELECT cmp_othertype1 FROM company WHERE company.cmp_id = legheader.cmp_id_end), 'UNK') + ',', @d_cmp_othertype1) > 0)
		  --DPH PTS 27213 ('PND')
		  -- LOR PTS# 28465 (@pending_statuses)
	  	  -- LOR PTS# 28465 (@pending_statuses)
		  AND (lgh_outstatus IN ( 'AVL', 'DSP', 'PLN', 'STD', 'MPN', 'PND') OR
		       charindex(lgh_outstatus, @pending_statuses) > 0 OR
		        (lgh_outstatus = 'CMP' AND s2.stp_departure_status <> 'DNE' AND charindex('CMP', @status)>0) AND
		         @v_LghActiveUntilDepCompNBC = 'Y' AND (select isnull(car_board,'N') from carrier where car_id = legheader.lgh_carrier and legheader.lgh_carrier <> 'UNKNOWN') = 'N')
		  AND (@status = '' OR CHARINDEX(lgh_outstatus, @status) > 0)
		  AND (@states = '' OR CHARINDEX(lgh_startstate, @states) > 0)
		  AND (@d_states = '' OR CHARINDEX(lgh_endstate, @d_states) > 0)
		  AND (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0)
		  AND (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0)
		  AND (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0)
		  AND (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
		  AND (@cmpids = ',,' OR CHARINDEX(',' + cmp_id_start + ',', @cmpids) > 0)
		  AND (@d_cmpids = ',,' OR CHARINDEX(',' + cmp_id_end + ',', @d_cmpids) > 0)
		  AND (@teamleader = ',,' OR CHARINDEX(',' + mpp_teamleader + ',', @teamleader) > 0)
		  AND (@tm_status = ',,' OR lgh_tm_status is null or CHARINDEX(lgh_tm_status, @tm_status) > 0)
		  AND (@lgh_type1 = ',,' OR lgh_type1 is null or CHARINDEX(',' + lgh_type1 + ',', @lgh_type1) > 0 or @lgh_type1 = ',UNK,')
		  AND (@lgh_type2 = ',,' OR lgh_type2 is null or CHARINDEX(',' + lgh_type2 + ',', @lgh_type2) > 0 or @lgh_type2 = ',UNK,')
		  AND (@company = ',,' OR CHARINDEX(',' + legheader.ord_ord_subcompany + ',', @company) > 0)
		  AND (@bookedby = ',ALL,' OR CHARINDEX(',' + rtrim(ltrim(legheader.ord_bookedby)) + ',', @bookedby) > 0)
		  AND (@trltype1 = ',,' OR CHARINDEX(',' + legheader.ord_trl_type1 + ',', @trltype1) > 0)
		  AND (ISNULL(legheader.ord_totalmiles, -1) between @miles_min and @miles_max)
		  AND legheader.stp_number_start = s1.stp_number
		  AND legheader.stp_number_end = s2.stp_number
		  -- PTS 30191 -- BL (start)
		  -- AND (@billto = ',,' OR CHARINDEX(',' + legheader.ord_billto + ',', @billto) > 0)
		  AND (@billto = ',,' OR CHARINDEX(',' + isnull(legheader.ord_billto, 'UNKNOWN') + ',', @billto) > 0)
	  	  -- PTS 30191 -- BL (end)
		  AND (@lgh_hzd_cmd_classes = ',UNK,' OR CHARINDEX(',' + lgh_hzd_cmd_class + ',', @lgh_hzd_cmd_classes) > 0)/*PTS 23162 CGK 9/1/2004*/
		  AND (@lgh_route = ',,' OR lgh_route is null OR CHARINDEX(',' + lgh_route + ',', @lgh_route) > 0)
		  AND (@lgh_booked_revtype1 = ',UNK,' OR lgh_booked_revtype1 is null OR CHARINDEX(',' + lgh_booked_revtype1 + ',', @lgh_booked_revtype1) > 0)
		  AND (@orderedby = ',,' OR CHARINDEX(',' + legheader.ord_company + ',', @orderedby) > 0)
		  AND (@lgh_permit_status = ',UNK,' OR CHARINDEX(',' + legheader.lgh_permit_status + ',', @lgh_permit_status) > 0)

-- Only perform the following logic if the Feature is on.
if @localization = 'Y'
Begin
 -- PTS 22601 - DJM
	SELECT @o_servicearea = ',' + LTRIM(RTRIM(ISNULL(@o_servicearea, '')))  + ','
	SELECT @o_servicezone = ',' + LTRIM(RTRIM(ISNULL(@o_servicezone, '')))  + ','
	SELECT @o_servicecenter = ',' + LTRIM(RTRIM(ISNULL(@o_servicecenter, '')))  + ','
	SELECT @o_serviceregion = ',' + LTRIM(RTRIM(ISNULL(@o_serviceregion, '')))  + ','
	SELECT @dest_servicearea = ',' + LTRIM(RTRIM(ISNULL(@dest_servicearea, '')))  + ','
	SELECT @dest_servicezone = ',' + LTRIM(RTRIM(ISNULL(@dest_servicezone, '')))  + ','
	SELECT @dest_servicecenter = ',' + LTRIM(RTRIM(ISNULL(@dest_servicecenter, '')))  + ','
	SELECT @dest_serviceregion = ',' + LTRIM(RTRIM(ISNULL(@dest_serviceregion, '')))  + ','

	/* PTS 20302 - DJM - display the localization settings for the Origin and Desitinations */
	select @o_servicezone_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )
	select @o_servicecenter_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )
	select @o_serviceregion_labelname = 'Origin ' + (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
	select @o_sericearea_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )
	select @dest_servicezone_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )
	select @dest_sericearea_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )
	select @dest_servicecenter_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )
	select @dest_serviceregion_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
	Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'

	/* PTS 26766 - DJM - Set the Localization fields */
	--select temp1.ord_hdrnumber,
	-- orderheader.ord_origincity,
	-- temp1.lgh_originzip,
	Update @ttbl1
		set origin_servicezone = isNull((select cz_zone from cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip),'UNK'),
			o_servicezone_t = @o_servicezone_labelname,
			origin_servicearea = isNull((select cz_area from cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip),'UNK'),
			o_servicearea_t = @o_sericearea_labelname,
			origin_servicecenter = isNull((select Case isNull(@service_revtype,'UNK')
									when 'REVTYPE1' then
									 (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
									when 'REVTYPE2' then
									 (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
									when 'REVTYPE3' then
									 (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
									when 'REVTYPE4' then
									 (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
									else 'UNK'
									End),'UNK'),
			o_servicecenter_t = @o_servicecenter_labelname,
			origin_serviceregion = isNull((select Case isNull(@service_revtype,'UNK')
									when 'REVTYPE1' then
									 (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
									when 'REVTYPE2' then
									 (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
									when 'REVTYPE3' then
									 (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
									when 'REVTYPE4' then
									 (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
									else
									  'UNKNOWN'
									End),'UNK') ,
			o_serviceregion_t = @o_serviceregion_labelname,
			dest_servicezone = isNull((select cz_zone from cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip),'UNK') ,
			dest_servicezone_t = @dest_servicezone_labelname ,
			dest_servicearea = isNull((select cz_area from cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip),'UNK') ,
			dest_servicearea_t = @dest_sericearea_labelname ,
			dest_servicecenter = isnull((select Case isNull(@service_revtype,'UNKNOWN')
									when 'REVTYPE1' then
									 (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
									when 'REVTYPE2' then
									 (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
									when 'REVTYPE3' then
									 (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
									when 'REVTYPE4' then
									 (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
									else
									  'UNKNOWN'
									End),'UNK') ,
			dest_servicecenter_t = @dest_servicecenter_labelname ,
			dest_serviceregion = isnull((select Case isNull(@service_revtype,'UNK')
									  when 'REVTYPE1' then
									   (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
									  when 'REVTYPE2' then
									   (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
									  when 'REVTYPE3' then
									   (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
									  when 'REVTYPE4' then
									   (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
									  else
									    'UNK'
									  End),'UNK') ,
			dest_serviceregion_t = @dest_serviceregion_labelname
		From Orderheader, @ttbl1 temp1
		where orderheader.ord_hdrnumber = temp1.ord_hdrnumber

	/* PTS 22601 - DJM - Remove rows from the temp table that do not meet the Localization parameter requirements,
	if any
	*/
	Delete from @ttbl1
		where CHARINDEX(',' + isnull(origin_servicezone,'') + ',', @o_servicezone) = 0
		and @o_servicezone <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(origin_servicearea,'') + ',', @o_servicearea) = 0
		and @o_servicearea <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(origin_servicecenter,'') + ',', @o_servicecenter) = 0
		and @o_servicecenter <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(origin_serviceregion,'') + ',', @o_serviceregion) = 0
		and @o_serviceregion <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(dest_servicezone,'') + ',', @dest_servicezone) = 0
		and @dest_servicezone <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(dest_servicearea,'') + ',', @dest_servicearea) = 0
		and @dest_servicearea <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(dest_servicecenter,'') + ',', @dest_servicecenter) = 0
		and @dest_servicecenter <> ',,'

	Delete from @ttbl1
		where CHARINDEX(',' + isnull(dest_serviceregion,'') + ',', @dest_serviceregion) = 0
		and @dest_serviceregion <> ',,'

	/* PTS 22601 - DJM - Update the table with the localization descriptions */
	Update @ttbl1
		set origin_servicezone = isNull((select name from labelfile where labeldefinition = 'ServiceZone' and abbr = origin_servicezone),'UNKNOWN'),
			origin_servicearea = isNull((select name from labelfile where labeldefinition = 'ServiceArea' and abbr = origin_servicearea),'UNKNOWN'),
			origin_servicecenter = isnull((select name from labelfile where labeldefinition = 'ServiceCenter' and abbr = origin_servicecenter),'UNKNOWN'),
			origin_serviceregion = isNull((select name from labelfile where labeldefinition = 'ServiceRegion' and abbr = origin_serviceregion),'UNKNOWN') ,
			dest_servicezone = isNull((select name from labelfile where labeldefinition = 'ServiceZone' and abbr = dest_servicezone),'UNKNOWN'),
			dest_servicearea = isNull((select name from labelfile where labeldefinition = 'ServiceArea' and abbr = dest_servicearea),'UNKNOWN'),
			dest_servicecenter = isnull((select name from labelfile where labeldefinition = 'ServiceCenter' and abbr = dest_servicecenter),'UNKNOWN') ,
			dest_serviceregion= isnull((select name from labelfile where labeldefinition = 'ServiceRegion' and abbr = dest_serviceregion),'UNKNOWN')
End

--PTS 40155 JJF 20071128
SELECT @rowsecurity = gi_string1
	FROM generalinfo
	WHERE gi_name = 'RowSecurity'

--PTS 41877
--SELECT @tmwuser = suser_sname()
exec @tmwuser = dbo.gettmwuser_fn

IF @rowsecurity = 'Y' AND EXISTS(SELECT * FROM UserTypeAssignment WHERE usr_userid = @tmwuser) BEGIN
	DELETE  @ttbl1
		FROM @ttbl1 tp
		WHERE EXISTS(SELECT * FROM orderheader oh WHERE tp.mov_number = oh.mov_number)
		AND NOT EXISTS ((SELECT *
						FROM orderheader oh
						WHERE tp.mov_number = oh.mov_number
								AND isnull(oh.ord_BelongsTo, 'UNK') = 'UNK')
			)
		AND NOT EXISTS(SELECT *
						FROM orderheader oh
						WHERE tp.mov_number = oh.mov_number
						AND EXISTS(SELECT *
									FROM UserTypeAssignment
									WHERE usr_userid = @tmwuser
									AND (uta_type1 = oh.ord_BelongsTo
										OR uta_type1 = 'UNK')))
END
--END PTS 40155 JJF 20071128

-- PTS 36608 vjh
-- Only perform the following logic if the Feature is on.
-- This assumes that all check call times are in the local dispatch TZ
--vjh 38226 TZ sift the departure date before comparison
--vjh 38677 redefine ord_manualeventcallminutes
--	0 means scheduled arrival
--	-1 means Apocalypse
if @ManualCheckCall = 'Y'
Begin
	update @ttbl1 set manualcheckcalltime =
		case
--			when s1.stp_status = 'OPN' and isnull(ord_manualeventcallminutes,0) = 0 then @Apocalypse
			when s1.stp_status = 'OPN' and isnull(ord_manualeventcallminutes,-1) = -1 then @Apocalypse  /* 03/05/2008 MDH PTS 41679: Changed from isNull (...,0) */
			when s1.stp_status = 'OPN' then dateadd(minute, -1*isnull(ord_manualeventcallminutes,0) -
(@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0))
, stp_arrivaldate)
			when isnull(ord_manualcheckcallminutes,0) = 0 then @Apocalypse
			when (select max(ckc_date) from checkcall where ckc_lghnumber = t.lgh_number) >
				dateadd(minute, 0 - (@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0))
				, stp_departuredate) then
				dateadd(minute, isnull(ord_manualcheckcallminutes,0), (select max(ckc_date) from checkcall where ckc_lghnumber = t.lgh_number))
			else dateadd(minute, isnull(ord_manualcheckcallminutes,0) -
(@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0))
, stp_departuredate)
		end
	from @ttbl1 t join legheader_active l on t.lgh_number = l.lgh_number
	join stops s1 on l.stp_number_start = s1.stp_number
	join orderheader o on l.ord_hdrnumber = o.ord_hdrnumber
	join city c on c.cty_code = s1.stp_city
End

/* 35747 DPETE if GI specified local time xzone compute TImeZone minutes adjustment for each row */
If @v_GILocalTImeOption = 'LOCAL'
   BEGIN
     update @ttbl1 set TimeZoneADJMins =
       Case
         when lgh_outstatus = 'Completed' then 0  -- trip is done it cant be late
         when evt_latedate is null and lgh_outstatus = 'Started' then 0  -- dw sets flag to GREEN for this
         when evt_latedate is null then   -- dw uses lgh_startdate if htis is true
            @v_LocalCityTZAdjFactor -
             (select ((isnull(cty_GMTDelta,5)
            + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end))) * 60)
            + isnull(cty_TZMins,0)
             From city where cty_code = o_city)
         else
              @v_LocalCityTZAdjFactor -
             (select ((isnull(cty_GMTDelta,5)
              + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end))) * 60)
              + isnull(cty_TZMins,0)
              From city where cty_code = (select stp_city from stops where stops.lgh_number = tt1.lgh_number and stp_mfh_sequence =
                       (select min(stp_mfh_sequence) from stops where stops.lgh_number = tt1.lgh_number and (stp_status = 'OPN' or isnull(stp_departure_status,stp_status) = 'OPN'))))


         end
      from @ttbl1 tt1
   END
/* 35747 end */

/*
	PTS 38765 - DJM - trc_latest_ctyst and trc_latest_cmpid added to display the last
	completed stop from the current trip.  Only displays data once the trip is started.			*/
update t1
	set t1.trc_latest_ctyst = city.cty_nmstct,
		t1.trc_latest_cmpid = stops.cmp_id
	from stops, @ttbl1 t1 , city
	where stops.lgh_number = t1.lgh_number
		and stops.stp_city = city.cty_code
		and stops.stp_status = 'DNE'
		and stops.stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where stops.lgh_number = t1.lgh_number and stp_status = 'DNE')

update t1
	set trc_last_mobcomm_received = isNull(trc.trc_lastpos_datetime, '1900/01/01'),
		trc_mobcomm_type = isNull(trc.trc_mobcommtype, 'UNKNOWN'),
		trc_nearest_mobcomm_nmstct = isNull(trc.trc_lastpos_nearctynme, 'UNKNOWN'),
		trc_lastpos_lat = isNull(trc.trc_lastpos_lat,0),					-- PTS 42829 - DJM
		trc_lastpos_long = isNull(trc.trc_lastpos_long,0)					-- PTS 42829 - DJM
	from @ttbl1 t1 inner join tractorprofile trc on t1.evt_tractor = trc.trc_number
-- End 38765

--vjh pts 38986
if @PlnWrkshtRefStr1 = 'Y' begin
	update @ttbl1 set ref_type = @PlnWrkshtRefStr3, ref_number = (select min(r.ref_number) from referencenumber r where r.ref_table=@PlnWrkshtRefStr2 and r.ref_type=@PlnWrkshtRefStr3 and r.ref_tablekey=s.stp_number)
	from @ttbl1 l join stops s on l.lgh_number = s.lgh_number
end

--PTS 38138 JJF 20080123
IF EXISTS(SELECT *
			FROM generalinfo gi
			WHERE gi.gi_name = 'NextDrpRefTypeOnPlanningWst'
						and isnull(gi.gi_string1, '') <> '') BEGIN
	UPDATE @ttbl1
	SET next_stop_ref_number = ref.ref_number
	FROM @ttbl1 t1 inner join legheader_active lgh on t1.lgh_number = lgh.lgh_number
			inner join referencenumber ref on (lgh.next_drp_stp_number = ref.ref_tablekey and ref.ref_table = 'stops'),
		generalinfo gi
	WHERE ref.ref_type = gi.gi_string1
		and gi.gi_name = 'NextDrpRefTypeOnPlanningWst'
END
--END PTS 38138 JJF 20080123

--PTS 41795 JJF 20080123
IF EXISTS(SELECT *
			FROM generalinfo gi
			WHERE gi.gi_name = 'FSCChargeTypes'
						and isnull(gi.gi_string1, '') <> '') BEGIN

	SELECT @FSCChargeTypeList = gi.gi_string1
	FROM generalinfo gi
	WHERE gi.gi_name = 'FSCChargeTypes'

	DECLARE @FSCChargeTypes TABLE  (value VARCHAR(6))

	INSERT @FSCChargeTypes(value) SELECT * FROM CSVStringsToTable_fn(@FSCChargeTypeList)

	UPDATE @ttbl1
	SET fsc_fuel_surcharge = isnull((SELECT sum(isnull(ivd.ivd_charge, 0)) 
								FROM orderheader oh inner join invoicedetail ivd on oh.ord_hdrnumber = ivd.ord_hdrnumber 
										INNER JOIN @FSCChargeTypes cht on ivd.cht_itemcode = cht.value
								WHERE (t1.mov_number = oh.mov_number) or (t1.ord_hdrnumber = ivd.ord_hdrnumber)
							) ,0)
	FROM @ttbl1 t1
END
--END PTS 41795 JJF 20080123


--Select * from @ttbl1
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
	fgt_description,
	cmd_count,
	ord_hdrnumber,
	evt_driver1,
	evt_driver2,
	evt_tractor,
	lgh_primary_trailer,
	trl_type1,
	evt_carrier,
	mov_number,
/* 08/27/2008 MDH PTS 42301: <<BEGIN>> */
	ord_ref_type_2	,
	ord_ref_number_2,
	ord_ref_type_3	,
	ord_ref_number_3,
	ord_ref_type_4	,
	ord_ref_number_4,
	ord_ref_type_5	,
	ord_ref_number_5
/* 08/27/2008 MDH PTS 42301: <<END>> */
FROM @ttbl1


GO

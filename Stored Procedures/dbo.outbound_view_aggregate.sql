SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************
Modifications:
* 9/13/2006 PTS 33890 - BDH - Added 2nd next drop fields from legheader_active.

********************************************************************************************/

create    PROCEDURE [dbo].[outbound_view_aggregate]
	@revtype1 varchar (254),
	@revtype2 varchar (254),
	@revtype3 varchar (254),
	@revtype4 varchar (254),
	@trltype1 varchar (254),
	@company varchar (254),
	@states varchar (254),
	@cmpids varchar (254),
	@reg1 varchar (254),
	@reg2 varchar (254),
	@reg3 varchar (254),
	@reg4 varchar (254),
	@city int,
	@hoursback int,
	@hoursout int,
	@status char (254),
	@bookedby varchar (254),
	@ref_type  varchar(6),
	@teamleader varchar(254), 
	@d_states varchar (254), 
	@d_cmpids varchar (254), 
	@d_reg1 varchar (254), 
	@d_reg2 varchar (254), 
	@d_reg3 varchar (254), 
	@d_reg4 varchar (254), 
	@d_city int,
	@includedrvplan varchar(3),
	@miles_min int,
	@miles_max int,
	@tm_status varchar(254),
	@lgh_type1 varchar(254),
	@lgh_type2 varchar(254),
	@billto varchar(254),
	@lgh_hzd_cmd_classes varchar (255), /*PTS 23162 CGK 9/1/2004*/
	@includeplanrec char(1),
	@lgh_permit_status varchar(254),
    @startdate			datetime,
	@daysout			int
AS

/* 09/03/2010 MDH PTS 53570: <<BEGIN>> Moved from just prior to insert into to here to minimize recompiles. */
--PTS 40155 JJF 20071128
CREATE TABLE #resultset(
	lgh_number int NULL,
	o_cmpid varchar(12) NULL,
	o_cmpname varchar(100) NULL,
	o_ctyname varchar(25) NULL,
	d_cmpid varchar(12) NULL,
	d_cmpname varchar(100) NULL,
	d_ctyname varchar(25) NULL,
	f_cmpid varchar(8) NULL,
	f_cmpname varchar(100) NULL,
	f_ctyname varchar(25) NULL,
	l_cmpid varchar(8) NULL,
	l_cmpname varchar(100) NULL,
	l_ctyname varchar(25) NULL,
	lgh_startdate datetime NULL,
	lgh_enddate datetime NULL,
	o_state varchar(6) NULL,
	d_state varchar(6) NULL,
	lgh_schdtearliest datetime NULL,
	lgh_schdtlatest datetime NULL,
	cmd_code varchar(8) NULL,
	fgt_description varchar(60) NULL,
	cmd_count int NULL,
	ord_hdrnumber int NULL,
	evt_driver1 varchar(45) NULL,
	evt_driver2 varchar(45) NULL,
	evt_tractor varchar(8) NULL,
	lgh_primary_trailer varchar(13) NULL,
	trl_type1 varchar(6) NULL,
	evt_carrier varchar(8) NULL,
	mov_number int NULL,
	ord_availabledate datetime NULL,
	ord_stopcount tinyint NULL,
	ord_totalcharge float NULL,
	ord_totalweight float NULL,
	ord_length money NULL,
	ord_width money NULL,
	ord_height money NULL,
	ord_totalmiles int NULL,
	ord_number char(12) NULL,
	o_city int NULL,
	d_city int NULL,
	lgh_priority varchar(6) NULL,
	lgh_outstatus varchar(20) NULL,
	lgh_instatus varchar(20) NULL,
	lgh_priority_name varchar(20) NULL,
	ord_subcompany varchar(20) NULL,
	trl_type1_name varchar(20) NULL,
	lgh_class1 varchar(20) NULL,
	lgh_class2 varchar(20) NULL,
	lgh_class3 varchar(20) NULL,
	lgh_class4 varchar(20) NULL,
	Company varchar(7) NULL,
	trllabel1 varchar(20) NULL,
	revlabel1 varchar(20) NULL,
	revlabel2 varchar(20) NULL,
	revlabel3 varchar(20) NULL,
	revlabel4 varchar(20) NULL,
	ord_bookedby varchar(20) NULL,
	dw_rowstatus char(10) NULL,
	lgh_primary_pup varchar(13) NULL,
	triptime float NULL,
	ord_totalweightunits varchar(6) NULL,
	ord_lengthunit varchar(6) NULL,
	ord_widthunit varchar(6) NULL,
	ord_heightunit varchar(6) NULL,
	loadtime float NULL,
	unloadtime float NULL,
	unloaddttm datetime NULL,
	unloaddttm_early datetime NULL,
	unloaddttm_late datetime NULL,
	ord_totalvolume int NULL,
	ord_totalvolumeunits varchar(6) NULL,
	washstatus varchar(1) NULL,
	f_state varchar(6) NULL,
	l_state varchar(6) NULL,
	evt_driver1_id varchar(8) NULL,
	evt_driver2_id varchar(8) NULL,
	ref_type varchar(6) NULL,
	ref_number varchar(30) NULL,
	d_address1 varchar(40) NULL,
	d_address2 varchar(40) NULL,
	ord_remark varchar(255) NULL,
	mpp_teamleader varchar(6) NULL,
	lgh_dsp_date datetime NULL,
	lgh_geo_date datetime NULL,
	ordercount smallint NULL,
	npup_cmpid varchar(8) NULL,
	npup_cmpname varchar(30) NULL,
	npup_ctyname varchar(25) NULL,
	npup_state varchar(6) NULL,
	npup_arrivaldate datetime NULL,
	ndrp_cmpid varchar(8) NULL,
	ndrp_cmpname varchar(30) NULL,
	ndrp_ctyname varchar(25) NULL,
	ndrp_state varchar(6) NULL,
	ndrp_arrivaldate datetime NULL,
	can_ld_expires datetime NULL,
	xdock int NULL,
	feetavailable smallint NULL,
	opt_trc_type4 varchar(6) NULL,
	opt_trc_type4_label varchar(20) NULL,
	opt_trl_type4 varchar(6) NULL,
	opt_trl_type4_label varchar(20) NULL,
	ord_originregion1 varchar(6) NULL,
	ord_originregion2 varchar(6) NULL,
	ord_originregion3 varchar(6) NULL,
	ord_originregion4 varchar(6) NULL,
	ord_destregion1 varchar(6) NULL,
	ord_destregion2 varchar(6) NULL,
	ord_destregion3 varchar(6) NULL,
	ord_destregion4 varchar(6) NULL,
	npup_departuredate datetime NULL,
	ndrp_departuredate datetime NULL,
	ord_fromorder varchar(12) NULL,
	c_lgh_type1 varchar(20) NULL,
	lgh_type1_label varchar(20) NULL,
	c_lgh_type2 varchar(20) NULL,
	lgh_type2_label varchar(20) NULL,
	lgh_tm_status varchar(6) NULL,
	lgh_tour_number int NULL,
	extrainfo1 varchar(255) NULL,
	extrainfo2 varchar(30) NULL,
	extrainfo3 varchar(30) NULL,
	extrainfo4 varchar(30) NULL,
	extrainfo5 varchar(30) NULL,
	extrainfo6 varchar(30) NULL,
	extrainfo7 varchar(30) NULL,
	extrainfo8 varchar(30) NULL,
	extrainfo9 varchar(30) NULL,
	extrainfo10 varchar(30) NULL,
	extrainfo11 varchar(30) NULL,
	extrainfo12 varchar(30) NULL,
	extrainfo13 varchar(30) NULL,
	extrainfo14 varchar(30) NULL,
	extrainfo15 varchar(30) NULL,
	o_cmp_geoloc varchar(50) NULL,
	d_cmp_geoloc varchar(50) NULL,
	mpp_fleet varchar(6) NULL,
	mpp_fleet_name varchar(20) NULL,
	next_stp_event_code varchar(6) NULL,
	next_stop_of_total varchar(10) NULL,
	lgh_comment varchar(255) NULL,
	lgh_earliest_pu datetime NULL,
	lgh_latest_pu datetime NULL,
	lgh_earliest_unl datetime NULL,
	lgh_latest_unl datetime NULL,
	lgh_miles int NULL,
	lgh_linehaul float NULL,
	evt_latedate datetime NULL,
	lgh_ord_charge float NULL,
	lgh_act_weight float NULL,
	lgh_est_weight float NULL,
	lgh_tot_weight float NULL,
	lgh_outstat varchar(6) NULL,
	lgh_max_weight_exceeded char(1) NULL,
	lgh_reftype varchar(6) NULL,
	lgh_refnum varchar(30) NULL,
	trctype1 varchar(20) NULL,
	trc_type1name varchar(20) NULL,
	trctype2 varchar(20) NULL,
	trc_type2name varchar(20) NULL,
	trctype3 varchar(20) NULL,
	trc_type3name varchar(20) NULL,
	trctype4 varchar(20) NULL,
	trc_type4name varchar(20) NULL,
	lgh_etaalert1 char(1) NULL,
	Expression1 int NULL,
	lgh_tm_statusname varchar(20) NULL,
	ord_billto varchar(8) NULL,
	cmp_name varchar(100) NULL,
	lgh_carrier varchar(8) NULL,
	TotalCarrierPay money NULL,
	lgh_hzd_cmd_class varchar(8) NULL,
	toep_id int NULL,
	toep_ordered_count int NULL,
	toep_planned_count int NULL,
	toep_delivery_date datetime NULL,
	count_of_loads int NULL,
	lgh_permit_status varchar(6) NULL,
	lgh_permit_status_t varchar(20) NULL,
	next_ndrp_cmpid varchar(8) NULL,
	next_ndrp_cmpname varchar(30) NULL,
	next_ndrp_ctyname varchar(25) NULL,
	next_ndrp_state varchar(6) NULL,
	next_ndrp_arrivaldate datetime NULL,
	ord_rate money NULL,
	--PTS 46118 JJF 20090709
	toep_available_count int null,
	toep_completed_count int null,
	--END PTS 46118 JJF 20090709
	--PTS 47858 JJF 20090716
	toep_ordered_work_quantity float NULL,
	toep_planned_work_quantity float NULL,
	toep_work_quantity_per_load float NULL,
	toep_work_unit varchar(6) NULL, 
	--PTS 47858 JJF 20090716
	ma_transaction_id		bigint			null,	-- RE - PTS #48722
	ma_tour_number			int				null,	-- RE - PTS #48722
	ma_tour_sequence		tinyint			null,	-- RE - PTS #48722
	ma_tour_max_sequence	tinyint			null,	-- RE - PTS #48722
	ma_trc_number			varchar(8)		null,	-- RE - PTS #48722
	ma_mpp_id				varchar(8)		null,	-- RE - PTS #48722
	lgh_chassis				varchar(13)		null,
	lgh_chassis2			varchar(13)		null,
	lgh_dolly				varchar(13)		null,
	lgh_dolly2				varchar(13)		null,
	lgh_trailer3			varchar(13)		null,
	lgh_trailer4			varchar(13)		null,
	ord_company				varchar(8)		NULL,	/* 09/03/2010 MDH PTS 53570: Added */
	ud_column1	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column1_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column2	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column2_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column3	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column3_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column4	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column4_t varchar(30)		 --	PTS 51911 SGB User Defined column header		
	)
--END PTS 40155 JJF 20071128
/* 09/03/2010 MDH PTS 53570: <<END>> */
DECLARE 
	@char8	  	varchar(8),
	@char1		varchar(1),						
	@char30   	varchar(30),
	@char20   	varchar(20),
	@char25   	varchar(25),
	@char40		varchar(40),
	@cmdcount 	int,
	@float		float,
	@hoursbackdate	datetime,
	@hoursoutdate	datetime,
	@gistring1	varchar(60),
	@dttm		datetime,
	@char2		char(2),
	@varchar45	varchar(45),
	@varchar6	varchar(6), 
	@runpups        char(1), 
	@rundrops       char(1), 
	@retvarchar     varchar(3),
	@LateWarnMode	VARCHAR(60),
	@PWExtraInfoLocation varchar(20),
   	@ud_column1 char(1), --PTS 51911 SGB
	@ud_column2 char(1),  --PTS 51911 SGB
	@ud_column3 char(1), --PTS 51911 SGB
	@ud_column4 char(1),  --PTS 51911 SGB
	@procname varchar(255), --PTS 51911 SGB
	@udheader varchar(30) --PTS 51911 SGB    	
	

-- RE - PTS #52017 BEGIN
DECLARE	@MatchAdviceInterface		CHAR(1)
DECLARE	@ma_transaction_id			BIGINT
DECLARE	@ma_inserted_date			DATETIME
DECLARE	@null_varchar8				VARCHAR(8)
DECLARE	@null_varchar100			VARCHAR(100)
DECLARE	@null_int					INTEGER
DECLARE	@Check						INTEGER
DECLARE @MatchAdviceMultiCompany	CHAR(1)
DECLARE @DefaultCompanyID			VARCHAR(8)
DECLARE @UserCompanyID				VARCHAR(8)
DECLARE @TMWUser					VARCHAR(255)

SELECT	@null_varchar8 = NULL, @null_int = NULL, @null_varchar100 = NULL

SELECT	@MatchAdviceInterface = LEFT(gi_string1, 1),
		@Check = gi_integer1
  FROM	generalinfo
 WHERE	gi_name = 'MatchAdviceInterface'
 
 SELECT	@MatchAdviceMultiCompany = LEFT(gi_string1, 1)	
  FROM	generalinfo
 WHERE	gi_name = 'MatchAdviceMultiCompany'
 
 exec @tmwuser = dbo.gettmwuser_fn
 
SELECT	@MatchAdviceInterface = ISNULL(@MatchAdviceInterface, 'N'), @Check = ISNULL(@Check, 60), @MatchAdviceMultiCompany = ISNULL(@MatchAdviceMultiCompany, 'N'), @DefaultCompanyID = ISNULL(@DefaultCompanyID, '')



IF @MatchAdviceInterface = 'Y'
BEGIN
	IF @MatchAdviceMultiCompany = 'Y'
	BEGIN
		 SELECT	@DefaultCompanyID = ISNULL(ttsusers.usr_type1, @DefaultCompanyID)
		   FROM	ttsusers
		  WHERE	(usr_userid = @tmwuser
		     OR  usr_windows_userid = @TMWUser)
  
		SELECT	TOP 1 
				@ma_transaction_id = transaction_id,
				@ma_inserted_date = inserted_date
		  FROM	LastMATransactionID
		 WHERE	company_id = @DefaultCompanyID
		ORDER BY inserted_date DESC
	END
	ELSE
	BEGIN
		SELECT	TOP 1 
				@ma_transaction_id = transaction_id,
				@ma_inserted_date = inserted_date
		  FROM	LastMATransactionID
		ORDER BY inserted_date DESC
	END

	IF ISNULL(@ma_transaction_id, -1) = -1
	BEGIN
		SET	@ma_transaction_id = NULL
	END
	ELSE
	BEGIN
		IF DATEDIFF(mi, @ma_inserted_date, GETDATE()) > @Check
		BEGIN
			SET	@ma_transaction_id = NULL
		END
	END
END
ELSE
BEGIN
	SET	@ma_transaction_id = NULL
END
-- RE - PTS #52017 END

--PTS 51911 SGB Only run when setting turned on 
Select @ud_column1 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column2 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column3 = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column4 = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'


--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
--declare @tmwuser varchar(255)
--END PTS 40155 JJF 20071128

/* 07/09/2009 MDH PTS 47833: Get cmd_total GI Setting */
DECLARE @v_cmd_count_setting VARCHAR (10)
SELECT @v_cmd_count_setting = upper(isnull(gi_string1,'Pieces')) FROM generalinfo WHERE gi_name = 'cmd_total'
IF @v_cmd_count_setting <> 'FREIGHT' SELECT @v_cmd_count_setting = 'PIECES'
/* 07/09/2009 MDH PTS 47833: <<END>> */

IF @hoursback = 0
	SELECT @hoursback= 1000000

IF @hoursout = 0
	SELECT @hoursout = 1000000
/* Get the hoursback and hoursout into variables
   Avoid doing this in the query --Jude */
/*JLB 44424
SELECT @hoursbackdate = DATEADD(hour, -@hoursback, GETDATE())
SELECT @hoursoutdate = DATEADD(hour,  @hoursout, GETDATE())
*/
--PTS 54465 20110223 - last included date off by 1
--if @daysout = 0 
--begin
--  set @daysout = 1
--end
--END PTS 54465 20110223 - last included date off by 1

if @startdate > '01/01/50'
begin
	SELECT @hoursbackdate = @startdate
	--PTS 54465 20110223 - last included date off by 1
	--SELECT @hoursoutdate = DATEADD(ss, ((@daysout * 24 * 60 * 60)-1), @startdate)
	SELECT @hoursoutdate = DATEADD(ss, (((@daysout + 1) * 24 * 60 * 60) - 1), @startdate)
	--END PTS 54465 20110223 - last included date off by 1
end
else
begin
	SELECT @hoursbackdate = DATEADD(hour, -@hoursback, GETDATE())
	SELECT @hoursoutdate = DATEADD(hour,  @hoursout, GETDATE())
end
SELECT @LateWarnMode = gi_string1 FROM generalinfo WHERE gi_name = 'PlnWrkshtLateWarnMode'

-- PTS 28565 JLB need to add the ability to determine where extrainfo comes from
Select @PWExtraInfoLocation = UPPER(isnull(gi_string1,'ORDERHEADER'))
  from generalinfo
 where gi_name = 'PWExtraInfoLocation'

If @miles_min = 0 select @miles_min = -1000
IF @city IS NULL
   SELECT @city = 0
IF @status IS NULL
   SELECT @status = ''
IF @states IS NULL
   SELECT @states = ''
IF @d_city IS NULL
   SELECT @d_city = 0
IF @d_states IS NULL
   SELECT @d_states = ''

IF @lgh_permit_status IS NULL OR @lgh_permit_status = ''
	SELECT @lgh_permit_status = 'UNK'
SELECT @lgh_permit_status = ',' + LTRIM(RTRIM(ISNULL(@lgh_permit_status, ''))) + ','

SELECT @bookedby = ',' + LTRIM(RTRIM(CASE ISNULL(@bookedby, '') WHEN '' THEN 'ALL' ELSE @bookedby END)) + ','
SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, '')))  + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, '')))  + ','
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, '')))  + ','
SELECT @cmpids = ',' + LTRIM(RTRIM(ISNULL(@cmpids, '')))  + ','
SELECT @d_cmpids = ',' + LTRIM(RTRIM(ISNULL(@d_cmpids, '')))  + ','
SELECT @teamleader = ',' + LTRIM(RTRIM(ISNULL(@teamleader, '')))  + ','
SELECT @company = ',' + LTRIM(RTRIM(ISNULL(@company, '')))  + ','
SELECT @trltype1 = ',' + LTRIM(RTRIM(ISNULL(@trltype1, '')))  + ','
SELECT @reg1 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg1, '') WHEN '' THEN 'UNK' ELSE @reg1 END)) + ','
SELECT @reg2 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg2, '') WHEN '' THEN 'UNK' ELSE @reg2 END)) + ','
SELECT @reg3 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg3, '') WHEN '' THEN 'UNK' ELSE @reg3 END)) + ','
SELECT @reg4 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg4, '') WHEN '' THEN 'UNK' ELSE @reg4 END)) + ','
SELECT @d_reg1 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg1, '') WHEN '' THEN 'UNK' ELSE @d_reg1 END)) + ','
SELECT @d_reg2 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg2, '') WHEN '' THEN 'UNK' ELSE @d_reg2 END)) + ','
SELECT @d_reg3 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg3, '') WHEN '' THEN 'UNK' ELSE @d_reg3 END)) + ','
SELECT @d_reg4 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg4, '') WHEN '' THEN 'UNK' ELSE @d_reg4 END)) + ','
SELECT @tm_status = ',' + LTRIM(RTRIM(ISNULL(@tm_status, '')))  + ','
SELECT @lgh_type1 = ',' + LTRIM(RTRIM(ISNULL(@lgh_type1, '')))  + ','
SELECT @lgh_type2 = ',' + LTRIM(RTRIM(ISNULL(@lgh_type2, '')))  + ','
SELECT @billto = ',' + LTRIM(RTRIM(ISNULL(@billto, '')))  + ',' --vjh 21520
SELECT @lgh_hzd_cmd_classes = ',' + LTRIM(RTRIM(CASE ISNULL(@lgh_hzd_cmd_classes, '') WHEN '' THEN 'UNK' ELSE @lgh_hzd_cmd_classes END)) + ','

INSERT INTO #resultset(
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
	lgh_priority,
	lgh_outstatus,
	lgh_instatus,
	lgh_priority_name,
	ord_subcompany,
	trl_type1_name,
	lgh_class1,
	lgh_class2,
	lgh_class3,
	lgh_class4,
	Company,
	trllabel1,
	revlabel1,
	revlabel2,
	revlabel3,
	revlabel4,
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
	ord_originregion1,
	ord_originregion2,
	ord_originregion3,
	ord_originregion4,
	ord_destregion1,
	ord_destregion2,
	ord_destregion3,
	ord_destregion4,
	npup_departuredate,
	ndrp_departuredate,
	ord_fromorder,
	c_lgh_type1,
	lgh_type1_label,
	c_lgh_type2,
	lgh_type2_label,
	lgh_tm_status,
	lgh_tour_number,
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
	mpp_fleet,
	mpp_fleet_name,
	next_stp_event_code,
	next_stop_of_total,
	lgh_comment,
	lgh_earliest_pu,
	lgh_latest_pu,
	lgh_earliest_unl,
	lgh_latest_unl,
	lgh_miles,
	lgh_linehaul,
	evt_latedate,
	lgh_ord_charge,
	lgh_act_weight,
	lgh_est_weight,
	lgh_tot_weight,
	lgh_outstat,
	lgh_max_weight_exceeded,
	lgh_reftype,
	lgh_refnum,
	trctype1,
	trc_type1name,
	trctype2,
	trc_type2name,
	trctype3,
	trc_type3name,
	trctype4,
	trc_type4name,
	lgh_etaalert1,
	Expression1,
	lgh_tm_statusname,
	ord_billto,
	cmp_name,
	lgh_carrier,
	TotalCarrierPay,
	lgh_hzd_cmd_class,
	toep_id,
	toep_ordered_count,
	toep_planned_count,
	toep_delivery_date,
	count_of_loads,
	lgh_permit_status,
	lgh_permit_status_t,
	next_ndrp_cmpid,
	next_ndrp_cmpname,
	next_ndrp_ctyname,
	next_ndrp_state,
	next_ndrp_arrivaldate,
	ord_rate,
	--PTS 47858 JJF 20090716
	toep_ordered_work_quantity,
	toep_planned_work_quantity,
	toep_work_quantity_per_load,
	toep_work_unit,
	--END PTS 47858 JJF 20090716
	ma_transaction_id,		-- RE - PTS #48722
	ma_tour_number,			-- RE - PTS #48722
	ma_tour_sequence,		-- RE - PTS #48722
	ma_tour_max_sequence,	-- RE - PTS #48722
	ma_trc_number,			-- RE - PTS #48722
	ma_mpp_id,				-- RE - PTS #48722
	lgh_chassis,
	lgh_chassis2,
	lgh_dolly,
	lgh_dolly2,
	lgh_trailer3,
	lgh_trailer4 ,
	ord_company			/* 09/03/2010 MDH PTS 53570: Added */
	,ud_column1			 -- PTS 51911 SGB User Defined column
	,ud_column1_t		 --	PTS 51911 SGB User Defined column header
	,ud_column2			 -- PTS 51911 SGB User Defined column
	,ud_column2_t 		 --	PTS 51911 SGB User Defined column header	
	,ud_column3			 -- PTS 51911 SGB User Defined column
	,ud_column3_t		 --	PTS 51911 SGB User Defined column header
	,ud_column4			 -- PTS 51911 SGB User Defined column
	,ud_column4_t 		 --	PTS 51911 SGB User Defined column header			
)
SELECT	legheader.lgh_number, 
	legheader.cmp_id_start o_cmpid, 
	o_cmpname, 
	lgh_startcty_nmstct o_ctyname, 
	legheader.cmp_id_end d_cmpid, 
	d_cmpname, 
	lgh_endcty_nmstct d_ctyname, 
	CASE WHEN toep.ord_hdrnumber is null THEN f_cmpid
	ELSE toep.toep_shipper END f_cmpid,
	f_cmpname,
	f_ctyname,
	l_cmpid,
	l_cmpname,
	l_ctyname,
	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	lgh_startstate o_state, 
	lgh_endstate d_state, 
	o.ord_origin_earliestdate lgh_schdtearliest, 
	o.ord_origin_latestdate lgh_schdtlatest,
	CASE WHEN toep.ord_hdrnumber is null THEN legheader.cmd_code
	ELSE toep.cmd_code END cmd_code,
	legheader.fgt_description,
	cmd_count,
	legheader.ord_hdrnumber, 
	evt_driver1_name evt_driver1, 
	evt_driver2_name evt_driver2, 
	lgh_tractor evt_tractor, 
	legheader.lgh_primary_trailer,
	o.trl_type1,
	lgh_carrier evt_carrier, 
	legheader.mov_number, 
	o.ord_availabledate, 
	legheader.ord_stopcount, 
	o.ord_totalcharge, 
	legheader.ord_totalweight, 
	o.ord_length, 
	o.ord_width, 
	o.ord_height, 
	legheader.ord_totalmiles ord_totalmiles,
	case isnull(upper(lgh_split_flag),'N')
	when 'S' then substring(rtrim(o.ord_number) + '*', 1, 12)
	when 'F' then substring(rtrim(o.ord_number) + '*', 1, 12)
	else o.ord_number
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
	'Company' 'Company',
	labelfile_headers.TrlType1 trllabel1,
	labelfile_headers.RevType1 revlabel1,
	labelfile_headers.RevType2 revlabel2,
	labelfile_headers.RevType3 revlabel3,
	labelfile_headers.RevType4 revlabel4,
	o.ord_bookedby,
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
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo1 ELSE lgh_extrainfo1 END) extrainfo1,
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
	legheader.lgh_comment,
	s1.stp_schdtearliest   lgh_earliest_pu,
	s1.stp_schdtlatest   lgh_latest_pu,
	s2.stp_schdtearliest   lgh_earliest_unl,
	s2.stp_schdtlatest   lgh_latest_unl,
	(SELECT SUM(stp_lgh_mileage) FROM stops s WHERE s.lgh_number = legheader.lgh_number) lgh_miles,
	lgh_linehaul,
	CASE
		WHEN @LateWarnMode <> 'EVENT' THEN NULL
		ELSE ISNULL((SELECT	MIN(evt_latedate)
					   FROM	event e,
							stops s
					  WHERE	e.stp_number = s.stp_number AND
							s.lgh_number = legheader.lgh_number AND
							e.evt_status = 'OPN'), '20491231')
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
	legheader.lgh_etaalert1,
	isnull(lgh_detstatus,0),
	legheader.lgh_tm_statusname,
	legheader.ord_billto,
	c.cmp_name,
	legheader.lgh_carrier, 
	IsNull((SELECT SUM(pyd_amount) FROM paydetail
		WHERE paydetail.asgn_id = legheader.lgh_carrier
		AND paydetail.asgn_type = 'CAR'
		AND paydetail.lgh_number = legheader.lgh_number
		AND paydetail.mov_number = legheader.mov_number),0) TotalCarrierPay,
	lgh_hzd_cmd_class,
	toep_id,
	toep_ordered_count,
	toep_planned_count,
	toep_delivery_date,
	toep_ordered_count - toep_planned_count count_of_loads,
	ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
	labelfile_headers.LghPermitStatus lgh_permit_status_t,
	-- 33890 BDH 9/12/06 start
	next_ndrp_cmpid,
	next_ndrp_cmpname,
	next_ndrp_ctyname,
	next_ndrp_state,
	next_ndrp_arrivaldate,
	-- 33890 BDH 9/12/06 end
	--PTS 38376
	o.ord_rate,
	--END PTS 38376
	--PTS 47858 JJF 20090716
	toep.toep_ordered_work_quantity,
	toep.toep_planned_work_quantity,
	toep.toep_work_quantity_per_load,
	toep.toep_work_unit, 
	--END PTS 47858 JJF 20090716
	@ma_transaction_id,		-- RE - PTS #52017
	NULL,					-- RE - PTS #52017
	NULL,					-- RE - PTS #52017
	NULL,					-- RE - PTS #52017
	NULL,					-- RE - PTS #52017
	NULL,					-- RE - PTS #52017
	lgh_chassis,
	lgh_chassis2,
	lgh_dolly,
	lgh_dolly2,
	lgh_trailer3,
	lgh_trailer4,
	o.ord_company				/* 09/03/2010 MDH PTS 53570: Added */
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column1' 	--	PTS 51911 SGB User Defined column header
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column2'		--	PTS 51911 SGB User Defined column header
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column3' 	--	PTS 51911 SGB User Defined column header
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column4'		--	PTS 51911 SGB User Defined column header	
FROM	legheader_active legheader
		INNER JOIN company c ON legheader.ord_billto = c.cmp_id
		INNER JOIN stops s1 ON legheader.stp_number_start = s1.stp_number
		INNER JOIN stops s2 ON legheader.stp_number_end = s2.stp_number
		LEFT OUTER JOIN orderheader o ON legheader.ord_hdrnumber = o.ord_hdrnumber
		LEFT OUTER JOIN ticket_order_entry_plan toep ON o.ord_hdrnumber = toep.ord_hdrnumber
						AND toep.toep_status IN ('N', 'P') AND @includeplanrec = 'Y', 
		labelfile_headers
WHERE	lgh_startdate >= @hoursbackdate
		AND lgh_startdate <= @hoursoutdate
		AND (@city = 0 OR legheader.lgh_startcity = @city)
		AND (@includedrvplan = 'Y' or legheader.drvplan_number is null or legheader.drvplan_number = 0) 
		AND (@d_city = 0 OR legheader.lgh_endcity = @d_city) 
		AND (@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_startregion1 + ',', @reg1) > 0) 
		AND (@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_startregion2 + ',', @reg2) > 0)  
		AND (@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_startregion3 + ',', @reg3) > 0)  
		AND (@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_startregion4 + ',', @reg4) > 0)  
		AND (@d_reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @d_reg1) > 0) 
		AND (@d_reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @d_reg2) > 0) 
		AND (@d_reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @d_reg3) > 0) 
		AND (@d_reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @d_reg4) > 0) 
		AND lgh_outstatus IN ('AVL', 'DSP', 'PLN', 'STD', 'MPN')
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
		AND (@billto = ',,' OR CHARINDEX(',' + legheader.ord_billto + ',', @billto) > 0)
		AND (@lgh_hzd_cmd_classes = ',UNK,' OR CHARINDEX(',' + lgh_hzd_cmd_class + ',', @lgh_hzd_cmd_classes) > 0)/*PTS 23162 CGK 9/1/2004*/
		AND (@lgh_permit_status = ',UNK,' OR CHARINDEX(',' + legheader.lgh_permit_status + ',', @lgh_permit_status) > 0)
UNION
SELECT	legheader.lgh_number, 
	toep.toep_shipper o_cmpid, 
	shipper.cmp_name o_cmpname, 
	shipper.cty_nmstct o_ctyname, 
	--PTS 49960 JJF 20091209
	--o.ord_consignee d_cmpid,
	toep.toep_consignee d_cmpid,
	--END PTS 49960 JJF 20091209 
	consignee.cmp_name d_cmpname, 
	consignee.cty_nmstct d_ctyname, 
	toep.toep_shipper o_cmpid, 
	shipper.cmp_name o_cmpname, 
	shipper.cty_nmstct o_ctyname, 
	--PTS 49960 JJF 20091209
	--o.ord_consignee d_cmpid, 
	toep.toep_consignee d_cmpid,
	--END PTS 49960 JJF 20091209
	consignee.cmp_name d_cmpname, 
	consignee.cty_nmstct d_ctyname, 
	toep.toep_delivery_date lgh_startdate, 
	toep.toep_delivery_date lgh_enddate, 
	shipper.cmp_state o_state, 
	consignee.cmp_state d_state, 
	o.ord_origin_earliestdate lgh_schdtearliest, 
	o.ord_origin_latestdate lgh_schdtlatest,
	toep.cmd_code cmd_code,
	cmd.cmd_name,
	--PTS 49579 JJF 20091229 -only need counts from pickup, not both pickup AND drop.
	--CASE @v_cmd_count_setting 
	--	WHEN 'FREIGHT' THEN (SELECT COUNT( freightdetail.cmd_code ) FROM stops JOIN freightdetail on stops.stp_number = freightdetail.stp_number WHERE stops.mov_number = o.mov_number)
	--	ELSE (SELECT SUM(ISNULL(freightdetail.fgt_count,0)) FROM stops JOIN freightdetail on stops.stp_number = freightdetail.stp_number WHERE stops.mov_number = o.mov_number)
	--END cmd_count,		/* 07/09/2009 MDH PTS 47833: Changed to count; No leg headers for master orders! */
	toep.toep_work_quantity_per_load,
	--END PTS 49579 JJF 20091229
	o.ord_hdrnumber, 
	legheader.evt_driver1_name evt_driver1, 
	legheader.evt_driver2_name evt_driver2, 
	legheader.lgh_tractor evt_tractor, 
	legheader.lgh_primary_trailer,
	o.trl_type1,
	legheader.lgh_carrier evt_carrier, 
	o.mov_number, 
	o.ord_availabledate, 
	legheader.ord_stopcount, 
	o.ord_totalcharge, 
	--PTS 43800 JJF 20081024
	--o.ord_totalweight, 
	case isnull(toep.toep_weight_per_load, 0) when 0 then o.ord_totalweight else toep.toep_weight_per_load end,
	--PTS 43800 JJF 20081024
	o.ord_length, 
	o.ord_width, 
	o.ord_height, 
	o.ord_totalmiles ord_totalmiles,
	case isnull(upper(legheader.lgh_split_flag),'N')
	when 'S' then substring(rtrim(o.ord_number)+'*',1,12)
	when 'F' then substring(rtrim(o.ord_number)+'*',1,12)
	else o.ord_number
	end ord_number, 
	legheader.lgh_startcity o_city, 
	legheader.lgh_endcity d_city,
	legheader.lgh_priority, 
	legheader.lgh_outstatus_name lgh_outstatus, 
	legheader.lgh_instatus_name lgh_instatus, 
        legheader.lgh_priority_name,
	(select name from labelfile where o.ord_subcompany = abbr AND labeldefinition = 'Company')  ord_subcompany,
	legheader.trl_type1_name,
	(SELECT name FROM labelfile WHERE labeldefinition = 'revtype1' AND abbr = ord_revtype1) lgh_class1,
	(SELECT name FROM labelfile WHERE labeldefinition = 'revtype2' AND abbr = ord_revtype2) lgh_class2,
	(SELECT name FROM labelfile WHERE labeldefinition = 'revtype3' AND abbr = ord_revtype3) lgh_class3,
	(SELECT name FROM labelfile WHERE labeldefinition = 'revtype4' AND abbr = ord_revtype4) lgh_class4,
	'Company' 'Company',
	labelfile_headers.TrlType1 trllabel1,
	labelfile_headers.RevType1 revlabel1,
	labelfile_headers.RevType2 revlabel2,
	labelfile_headers.RevType3 revlabel3,
	labelfile_headers.RevType4 revlabel4,
	-- BYoung 29930 o.ord_bookedby,
      toep.toep_bookedby,
	convert(char(10), '') dw_rowstatus,
	legheader.lgh_primary_pup,
	IsNull(ord_loadtime, 0) + IsNull(ord_unloadtime, 0) + IsNull(ord_drivetime, 0) triptime,
	--PTS 43800 JJF 20081024
	--ord_totalweightunits, 
	case isnull(toep.toep_weights_units, '') when '' then ord_totalweightunits else toep.toep_weights_units end,
	--PTS 43800 JJF 20081024
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
	legheader.washstatus,
	legheader.f_state,	
	legheader.l_state,
	legheader.lgh_driver1 evt_driver1_id,
	legheader.lgh_driver2 evt_driver2_id,
--START PTS 31569
	--OLD - legheader.ref_type,
	--OLD - legheader.ref_number,
	ref_type = case when isNull(legheader.ref_type,'') = '' 
			then (	select 	isNull(toepr_ref_type,'') 
				  from 	ticket_order_entry_plan_ref 
				 where 	toepr_ref_sequence = 1 and ticket_order_entry_plan_ref.toep_id = toep.toep_id) 
			ELSE legheader.ref_type
			END,
	ref_number = case when isNull(legheader.ref_number,'') = '' 
			then (	select 	isNull(toepr_ref_number,'') 
				  from 	ticket_order_entry_plan_ref 
				 where 	toepr_ref_sequence = 1 and ticket_order_entry_plan_ref.toep_id = toep.toep_id) 
			ELSE legheader.ref_number
			END,
--END PTS 31569
	left (consignee.cmp_address1, 40) d_address1,		/* 07/09/2009 MDH PTS 47833: Changed to use consignee address. */
	left (consignee.cmp_address2, 40) d_address2,		/* 07/09/2009 MDH PTS 47833: Changed to use consignee address. */
--PTS 38376
	--ord_remark,
	COALESCE (toep_comment, ord_remark),	/* 07/09/2009 MDH PTS 47833: Added coalesce with ord_remark. */
--END PTS 38376
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
	o.ord_originregion1 ord_originregion1, 
	o.ord_originregion2 ord_originregion2, 
	o.ord_originregion3 ord_originregion3, 
	o.ord_originregion4 ord_originregion4, 
	o.ord_destregion1 ord_destregion1,
	o.ord_destregion2 ord_destregion2,
	o.ord_destregion3 ord_destregion3,
	o.ord_destregion4 ord_destregion4,
	npup_departuredate,
	ndrp_departuredate, 
	ord_fromorder,
	c_lgh_type1,
	labelfile_headers.LghType1 lgh_type1_label,
	c_lgh_type2,
	labelfile_headers.LghType2 lgh_type2_label,
	lgh_tm_status,
	lgh_tour_number,
	ord_extrainfo1,
	ord_extrainfo2,
	ord_extrainfo3,
	ord_extrainfo4,
	ord_extrainfo5,
	ord_extrainfo6,
	ord_extrainfo7,
	ord_extrainfo8,
	ord_extrainfo9,
	ord_extrainfo10,
	ord_extrainfo11,
	ord_extrainfo12,
	ord_extrainfo13,
	ord_extrainfo14,
	ord_extrainfo15,	
	o_cmp_geoloc,
	d_cmp_geoloc,
	legheader.mpp_fleet,
	mpp_fleet_name,
	next_stp_event_code,
	next_stop_of_total,
	legheader.lgh_comment,
	o.ord_origin_earliestdate   lgh_earliest_pu,
	o.ord_origin_latestdate   lgh_latest_pu,
	o.ord_dest_earliestdate   lgh_earliest_unl,
	o.ord_dest_latestdate   lgh_latest_unl,
	(SELECT SUM(stp_lgh_mileage) FROM stops s WHERE s.mov_number = o.mov_number) lgh_miles,
	lgh_linehaul,
	CASE
		WHEN @LateWarnMode <> 'EVENT' THEN NULL
		ELSE ISNULL((SELECT	MIN(evt_latedate)
					   FROM	event e,
							stops s
					  WHERE	e.stp_number = s.stp_number AND
							s.mov_number = o.mov_number AND
							e.evt_status = 'OPN'), '20491231')
	END evt_latedate,
	lgh_ord_charge,
	lgh_act_weight,
	--PTS 43800 JJF 20081024
	--lgh_est_weight, 
	case isnull(toep.toep_weight_per_load, 0) when 0 then lgh_est_weight else toep.toep_weight_per_load end,
	--PTS 43800 JJF 20081024
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
	legheader.lgh_etaalert1,
	isnull(lgh_detstatus,0),
	legheader.lgh_tm_statusname,
	--PTS 50406 JJF 20100416
	--legheader.ord_billto,
	o.ord_billto,
	--END PTS 50406 JJF 20100416
	c.cmp_name,
	legheader.lgh_carrier, 
	0 TotalCarrierPay,
	lgh_hzd_cmd_class,
	toep_id,
	toep_ordered_count,
	toep_planned_count,
	toep_delivery_date,
	toep_ordered_count - toep_planned_count count_of_loads,
	legheader.lgh_permit_status,
	labelfile_headers.LghPermitStatus lgh_permit_status_t,
	-- 33890 BDH 9/12/06 start
	next_ndrp_cmpid,
	next_ndrp_cmpname,
	next_ndrp_ctyname,
	next_ndrp_state,
	next_ndrp_arrivaldate,
	-- 33890 BDH 9/12/06 end
	--PTS 38376
	CASE WHEN isnull(toep.toep_tarnumber,'')<>'' THEN toep_rate ELSE o.ord_rate  END ord_rate ,
	--END PTS 38376
	--PTS 47858 JJF 20090716
	toep.toep_ordered_work_quantity,
	toep.toep_planned_work_quantity,
	toep.toep_work_quantity_per_load,
	toep.toep_work_unit, 
	--END PTS 47858 JJF 20090716
	NULL, NULL, NULL, NULL, NULL, NULL, -- RE - PTS #48722
	NULL, NULL, NULL, NULL, NULL, NULL,
	o.ord_company		/* 09/03/2010 MDH PTS 53570: Added */
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column1' 	--	PTS 51911 SGB User Defined column header
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column2'		--	PTS 51911 SGB User Defined column header
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column3' 	--	PTS 51911 SGB User Defined column header
	,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
	,'UD Column4'		--	PTS 51911 SGB User Defined column header	
FROM	ticket_order_entry_plan toep 
		INNER JOIN company shipper ON toep.toep_shipper = shipper.cmp_id
		INNER JOIN commodity cmd ON toep.cmd_code = cmd.cmd_code
		INNER JOIN orderheader o ON toep.ord_hdrnumber = o.ord_hdrnumber
		INNER JOIN company c ON o.ord_billto = c.cmp_id
		--PTS 49960 JJF 20091209
		--INNER JOIN company consignee ON o.ord_consignee = consignee.cmp_id
		INNER JOIN company consignee ON toep.toep_consignee = consignee.cmp_id
		--END PTS 49960 JJF 20091209
		LEFT OUTER JOIN legheader_active legheader ON o.ord_hdrnumber = legheader.ord_hdrnumber,
		labelfile_headers
WHERE	toep.toep_delivery_date >= @hoursbackdate
        AND toep.toep_delivery_date <= @hoursoutdate
		AND (@city = 0 OR o.ord_origincity = @city)
		AND (@d_city = 0 OR o.ord_destcity = @d_city) 
		AND (@reg1 = ',UNK,' OR CHARINDEX(',' + ord_originregion1 + ',', @reg1) > 0) 
		AND (@reg2 = ',UNK,' OR CHARINDEX(',' + ord_originregion2 + ',', @reg2) > 0)  
		AND (@reg3 = ',UNK,' OR CHARINDEX(',' + ord_originregion3 + ',', @reg3) > 0)  
		AND (@reg4 = ',UNK,' OR CHARINDEX(',' + ord_originregion4 + ',', @reg4) > 0)  
		AND (@d_reg1 = ',UNK,' OR CHARINDEX(',' + ord_destregion1 + ',', @d_reg1) > 0) 
		AND (@d_reg2 = ',UNK,' OR CHARINDEX(',' + ord_destregion2 + ',', @d_reg2) > 0) 
		AND (@d_reg3 = ',UNK,' OR CHARINDEX(',' + ord_destregion3 + ',', @d_reg3) > 0) 
		AND (@d_reg4 = ',UNK,' OR CHARINDEX(',' + ord_destregion4 + ',', @d_reg4) > 0) 
		AND (@states = '' OR CHARINDEX(ord_originstate, @states) > 0)
		AND (@d_states = '' OR CHARINDEX(ord_deststate, @d_states) > 0)
		AND (@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0) 
		AND (@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
		AND (@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0) 
		AND (@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0) 
		AND (@cmpids = ',,' OR CHARINDEX(',' + toep.toep_shipper + ',', @cmpids) > 0)
		--PTS 49960 JJF 20091209
		--AND (@d_cmpids = ',,' OR CHARINDEX(',' + o.ord_consignee + ',', @d_cmpids) > 0) 
		AND (@d_cmpids = ',,' OR CHARINDEX(',' + toep.toep_consignee + ',', @d_cmpids) > 0) 
		--END PTS 49960 JJF 20091209
		AND (@company = ',,' OR CHARINDEX(',' + o.ord_subcompany + ',', @company) > 0)
		--29930
		--AND (@bookedby = ',ALL,' OR CHARINDEX(',' + rtrim(ltrim(o.ord_bookedby)) + ',', @bookedby) > 0)
		AND (@bookedby = ',ALL,' OR CHARINDEX(',' + rtrim(ltrim(toep.toep_bookedby)) + ',', @bookedby) > 0)
		AND (@trltype1 = ',,' OR CHARINDEX(',' + o.trl_type1 + ',', @trltype1) > 0)
		AND (ISNULL(o.ord_totalmiles, -1) between @miles_min and @miles_max)
		AND (@billto = ',,' OR CHARINDEX(',' + o.ord_billto + ',', @billto) > 0)
		AND toep.toep_status IN ('N', 'P') AND @includeplanrec = 'Y'

--PTS 51570 JJF 20100510
--PTS 40155 JJF 20071128
SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

--PTS 41877
----SELECT @tmwuser = suser_sname()
--exec @tmwuser = dbo.gettmwuser_fn

--IF @rowsecurity = 'Y' AND EXISTS(SELECT * 
--				FROM UserTypeAssignment
--				WHERE usr_userid = @tmwuser) BEGIN 

--	DELETE  #resultset
--	FROM #resultset tp 
--	WHERE EXISTS(SELECT * FROM orderheader oh WHERE tp.mov_number = oh.mov_number)
--			AND NOT EXISTS ((SELECT *
--				FROM orderheader oh 
--				WHERE tp.mov_number = oh.mov_number 
--						AND isnull(oh.ord_BelongsTo, 'UNK') = 'UNK') 

--			)
--			AND NOT EXISTS(SELECT *
--				FROM orderheader oh 
--				WHERE tp.mov_number = oh.mov_number
--						AND EXISTS(SELECT * 
--							FROM UserTypeAssignment
--							WHERE usr_userid = @tmwuser	
--									AND (uta_type1 = oh.ord_BelongsTo
--											OR uta_type1 = 'UNK')))
	
--END
----END PTS 40155 JJF 20071128

SELECT @rowsecurity = gi_string1
	FROM generalinfo
	WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	DELETE	#resultset
	FROM	#resultset tp
	  --security only if mov has an associated order
	WHERE	EXISTS	(	SELECT	*
						FROM	orderheader oh 
						WHERE	tp.mov_number = oh.mov_number
					)
			AND NOT EXISTS	(	SELECT	*  
								FROM	orderheader oh INNER JOIN RowRestrictValidAssignments_orderheader_fn() rsva on	(	oh.rowsec_rsrv_id = rsva.rowsec_rsrv_id
																															OR rsva.rowsec_rsrv_id = 0
																														)
								WHERE	oh.mov_number = tp.mov_number
							)	
END
--PTS 51570 JJF 20100510

--PTS 46118 JJF 20090709
UPDATE #resultSet
SET
	toep_available_count = (SELECT	count(*) 
							FROM	ticket_order_entry_plan toepinner 
									INNER JOIN ticket_order_entry_plan_orders toepoinner 
										on toepinner.toep_id = toepoinner.toep_id 
									INNER JOIN orderheader ohinner 
										on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
							WHERE	ohinner.ord_status = 'AVL' 
									and toepinner.toep_id = rs.toep_id),
	toep_completed_count = (	SELECT	count(*) 
							FROM	ticket_order_entry_plan toepinner 
									INNER JOIN ticket_order_entry_plan_orders toepoinner 
										on toepinner.toep_id = toepoinner.toep_id 
									INNER JOIN orderheader ohinner 
										on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
							WHERE	ohinner.ord_status = 'CMP' 
									and toepinner.toep_id = rs.toep_id)
FROM #ResultSet rs
--PTS 51911 SGB 
IF @ud_column1 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',1)
			UPDATE #ResultSet
			set ud_column1 = dbo.UD_STOP_LEG_SHELL_FN (rs.lgh_number,'LS',1),
			ud_column1_t = @udheader
			from #ResultSet rs
			where isnull(lgh_number,0) > 0

		END
 
END 

IF @ud_column2 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',2)
			UPDATE #ResultSet
			set ud_column2 = DBO.UD_STOP_LEG_SHELL_FN (rs.lgh_number,'LE',2),
			ud_column2_t = @udheader
			from #ResultSet rs
			where isnull(lgh_number,0) > 0

		END
 
END 

IF @ud_column3 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',3)
			UPDATE #ResultSet
			set ud_column3 = dbo.UD_STOP_LEG_SHELL_FN (rs.lgh_number,'L',3),
			ud_column3_t = @udheader
			from #ResultSet rs
			where isnull(lgh_number,0) > 0

		END
 
END 

IF @ud_column4 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',4)
			UPDATE #ResultSet
			set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (rs.lgh_number,'L',4),
			ud_column4_t = @udheader
			from #ResultSet rs
			where isnull(lgh_number,0) > 0

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
	lgh_priority,
	lgh_outstatus,
	lgh_instatus,
	lgh_priority_name,
	ord_subcompany,
	trl_type1_name,
	lgh_class1,
	lgh_class2,
	lgh_class3,
	lgh_class4,
	Company,
	trllabel1,
	revlabel1,
	revlabel2,
	revlabel3,
	revlabel4,
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
	ord_originregion1,
	ord_originregion2,
	ord_originregion3,
	ord_originregion4,
	ord_destregion1,
	ord_destregion2,
	ord_destregion3,
	ord_destregion4,
	npup_departuredate,
	ndrp_departuredate,
	ord_fromorder,
	c_lgh_type1,
	lgh_type1_label,
	c_lgh_type2,
	lgh_type2_label,
	lgh_tm_status,
	lgh_tour_number,
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
	mpp_fleet,
	mpp_fleet_name,
	next_stp_event_code,
	next_stop_of_total,
	lgh_comment,
	lgh_earliest_pu,
	lgh_latest_pu,
	lgh_earliest_unl,
	lgh_latest_unl,
	lgh_miles,
	lgh_linehaul,
	evt_latedate,
	lgh_ord_charge,
	lgh_act_weight,
	lgh_est_weight,
	lgh_tot_weight,
	lgh_outstat,
	lgh_max_weight_exceeded,
	lgh_reftype,
	lgh_refnum,
	trctype1,
	trc_type1name,
	trctype2,
	trc_type2name,
	trctype3,
	trc_type3name,
	trctype4,
	trc_type4name,
	lgh_etaalert1,
	Expression1,
	lgh_tm_statusname,
	ord_billto,
	cmp_name,
	lgh_carrier,
	TotalCarrierPay,
	lgh_hzd_cmd_class,
	toep_id,
	toep_ordered_count,
	toep_planned_count,
	toep_delivery_date,
	count_of_loads,
	lgh_permit_status,
	lgh_permit_status_t,
	next_ndrp_cmpid,
	next_ndrp_cmpname,
	next_ndrp_ctyname,
	next_ndrp_state,
	next_ndrp_arrivaldate,
	ord_rate,
	--PTS 46118 JJF 20090709
	toep_available_count,
	toep_completed_count,
	--END PTS 46118 JJF 20090709
	--PTS 47858 JJF 20090716
	toep_ordered_work_quantity,
	toep_planned_work_quantity,
	toep_work_quantity_per_load,
	toep_work_unit, 
	--PTS 47858 JJF 20090716
	ma_transaction_id,														-- RE - PTS #52017
	CASE																	-- RE - PTS #52017
		WHEN ma_transaction_id IS NULL THEN @null_int						-- RE - PTS #52017
		ELSE dbo.Load_MATourNumber_fn(@DefaultCompanyID, ma_transaction_id, lgh_number)		-- RE - PTS #52017
	END,																	-- RE - PTS #52017
	@null_varchar8,															-- RE - PTS #52017
	@null_varchar8,															-- RE - PTS #52017
	CASE																	-- RE - PTS #52017
		WHEN ma_transaction_id IS NULL THEN @null_varchar100				-- RE - PTS #52017
		ELSE dbo.Load_MAReccomendation_fn(@DefaultCompanyID, ma_transaction_id, lgh_number)	-- RE - PTS #52017
	END,																	-- RE - PTS #52017
	0 'org_distfrom',  -- PTS 45271 - DJM  
	0 'dest_distfrom',  -- PTS 45271 - DJM  
	lgh_chassis,
	lgh_chassis2,
	lgh_dolly,
	lgh_dolly2,
	lgh_trailer3,
	lgh_trailer4,
	ord_company
	,ud_column1			 -- PTS 51911 SGB User Defined column
	,ud_column1_t		 --	PTS 51911 SGB User Defined column header
	,ud_column2			 -- PTS 51911 SGB User Defined column
	,ud_column2_t 		 --	PTS 51911 SGB User Defined column header	
	,ud_column3			 -- PTS 51911 SGB User Defined column
	,ud_column3_t		 --	PTS 51911 SGB User Defined column header
	,ud_column4			 -- PTS 51911 SGB User Defined column
	,ud_column4_t 		 --	PTS 51911 SGB User Defined column header		
FROM #resultset

GO
GRANT EXECUTE ON  [dbo].[outbound_view_aggregate] TO [public]
GO

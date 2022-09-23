SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE       [dbo].[inbound_view_drv_matrix]
	@mmptype1       varchar(254),
	@mmptype2       varchar(254),
	@mmptype3       varchar(254),
	@mmptype4       varchar(254),
	@teamleader     varchar(254),
	@domicile       varchar(254),
	@fleet          varchar(254),
	@division       varchar(254),
	@company        varchar(254),
	@terminal       varchar(254),
	@states         varchar(254),
	@cmpids         varchar(254),
	@region1        varchar(254),
	@region2        varchar(254),
	@region3        varchar(254),
	@region4        varchar(254),
	@city           int,
	@hoursback      int,
	@hoursout       int,
	@days           int, 
	@last_event 	varchar(254),
	@d_states 		varchar (254), 
	@d_cmpids 		varchar (254), 
	@d_reg1 		varchar (254), 
	@d_reg2 		varchar (254), 
	@d_reg3 		varchar (254), 
	@d_reg4 		varchar (254), 
	@d_city 		int,
	@next_event 	varchar(254),
	@next_cmp_id 	varchar(254),
	@next_city 		int, 
	@next_state 	varchar(254), 
	@next_region1 	varchar(254), 
	@next_region2 	varchar(254), 
	@next_region3 	varchar(254), 
	@next_region4 	varchar(254),
	@drv_qualifications varchar(254),
	@drv_status	varchar(254),
	@cmp_othertype1	varchar(254),			/* 02/14/2008 MDH PTS 39077: Added */
	@d_cmp_othertype1	varchar(254),		/* 02/14/2008 MDH PTS 39077: Added */
	@next_cmp_othertype1	varchar(254)	/* 02/14/2008 MDH PTS 39077: Added */
AS
-- PTS 3436 PG 1/8/98 Performance Enhancement added NOLOCK on expiration
/* MF pts 4175 add extra cols*/
/* LOR	5/12/98	PTS# 3905	add driver name and date hired */
--08/01/2001	Vern Jewett (label=vmj1)	PTS 11594: Improve DB performance (Manfredi)
-- dpete pts12599 add cmp_geoloc to return set for Gibson 12/21/01
--04/24/2002	Vern Jewett	(label=vmj2)	PTS 13682: planning worksheet Avl Hrs & Avl Trip are showing -100 too often.


DECLARE @int        smallint,
	@servicerule	char(6),
	@def_srvrule	char(6),
	@logdays		int,
	@loghrs         int,
	@avlhrs         float,
	@float			float,
	@neardate       datetime,
	@mppid          char(8),
	@char6          char(6),
	@retval  		int,
	@ls_whats_left	varchar(255),
	@li_pos			int,
	@li_count		int,
	@ls_value		varchar(255),
	@ls_dayname 	char(3),
	@ld_comparedate datetime,
	@varchar6		varchar(6),
	@varchar20		varchar(20),
	@dt				datetime,
	@ldt_yesterday	datetime,
	@vs_counter		varchar(13),
	@vdtm_avl_date	datetime,
	@vdtm_exp_completiondate datetime,
	@StatusCutoff	INTEGER -- dsk 54917

-- RE - PTS #42565 BEGIN
----PTS 36624 JJF 20070911
--DECLARE @drv_qualification_list table(
--    value	varchar(100)
--)
----END PTS 36624 JJF 20070911
-- RE - PTS #42565 END

--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510
--END PTS 40155 JJF 20071128

CREATE TABLE #tt (
	mpp_id varchar(8),
	company_cmp_id varchar(8),
	-- PTS 29082 -- BL (start)
--	company_cmp_name varchar(100),
	company_cmp_name varchar(100) null,
	-- PTS 29082 -- BL (end)
	city_cty_nmstct varchar(50) null,
	mpp_teamleader varchar(100) null,
	mpp_avl_date datetime null,
	mpp_status varchar(20) null,
	mpp_last_home datetime null,
	mpp_want_home datetime null,
	mpp_fleet varchar(100) null,
	mpp_division varchar(12) null,
	mpp_domicile varchar(254) null,
	mpp_company varchar(12) null,
	mpp_terminal varchar(12) null,
	mpp_type1 varchar(12) null,
	mpp_type2 varchar(12) null,
	mpp_type3 varchar(12) null,
	mpp_type4 varchar(12) null,
	city_cty_state varchar(6) null,
	city_cty_code int null,
	cpri2 int null,
	cpri22 int null,
	cpri1 int null,
	cpri11 int null,
	loghrs float null,
	filtflag varchar(1),
	updateflag varchar(1),
	servicerule varchar(6) null,
	mpp_hiredate datetime null,
	mpp_lastfirst varchar(45) null,
	mpp_gps_desc varchar(254) null,
	mpp_gps_date datetime null,
    	mpp_travel_minutes smallint null,
    	mpp_mile_day7 smallint null,
    	mpp_last_log_date datetime null,
	mpp_hours1 float null,
	mpp_hours2 float null,
	mpp_hours3 float null,
	mpp_last_home_date datetime null,
	mpp_prior_event char(6) null,
	mpp_prior_cmp_id varchar(8) null,
	mpp_prior_city int null,
	mpp_prior_ctyname varchar(100) null, 
	mpp_prior_state varchar(6) null, 
	mpp_prior_region1 varchar(6) null, 
	mpp_prior_region2 varchar(6) null, 
	mpp_prior_region3 varchar(6) null, 
	mpp_prior_region4 varchar(6) null, 
	mpp_prior_cmp_name varchar(254) null,
	mpp_next_event char(6) null,
	mpp_next_cmp_id varchar(8) null,
	mpp_next_city int null,
	mpp_next_ctyname varchar(100) null, 
	mpp_next_state varchar(6) null, 
	mpp_next_region1 varchar(6) null, 
	mpp_next_region2 varchar(6) null, 
	mpp_next_region3 varchar(6) null, 
	mpp_next_region4 varchar(6) null, 
	mpp_next_cmp_name varchar(100) null,
	cmp_geoloc varchar(200) null,
	mpp_next_exp_code		VARCHAR(6) NULL,
	mpp_next_exp_name		VARCHAR(20) NULL,
	mpp_next_exp_date		DATETIME NULL,
	mpp_next_exp_compldate  DATETIME NULL,
	mpp_bid_next_starttime	DATETIME NULL,
	mpp_bid_next_type	VARCHAR(6) NULL,
	mpp_bid_next_routestore	VARCHAR (8) NULL,
	mpp_senioritydate	DATETIME NULL,
	mpp_hours1_week 	float null,
	mpp_pta_date		DATETIME NULL, --DPH PTS 32698
	exp_affects_avail_dtm char(1) NULL, --JLB PTS 32387
    mpp_comment1			varchar(255) NULL,  --JLB PTS 38766
	--PTS 51918 20110209
	qualification_list_drv	varchar(255)	null,
	--END PTS 51918 20110209
	--PTS 55760 JJF 20110609
	mpp_rtw_date			datetime		null,
	--END PTS 55760 JJF 20110609
	/* 03/27/2012 MDH PTS 59481: <<BEGIN>> */
	mpp_hosstatus 			integer		null,
	mpp_hosstatusdate		datetime	null,
	mpp_hosactivityupdateon	datetime	null
	/* 03/27/2012 MDH PTS 59481: <<END>> */
)

--vmj1+	create temp table to store parm list for @terminal..
create table #terminal
	(mpp_terminal	varchar(6)	null)


--Parse @terminal into a temptable possibly containing multiple values.  This will allow an index read on
--legheader_active, where the older charindex function prevented that.  This assumes, as the older code did, 
--that the list is comma-delimited..
select @ls_whats_left = isnull(ltrim(rtrim(@terminal)), '')
select @li_pos = charindex(',', @ls_whats_left)

while @li_pos > 0
begin
	select @ls_value = isnull(ltrim(rtrim(substring(@ls_whats_left, 1, @li_pos - 1))), '')
	if @ls_value <> ''
		and @ls_value <> 'UNK'
	begin
		insert into #terminal
				(mpp_terminal)
		  values (@ls_value)
	end

	--Find the next comma..
	select @ls_whats_left = isnull(ltrim(rtrim(substring(@ls_whats_left, @li_pos + 1, 255))), '')
	select @li_pos = charindex(',', @ls_whats_left)
end

--Get the last value..
if @ls_whats_left <> ''
	insert into #terminal
			(mpp_terminal)
	  values (@ls_whats_left)
--vmj1-


SELECT  @neardate = DateAdd(dy, @days, GetDate())

IF @hoursback = 0
	SELECT @hoursback = 1000000
IF @hoursout = 0
	SELECT @hoursout = 1000000

SELECT @def_srvrule = gi_string1
	FROM	generalinfo
	WHERE	gi_name = 'SERVICERULE'

-- dsk 54917
SELECT @StatusCutoff = gi_integer1
	FROM	generalinfo
	WHERE	gi_name = 'IBViewStatusCutoff'
SELECT @StatusCutoff = ISNULL(@StatusCutoff, 200)

-- prep all variables for a charindex check
IF @mmptype1 IS NULL OR @mmptype1 = ''
   SELECT @mmptype1 = 'UNK'
   SELECT @mmptype1 = ',' + LTRIM(RTRIM(@mmptype1))  + ','
IF @mmptype2 IS NULL OR @mmptype2 = ''
   SELECT @mmptype2 = 'UNK'
   SELECT @mmptype2 = ',' + LTRIM(RTRIM(@mmptype2))  + ','
IF @mmptype3 IS NULL OR @mmptype3 = ''
   SELECT @mmptype3 = 'UNK'
   SELECT @mmptype3 = ',' + LTRIM(RTRIM(@mmptype3))  + ','
IF @mmptype4 IS NULL OR @mmptype4 = ''
   SELECT @mmptype4 = 'UNK'
   SELECT @mmptype4 = ',' + LTRIM(RTRIM(@mmptype4))  + ','
IF @teamleader IS NULL OR @teamleader = ''
   SELECT @teamleader = 'UNK'
   SELECT @teamleader = ',' + LTRIM(RTRIM(@teamleader))  + ','
IF @domicile IS NULL OR @domicile = ''
   SELECT @domicile = 'UNK'
   SELECT @domicile = ',' + LTRIM(RTRIM(@domicile))  + ','
IF @fleet IS NULL OR @fleet = ''
   SELECT @fleet = 'UNK'
   SELECT @fleet = ',' + LTRIM(RTRIM(@fleet))  + ','
IF @division IS NULL OR @division = ''
   SELECT @division = 'UNK'
   SELECT @division = ',' + LTRIM(RTRIM(@division))  + ','
IF @company IS NULL OR @company = ''
   SELECT @company = 'UNK'
   SELECT @company = ',' + LTRIM(RTRIM(@company))  + ','
IF @states IS NULL OR @states = ''
   SELECT @states = 'UNK'
   SELECT @states = ',' + LTRIM(RTRIM(@states))  + ','
IF @cmpids IS NULL OR @cmpids = ''
   SELECT @cmpids = 'UNK'
   SELECT @cmpids = ',' + LTRIM(RTRIM(@cmpids))  + ','
IF @city IS NULL
   SELECT @city = 0
IF @region1 IS NULL OR @region1 = ''
   SELECT @region1 = 'UNK'
   SELECT @region1 = ',' + LTRIM(RTRIM(@region1))  + ','
IF @region2 IS NULL OR @region2 = ''
   SELECT @region2 = 'UNK'
   SELECT @region2 = ',' + LTRIM(RTRIM(@region2))  + ','
IF @region3 IS NULL OR @region3 = ''
   SELECT @region3 = 'UNK'
   SELECT @region3 = ',' + LTRIM(RTRIM(@region3))  + ','
IF @region4 IS NULL OR @region4 = ''
   SELECT @region4 = 'UNK'
   SELECT @region4 = ',' + LTRIM(RTRIM(@region4))  + ','
IF @d_city IS NULL
   SELECT @d_city = 0
IF @d_states IS NULL OR @d_states = ''
   SELECT @d_states = 'UNK'
   SELECT @d_states = ',' + LTRIM(RTRIM(@d_states))  + ','
IF @d_reg1 IS NULL OR @d_reg1 = ''
   SELECT @d_reg1 = 'UNK'
   SELECT @d_reg1 = ',' + LTRIM(RTRIM(@d_reg1))  + ','
IF @d_reg2 IS NULL OR @d_reg2 = ''
   SELECT @d_reg2 = 'UNK'
   SELECT @d_reg2 = ',' + LTRIM(RTRIM(@d_reg2))  + ','
IF @d_reg3 IS NULL OR @d_reg3 = ''
   SELECT @d_reg3 = 'UNK'
   SELECT @d_reg3 = ',' + LTRIM(RTRIM(@d_reg3))  + ','
IF @d_reg4 IS NULL OR @d_reg4 = ''
   SELECT @d_reg4 = 'UNK'
   SELECT @d_reg4 = ',' + LTRIM(RTRIM(@d_reg4))  + ','
IF @next_city IS NULL
   SELECT @next_city = 0
IF @next_region1 IS NULL OR @next_region1 = ''
   SELECT @next_region1 = 'UNK'
   SELECT @next_region1 = ',' + LTRIM(RTRIM(@next_region1))  + ','
IF @next_region2 IS NULL OR @next_region2 = ''
   SELECT @next_region2 = 'UNK'
   SELECT @next_region2 = ',' + LTRIM(RTRIM(@next_region2))  + ','
IF @next_region3 IS NULL OR @next_region3 = ''
   SELECT @next_region3 = 'UNK'
   SELECT @next_region3 = ',' + LTRIM(RTRIM(@next_region3))  + ','
IF @next_region4 IS NULL OR @next_region4 = ''
   SELECT @next_region4 = 'UNK'
   SELECT @next_region4 = ',' + LTRIM(RTRIM(@next_region4))  + ','
IF @next_state IS NULL OR @next_state = ''
   SELECT @next_state = 'UNK'
   SELECT @next_state = ',' + LTRIM(RTRIM(@next_state))  + ','
IF @next_event IS NULL OR @next_event = ''
   SELECT @next_event = 'UNK'
   SELECT @next_event = ',' + LTRIM(RTRIM(@next_event))  + ','
IF @last_event IS NULL OR @last_event = ''
   SELECT @last_event = 'UNK'
   SELECT @last_event = ',' + LTRIM(RTRIM(@last_event))  + ','
IF @d_cmpids IS NULL OR @d_cmpids = ''
   SELECT @d_cmpids = 'UNK'
   SELECT @d_cmpids = ',' + LTRIM(RTRIM(@d_cmpids)) + ',' 
IF @next_cmp_id IS NULL OR @next_cmp_id = ''
   SELECT @next_cmp_id = 'UNK'
   SELECT @next_cmp_id = ',' + LTRIM(RTRIM(@next_cmp_id)) + ',' 
IF @next_city IS NULL
   SELECT @next_city = 0
IF @drv_status IS NULL OR @drv_status = ''
   SELECT @drv_status = 'UNK'
   SELECT @drv_status = ',' + LTRIM(RTRIM(@drv_status)) + ','
-- RE - PTS #42565 BEGIN
--IF @drv_qualifications IS NULL OR @drv_qualifications = ''
--   SELECT @drv_qualifications = 'UNK'
--   SELECT @drv_qualifications = ',' + LTRIM(RTRIM(@drv_qualifications)) + ','
-- RE - PTS #42565 END
-- 02/14/2008 MDH PTS 39077: Added to make sure cmp_othertype1 fields are populated. <<BEGIN>>
IF @cmp_othertype1 IS NULL OR @cmp_othertype1 = ''
	SELECT @cmp_othertype1 = 'UNK'
SELECT @cmp_othertype1 = ',' + LTRIM(RTRIM(@cmp_othertype1)) + ','
IF @cmp_othertype1 IS NULL OR @d_cmp_othertype1 = ''
	SELECT @d_cmp_othertype1 = 'UNK'
SELECT @d_cmp_othertype1 = ',' + LTRIM(RTRIM(@d_cmp_othertype1)) + ','
IF @next_cmp_othertype1 IS NULL OR @next_cmp_othertype1 = ''
	SELECT @next_cmp_othertype1 = 'UNK'
SELECT @next_cmp_othertype1 = ',' + LTRIM(RTRIM(@next_cmp_othertype1)) + ','
-- 02/14/2008 MDH PTS 39077: <<END>>

-- RE - PTS #42565 BEGIN
--PTS 36624 JJF 20070911
--INSERT INTO @drv_qualification_list 
--SELECT * FROM CSVStringsToTable_fn(@drv_qualifications)
--
--DELETE FROM @drv_qualification_list 
--WHERE value = '%' or value = '%%'
--
----END PTS 36624 JJF 20070911
-- RE - PTS #42565 END

--vmj2+	Calculate the beginning of the day yesterday..
select @ldt_yesterday = convert(datetime, left(convert(varchar(30), dateadd(day, -1, getdate()), 120), 10))
--vmj2-

--vmj1+	If any values were passed in on the @terminal parm, use a faster select..
select 	@li_count = count(*)
  from	#terminal

if @li_count > 0
begin
	INSERT INTO    #tt
	SELECT  manpowerprofile.mpp_id                  mpp_id,
		company_a.cmp_id                        company_cmp_id,
		company_a.cmp_name                      company_cmp_name,
		city_a.cty_nmstct                       city_cty_nmstct,
		manpowerprofile.mpp_teamleader + @char6 mpp_teamleader,
		manpowerprofile.mpp_avl_date            mpp_avl_date,
		-- dsk 54917 adding @char6 is null here, so result is null
		--manpowerprofile.mpp_status + @char6     mpp_status,
		 manpowerprofile.mpp_status			    mpp_status,

		ordenstatus = case when (select count(ord_status) from orderheader where ord_driver1 = manpowerprofile.mpp_id  and ord_status in ('STD','PNL')) > 0
		then 'Curso' else 'Dispo' end,

		manpowerprofile.mpp_last_home           mpp_last_home,
		manpowerprofile.mpp_want_home           mpp_want_home,
		manpowerprofile.mpp_fleet + @char6      mpp_fleet,
		manpowerprofile.mpp_division + @char6   mpp_division,
		manpowerprofile.mpp_domicile + @char6   mpp_domicile,
		manpowerprofile.mpp_company + @char6    mpp_company,
		manpowerprofile.mpp_terminal + @char6   mpp_terminal,
		manpowerprofile.mpp_type1 + @char6      mpp_type1,
		manpowerprofile.mpp_type2 + @char6      mpp_type2,
		manpowerprofile.mpp_type3 + @char6      mpp_type3,
		manpowerprofile.mpp_type4 + @char6      mpp_type4,
		city_a.cty_state                        city_cty_state,
		city_a.cty_code                         city_cty_code,

		CASE WHEN mpp_exp2_date <= Getdate() THEN 1
			ELSE 0
			END cpri2,
		CASE WHEN mpp_exp2_date <= @neardate THEN 1
			ELSE 0
			END cpri22,
		CASE WHEN mpp_exp1_date <= Getdate() THEN 1
			ELSE 0
			END cpri1,
		CASE WHEN mpp_exp1_date <= @neardate THEN 1
			ELSE 0
			END cpri11,

		--vmj2+	Go back to the beginning of yesterday, because log entries are always saved with a time of 00:00:00..
		case when mpp_last_log_date >= @ldt_yesterday
--		case when mpp_last_log_date >= dateadd(dd,-1,getdate()) 
			then isnull(manpowerprofile.mpp_hours1,-100) 		
			else -100 
			end loghrs,
		--vmj1-

		'F'                                     filtflag,
		'N'                                     updateflag,
		manpowerprofile.mpp_servicerule			servicerule,
		manpowerprofile.mpp_hiredate			mpp_hiredate,
		manpowerprofile.mpp_lastfirst	mpp_lastfirst,
		mpp_gps_desc,
		mpp_gps_date,
        mpp_travel_minutes,
        mpp_mile_day7,
        mpp_last_log_date,
		mpp_hours1,
		mpp_hours2,
		mpp_hours3,
		convert(datetime, null) mpp_last_home_date,
	mpp_prior_event,
	mpp_prior_cmp_id,
	mpp_prior_city,
	city_pr.cty_nmstct mpp_prior_ctyname, 
	company_pr.cmp_state mpp_prior_state, 
	mpp_prior_region1, 
	mpp_prior_region2, 
	mpp_prior_region3, 
	mpp_prior_region4, 
	company_pr.cmp_name mpp_prior_cmp_name,
	mpp_next_event,
	mpp_next_cmp_id,
	mpp_next_city,
	city_n.cty_nmstct mpp_next_ctyname, 
	company_n.cmp_state mpp_next_state, 
	mpp_next_region1, 
	mpp_next_region2, 
	mpp_next_region3, 
	mpp_next_region4,
	company_n.cmp_name mpp_next_cmp_name,
	IsNull(company_a.cmp_geoloc,'') cmp_geoloc,
	@varchar6 mpp_next_exp_code,
	@varchar20 mpp_next_exp_name,
	@dt mpp_next_exp_date,
	@dt mpp_next_exp_compldate,
	mpp_bid_next_starttime,
	mpp_bid_next_type,
	mpp_bid_next_routestore,
	mpp_senioritydate, 
        manpowerprofile.mpp_hours1_week mpp_hours1_week,
	manpowerprofile.mpp_pta_date mpp_pta_date, --DPH PTS 32698
	'N' as exp_affects_avail_dtm,
	mpp_comment1,
	--PTS 51918 JJF 20110209
	NULL,
	--END PTS 51918 JJF 20110209
	--PTS 55760 JJF 20110609
	manpowerprofile.mpp_rtw_date,
	--END PTS 55760 JJF 20110609
	/* 03/27/2012 MDH PTS 59481: <<BEGIN>> */
	manpowerprofile.mpp_hosstatus,
	manpowerprofile.mpp_hosstatusdate,
	manpowerprofile.mpp_hosactivityupdateon
	/* 03/27/2012 MDH PTS 59481: <<END>> */
   FROM #terminal AS tr JOIN manpowerprofile 
                        JOIN labelfile ON manpowerprofile.mpp_status = labelfile.abbr 
                        JOIN company AS company_a ON manpowerprofile.mpp_avl_cmp_id = company_a.cmp_id 
                        JOIN city AS city_a ON manpowerprofile.mpp_avl_city = city_a.cty_code 
             LEFT OUTER JOIN company AS company_n ON manpowerprofile.mpp_next_cmp_id = company_n.cmp_id --(index = pk_id) 
             LEFT OUTER JOIN city AS city_n ON manpowerprofile.mpp_next_city = city_n.cty_code --(index=pk_code)
             LEFT OUTER JOIN company AS company_pr ON manpowerprofile.mpp_prior_cmp_id = company_pr.cmp_id --(index=pk_id)
             LEFT OUTER JOIN city AS city_pr ON manpowerprofile.mpp_prior_city = city_pr.cty_code --(index=pk_code)
        ON tr.mpp_terminal = manpowerprofile.mpp_terminal
  WHERE manpowerprofile.mpp_id <> 'UNKNOWN' AND 
        labelfile.labeldefinition = 'DrvStatus' AND 
		-- dsk 54917
        --labelfile.code < 200 AND 
        labelfile.code < @StatusCutoff AND 
	(manpowerprofile.mpp_avl_date >= DATEADD(hour, - @hoursback, GETDATE()) AND 
         manpowerprofile.mpp_avl_date <= DATEADD(hour, @hoursout, GETDATE())) AND 
        (@mmptype1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @mmptype1) > 0) AND 
        (@mmptype2 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type2 + ',', @mmptype2) > 0) AND 
        (@mmptype3 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type3 + ',', @mmptype3) > 0) AND 
        (@mmptype4 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type4 + ',', @mmptype4) > 0) AND 
        (@teamleader = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_teamleader + ',', @teamleader) > 0) AND 
        (@domicile = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_domicile + ',', @domicile) > 0) AND
        (@fleet = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_fleet + ',', @fleet) > 0) AND 
        (@division = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_division + ',', @division) > 0) AND 
        (@company = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_company + ',', @company) > 0) AND 
        (@states = ',UNK,' OR CHARINDEX(',' + city_a.cty_state + ',', @states) > 0) AND 
        (@cmpids = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_avl_cmp_id + ',', @cmpids) > 0) AND 
	(@region1 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region1 + ',', @region1) > 0) AND 
	(@region2 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region2 + ',', @region2) > 0) AND 
	(@region3 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region3 + ',', @region3) > 0) AND 
	(@region4 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region4 + ',', @region4) > 0) AND 
	(@cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + company_a.cmp_othertype1 + ',', @cmp_othertype1) > 0) AND 	/* 02/25/2008 MDH PTS 39077: Added */
	(@city = city_a.cty_code OR @city = 0) AND 
	(@last_event = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_event + ',', @last_event) > 0) AND 
	(@d_states = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_state + ',', @d_states) > 0) AND 
	(@d_city = 0 OR manpowerprofile.mpp_prior_city = @d_city) AND 
	(@d_cmpids = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_cmp_id + ',', @d_cmpids) > 0) AND 
	(@d_reg1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region1 + ',', @d_reg1) > 0) AND 
	(@d_reg2 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region2 + ',', @d_reg2) > 0) AND 
	(@d_reg3 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region3 + ',', @d_reg3) > 0) AND 
	(@d_reg4 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region4 + ',', @d_reg4) > 0) AND 
	(@d_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_cmp_othertype1 + ',', @d_cmp_othertype1) > 0) AND 	/* 02/25/2008 MDH PTS 39077: Added */
	(@next_event = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_event + ',', @next_event) > 0) AND 
	(@next_state = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_state + ',', @next_state) > 0) AND 
	(@next_city = 0 OR manpowerprofile.mpp_next_city = @next_city) AND 
	(@next_cmp_id = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_cmp_id + ',', @next_cmp_id) > 0) AND 
	(@next_region1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region1 + ',', @next_region1) > 0) AND
	(@next_region2 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region2 + ',', @next_region2) > 0) AND
	(@next_region3 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region3 + ',', @next_region3) > 0) AND
	(@next_region4 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region4 + ',', @next_region4) > 0) AND 
	(@next_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_cmp_othertype1 + ',', @next_cmp_othertype1) > 0) AND 	/* 02/25/2008 MDH PTS 39077: Added */
	(@drv_status = ',UNK,' OR CHARINDEX(',' + cast(manpowerprofile.mpp_status as varchar(6)) + ',', @drv_status) > 0) --AND 
	--PTS 36624 JJF 20070911
	--(@drv_qualifications = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_qualificationlist + ',', @drv_qualifications) > 0) 
-- RE - PTS #42565 BEGIN
--	(@drv_qualifications = ',UNK,' OR EXISTS(SELECT * 
--										FROM @drv_qualification_list ql INNER JOIN driverqualifications drvq on ql.value = drvq.drq_type 
--										where drq_driver = manpowerprofile.mpp_id))
--	--END PTS 36624 JJF 20070911
-- RE - PTS #42565 END
end
else
begin
	INSERT INTO    #tt
	SELECT  manpowerprofile.mpp_id                  mpp_id,
		company_a.cmp_id                        company_cmp_id,
		company_a.cmp_name                      company_cmp_name,
		city_a.cty_nmstct                       city_cty_nmstct,
		manpowerprofile.mpp_teamleader + @char6 mpp_teamleader,
		manpowerprofile.mpp_avl_date            mpp_avl_date,
		-- dsk 54917
		--manpowerprofile.mpp_status + @char6     mpp_status,
		manpowerprofile.mpp_status				mpp_status,
		manpowerprofile.mpp_last_home           mpp_last_home,
		manpowerprofile.mpp_want_home           mpp_want_home,
		manpowerprofile.mpp_fleet + @char6      mpp_fleet,
		manpowerprofile.mpp_division + @char6   mpp_division,
		manpowerprofile.mpp_domicile + @char6   mpp_domicile,
		manpowerprofile.mpp_company + @char6    mpp_company,
		manpowerprofile.mpp_terminal + @char6   mpp_terminal,
		manpowerprofile.mpp_type1 + @char6      mpp_type1,
		manpowerprofile.mpp_type2 + @char6      mpp_type2,
		manpowerprofile.mpp_type3 + @char6      mpp_type3,
		manpowerprofile.mpp_type4 + @char6      mpp_type4,
		city_a.cty_state                        city_cty_state,
		city_a.cty_code                         city_cty_code,

		CASE WHEN mpp_exp2_date <= Getdate() THEN 1
			ELSE 0
			END cpri2,
		CASE WHEN mpp_exp2_date <= @neardate THEN 1
			ELSE 0
			END cpri22,
		CASE WHEN mpp_exp1_date <= Getdate() THEN 1
			ELSE 0
			END cpri1,
		CASE WHEN mpp_exp1_date <= @neardate THEN 1
			ELSE 0
			END cpri11,

		--vmj2+	Go back to the beginning of yesterday, because log entries are always saved with a time of 00:00:00..
		case when mpp_last_log_date >= @ldt_yesterday
--		case when mpp_last_log_date >= dateadd(dd,-1,getdate()) 
		--vmj2-
			then isnull(manpowerprofile.mpp_hours1,-100) 		
			else -100 
			end loghrs,

		'F' filtflag,
		'N' updateflag,
		manpowerprofile.mpp_servicerule	servicerule,
		manpowerprofile.mpp_hiredate	mpp_hiredate,
		manpowerprofile.mpp_lastfirst	mpp_lastfirst,
		mpp_gps_desc,
		mpp_gps_date,
        mpp_travel_minutes,
        mpp_mile_day7,
        mpp_last_log_date,
		mpp_hours1,
		mpp_hours2,
		mpp_hours3,
		convert(datetime, null) mpp_last_home_date,
	mpp_prior_event,
	mpp_prior_cmp_id,
	mpp_prior_city,
	city_pr.cty_nmstct mpp_prior_ctyname, 
	company_pr.cmp_state mpp_prior_state, 
	mpp_prior_region1, 
	mpp_prior_region2, 
	mpp_prior_region3, 
	mpp_prior_region4, 
	company_pr.cmp_name mpp_prior_cmp_name,
	mpp_next_event,
	mpp_next_cmp_id,
	mpp_next_city,
	city_n.cty_nmstct mpp_next_ctyname, 
	company_n.cmp_state mpp_next_state, 
	mpp_next_region1, 
	mpp_next_region2, 
	mpp_next_region3, 
	mpp_next_region4,
	company_n.cmp_name mpp_next_cmp_name,
	IsNUll(company_a.cmp_geoloc,'') cmp_geoloc,
	@varchar6	mpp_next_exp_code,
	@varchar20	mpp_next_exp_name,
	@dt 		mpp_next_exp_date,
	@dt			mpp_next_exp_compldate,
	mpp_bid_next_starttime,
	mpp_bid_next_type,
	mpp_bid_next_routestore,
	mpp_senioritydate,
        manpowerprofile.mpp_hours1_week mpp_hours1_week,
	manpowerprofile.mpp_pta_date mpp_pta_date, --DPH PTS 32698
	'N' as exp_affects_avail_dtm, --JLB PTS 32387
     mpp_comment1,
	--PTS 51918 JJF 20110209
	NULL,
	--END PTS 51918 JJF 20110209
	--PTS 55760 JJF 20110609
	manpowerprofile.mpp_rtw_date,
	--END PTS 55760 JJF 20110609
	/* 03/27/2012 MDH PTS 59481: <<BEGIN>> */
	manpowerprofile.mpp_hosstatus,
	manpowerprofile.mpp_hosstatusdate,
	manpowerprofile.mpp_hosactivityupdateon
	/* 03/27/2012 MDH PTS 59481: <<END>> */

   FROM manpowerprofile JOIN labelfile ON manpowerprofile.mpp_status = abbr 
                        JOIN company AS company_a ON manpowerprofile.mpp_avl_cmp_id = company_a.cmp_id
                        JOIN city AS city_a ON manpowerprofile.mpp_avl_city = city_a.cty_code 
             LEFT OUTER JOIN company AS company_pr ON manpowerprofile.mpp_prior_cmp_id = company_pr.cmp_id --(index=pk_id) 
             LEFT OUTER JOIN city AS city_pr ON manpowerprofile.mpp_prior_city = city_pr.cty_code --(index=pk_code) 
             LEFT OUTER JOIN company AS company_n ON manpowerprofile.mpp_next_cmp_id = company_n.cmp_id --(index=pk_id) 
             LEFT OUTER JOIN city AS city_n ON manpowerprofile.mpp_next_city = city_n.cty_code --(index=pk_code) 
  WHERE manpowerprofile.mpp_id <> 'UNKNOWN' AND 
        labelfile.labeldefinition = 'DrvStatus' AND 
		-- dsk 54917
        --labelfile.code < 200 AND 
		labelfile.code < @StatusCutOff AND
		(manpowerprofile.mpp_avl_date >= DATEADD(hour, - @hoursback, GETDATE()) AND 
         manpowerprofile.mpp_avl_date <= DATEADD(hour, @hoursout, GETDATE())) AND 
        (@mmptype1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @mmptype1) > 0) AND 
        (@mmptype2 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type2 + ',', @mmptype2) > 0) AND 
        (@mmptype3 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type3 + ',', @mmptype3) > 0) AND 
        (@mmptype4 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_type4 + ',', @mmptype4) > 0) AND 
        (@teamleader = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_teamleader + ',', @teamleader) > 0) AND 
        (@domicile = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_domicile + ',', @domicile) > 0) AND
        (@fleet = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_fleet + ',', @fleet) > 0) AND 
        (@division = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_division + ',', @division) > 0) AND 
        (@company = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_company + ',', @company) > 0) AND 
        (@states = ',UNK,' OR CHARINDEX(',' + city_a.cty_state + ',', @states) > 0) AND 
        (@cmpids = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_avl_cmp_id + ',', @cmpids) > 0) AND 
	(@region1 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region1 + ',', @region1) > 0) AND 
	(@region2 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region2 + ',', @region2) > 0) AND 
	(@region3 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region3 + ',', @region3) > 0) AND 
	(@region4 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region4 + ',', @region4) > 0) AND 
	(@cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + company_a.cmp_othertype1 + ',', @cmp_othertype1) > 0) AND 	/* 02/25/2008 MDH PTS 39077: Added */
	(@city = city_a.cty_code OR @city = 0) AND 
	(@last_event = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_event + ',', @last_event) > 0) AND 
	(@d_states = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_state + ',', @d_states) > 0) AND 
	(@d_city = 0 OR manpowerprofile.mpp_prior_city = @d_city) AND 
	(@d_cmpids = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_cmp_id + ',', @d_cmpids) > 0) AND 
	(@d_reg1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region1 + ',', @d_reg1) > 0) AND 
	(@d_reg2 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region2 + ',', @d_reg2) > 0) AND 
	(@d_reg3 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region3 + ',', @d_reg3) > 0) AND 
	(@d_reg4 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_region4 + ',', @d_reg4) > 0) AND 
	(@d_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_prior_cmp_othertype1 + ',', @d_cmp_othertype1) > 0) AND 	/* 02/25/2008 MDH PTS 39077: Added */
	(@next_event = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_event + ',', @next_event) > 0) AND 
	(@next_state = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_state + ',', @next_state) > 0) AND 
	(@next_city = 0 OR manpowerprofile.mpp_next_city = @next_city) AND 
	(@next_cmp_id = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_cmp_id + ',', @next_cmp_id) > 0) AND 
	(@next_region1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region1 + ',', @next_region1) > 0) AND
	(@next_region2 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region2 + ',', @next_region2) > 0) AND
	(@next_region3 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region3 + ',', @next_region3) > 0) AND
	(@next_region4 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_region4 + ',', @next_region4) > 0) AND 
	(@next_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_next_cmp_othertype1 + ',', @next_cmp_othertype1) > 0) AND 	/* 02/25/2008 MDH PTS 39077: Added */
	(@drv_status = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_status + ',', @drv_status) > 0) --AND 
-- RE - PTS #42565 BEGIN
--	--PTS 36624 JJF 20070911
--	--(@drv_qualifications = ',UNK,' OR CHARINDEX(',' + manpowerprofile.mpp_qualificationlist + ',', @drv_qualifications) > 0) 
--	(@drv_qualifications = ',UNK,' OR EXISTS(SELECT * 
--										FROM @drv_qualification_list ql INNER JOIN driverqualifications drvq on ql.value = drvq.drq_type 
--										where drq_driver = manpowerprofile.mpp_id))
--	--END PTS 36624 JJF 20070911
-- RE - PTS #42565 END
end
--vmj1-

-- PTS 51570 JJF 20100510
----PTS 40155 JJF 20071128
--SELECT @rowsecurity = gi_string1
--FROM generalinfo 
--WHERE gi_name = 'RowSecurity'

----PTS 41877
----SELECT @tmwuser = suser_sname()
--exec @tmwuser = dbo.gettmwuser_fn

--IF @rowsecurity = 'Y' AND EXISTS(SELECT * 
--				FROM UserTypeAssignment
--				WHERE usr_userid = @tmwuser) BEGIN 
	
--	DELETE #tt
--	from #tt tp inner join manpowerprofile mpp on tp.mpp_id = mpp.mpp_id
--	where NOT ((isnull(mpp.mpp_terminal, 'UNK') = 'UNK' 
--			or EXISTS(SELECT * 
--						FROM UserTypeAssignment
--						WHERE usr_userid = @tmwuser	
--								and (uta_type1 = mpp.mpp_terminal
--										or uta_type1 = 'UNK'))))
--END
----END PTS 40155 JJF 20071128

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN 
	DELETE #tt
	from #tt tp inner join manpowerprofile mpp on tp.mpp_id = mpp.mpp_id
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_manpowerprofile_fn() rsva 
							WHERE	mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)
END
--END PTS 51570 JJF 20100510

-- PTS 40155 JJF 20071128 - remove =* 
UPDATE  #tt
SET     mpp_teamleader = (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_teamleader AND
					labeldefinition = 'TeamLeader'),
	mpp_status =    (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_status AND 
							labeldefinition = 'DrvStatus'),
	mpp_fleet =     (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_fleet AND
						labeldefinition = 'Fleet'),
	mpp_division =  (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_division AND
						labeldefinition = 'Division'),
	mpp_domicile =  (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_domicile AND
						labeldefinition = 'Domicile'),
	mpp_company =   (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_company AND
						labeldefinition = 'Company'),
	mpp_terminal =  (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_terminal AND
						labeldefinition = 'Terminal')
UPDATE  #tt
SET     mpp_type1 = (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_type1 AND
						labeldefinition = 'DrvType1'),
	mpp_type2 =     (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_type2 AND
						labeldefinition = 'DrvType2'),
	mpp_type3 =     (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_type3 AND
						labeldefinition = 'DrvType3'),
	mpp_type4 =     (SELECT name
					FROM labelfile
					WHERE abbr = #tt.mpp_type4 AND
						labeldefinition = 'DrvType4')

/* update last home date */
update #tt
set mpp_last_home_date = (select max(mhl_end) from manpowerhomelog
				where #tt.mpp_id = manpowerhomelog.mpp_id)

--#12815 04/17/02 JD.
If exists (select * from generalinfo where gi_name = 'PlnWrkshtShowDrvExpirations' and substring(gi_string1,1,1) = 'Y' )
BEGIN
	Update 	#TT
	set 	mpp_next_exp_code 	= 	b.exp_code,
			mpp_next_exp_name	=	substring(b.exp_description,1,20),
		    mpp_next_exp_date	=	b.exp_expirationdate,
			mpp_next_exp_compldate = b.exp_compldate
	from	expiration b
	where	b.exp_idtype = 'DRV' and
			b.exp_id = #TT.mpp_id and
			b.exp_expirationdate = (select min(exp_expirationdate) from expiration d where
											d.exp_idtype = 'DRV' and
											d.exp_id = #TT.mpp_id and
											d.exp_expirationdate >= getdate() and
											d.exp_completed = 'N')



		Update 	#TT 
		set		mpp_avl_date = exp_compldate
		from 	expiration b
		where	b.exp_idtype = 'DRV' and
				b.exp_id = #TT.mpp_id and
				b.exp_compldate = (select max(exp_compldate) from expiration d where
									d.exp_idtype = b.exp_idtype and 
									d.exp_id	 = b.exp_id and 
									d.exp_expirationdate <= getdate() and
									d.exp_compldate >= getdate() and
									d.exp_completed = 'N')

END
--JLB PTS 32387 new logic to allow starting of expirations for planning purposes only
IF exists (select * from generalinfo where gi_name = 'PlnWrkshtStartExpForPlanning' and left(gi_string1,1) = 'Y')
begin
	--Loop thru each row and update the available date if there is an expiration marked as started that has a higher end date than the current one
	--Loop by Driver
	select @vs_counter = min(mpp_id), @vdtm_avl_date = min(mpp_avl_date)
	  from #TT
	 where mpp_id <> 'UNKNOWN'
	while @vs_counter is not null
    begin
		set @vdtm_exp_completiondate = NULL
		select @vdtm_exp_completiondate = exp_compldate 
		  from expiration b 
		 where b.exp_control_avl_date = 'Y' 
		   and b.exp_id = @vs_counter
		   and b.exp_idtype = 'DRV'
		if isnull(@vdtm_exp_completiondate, '01/01/50 00:00:00.000') > @vdtm_avl_date
		begin
			update #TT
			   set mpp_avl_date = @vdtm_exp_completiondate,
                   exp_affects_avail_dtm = 'Y'
             where mpp_id = @vs_counter
		end
	select @vs_counter = min(mpp_id), @vdtm_avl_date = min(mpp_avl_date)
	  from #TT
	 where mpp_id <> 'UNKNOWN'
       and mpp_id > @vs_counter	
	end
end
--end 32387

-- RE - PTS #42565 BEGIN
DECLARE @accessory_count INT

--select len(@drv_qualifications)

IF len(@drv_qualifications) > 0
BEGIN
	
	DECLARE @drvaccessories TABLE  (value VARCHAR(8))

	INSERT @drvaccessories(value) SELECT * FROM CSVStringsToTable_fn(@drv_qualifications) WHERE value NOT IN ('','%','%%')


	SELECT @accessory_count = count(*) from @drvaccessories

	IF @accessory_count > 0
	BEGIN
		DELETE	#TT
		 WHERE	mpp_id NOT IN
					(SELECT	t.mpp_id
					   FROM	#TT t
								inner join driverqualifications ta on t.mpp_id = ta.drq_driver and ta.drq_expire_date >= getdate() and isnull(ta.drq_expire_flag, 'N') <> 'Y' and drq_source = 'DRV'
								inner join @drvaccessories tc on ta.drq_type = tc.value
					GROUP BY t.mpp_id
					HAVING COUNT(*) = @accessory_count)
	END
END
-- RE - PTS #42565 END

--PTS 51918 JJF 20110210
DECLARE @AssetsToInclude varchar(60)
DECLARE @DisplayQualifications varchar(1)
DECLARE @Delimiter varchar(1)
DECLARE @IncludeAssetPrefix int
DECLARE @IncludeLabelName int

SELECT	@DisplayQualifications = ISNULL(gi_string1, 'N'),
		@AssetsToInclude = ',' + ISNULL(gi_string2, '') + ',',
		@Delimiter = ISNULL(gi_string3, '*'),
		@IncludeAssetPrefix = ISNULL(gi_integer1, 0),
		@IncludeLabelName = ISNULL(gi_integer2, 0)
FROM	generalinfo
WHERE gi_name = 'QualListDriverPlan'

IF @DisplayQualifications = 'Y' BEGIN
	IF @AssetsToInclude = ',,' BEGIN
		SET @AssetsToInclude = ',DRV1,'
	END

	UPDATE #tt
	SET qualification_list_drv = dbo.QualificationsToCSV_fn	(	CASE CHARINDEX(',DRV1,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE #tt.mpp_id END, 
															NULL, 
															NULL, 
															NULL, 
															NULL, 
															NULL, 
															NULL,
															NULL,
															NULL,
															#tt.mpp_avl_date, 
															#tt.mpp_avl_date,
															@IncludeAssetPrefix,
															@IncludeLabelName,
															@Delimiter
														)
	FROM #tt
END 
--END PTS 51918 JJF 20110210

SELECT  


  	Cliente =   (select ord_billto from orderheader where ord_hdrnumber in (select max(ord_hdrnumber) from orderheader where ord_status ='CMP'
	and ord_Driver1 = mpp_id)),
	
	Origen =  (select cmp_id_start from legheader where lgh_number in (select max(lgh_number) from legheader where lgh_outstatus ='CMP'
	and lgh_driver1 = mpp_id)),

	Destino = (select cmp_id_end from legheader where lgh_number in (select max(lgh_number) from legheader where lgh_outstatus ='CMP'
	and lgh_driver1 = mpp_id)),

	Remolque = (select max(stp_departuredate) from stops  where mov_number = 
	  (select mov_number from orderheader where ord_hdrnumber in (select max(ord_hdrnumber) from orderheader where ord_status ='CMP'
	and ord_Driver1 = mpp_id))),

    Proyecto = isnull((select replace(name,'BAJIO','ABIERTO') from labelfile where labeldefinition = 'revtype3' and abbr = 
	(select ord_revtype3 from orderheader where ord_hdrnumber = (select max(ord_hdrnumber) from orderheader where ord_driver1 = mpp_id  and ord_status = 'CMP'))),'UNKNOWN'),
    
	Region =  
	isnull((select rgh_name from regionheader where rgh_id = (select lgh_endregion1 from legheader where lgh_number in (select max(lgh_number) from legheader where lgh_outstatus ='CMP'
	and lgh_driver1 = mpp_id))),''),
	           
    Tractor = (select mpp_tractornumber from manpowerprofile ma where ma.mpp_id = #tt.mpp_id),
	Operador = mpp_id,
	Status = 'DSP' ,
	OrdStatus = mpp_status,

	Fecha = (select max(stp_departuredate) from stops  where mov_number = 
	  (select mov_number from orderheader where ord_hdrnumber in (select max(ord_hdrnumber) from orderheader where ord_status ='CMP'
	and ord_Driver1 = mpp_id))),

	Ciudad =  (select legheader.lgh_endcty_nmstct from legheader where lgh_number in (select max(lgh_number) from legheader where lgh_outstatus ='CMP'
	and lgh_driver1 = mpp_id))

FROM    #tt 
where mpp_status = 'Available' and mpp_id <> 'TDRTD'
and 
(select rgh_name from regionheader where rgh_id =  (select lgh_endregion1 from legheader where lgh_number in (select max(lgh_number) from legheader where lgh_outstatus ='CMP'
	and lgh_driver1 = mpp_id)))
 is not null

--vmj1+
drop table #tt
drop table #terminal
--vmj1-

GO

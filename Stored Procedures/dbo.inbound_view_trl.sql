SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	PROCEDURE [dbo].[inbound_view_trl]
	@p_trctype1       varchar(254),
	@p_trctype2       varchar(254),
	@p_trctype3       varchar(254), 
	@p_trctype4       varchar(254),
	@p_fleet          varchar(254),
	@p_division       varchar(254),
	@p_company        varchar(254),
	@p_terminal       varchar(254),
	@p_states         varchar(254),
	@p_cmp_id         varchar(254),
	@p_region1        varchar(254),
	@p_region2        varchar(254),
	@p_region3        varchar(254),
	@p_region4        varchar(254),
	@p_city           int,
	@p_hoursback      int,
	@p_hoursout       int,
	@p_days           int,
	@p_trlstatus      varchar(254), 
	@p_last_event varchar(254),
	@p_d_states varchar (254), 
	@p_d_cmpids varchar (254), 
	@p_d_reg1 varchar (254), 
	@p_d_reg2 varchar (254), 
	@p_d_reg3 varchar (254), 
	@p_d_reg4 varchar (254), 
	@p_d_city int,
	@p_next_event varchar(254),
	@p_next_cmp_id varchar(254),
	@p_next_city int , 
	@p_next_state varchar(254), 
	@p_next_region1 varchar(254), 
	@p_next_region2 varchar(254), 
	@p_next_region3 varchar(254), 
	@p_next_region4 varchar(254),
	@p_trl_accessories varchar(254), 
	@p_cmp_othertype1 varchar(254), 	-- 02/14/2008 MDH PTS 39077: Added
	@p_d_cmp_othertype1 varchar(254), 	-- 02/14/2008 MDH PTS 39077: Added
	@p_next_cmp_othertype1 varchar(254),	-- 02/14/2008 MDH PTS 39077: Added
	@p_trl_equipment_type	varchar(254)
AS

	SET NOCOUNT ON

/**
 * 
 * NAME:
 * dbo.inbound_view_trl
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a snapshot of the trailers location, status etc.
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 *  @p_trctype1  - trailer type 1
 *  @p_trctype2  - trailer type 2    
 *  @p_trctype3  - trailer type 3     
 *  @p_trctype4  - trailer type 4  
 *  @p_fleet     - trailer fleet
 *  @p_division  - trailer division
 *  @p_company   - company
 *  @p_terminal  - terminal
 *  @p_states    - state     
 *  @p_cmp_id    - company ID     
 *  @p_region1   - region 1     
 *  @p_region2   - region 2     
 *  @p_region3   - region 3     
 *  @p_region4   - region 4      
 *  @p_city      - city     
 *  @p_hoursback - hours back
 *  @p_hoursout  - hours out     
 *  @p_days      - days     
 *  @p_trlstatus - trailer status     
 *  @p_last_event - last event 
 *  @p_d_states - prior states 
 *  @p_d_cmpids - prior company 
 *  @p_d_reg1 - prior region 1
 *  @p_d_reg2 - prior region 2
 *  @p_d_reg3 - prior region 3
 *  @p_d_reg4 - prior region 4
 *  @p_d_city - prior city
 *  @p_next_event - next event
 *  @p_next_cmp_id - next company id
 *  @p_next_city - next city  
 *  @p_next_state - next state 
 *  @p_next_region1 - next region 1
 *  @p_next_region2 - next region 2 
 *  @p_next_region3 - next region 3
 *  @p_next_region4 - next region 4
 *  @p_trl_accessories - trailer accessories
 *	@p_cmp_othertype1  - cmp_othertype1 for cmp 			-- 02/14/2008 MDH PTS 39077: Added
 *	@p_d_cmp_othertype1 - cmp_othertype1 for prior cmp		-- 02/14/2008 MDH PTS 39077: Added
 *	@p_next_cmp_othertype1 - cmp_othertype1 for next cmp	-- 02/14/2008 MDH PTS 39077: Added
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 ********************************************************************************************************************************************
 *  1) If len(label.name)>12 for trl_types1..4, then column update fails. 
 *	SNBC has 55 label.name for trl,trc,car,oth(cmp)and drv that are >12 long -- TRL_types is all that matter for this
 *	proc.
 *  2) If len(company.cmp_name)>30 then column update fail too. SNBC has 17 companies like 
 *  3) if type Abbr value is a subset of another value then the restriction fails
 *	Example. If trailer 100 has trl_type1='CR' and they restrict to 'CRB' trailer 100 is included
 *	<< ( ',' +@trctype1 like '%,'+trailerprofile.trl_type1+'%' OR @trctype1 = '') AND  >>  IS wrong	
 *  4) Variable @char6 was not being initialized. Added line  Set @char6 =''
 *
 *  Search for DM_2002_05_05 to see specific changes below	
 *
 ********************************************************************************************************************************************
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 01/08/1998 - PTS3436  - PG -  Performance Enhancement added NOLOCK on expiration
 * 08/01/2001 - PTS11594 - Vern Jewett - (label=vmj1) DB performance (Manfredi)
 * 12/21/2001 - PTS12599 - dpete - add cmp_geoloc to return set for Gibson 
 * 07/12/2002 -	PTS14722 - Vern Jewett - (label=vmj2) when a VPlanner view with Terminal spec is used, no rows are selected..
 * 10/16/2005 - PTS27429 - Imari Bremer - add new column which displays the current actual location of the trailer
 * 01/04/2006 - PTS31173 - Ron Eyink - changes for performance improvement 
 * 02/14/2008 - PTS39077 - Mark Hampton - added cmp_othertype1 searches.
 * 12/17/2009 - PTS48613 - vjh add User Defined Fields
 **/

--PTS70753 JJF 20130826 - re-written.  Original commented out at bottom

DECLARE 
	@v_neardate			datetime,
	@v_trl_planmode   	char(1),
	@v_statuscode     	varchar(254),
	@udflabel			varchar(255),
	@StatusCutoff	INTEGER -- dsk 54917

DECLARE	@sql nvarchar(max)

DECLARE @lfh_trltype1 varchar(20)
DECLARE @lfh_trltype2 varchar(20)
DECLARE @lfh_trltype3 varchar(20)
DECLARE @lfh_trltype4 varchar(20)

-- KM PTS 13769, read generalinfo to determine what to put in the status and location fields
SELECT 	@v_trl_planmode = gi_string1
	FROM	generalinfo
	WHERE	gi_name = 'ENHANCEDTRAILERPLANNING'

If Upper(left(@v_trl_planmode,1)) = 'Y'
	SELECT 	@v_statuscode = ',' + gi_string1 + ','
		FROM	generalinfo
		WHERE	gi_name = 'ENHANCEDTRAILERPLNstatus'
		
SELECT @v_STATUSCODE = Isnull(@v_Statuscode, '')

-- dsk 54917
SELECT @StatusCutoff = gi_integer1
	FROM	generalinfo
	WHERE	gi_name = 'IBViewStatusCutoff'
SELECT @StatusCutoff = ISNULL(@StatusCutoff, 200)


--CREATE TABLE #TT (
DECLARE @TT TABLE (
	trl_id				varchar(13)	PRIMARY KEY CLUSTERED,
	cmp_id				varchar(8),
	cmp_name			varchar(100)	null,
	cty_nmstct			varchar(25)		null,
	trl_avail_date		datetime		null,
	trl_status 			varchar(20)		null,
	trl_type1 			varchar(20)		null,    
	trl_type2 			varchar(20)		null, 
	trl_type3 			varchar(20)		null, 
	trl_type4 			varchar(20)		null,    
	trl_company 		varchar(20)		null, 
	trl_fleet 			varchar(20)		null, 
	trl_division 		varchar(20)		null,
	trl_terminal 		varchar(20)		null,
	cty_state			varchar(6)		null,
	cty_code			int				null,
	cpril2				int				null,
	cpril22				int				null,
	cpril1				int				null,
	cpril11				int				null,
	filtflag			varchar(1)		null,
	trltype1header		varchar(20)		null,
	trltype2header		varchar(20)		null,
	trltype3header		varchar(20)		null,
	trltype4header		varchar(20)		null,
	trl_wash_status		char(1)			null,
	trl_last_cmd		varchar(8)		null,
	trl_last_cmd_ord	varchar(12)		null,
	trl_last_cmd_date	datetime		null,
	trl_prior_event		char(6)			null,
	trl_prior_cmp_id	varchar(8)		null,
	trl_prior_city		int				null,
	trl_prior_ctyname	varchar(25)		null, 
	trl_prior_state		varchar(6)		null, 
	trl_prior_region1	varchar(6)		null, 
	trl_prior_region2	varchar(6)		null, 
	trl_prior_region3	varchar(6)		null, 
	trl_prior_region4	varchar(6)		null,
	trl_prior_cmp_name	varchar(100)	null,
	trl_next_event		char(6)			null,
	trl_next_cmp_id		varchar(8)		null,
	trl_next_city		int				null,
	trl_next_ctyname	varchar(25)		null, 
	trl_next_state		varchar(6)		null, 
	trl_next_region1	varchar(6)		null, 
	trl_next_region2	varchar(6)		null, 
	trl_next_region3	varchar(6)		null, 
	trl_next_region4	varchar(6)		null, 
	trl_next_cmp_name	varchar(100)	null,
	cmp_geoloc			varchar(50)		null,
	trl_worksheet_comment1 varchar(60)	null,
	trl_worksheet_comment2 varchar(60)	null,
	trl_gps_desc		varchar (45)	null, /*PTS 23481 CGK 10/20/2004*/
	trl_actual_location	varchar(30)		null, /* PTS# 27429 ILB 10/26/2005 */
	udf_trl_1			varchar(255)	null,   -- vjh 48613
	udf_trl_2			varchar(255)	null,
	udf_trl_3			varchar(255)	null,
	udf_trl_4			varchar(255)	null,
	udf_trl_5			varchar(255)	null,
	udf_trl_6			varchar(255)	null,
	udf_trl_7			varchar(255)	null,
	udf_trl_8			varchar(255)	null,
	udf_trl_9			varchar(255)	null,
	udf_trl_10			varchar(255)	null,
	udf_trl_1_t			varchar(255)	null,
	udf_trl_2_t			varchar(255)	null,
	udf_trl_3_t			varchar(255)	null,
	udf_trl_4_t			varchar(255)	null,
	udf_trl_5_t			varchar(255)	null,
	udf_trl_6_t			varchar(255)	null,
	udf_trl_7_t			varchar(255)	null,
	udf_trl_8_t			varchar(255)	null,
	udf_trl_9_t			varchar(255)	null,
	udf_trl_10_t		varchar(255)	null,
	trl_equipmenttype	varchar(10)		null,
	trl_rowsec_rsrv_id	integer			null,
	--PTS 51918 20110209
	qualification_list_trl	varchar(255)	null
	--END PTS 51918 20110209
	)


DECLARE @temp TABLE (
	trl_id varchar(13) PRIMARY KEY CLUSTERED,   
	max_asgn_enddate datetime, 
	asgn_number int, 
	cty_nmstct varchar(25)

)   
  

SELECT  @v_neardate = DateAdd(dy, @p_days, GetDate())

If @p_hoursback = 0
	SELECT @p_hoursback = 1000000
If @p_hoursout = 0
	SELECT @p_hoursout = 1000000

IF @p_city IS NULL
   SELECT @p_city = 0
IF @p_d_city IS NULL
   SELECT @p_d_city = 0
IF @p_next_city IS NULL
   SELECT @p_next_city = 0
-- RE - PTS #42565 BEGIN
--IF @p_trl_accessories IS NULL OR @p_trl_accessories = ''
--   SELECT @p_trl_accessories = 'UNK'
--   SELECT @p_trl_accessories = ',' + LTRIM(RTRIM(@p_trl_accessories)) + ','
-- RE - PTS #42565 END


SELECT TOP 1	@lfh_trltype1 = trltype1,
		@lfh_trltype2 = trltype2, 
		@lfh_trltype3 = trltype3, 
		@lfh_trltype4 = trltype4
FROM	labelfile_headers

SET @sql = 'SELECT  trl.trl_id,
	company_a.cmp_id,
	company_a.cmp_name,
	city_a.cty_nmstct,
	trl.trl_avail_date,
	trl.trl_status,
	lblTrlType1.name,
	lblTrlType2.name,
	lblTrlType3.name, 
	lblTrlType4.name,
	lblCompany.name,
	lblFleet.name,
	lblDivision.name,
	lblTerminal.name,
	city_a.cty_state,
	city_a.cty_code,
	CASE WHEN trl.trl_exp2_date <= Getdate() THEN 1
		ELSE 0
		END cpril2,
	CASE WHEN  trl.trl_exp2_date <= @v_neardate THEN 1
		ELSE 0
		END cpril22,
	CASE WHEN trl.trl_exp1_date <= Getdate() THEN 1
		ELSE 0
		END cpril1,
	CASE WHEN trl.trl_exp1_date <= @v_neardate THEN 1
		ELSE 0
		END cpril11,
	''F'' filtflag,'

SELECT @sql = @sql + '''' + @lfh_trltype1 + N''' trltype1header,'
SELECT @sql = @sql + '''' + @lfh_trltype2 + N''' trltype2header,'
SELECT @sql = @sql + '''' + @lfh_trltype3 + N''' trltype3header,'
SELECT @sql = @sql + '''' + @lfh_trltype4 + N''' trltype4header,'

SELECT @sql = @sql + ' trl.trl_wash_status,
	trl.trl_last_cmd,
	trl.trl_last_cmd_ord,
	trl.trl_last_cmd_date,
	trl.trl_prior_event,
	trl.trl_prior_cmp_id,
	trl.trl_prior_city,
	city_pr.cty_nmstct trl_prior_ctyname, 
	company_pr.cmp_state trl_prior_state, 
	trl.trl_prior_region1, 
	trl.trl_prior_region2, 
	trl.trl_prior_region3, 
	trl.trl_prior_region4, 
	company_pr.cmp_name trl_prior_cmp_name,
	trl.trl_next_event,
	trl.trl_next_cmp_id,
	trl.trl_next_city,
	city_n.cty_nmstct trl_next_ctyname, 
	company_n.cmp_state trl_next_state, 
	trl.trl_next_region1, 
	trl.trl_next_region2, 
	trl.trl_next_region3, 
	trl.trl_next_region4, 
	company_n.cmp_name trl_next_cmp_name,
	ISNULL(company_a.cmp_geoloc, '''') cmp_geoloc,
	trl.trl_worksheet_comment1,
	trl.trl_worksheet_comment2,
	trl.trl_gps_desc, 
	'''' trl_actual_location,		 
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,		
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	trl.trl_equipmenttype,
	trl.rowsec_rsrv_id,
	NULL
'

SET @sql = @sql + '	FROM	trailerprofile trl with (nolock)'

IF EXISTS	(	SELECT	1
				FROM	generalinfo
				WHERE	gi_name = 'RowSecurity'
						AND gi_string1 = 'Y'
			) BEGIN
	
	SET @sql = @sql + ' INNER JOIN RowRestrictValidAssignments_trailerprofile_fn() rsva on (trl.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)'
END

SET @sql = @sql + '	INNER JOIN labelfile lblTrlStatus with (nolock) ON (trl.trl_status = lblTrlStatus.abbr AND lblTrlStatus.labeldefinition = ''TrlStatus'') 
	LEFT OUTER JOIN labelfile lblTrlType1 with (nolock) ON (trl.trl_type1 = lblTrlType1.abbr AND lblTrlType1.labeldefinition = ''TrlType1'') 
	LEFT OUTER JOIN labelfile lblTrlType2 with (nolock) ON (trl.trl_type2 = lblTrlType2.abbr AND lblTrlType2.labeldefinition = ''TrlType2'') 
	LEFT OUTER JOIN labelfile lblTrlType3 with (nolock) ON (trl.trl_type3 = lblTrlType3.abbr AND lblTrlType3.labeldefinition = ''TrlType3'') 
	LEFT OUTER JOIN labelfile lblTrlType4 with (nolock) ON (trl.trl_type4 = lblTrlType4.abbr AND lblTrlType4.labeldefinition = ''TrlType4'') 
	LEFT OUTER JOIN labelfile lblCompany with (nolock) ON (trl.trl_company = lblCompany.abbr AND lblCompany.labeldefinition = ''Company'') 
	LEFT OUTER JOIN labelfile lblFleet with (nolock) ON (trl.trl_fleet = lblFleet.abbr AND lblFleet.labeldefinition = ''Fleet'') 
	LEFT OUTER JOIN labelfile lblDivision with (nolock) ON (trl.trl_division = lblDivision.abbr AND lblDivision.labeldefinition = ''Division'') 
	LEFT OUTER JOIN labelfile lblTerminal with (nolock) ON (trl.trl_terminal = lblTerminal.abbr AND lblTerminal.labeldefinition = ''Terminal'') 
	INNER JOIN company AS company_a with (nolock) ON trl.trl_avail_cmp_id = company_a.cmp_id 
	INNER JOIN city AS city_a with (nolock) ON trl.trl_avail_city = city_a.cty_code 
	LEFT OUTER JOIN company AS company_pr with (nolock) ON trl.trl_prior_cmp_id = company_pr.cmp_id
	LEFT OUTER JOIN city AS city_pr with (nolock) ON trl.trl_prior_city = city_pr.cty_code
	LEFT OUTER JOIN company AS company_n with (nolock) ON trl.trl_next_cmp_id = company_n.cmp_id
	LEFT OUTER JOIN city AS city_n with (nolock) ON trl.trl_next_city = city_n.cty_code
'

--Initial Where, static and parameter based
SET @sql = @sql + ' WHERE trl.trl_id <> ''UNKNOWN'' 
	AND trl.trl_avail_date >= DATEADD(hour, -@p_hoursback, GETDATE()) 
	AND trl.trl_avail_date <= DATEADD(hour, @p_hoursout, GETDATE())
'
--'	AND (lblTrlStatus.code < @StatusCutoff OR CHARINDEX(lblTrlStatus.abbr, @v_statuscode) > 0)'
SELECT @sql = @sql + '	AND (lblTrlStatus.code < @StatusCutoff ' + dbo.EquateCondition('OR lblTrlStatus.abbr', '', @v_statuscode, '') + ')'

SELECT @sql = @sql + '	AND (@p_city = 0 OR @p_city = city_a.cty_code)
	AND (@p_d_city = 0 OR trl.trl_prior_city = @p_d_city)
	AND (@p_next_city = 0 OR trl.trl_next_city = @p_next_city)
'


SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_status', '', @p_trlstatus, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_type1', '', @p_trctype1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_type2', '', @p_trctype2, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_type3', '', @p_trctype3, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_type4', '', @p_trctype4, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_fleet', '', @p_fleet, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_division', '', @p_division, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_company', '', @p_company, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_terminal', '', @p_terminal, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_avail_cmp_id', '', @p_cmp_id, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and city_a.cty_state', '', @p_states, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and city_a.cty_region1', '', @p_region1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and city_a.cty_region2', '', @p_region2, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and city_a.cty_region3', '', @p_region3, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and city_a.cty_region4', '', @p_region4, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and company_a.cmp_othertype1', '', @p_cmp_othertype1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_cmp_id', '', @p_d_cmpids, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_state', '', @p_d_states, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_region1', '', @p_d_reg1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_region2', '', @p_d_reg2, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_region3', '', @p_d_reg3, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_region4', '', @p_d_reg4, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_prior_cmp_othertype1', '', @p_d_cmp_othertype1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and ltrim(rtrim(trl.trl_prior_event))', '', @p_last_event, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and ltrim(rtrim(trl.trl_next_event))', '', @p_next_event, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_cmp_id', '', @p_next_cmp_id, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_state', '', @p_next_state, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_region1', '', @p_next_region1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_region2', '', @p_next_region2, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_region3', '', @p_next_region3, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_region4', '', @p_next_region4, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_next_cmp_othertype1', '', @p_next_cmp_othertype1, 'UNK')
SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_equipmenttype', '', @p_trl_equipment_type, 'UNK')


/*
select  'parms',
		@v_neardate , 
		@p_hoursback , 
		@p_hoursout , 
		@StatusCutoff , 
		@p_city , 
		@p_d_city , 
		@p_next_city 

DECLARE @sqlout nvarchar(max)
SET @sqlout = @sql

SELECT LEN(@sqlout)

WHILE	(	LEN(@sqlout) > 0 ) BEGIN
	PRINT left(@sqlout, 1024)
	SELECT @sqlout = SUBSTRING(@sqlout, 1025, LEN(@sqlout))
END
*/


Insert Into @TT
exec sp_executesql @sql, 
@params=N'@v_neardate datetime, @p_hoursback int, @p_hoursout int, @StatusCutoff int, @p_city int, @p_d_city int, @p_next_city int',
@v_neardate = @v_neardate, @p_hoursback = @p_hoursback, @p_hoursout = @p_hoursout, @StatusCutoff = @StatusCutoff, @p_city = @p_city, @p_d_city = @p_d_city, @p_next_city = @p_next_city;


-- DSK 54917
UPDATE	@TT
SET		trl_status = 'PLN'
FROM	assetassignment a
		INNER JOIN @TT tt on	(	a.asgn_id = tt.trl_id
									AND a.asgn_type = 'TRL'
								)
WHERE	tt.trl_status = 'AVL'
		AND a.asgn_status = 'PLN'


/* ***************************WARNING IMPORTANT********************************************

	KLUGIE SCMAATA!!! MULTIPLE UPDATES ARE REQUIRED TO SUPPORT SYBASE  

*******************************************************************************************/
--PTS#27429 ILB 10/26/2005 (modify outer join statements to meet TMW SQL Standards
UPDATE  @TT
SET		trl_status = (SELECT name
						FROM labelfile lbf	
						WHERE lbf.abbr = tt.trl_status and 
                              lbf.labeldefinition = 'TrlStatus')
FROM	@TT tt


INSERT	@temp (trl_id, max_asgn_enddate)  
SELECT	tt.trl_id, MAX(a.asgn_enddate)     
FROM	assetassignment a with (nolock) 
		inner join @TT tt on	(	a.asgn_id = tt.trl_id 
									AND a.asgn_type = 'TRL' 
								)
WHERE a.asgn_status IN ('STD', 'CMP')     
GROUP BY tt.trl_id  
ORDER BY tt.trl_id  
    
UPDATE	@temp 
SET		asgn_number =  a.max_asgn_number   
FROM	(	SELECT	asgn_id, 
					max(a.asgn_number) as max_asgn_number 
			FROM	assetassignment a with (nolock) 
					INNER JOIN @temp tempinner on a.asgn_id = tempinner.trl_id
			WHERE	a.asgn_type = 'TRL' 
					AND a.asgn_status IN ('STD', 'CMP')
					AND a.asgn_enddate = tempinner.max_asgn_enddate
			GROUP BY asgn_id  
		) a 
		INNER JOIN @temp temp on a.asgn_id = temp.trl_id  
         
UPDATE	@temp
SET		--lgh_number = a.lgh_number,     
		--mov_number = a.mov_number,  
		cty_nmstct = c.cty_nmstct  
FROM	assetassignment a with (nolock) 
		INNER JOIN @temp temp on	(	a.asgn_number = temp.asgn_number 
										and a.asgn_id = temp.trl_id
									)
		INNER JOIN [event] e ON a.last_dne_evt_number = e.evt_number    
		INNER JOIN stops s ON e.stp_number = s.stp_number    
		INNER JOIN city c ON s.stp_city = c.cty_code    
   
UPDATE	@temp 
SET		cty_nmstct = 'UNKNOWN' 
WHERE	cty_nmstct = ''  
    
UPDATE	@TT    
SET		trl_actual_location = ISNULL(temp.cty_nmstct,'UNKNOWN')   
FROM	@temp temp 
		INNER JOIN @TT tt on temp.trl_id = tt.trl_id   
---MTC PTS48736 20090821


-- RE - PTS #42565 BEGIN
DECLARE @accessory_count INT

IF len(@p_trl_accessories) > 0
BEGIN
	DECLARE @trlaccessories TABLE  (value VARCHAR(8))

	INSERT @trlaccessories(value) SELECT * FROM CSVStringsToTable_fn(@p_trl_accessories) WHERE value NOT IN ('','%','%%')

	SELECT @accessory_count = count(*) from @trlaccessories

	IF @accessory_count > 0 
	BEGIN
		DELETE	@TT
		 WHERE	trl_id NOT IN
					(SELECT	t.trl_id
					   FROM	@TT t
								inner join trlaccessories ta on t.trl_id = ta.ta_trailer and ta.ta_expire_date >= getdate() and isnull(ta.ta_expire_flag, 'N') <> 'Y' and ta_source = 'TRL'
								inner join @trlaccessories tc on ta.ta_type = tc.value
					GROUP BY t.trl_id
					HAVING COUNT(*) = @accessory_count)
	END
END
-- RE - PTS #42565 END

--vjh 48613 User Defined Fields
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_1' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_1_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_1 = dbo.udf_trl_1_fn(tt1.trl_id, 'D'),	udf_trl_1_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_2' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_2_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_2 = dbo.udf_trl_2_fn(tt1.trl_id, 'D'),	udf_trl_2_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_3' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_3_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_3 = dbo.udf_trl_3_fn(tt1.trl_id, 'D'),	udf_trl_3_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_4' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_4_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_4 = dbo.udf_trl_4_fn(tt1.trl_id, 'D'),	udf_trl_4_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_5' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_5_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_5 = dbo.udf_trl_5_fn(tt1.trl_id, 'D'),	udf_trl_5_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_6' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_6_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_6 = dbo.udf_trl_6_fn(tt1.trl_id, 'D'),	udf_trl_6_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_7' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_7_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_7 = dbo.udf_trl_7_fn(tt1.trl_id, 'D'),	udf_trl_7_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_8' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_8_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_8 = dbo.udf_trl_8_fn(tt1.trl_id, 'D'),	udf_trl_8_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_9' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_9_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_9 = dbo.udf_trl_9_fn(tt1.trl_id, 'D'),	udf_trl_9_t = @udflabel
	FROM	@TT TT1
END
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_10' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	SELECT	@udflabel = dbo.udf_trl_10_fn('', 'L')
	UPDATE	@TT
	SET		udf_trl_10 = dbo.udf_trl_10_fn(tt1.trl_id, 'D'),	udf_trl_10_t = @udflabel
	FROM	@TT TT1
END

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
WHERE gi_name = 'QualListTrailerPlan'

IF @DisplayQualifications = 'Y' BEGIN
	IF @AssetsToInclude = ',,' BEGIN
		SET @AssetsToInclude = ',TRL1,'
	END

	UPDATE @TT
	SET qualification_list_trl = dbo.QualificationsToCSV_fn	(	NULL, 
															NULL, 
															NULL, 
															CASE CHARINDEX(',TRL1,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE tt.trl_id END, 
															NULL, 
															NULL, 
															NULL,
															NULL,
															NULL,
															tt.trl_avail_date, 
															tt.trl_avail_date,
															@IncludeAssetPrefix,
															@IncludeLabelName,
															@Delimiter
														)
	FROM @TT tt
END 
--END PTS 51918 JJF 20110210


SELECT  trl_id,					-- 1
	cmp_id,
	cmp_name,
	cty_nmstct,
	trl_avail_date,
	trl_status,
	trl_type1,
	trl_type2,
	trl_type3,
	trl_type4,					-- 10
	trl_company,
	trl_fleet,
	trl_division,
	trl_terminal,
	cty_state,
	cty_code,
	cpril2,
	cpril22,
	cpril1,
	cpril11,					-- 20
	filtflag,
	trltype1header,
	trltype2header,
	trltype3header,
	trltype4header,
	trl_wash_status,
	trl_last_cmd,
	trl_last_cmd_ord,
	trl_last_cmd_date,
	trl_prior_event,			-- 30
	trl_prior_cmp_id,
	trl_prior_city,
	trl_prior_ctyname, 
	trl_prior_state, 
	trl_prior_region1, 
	trl_prior_region2, 
	trl_prior_region3, 
	trl_prior_region4, 
	trl_prior_cmp_name,
	trl_next_event,				-- 40
	trl_next_cmp_id,
	trl_next_city,
	trl_next_ctyname, 
	trl_next_state, 
	trl_next_region1, 
	trl_next_region2, 
	trl_next_region3, 
	trl_next_region4, 
	trl_next_cmp_name,
	cmp_geoloc,					-- 50
	trl_worksheet_comment1,
	trl_worksheet_comment2,
	trl_gps_desc ,/*PTS 23481 CGK 10/20/2004*/
	trl_actual_location, /*PTS# 27429 ILB 10/26/2005*/
	udf_trl_1,					-- 55
	udf_trl_2,					-- 56
	udf_trl_3,					-- 57
	udf_trl_4,					-- 58
	udf_trl_5,					-- 59
	udf_trl_6,					-- 60
	udf_trl_7,					-- 61
	udf_trl_8,					-- 62
	udf_trl_9,					-- 63
	udf_trl_10,					-- 64
	udf_trl_1_t,				-- 65
	udf_trl_2_t,				-- 66
	udf_trl_3_t,				-- 67
	udf_trl_4_t,				-- 68
	udf_trl_5_t,				-- 69
	udf_trl_6_t,				-- 70
	udf_trl_7_t,				-- 71
	udf_trl_8_t,				-- 72
	udf_trl_9_t,				-- 73
	udf_trl_10_t,				-- 74
	trl_equipmenttype,
	--PTS 51918 JJF 20110209
	qualification_list_trl
	--END PTS 51918 JJF 20110209
FROM    @TT

/*
--PTS70753 --REMOVE
ORDER BY 
trl_id,					-- 1
	cmp_id,
	cmp_name,
	cty_nmstct,
	trl_avail_date,
	trl_status,
	trl_type1,
	trl_type2,
	trl_type3,
	trl_type4

*/

--CREATE	PROCEDURE inbound_view_trl
--	@p_trctype1       varchar(254),
--	@p_trctype2       varchar(254),
--	@p_trctype3       varchar(254), 
--	@p_trctype4       varchar(254),
--	@p_fleet          varchar(254),
--	@p_division       varchar(254),
--	@p_company        varchar(254),
--	@p_terminal       varchar(254),
--	@p_states         varchar(254),
--	@p_cmp_id         varchar(254),
--	@p_region1        varchar(254),
--	@p_region2        varchar(254),
--	@p_region3        varchar(254),
--	@p_region4        varchar(254),
--	@p_city           int,
--	@p_hoursback      int,
--	@p_hoursout       int,
--	@p_days           int,
--	@p_trlstatus      varchar(254), 
--	@p_last_event varchar(254),
--	@p_d_states varchar (254), 
--	@p_d_cmpids varchar (254), 
--	@p_d_reg1 varchar (254), 
--	@p_d_reg2 varchar (254), 
--	@p_d_reg3 varchar (254), 
--	@p_d_reg4 varchar (254), 
--	@p_d_city int,
--	@p_next_event varchar(254),
--	@p_next_cmp_id varchar(254),
--	@p_next_city int , 
--	@p_next_state varchar(254), 
--	@p_next_region1 varchar(254), 
--	@p_next_region2 varchar(254), 
--	@p_next_region3 varchar(254), 
--	@p_next_region4 varchar(254),
--	@p_trl_accessories varchar(254), 
--	@p_cmp_othertype1 varchar(254), 	-- 02/14/2008 MDH PTS 39077: Added
--	@p_d_cmp_othertype1 varchar(254), 	-- 02/14/2008 MDH PTS 39077: Added
--	@p_next_cmp_othertype1 varchar(254),	-- 02/14/2008 MDH PTS 39077: Added
--	@p_trl_equipment_type	varchar(254)
--AS

--DECLARE @v_int			smallint,
--	@v_neardate			datetime,
--	@v_char6			char(6),
--	@v_varchar20		varchar(20),
--	@v_ls_whats_left	varchar(255),
--	@v_li_pos			int,
--	@v_li_count			int,
--	@v_ls_value			varchar(255),
--	@v_trl_planmode   	char(1),
--	@v_statuscode     	varchar(254),
--	@v_varchar30      	varchar(30),
--	@v_MinTrl         	varchar(13),
--	@v_trl_actual_loc 	varchar(30),
--	@v_mov            	int,
--	@v_mfh_sequence   	int,
--	@v_stp_number     	int,
--	@v_city           	int,
--	@v_count          	int,
--	@v_asgn_number		int,
--	@v_lgh_number		int,
--	@udflabel			varchar(255),
--	@StatusCutoff	INTEGER -- dsk 54917

----PTS 40155 JJF 20071128
--declare @rowsecurity char(1)
--declare @tmwuser varchar(255)
----END PTS 40155 JJF 20071128

---- KM PTS 13769, read generalinfo to determine what to put in the status and location fields
--SELECT 	@v_trl_planmode = gi_string1
--	FROM	generalinfo
--	WHERE	gi_name = 'ENHANCEDTRAILERPLANNING'

--If Upper(left(@v_trl_planmode,1)) = 'Y'
--	SELECT 	@v_statuscode = ',' + gi_string1 + ','
--		FROM	generalinfo
--		WHERE	gi_name = 'ENHANCEDTRAILERPLNstatus'
--SELECT @v_STATUSCODE = Isnull(@v_Statuscode, '')

---- dsk 54917
--SELECT @StatusCutoff = gi_integer1
--	FROM	generalinfo
--	WHERE	gi_name = 'IBViewStatusCutoff'
--SELECT @StatusCutoff = ISNULL(@StatusCutoff, 200)

--CREATE TABLE #TT (
--	trl_id				varchar(13)		null,
--	cmp_id				varchar(8),
--	cmp_name			varchar(100)	null,
--	cty_nmstct			varchar(25)		null,
--	trl_avail_date		datetime		null,
--	trl_status 			varchar(20)		null,
--	trl_type1 			varchar(20)		null,    
--	trl_type2 			varchar(20)		null, 
--	trl_type3 			varchar(20)		null, 
--	trl_type4 			varchar(20)		null,    
--	trl_company 		varchar(20)		null, 
--	trl_fleet 			varchar(20)		null, 
--	trl_division 		varchar(20)		null,
--	trl_terminal 		varchar(20)		null,
--	cty_state			varchar(6)		null,
--	cty_code			int				null,
--	cpril2				int				null,
--	cpril22				int				null,
--	cpril1				int				null,
--	cpril11				int				null,
--	filtflag			varchar(1)		null,
--	trltype1header		varchar(20)		null,
--	trltype2header		varchar(20)		null,
--	trltype3header		varchar(20)		null,
--	trltype4header		varchar(20)		null,
--	trl_wash_status		char(1)			null,
--	trl_last_cmd		varchar(8)		null,
--	trl_last_cmd_ord	varchar(12)		null,
--	trl_last_cmd_date	datetime		null,
--	trl_prior_event		char(6)			null,
--	trl_prior_cmp_id	varchar(8)		null,
--	trl_prior_city		int				null,
--	trl_prior_ctyname	varchar(25)		null, 
--	trl_prior_state		varchar(6)		null, 
--	trl_prior_region1	varchar(6)		null, 
--	trl_prior_region2	varchar(6)		null, 
--	trl_prior_region3	varchar(6)		null, 
--	trl_prior_region4	varchar(6)		null,
--	trl_prior_cmp_name	varchar(100)	null,
--	trl_next_event		char(6)			null,
--	trl_next_cmp_id		varchar(8)		null,
--	trl_next_city		int				null,
--	trl_next_ctyname	varchar(25)		null, 
--	trl_next_state		varchar(6)		null, 
--	trl_next_region1	varchar(6)		null, 
--	trl_next_region2	varchar(6)		null, 
--	trl_next_region3	varchar(6)		null, 
--	trl_next_region4	varchar(6)		null, 
--	trl_next_cmp_name	varchar(100)	null,
--	cmp_geoloc			varchar(50)		null,
--	trl_worksheet_comment1 varchar(60)	null,
--	trl_worksheet_comment2 varchar(60)	null,
--	trl_gps_desc		varchar (45)	null, /*PTS 23481 CGK 10/20/2004*/
--	trl_actual_location	varchar(30)		null, /* PTS# 27429 ILB 10/26/2005 */
--	udf_trl_1			varchar(255)	null,   -- vjh 48613
--	udf_trl_2			varchar(255)	null,
--	udf_trl_3			varchar(255)	null,
--	udf_trl_4			varchar(255)	null,
--	udf_trl_5			varchar(255)	null,
--	udf_trl_6			varchar(255)	null,
--	udf_trl_7			varchar(255)	null,
--	udf_trl_8			varchar(255)	null,
--	udf_trl_9			varchar(255)	null,
--	udf_trl_10			varchar(255)	null,
--	udf_trl_1_t			varchar(255)	null,
--	udf_trl_2_t			varchar(255)	null,
--	udf_trl_3_t			varchar(255)	null,
--	udf_trl_4_t			varchar(255)	null,
--	udf_trl_5_t			varchar(255)	null,
--	udf_trl_6_t			varchar(255)	null,
--	udf_trl_7_t			varchar(255)	null,
--	udf_trl_8_t			varchar(255)	null,
--	udf_trl_9_t			varchar(255)	null,
--	udf_trl_10_t		varchar(255)	null,
--	trl_equipmenttype	varchar(10)		null,
--	trl_rowsec_rsrv_id	integer			null,
--	--PTS 51918 20110209
--	qualification_list_trl	varchar(255)	null
--	--END PTS 51918 20110209
--	)


-----MTC PTS48736 20090821
--create unique clustered index ix_trlid on #TT(trl_id)  
    
--create table #temp (trl_id varchar(13),   
--max_asgn_enddate datetime, asgn_number int, cty_nmstct varchar(25))   
  
--create unique clustered index ix_trlid2 on #temp(trl_id)
-----MTC PTS48736 20090821

----vmj1+	create temp table to store parm list for @terminal..
--create table #terminal
--	(trl_terminal	varchar(6)	null)


----Parse @terminal into a temptable possibly containing multiple values.  This will allow an index read on
----legheader_active, where the older charindex function prevented that.  This assumes, as the older code did, 
----that the list is comma-delimited..
--select @v_ls_whats_left = isnull(ltrim(rtrim(@p_terminal)), '')
--select @v_li_pos = charindex(',', @v_ls_whats_left)

----DM_2002_05_05 -Start change
--Set @v_char6 =''
----DM_2002_05_05 -END change



--while @v_li_pos > 0
--begin
--	select @v_ls_value = isnull(ltrim(rtrim(substring(@v_ls_whats_left, 1, @v_li_pos - 1))), '')
--	if @v_ls_value <> ''
--		and @v_ls_value <> 'UNK'
--	begin
--		insert into #terminal
--				(trl_terminal)
--		  values (@v_ls_value)
--	end

--	--Find the next comma..
--	select @v_ls_whats_left = isnull(ltrim(rtrim(substring(@v_ls_whats_left, @v_li_pos + 1, 255))), '')
--	select @v_li_pos = charindex(',', @v_ls_whats_left)
--end

----Get the last value..
--if @v_ls_whats_left <> ''
--	insert into #terminal
--			(trl_terminal)
--	  values (@v_ls_whats_left)
----vmj1-


--SELECT  @v_neardate = DateAdd(dy, @p_days, GetDate())

--If @p_hoursback = 0
--	SELECT @p_hoursback = 1000000
--If @p_hoursout = 0
--	SELECT @p_hoursout = 1000000

--IF @p_trlstatus IS NULL OR @p_trlstatus = ''
--   SELECT @p_trlstatus = 'UNK'
--   SELECT @p_trlstatus = ',' + LTRIM(RTRIM(@p_trlstatus)) + ','
--IF @p_trctype1 IS NULL OR @p_trctype1 = ''
--   SELECT @p_trctype1 = 'UNK'
--   SELECT @p_trctype1 = ',' + LTRIM(RTRIM(@p_trctype1)) + ','
--IF @p_trctype2 IS NULL OR @p_trctype2 = ''
--   SELECT @p_trctype2 = 'UNK'
--   SELECT @p_trctype2 = ',' + LTRIM(RTRIM(@p_trctype2)) + ','
--IF @p_trctype3 IS NULL OR @p_trctype3 = ''
--   SELECT @p_trctype3 = 'UNK'
--   SELECT @p_trctype3 = ',' + LTRIM(RTRIM(@p_trctype3)) + ','
--IF @p_trctype4 IS NULL OR @p_trctype4 = ''
--   SELECT @p_trctype4 = 'UNK'
--   SELECT @p_trctype4 = ',' + LTRIM(RTRIM(@p_trctype4)) + ','
--IF @p_fleet IS NULL OR @p_fleet = ''
--   SELECT @p_fleet = 'UNK'
--   SELECT @p_fleet = ',' + LTRIM(RTRIM(@p_fleet)) + ','
--IF @p_division IS NULL OR @p_division = ''
--   SELECT @p_division = 'UNK'
--   SELECT @p_division = ',' + LTRIM(RTRIM(@p_division)) + ','
--IF @p_company IS NULL OR @p_company = ''
--   SELECT @p_company = 'UNK'
--   SELECT @p_company = ',' + LTRIM(RTRIM(@p_company)) + ','
--IF @p_cmp_id IS NULL OR @p_cmp_id = ''
--   SELECT @p_cmp_id = 'UNK'
--   SELECT @p_cmp_id = ',' + LTRIM(RTRIM(@p_cmp_id)) + ','
--IF @p_city IS NULL
--   SELECT @p_city = 0
--IF @p_states IS NULL OR @p_states = ''
--   SELECT @p_states = 'UNK'
--   SELECT @p_states = ',' + LTRIM(RTRIM(@p_states)) + ','
----LOR
--IF @p_region1 IS NULL OR @p_region1 = ''
--   SELECT @p_region1 = 'UNK'
--   SELECT @p_region1 = ',' + LTRIM(RTRIM(@p_region1)) + ','
--IF @p_region2 IS NULL OR @p_region2 = ''
--   SELECT @p_region2 = 'UNK'
--   SELECT @p_region2 = ',' + LTRIM(RTRIM(@p_region2)) + ','
--IF @p_region3 IS NULL OR @p_region3 = ''
--   SELECT @p_region3 = 'UNK'
--   SELECT @p_region3 = ',' + LTRIM(RTRIM(@p_region3)) + ','
--IF @p_region4 IS NULL OR @p_region4 = ''
--   SELECT @p_region4 = 'UNK'
--   SELECT @p_region4 = ',' + LTRIM(RTRIM(@p_region4)) + ','
--IF @p_d_cmpids IS NULL OR @p_d_cmpids = ''
--   SELECT @p_d_cmpids = 'UNK'
--   SELECT @p_d_cmpids = ',' + LTRIM(RTRIM(@p_d_cmpids)) + ',' 
--IF @p_d_city IS NULL
--   SELECT @p_d_city = 0
--IF @p_d_states IS NULL OR @p_d_states = ''
--   SELECT @p_d_states = 'UNK'
--   SELECT @p_d_states = ',' + LTRIM(RTRIM(@p_d_states)) + ',' 
--IF @p_d_reg1 IS NULL OR @p_d_reg1 = ''
--   SELECT @p_d_reg1 = 'UNK'
--   SELECT @p_d_reg1 = ',' + LTRIM(RTRIM(@p_d_reg1)) + ','
--IF @p_d_reg2 IS NULL OR @p_d_reg2 = ''
--   SELECT @p_d_reg2 = 'UNK'
--   SELECT @p_d_reg2 = ',' + LTRIM(RTRIM(@p_d_reg2)) + ','
--IF @p_d_reg3 IS NULL OR @p_d_reg3 = ''
--   SELECT @p_d_reg3 = 'UNK'
--   SELECT @p_d_reg3 = ',' + LTRIM(RTRIM(@p_d_reg3)) + ','
--IF @p_d_reg4 IS NULL OR @p_d_reg4 = ''
--   SELECT @p_d_reg4 = 'UNK'
--   SELECT @p_d_reg4 = ',' + LTRIM(RTRIM(@p_d_reg4)) + ','
--IF @p_last_event IS NULL OR @p_last_event = ''
--   SELECT @p_last_event = 'UNK'
--   SELECT @p_last_event = ',' + LTRIM(RTRIM(@p_last_event)) + ','
--IF @p_next_event IS NULL OR @p_next_event = ''
--   SELECT @p_next_event = 'UNK'
--   SELECT @p_next_event = ',' + LTRIM(RTRIM(@p_next_event)) + ','
--IF @p_next_cmp_id IS NULL OR @p_next_cmp_id = ''
--   SELECT @p_next_cmp_id = 'UNK'
--   SELECT @p_next_cmp_id = ',' + LTRIM(RTRIM(@p_next_cmp_id)) + ',' 
--IF @p_next_city IS NULL
--   SELECT @p_next_city = 0
--IF @p_next_state IS NULL OR @p_next_state = ''
--   SELECT @p_next_state = 'UNK'
--   SELECT @p_next_state = ',' + LTRIM(RTRIM(@p_next_state)) + ','
--IF @p_next_region1 IS NULL OR @p_next_region1 = ''
--   SELECT @p_next_region1 = 'UNK'
--   SELECT @p_next_region1 = ',' + LTRIM(RTRIM(@p_next_region1)) + ','
--IF @p_next_region2 IS NULL OR @p_next_region2 = ''
--   SELECT @p_next_region2 = 'UNK'
--   SELECT @p_next_region2 = ',' + LTRIM(RTRIM(@p_next_region2)) + ','
--IF @p_next_region3 IS NULL OR @p_next_region3 = ''
--   SELECT @p_next_region3 = 'UNK'
--   SELECT @p_next_region3 = ',' + LTRIM(RTRIM(@p_next_region3)) + ','
--IF @p_next_region4 IS NULL OR @p_next_region4 = ''
--   SELECT @p_next_region4 = 'UNK'
--   SELECT @p_next_region4 = ',' + LTRIM(RTRIM(@p_next_region4)) + ','
---- RE - PTS #42565 BEGIN
----IF @p_trl_accessories IS NULL OR @p_trl_accessories = ''
----   SELECT @p_trl_accessories = 'UNK'
----   SELECT @p_trl_accessories = ',' + LTRIM(RTRIM(@p_trl_accessories)) + ','
---- RE - PTS #42565 END
---- 02/14/2008 MDH PTS 39077: Added to make sure cmp_othertype1 fields are populated. <<BEGIN>>
--IF @p_cmp_othertype1 IS NULL OR @p_cmp_othertype1 = ''
--	SELECT @p_cmp_othertype1 = 'UNK'
--SELECT @p_cmp_othertype1 = ',' + LTRIM(RTRIM(@p_cmp_othertype1)) + ','
--IF @p_d_cmp_othertype1 IS NULL OR @p_d_cmp_othertype1 = ''
--	SELECT @p_d_cmp_othertype1 = 'UNK'
--SELECT @p_d_cmp_othertype1 = ',' + LTRIM(RTRIM(@p_d_cmp_othertype1)) + ','
--IF @p_next_cmp_othertype1 IS NULL OR @p_next_cmp_othertype1 = ''
--	SELECT @p_next_cmp_othertype1 = 'UNK'
--SELECT @p_next_cmp_othertype1 = ',' + LTRIM(RTRIM(@p_next_cmp_othertype1)) + ','
---- 02/14/2008 MDH PTS 39077: <<END>>
--IF @p_trl_equipment_type IS NULL OR @p_trl_equipment_type = ''
--	SELECT @p_trl_equipment_type = 'UNK'
--SELECT @p_trl_equipment_type = ',' + LTRIM(RTRIM(@p_trl_equipment_type)) + ','

----vmj1+	If any values were passed in on the @terminal parm, use a faster select..
--select 	@v_li_count = count(*)
--  from	#terminal

--if @v_li_count > 0
--begin
--	--vmj2	DEVELOPERS:  IF YOU CHANGE THIS SELECT, YOU MUST CHANGE THE SELECT ON THE LOWER HALF OF THE IF CONDITION!!
	
--INSERT INTO    #TT
--	SELECT  trailerprofile.trl_id,
--		company_a.cmp_id,
--		company_a.cmp_name,
--		city_a.cty_nmstct,
--		trailerprofile.trl_avail_date,
--		trailerprofile.trl_status + @v_char6 trl_status,
--		trailerprofile.trl_type1 + @v_char6 trl_type1,    
--		trailerprofile.trl_type2 + @v_char6 trl_type2, 
--		trailerprofile.trl_type3 + @v_char6 trl_type3, 
--		trailerprofile.trl_type4 + @v_char6 trl_type4,    
--		trailerprofile.trl_company + @v_char6 trl_company, 
--		trailerprofile.trl_fleet + @v_char6 trl_fleet, 
--		trailerprofile.trl_division + @v_char6 trl_division,
--		trailerprofile.trl_terminal + @v_char6 trl_terminal,
--		city_a.cty_state,
--		city_a.cty_code,
--		CASE WHEN trl_exp2_date <= Getdate() THEN 1
--			ELSE 0
--			END cpril2,
--		CASE WHEN  trl_exp2_date <= @v_neardate THEN 1
--			ELSE 0
--			END cpril22,
--		CASE WHEN trl_exp1_date <= Getdate() THEN 1
--			ELSE 0
--			END cpril1,
--		CASE WHEN trl_exp1_date <= @v_neardate THEN 1
--			ELSE 0
--			END cpril11,
--		'F' filtflag,
--		@v_varchar20 trltype1header,
--		@v_varchar20 trltype2header,
--		@v_varchar20 trltype3header,
--		@v_varchar20 trltype4header,
--		trailerprofile.trl_wash_status,
--		trl_last_cmd,
--		trl_last_cmd_ord,
--		trl_last_cmd_date,
--		trl_prior_event,
--		trl_prior_cmp_id,
--		trl_prior_city,
--		city_pr.cty_nmstct trl_prior_ctyname, 
--		company_pr.cmp_state trl_prior_state, 
--		trl_prior_region1, 
--		trl_prior_region2, 
--		trl_prior_region3, 
--		trl_prior_region4, 
--		company_pr.cmp_name trl_prior_cmp_name,
--		trl_next_event,
--		trl_next_cmp_id,
--		trl_next_city,
--		city_n.cty_nmstct trl_next_ctyname, 
--		company_n.cmp_state trl_next_state, 
--		trl_next_region1, 
--		trl_next_region2, 
--		trl_next_region3, 
--		trl_next_region4, 
--		company_n.cmp_name trl_next_cmp_name,
--		IsNUll(company_a.cmp_geoloc,'') cmp_geoloc,
--		trl_worksheet_comment1,
--		trl_worksheet_comment2,
--		trailerprofile.trl_gps_desc, /*PTS 23481 CGK 10/20/2004*/
--		'' trl_actual_location,		 /*PTS# 27429 ILB 10/26/2005*/
--		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,		-- vjh 48613
--		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,trl_equipmenttype,
--		trailerprofile.rowsec_rsrv_id,
--		--PTS 51918 JJF 20110209
--		NULL
--		--END PTS 51918 JJF 20110209
--           FROM #terminal AS tr JOIN trailerprofile 
--                                JOIN labelfile ON trailerprofile.trl_status = labelfile.abbr 
--                                JOIN company AS company_a ON trailerprofile.trl_avail_cmp_id = company_a.cmp_id 
--                                JOIN city AS city_a ON trailerprofile.trl_avail_city = city_a.cty_code 
--                     LEFT OUTER JOIN company AS company_pr ON trailerprofile.trl_prior_cmp_id = company_pr.cmp_id --(index=pk_id)
--                     LEFT OUTER JOIN city AS city_pr ON trailerprofile.trl_prior_city = city_pr.cty_code --(index=pk_code)
--                     LEFT OUTER JOIN company AS company_n ON trailerprofile.trl_next_cmp_id = company_n.cmp_id --(index=pk_id)
--                     LEFT OUTER JOIN city AS city_n ON trailerprofile.trl_next_city = city_n.cty_code --(index=pk_code)
--                ON trailerprofile.trl_terminal = tr.trl_terminal
--	  WHERE trailerprofile.trl_id <> 'UNKNOWN' AND 
--                labelfile.labeldefinition = 'TrlStatus' AND 
--				-- dsk 54917
--                --(labelfile.code < 200 OR CHARINDEX(labelfile.abbr, @v_statuscode) > 0) AND 
--                (labelfile.code < @StatusCutoff OR CHARINDEX(labelfile.abbr, @v_statuscode) > 0) AND 
--		trailerprofile.trl_avail_date >= DATEADD(hour, -@p_hoursback, GETDATE()) AND 
--		trailerprofile.trl_avail_date <= DATEADD(hour, @p_hoursout, GETDATE()) AND 
--		(@p_trlstatus = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_status + ',', @p_trlstatus) > 0) AND 
--		(@p_trctype1 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type1 + ',', @p_trctype1) > 0) AND 
--		(@p_trctype2 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type2 + ',', @p_trctype2) > 0) AND 
--		(@p_trctype3 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type3 + ',', @p_trctype3) > 0) AND 
--		(@p_trctype4 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type4 + ',', @p_trctype4) > 0) AND 
--		(@p_fleet = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_fleet + ',', @p_fleet) > 0) AND 
--		(@p_division = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_division + ',', @p_division) > 0) AND 
--		(@p_company = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_company +',', @p_company) > 0) AND 
--		(@p_cmp_id = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_avail_cmp_id + ',', @p_cmp_id) > 0) AND 
--		(@p_city = 0 OR @p_city = city_a.cty_code) AND 
--		(@p_states = ',UNK,' OR CHARINDEX(',' + city_a.cty_state + ',', @p_states) > 0) AND 
--		(@p_region1 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region1 + ',', @p_region1) > 0) AND 
--		(@p_region2 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region2 + ',', @p_region2) > 0) AND 
--		(@p_region3 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region3 + ',', @p_region3) > 0) AND 
--		(@p_region4 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region4 + ',', @p_region4) > 0) AND 
--		(@p_cmp_othertype1 = ',UNK,' OR CHARINDEX (',' + company_a.cmp_othertype1 + ',', @p_cmp_othertype1) > 0) AND /* 02/14/2008 MDH PTS 39077: Added */
--		(@p_d_cmpids = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_cmp_id + ',', @p_d_cmpids) > 0) AND 
--		(@p_d_city = 0 OR trailerprofile.trl_prior_city = @p_d_city) AND 
--		(@p_d_states = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_state + ',', @p_d_states) > 0) AND 
--		(@p_d_reg1 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region1 + ',', @p_d_reg1) > 0) AND 
--		(@p_d_reg2 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region2 + ',', @p_d_reg2) > 0) AND 
--		(@p_d_reg3 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region3 + ',', @p_d_reg3) > 0) AND 
--		(@p_d_reg4 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region4 + ',', @p_d_reg4) > 0) AND 
--		(@p_d_cmp_othertype1 = ',UNK,' OR CHARINDEX (',' + trailerprofile.trl_prior_cmp_othertype1 + ',', @p_d_cmp_othertype1) > 0) AND /* 02/25/2008 MDH PTS 39077: Added */
---- PTS 34672 -- BL (start)
----		(@p_last_event = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_event + ',', @p_last_event) > 0) AND 
----		(@p_next_event = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_event + ',', @p_next_event) > 0) AND 
--		(@p_last_event = ',UNK,' OR CHARINDEX(',' + rtrim(ltrim(trailerprofile.trl_prior_event)) + ',', @p_last_event) > 0) AND 
--		(@p_next_event = ',UNK,' OR CHARINDEX(',' + rtrim(ltrim(trailerprofile.trl_next_event)) + ',', @p_next_event) > 0) AND 
---- PTS 34672 -- BL (end)
--		(@p_next_cmp_id = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_cmp_id + ',', @p_next_cmp_id) > 0) AND 
--		(@p_next_city = 0 OR trailerprofile.trl_next_city = @p_next_city) AND 
--		(@p_next_state = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_state + ',', @p_next_state) > 0) AND 
--		(@p_next_region1 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region1 + ',', @p_next_region1) > 0) AND 
--		(@p_next_region2 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region2 + ',', @p_next_region2) > 0) AND 
--		(@p_next_region3 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region3 + ',', @p_next_region3) > 0) AND 
--		(@p_next_region4 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region4 + ',', @p_next_region4) > 0) AND 
--		(@p_next_cmp_othertype1 = ',UNK,' OR CHARINDEX (',' + trailerprofile.trl_next_cmp_othertype1 + ',', @p_next_cmp_othertype1) > 0) AND
--		(@p_trl_equipment_type = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_equipmenttype + ',', @p_trl_equipment_type) > 0) --JLB PTS 49323
--		-- RE - PTS #42565
--		--(@p_trl_accessories = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_accessorylist + ',', @p_trl_accessories) > 0) 
-----MTC PTS48736 20090821		
--		order by trailerprofile.trl_id
-----MTC PTS48736 20090821
--end
--else
--begin
--	--vmj1-
--	--vmj2	DEVELOPERS:  IF YOU CHANGE THIS SELECT, YOU MUST CHANGE THE SELECT ON THE UPPER HALF OF THE IF CONDITION!!
--	INSERT INTO    #TT
--	SELECT  trailerprofile.trl_id,
--		company_a.cmp_id,
--		company_a.cmp_name,
--		city_a.cty_nmstct,
--		trailerprofile.trl_avail_date,
--		trailerprofile.trl_status + @v_char6 trl_status,
--		trailerprofile.trl_type1 + @v_char6 trl_type1,    
--		trailerprofile.trl_type2 + @v_char6 trl_type2, 
--		trailerprofile.trl_type3 + @v_char6 trl_type3, 
--		trailerprofile.trl_type4 + @v_char6 trl_type4,    
--		trailerprofile.trl_company + @v_char6 trl_company, 
--		trailerprofile.trl_fleet + @v_char6 trl_fleet, 
--		trailerprofile.trl_division + @v_char6 trl_division,
--		trailerprofile.trl_terminal + @v_char6 trl_terminal,
--		city_a.cty_state,
--		city_a.cty_code,
--		CASE WHEN trl_exp2_date <= Getdate() THEN 1
--			ELSE 0
--			END cpril2,
--		CASE WHEN  trl_exp2_date <= @v_neardate THEN 1
--			ELSE 0
--			END cpril22,
--		CASE WHEN trl_exp1_date <= Getdate() THEN 1
--			ELSE 0
--			END cpril1,
--		CASE WHEN trl_exp1_date <= @v_neardate THEN 1
--			ELSE 0
--			END cpril11,
--		'F' filtflag,
--		@v_varchar20 trltype1header,
--		@v_varchar20 trltype2header,
--		@v_varchar20 trltype3header,
--		@v_varchar20 trltype4header,
--		trailerprofile.trl_wash_status,
--		trl_last_cmd,
--		trl_last_cmd_ord,
--		trl_last_cmd_date,
--		trl_prior_event,
--		trl_prior_cmp_id,
--		trl_prior_city,
--		city_pr.cty_nmstct trl_prior_ctyname, 
--		company_pr.cmp_state trl_prior_state, 
--		trl_prior_region1, 
--		trl_prior_region2, 
--		trl_prior_region3, 
--		trl_prior_region4, 
--		company_pr.cmp_name trl_prior_cmp_name,
--		trl_next_event,
--		trl_next_cmp_id,
--		trl_next_city,
--		city_n.cty_nmstct trl_next_ctyname, 
--		company_n.cmp_state trl_next_state, 
--		trl_next_region1, 
--		trl_next_region2, 
--		trl_next_region3, 
--		trl_next_region4, 
--		company_n.cmp_name trl_next_cmp_name,
--		IsNull(company_a.cmp_geoloc,'') cmp_geoloc,
--		trl_worksheet_comment1,
--		trl_worksheet_comment2,
--		trailerprofile.trl_gps_desc  ,/*PTS 23481 CGK 10/20/2004*/
--		'' trl_actual_location,		 /*PTS# 27429 ILB 10/26/2005*/
--		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,		--vjh 48613
--		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,trl_equipmenttype,
--		trailerprofile.rowsec_rsrv_id,
--		--PTS 51918 JJF 20110209
--		NULL
--		--END PTS 51918 JJF 20110209
--           FROM trailerprofile JOIN labelfile ON trailerprofile.trl_status = labelfile.abbr 
--                               JOIN company AS company_a ON trailerprofile.trl_avail_cmp_id = company_a.cmp_id 
--                               JOIN city AS city_a ON trailerprofile.trl_avail_city = city_a.cty_code 
--                    LEFT OUTER JOIN company AS company_pr ON trailerprofile.trl_prior_cmp_id = company_pr.cmp_id --(index=pk_id)
--                    LEFT OUTER JOIN city AS city_pr ON trailerprofile.trl_prior_city = city_pr.cty_code --(index=pk_code)
--                    LEFT OUTER JOIN company AS company_n ON trailerprofile.trl_next_cmp_id = company_n.cmp_id --(index=pk_id)
--                    LEFT OUTER JOIN city AS city_n ON trailerprofile.trl_next_city = city_n.cty_code --(index=pk_code)
--	  WHERE trailerprofile.trl_id <> 'UNKNOWN' AND 
--                labelfile.labeldefinition = 'TrlStatus' AND 
--				-- dsk 54917
--                --(labelfile.code < 200 OR CHARINDEX(labelfile.abbr, @v_statuscode) > 0) AND 
--                (labelfile.code < @StatusCutoff OR CHARINDEX(labelfile.abbr, @v_statuscode) > 0) AND 
--		trailerprofile.trl_avail_date >= DATEADD(hour, -@p_hoursback, GETDATE()) AND 
--		trailerprofile.trl_avail_date <= DATEADD(hour, @p_hoursout, GETDATE()) AND 
--		(@p_trlstatus = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_status + ',', @p_trlstatus) > 0) AND 
--		(@p_trctype1 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type1 + ',', @p_trctype1) > 0) AND 
--		(@p_trctype2 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type2 + ',', @p_trctype2) > 0) AND 
--		(@p_trctype3 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type3 + ',', @p_trctype3) > 0) AND 
--		(@p_trctype4 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_type4 + ',', @p_trctype4) > 0) AND 
--		(@p_fleet = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_fleet + ',', @p_fleet) > 0) AND 
--		(@p_division = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_division + ',', @p_division) > 0) AND 
--		(@p_company = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_company +',', @p_company) > 0) AND 
--		(@p_cmp_id = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_avail_cmp_id + ',', @p_cmp_id) > 0) AND 
--		(@p_city = 0 OR @p_city = city_a.cty_code) AND 
--		(@p_states = ',UNK,' OR CHARINDEX(',' + city_a.cty_state + ',', @p_states) > 0) AND 
--		(@p_region1 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region1 + ',', @p_region1) > 0) AND 
--		(@p_region2 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region2 + ',', @p_region2) > 0) AND 
--		(@p_region3 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region3 + ',', @p_region3) > 0) AND 
--		(@p_region4 = ',UNK,' OR CHARINDEX(',' + city_a.cty_region4 + ',', @p_region4) > 0) AND 
--		(@p_cmp_othertype1 = ',UNK,' OR CHARINDEX (',' + company_a.cmp_othertype1 + ',', @p_cmp_othertype1) > 0) AND /* 02/14/2008 MDH PTS 39077: Added */
--		(@p_d_cmpids = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_cmp_id + ',', @p_d_cmpids) > 0) AND 
--		(@p_d_city = 0 OR trailerprofile.trl_prior_city = @p_d_city) AND 
--		(@p_d_states = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_state + ',', @p_d_states) > 0) AND 
--		(@p_d_reg1 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region1 + ',', @p_d_reg1) > 0) AND 
--		(@p_d_reg2 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region2 + ',', @p_d_reg2) > 0) AND 
--		(@p_d_reg3 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region3 + ',', @p_d_reg3) > 0) AND 
--		(@p_d_reg4 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_region4 + ',', @p_d_reg4) > 0) AND 
--		(@p_d_cmp_othertype1 = ',UNK,' OR CHARINDEX (',' + trailerprofile.trl_prior_cmp_othertype1 + ',', @p_d_cmp_othertype1) > 0) AND /* 02/14/2008 MDH PTS 39077: Added */
---- PTS 34672 -- BL (start)
----		(@p_last_event = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_prior_event + ',', @p_last_event) > 0) AND 
----		(@p_next_event = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_event + ',', @p_next_event) > 0) AND 
--		(@p_last_event = ',UNK,' OR CHARINDEX(',' + ltrim(rtrim(trailerprofile.trl_prior_event)) + ',', @p_last_event) > 0) AND 
--		(@p_next_event = ',UNK,' OR CHARINDEX(',' + ltrim(rtrim(trailerprofile.trl_next_event)) + ',', @p_next_event) > 0) AND 
---- PTS 34672 -- BL (end)
--		(@p_next_cmp_id = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_cmp_id + ',', @p_next_cmp_id) > 0) AND 
--		(@p_next_city = 0 OR trailerprofile.trl_next_city = @p_next_city) AND 
--		(@p_next_state = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_state + ',', @p_next_state) > 0) AND 
--		(@p_next_region1 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region1 + ',', @p_next_region1) > 0) AND 
--		(@p_next_region2 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region2 + ',', @p_next_region2) > 0) AND 
--		(@p_next_region3 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region3 + ',', @p_next_region3) > 0) AND 
--		(@p_next_region4 = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_next_region4 + ',', @p_next_region4) > 0) AND 
--		(@p_next_cmp_othertype1 = ',UNK,' OR CHARINDEX (',' + trailerprofile.trl_next_cmp_othertype1 + ',', @p_next_cmp_othertype1) > 0) AND
--		(@p_trl_equipment_type = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_equipmenttype + ',', @p_trl_equipment_type) > 0) --JLB PTS 49323
--		-- RE - PTS #42565
--		--(@p_trl_accessories = ',UNK,' OR CHARINDEX(',' + trailerprofile.trl_accessorylist + ',', @p_trl_accessories) > 0) 
-----MTC PTS48736 20090821		
--		order by trailerprofile.trl_id
-----MTC PTS48736 20090821
--end
----vmj1-



--SELECT @rowsecurity = gi_string1
--FROM generalinfo 
--WHERE gi_name = 'RowSecurity'

--IF @rowsecurity = 'Y' BEGIN 

--	DELETE	#TT
--	WHERE	NOT EXISTS	(	SELECT	*  
--							FROM	RowRestrictValidAssignments_trailerprofile_fn() rsva 
--							WHERE	#tt.trl_rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
--						)

--END
---- END PTS 51570 JJF 20100510

---- DSK 54917
--UPDATE #tt
--SET trl_status = 'PLN'
--FROM assetassignment a
--WHERE a.asgn_type = 'TRL'
--AND a.asgn_id = #tt.trl_id
--AND #tt.trl_status = 'AVL'
--AND a.asgn_status = 'PLN'


----PTS#27429 ILB 10/26/2005 (modify outer join statements to meet TMW SQL Standards
--UPDATE  #TT
--   SET   trl_status = (SELECT name
--						FROM labelfile lbf	
--						WHERE lbf.abbr = #TT.trl_status and 
--                              lbf.labeldefinition = 'TrlStatus'),
--	trl_type1 =  (SELECT name
--					FROM labelfile lbf
--				   WHERE lbf.abbr = #TT.trl_type1 AND 
--           labeldefinition = 'TrlType1'),
--	trl_type2 =  (SELECT name
--					FROM labelfile lbf			
--					WHERE lbf.abbr = #TT.trl_type2 AND 
--                             labeldefinition = 'TrlType2'),
--	trl_type3 =  (SELECT name
--					FROM labelfile lbf			
--					WHERE lbf.abbr = #TT.trl_type3 AND 
--							labeldefinition = 'TrlType3'),
--	trl_type4 =  (SELECT name
--					FROM labelfile lbf			
--					WHERE lbf.abbr = #TT.trl_type4 AND 
--                             labeldefinition = 'TrlType4'),
--    trl_company =  (SELECT name
--						FROM labelfile lbf			
--						WHERE lbf.abbr = #TT.trl_company AND
--                              labeldefinition = 'Company'),
--	trl_fleet =  (SELECT name
--					FROM labelfile lbf			
--					WHERE lbf.abbr = #TT.trl_fleet AND 
--                             labeldefinition = 'Fleet')

--update #tt
--set	
--	trl_division =  (SELECT name
--			   			FROM labelfile lbf                         
--				  		WHERE lbf.abbr = #TT.trl_division AND 
--                                labeldefinition = 'Division'),

--	trl_terminal =  (SELECT name
--	             		FROM labelfile lbf 			  
--			  			WHERE lbf.abbr = #TT.trl_terminal AND 
--                               labeldefinition = 'Terminal')
----PTS#27429 ILB 10/26/2005 (modify outer join statements to meet TMW SQL Standards

--update #tt
--set	trltype1header = (SELECT MAX ( userlabelname ) 
--						FROM labelfile 
--						WHERE labeldefinition = 'TrlType1'),
--	trltype2header = (SELECT MAX ( userlabelname ) 
--						FROM labelfile 
--						WHERE labeldefinition = 'TrlType2'),
--	trltype3header = (SELECT MAX ( userlabelname ) 
--						FROM labelfile 
--						WHERE labeldefinition = 'TrlType3'),
--	trltype4header = (SELECT MAX ( userlabelname ) 
--						FROM labelfile 
--						WHERE labeldefinition = 'TrlType4')      

--insert #temp (trl_id, max_asgn_enddate)  
--SELECT #TT.trl_id, MAX(a.asgn_enddate)     
--  FROM assetassignment a with (nolock) inner join #TT on a.asgn_id = #TT.trl_id   
-- WHERE a.asgn_type = 'TRL' AND     
--       a.asgn_status IN ('STD', 'CMP')     
--       group by #TT.trl_id  
--       order by #TT.trl_id  
    
--update #temp set   
-- asgn_number =  a.max_asgn_number   
-- FROM (  
--   select asgn_id, max(a.asgn_number) as max_asgn_number from assetassignment a with (nolock) inner join #temp t on a.asgn_id = t.trl_id  
--   WHERE a.asgn_type = 'TRL' AND     
--   a.asgn_status IN ('STD', 'CMP') AND     
--   a.asgn_enddate = t.max_asgn_enddate  
--   group by asgn_id  
--   ) a inner join #temp tt on a.asgn_id = tt.trl_id  
         
--update #temp set  
-- --lgh_number = a.lgh_number,     
-- --mov_number = a.mov_number,  
-- cty_nmstct = c.cty_nmstct  
-- FROM assetassignment a with (nolock) inner join #temp t on a.asgn_number = t.asgn_number and a.asgn_id = t.trl_id  
-- INNER JOIN [event] e ON a.last_dne_evt_number = e.evt_number    
-- INNER JOIN stops s ON e.stp_number = s.stp_number    
-- INNER JOIN city c ON s.stp_city = c.cty_code    
   
--update #temp set cty_nmstct = 'UNKNOWN' where cty_nmstct = ''  
    
         
--UPDATE #TT    
--SET trl_actual_location = ISNULL(t.cty_nmstct,'UNKNOWN')   
--from #temp t inner join #TT on t.trl_id = #TT.trl_id   

---- RE - PTS #42565 BEGIN
--DECLARE @accessory_count INT

--IF len(@p_trl_accessories) > 0
--BEGIN
--	DECLARE @trlaccessories TABLE  (value VARCHAR(8))

--	INSERT @trlaccessories(value) SELECT * FROM CSVStringsToTable_fn(@p_trl_accessories) WHERE value NOT IN ('','%','%%')

--	SELECT @accessory_count = count(*) from @trlaccessories

--	IF @accessory_count > 0 
--	BEGIN
--		DELETE	#TT
--		 WHERE	trl_id NOT IN
--					(SELECT	t.trl_id
--					   FROM	#TT t
--								inner join trlaccessories ta on t.trl_id = ta.ta_trailer and ta.ta_expire_date >= getdate() and isnull(ta.ta_expire_flag, 'N') <> 'Y' and ta_source = 'TRL'
--								inner join @trlaccessories tc on ta.ta_type = tc.value
--					GROUP BY t.trl_id
--					HAVING COUNT(*) = @accessory_count)
--	END
--END
---- RE - PTS #42565 END

----vjh 48613 User Defined Fields
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_1' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_1_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_1 = dbo.udf_trl_1_fn(tt1.trl_id, 'D'),	udf_trl_1_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_2' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_2_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_2 = dbo.udf_trl_2_fn(tt1.trl_id, 'D'),	udf_trl_2_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_3' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_3_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_3 = dbo.udf_trl_3_fn(tt1.trl_id, 'D'),	udf_trl_3_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_4' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_4_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_4 = dbo.udf_trl_4_fn(tt1.trl_id, 'D'),	udf_trl_4_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_5' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_5_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_5 = dbo.udf_trl_5_fn(tt1.trl_id, 'D'),	udf_trl_5_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_6' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_6_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_6 = dbo.udf_trl_6_fn(tt1.trl_id, 'D'),	udf_trl_6_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_7' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_7_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_7 = dbo.udf_trl_7_fn(tt1.trl_id, 'D'),	udf_trl_7_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_8' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_8_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_8 = dbo.udf_trl_8_fn(tt1.trl_id, 'D'),	udf_trl_8_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_9' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_9_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_9 = dbo.udf_trl_9_fn(tt1.trl_id, 'D'),	udf_trl_9_t = @udflabel
--	FROM	#TT TT1
--END
--IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'udf_trl_10' and substring(gi_string1,1,1) = 'Y' ) BEGIN
--	SELECT	@udflabel = dbo.udf_trl_10_fn('', 'L')
--	UPDATE	#TT
--	SET		udf_trl_10 = dbo.udf_trl_10_fn(tt1.trl_id, 'D'),	udf_trl_10_t = @udflabel
--	FROM	#TT TT1
--END

----PTS 51918 JJF 20110210
--DECLARE @AssetsToInclude varchar(60)
--DECLARE @DisplayQualifications varchar(1)
--DECLARE @Delimiter varchar(1)
--DECLARE @IncludeAssetPrefix int
--DECLARE @IncludeLabelName int

--SELECT	@DisplayQualifications = ISNULL(gi_string1, 'N'),
--		@AssetsToInclude = ',' + ISNULL(gi_string2, '') + ',',
--		@Delimiter = ISNULL(gi_string3, '*'),
--		@IncludeAssetPrefix = ISNULL(gi_integer1, 0),
--		@IncludeLabelName = ISNULL(gi_integer2, 0)
--FROM	generalinfo
--WHERE gi_name = 'QualListTrailerPlan'

--IF @DisplayQualifications = 'Y' BEGIN
--	IF @AssetsToInclude = ',,' BEGIN
--		SET @AssetsToInclude = ',TRL1,'
--	END

--	UPDATE #TT
--	SET qualification_list_trl = dbo.QualificationsToCSV_fn	(	NULL, 
--															NULL, 
--															NULL, 
--															CASE CHARINDEX(',TRL1,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE #TT.trl_id END, 
--															NULL, 
--															NULL, 
--															NULL,
--															NULL,
--															NULL,
--															#TT.trl_avail_date, 
--															#TT.trl_avail_date,
--															@IncludeAssetPrefix,
--															@IncludeLabelName,
--															@Delimiter
--														)
--	FROM #TT 
--END 
----END PTS 51918 JJF 20110210


--SELECT  trl_id,					-- 1
--	cmp_id,
--	cmp_name,
--	cty_nmstct,
--	trl_avail_date,
--	trl_status,
--	trl_type1,
--	trl_type2,
--	trl_type3,
--	trl_type4,					-- 10
--	trl_company,
--	trl_fleet,
--	trl_division,
--	trl_terminal,
--	cty_state,
--	cty_code,
--	cpril2,
--	cpril22,
--	cpril1,
--	cpril11,					-- 20
--	filtflag,
--	trltype1header,
--	trltype2header,
--	trltype3header,
--	trltype4header,
--	trl_wash_status,
--	trl_last_cmd,
--	trl_last_cmd_ord,
--	trl_last_cmd_date,
--	trl_prior_event,			-- 30
--	trl_prior_cmp_id,
--	trl_prior_city,
--	trl_prior_ctyname, 
--	trl_prior_state, 
--	trl_prior_region1, 
--	trl_prior_region2, 
--	trl_prior_region3, 
--	trl_prior_region4, 
--	trl_prior_cmp_name,
--	trl_next_event,				-- 40
--	trl_next_cmp_id,
--	trl_next_city,
--	trl_next_ctyname, 
--	trl_next_state, 
--	trl_next_region1, 
--	trl_next_region2, 
--	trl_next_region3, 
--	trl_next_region4, 
--	trl_next_cmp_name,
--	cmp_geoloc,					-- 50
--	trl_worksheet_comment1,
--	trl_worksheet_comment2,
--	trl_gps_desc ,/*PTS 23481 CGK 10/20/2004*/
--	trl_actual_location, /*PTS# 27429 ILB 10/26/2005*/
--	udf_trl_1,					-- 55
--	udf_trl_2,					-- 56
--	udf_trl_3,					-- 57
--	udf_trl_4,					-- 58
--	udf_trl_5,					-- 59
--	udf_trl_6,					-- 60
--	udf_trl_7,					-- 61
--	udf_trl_8,					-- 62
--	udf_trl_9,					-- 63
--	udf_trl_10,					-- 64
--	udf_trl_1_t,				-- 65
--	udf_trl_2_t,				-- 66
--	udf_trl_3_t,				-- 67
--	udf_trl_4_t,				-- 68
--	udf_trl_5_t,				-- 69
--	udf_trl_6_t,				-- 70
--	udf_trl_7_t,				-- 71
--	udf_trl_8_t,				-- 72
--	udf_trl_9_t,				-- 73
--	udf_trl_10_t,				-- 74
--	trl_equipmenttype,
--	--PTS 51918 JJF 20110209
--	qualification_list_trl
--	--END PTS 51918 JJF 20110209
--FROM    #TT

GO
GRANT EXECUTE ON  [dbo].[inbound_view_trl] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* modification log
03/10/2005	KWS		Added carrier id
03/24/2005	KWS		Bring back all trailers from legheader_active for the date range and then add
					the asset combination from tractorprofile that is not in the list
06/05/2005	KWS		Changed day[x] fields to text fields to return more than 255 characters
06/07/2005	KWS		Added driver restrictions and linking to manpowerprofile table
					(not going to do anything with @drv_status at the moment)
07/12/2005	KWS		Added Carriers (two additional insert/select statements for retrieving carrier info)
11/01/05	JJF		PTS 29929 Added carrier handling + cartype restrictions
				@carhandling: 	0 - Include Carriers (prior existing behavior)
						1 - Exclude Carriers
						2 - Carriers ONLY
PTS 31125 JJF 1/3/06 - Trips randomly not appearing in tractor plan view.  
			When you double click on a date for an asset, 
			additional trips will correctly show in the sequence loads dialog.
PTS 31156 JJF 1/19/06 - fixed join problem resulting in duplicate asset combos
PTS 31156 JJF 1/20/06 - made explicit null declarations
PTS 31953 JJF 3/1/06 - Added ability to allow for filter to load requirements on client 
			- Added expirations check
PTS 31946 JJF 3/2/06 - Added ability to allow for filter to load requirements on client + added some diagnostic logic
PTS 32027 JJF 3/7/06 - now excludes UNKNOWN carrier when retrieving carrier list
PTS 33274 JJF 6/12/06 -mfh_number is valid on a per date basis...so must sort initially on date
PTS 57255 MTC 05/31/11 - changed #legheader from a temp table to a table var for performance improvement
*/
CREATE PROCEDURE [dbo].[inbound_view_trcplan] 
	(
	@trctype1 			VARCHAR(254),
	@trctype2 			VARCHAR(254),
	@trctype3 			VARCHAR(254),
	@trctype4 			VARCHAR(254),
	@fleet 				VARCHAR(254),
	@division 			VARCHAR(254),
	@company 			VARCHAR(254),
	@terminal 			VARCHAR(254),
	@tractor 			CHAR(8),
	@days 				INT,
	@status 			VARCHAR(254),
	@states 			VARCHAR(254),
	@cmpids 			VARCHAR(254),
	@city 				INT,
	@reg1 				VARCHAR(254),
	@reg2 				VARCHAR(254),
	@reg3 				VARCHAR(254),
	@reg4 				VARCHAR(254),
	@d_states 			VARCHAR(254),
	@d_cmpids 			VARCHAR(254),
	@d_city 			INT,
	@d_reg1 			VARCHAR(254),
	@d_reg2 			VARCHAR(254),
	@d_reg3 			VARCHAR(254),
	@d_reg4 			VARCHAR(254),
	@startend 			VARCHAR(3),
	@hoursbackdate 		DATETIME,
	@detail 			INT,
	@mpptype1 			VARCHAR(254),
	@mpptype2 			VARCHAR(254),
	@mpptype3 			VARCHAR(254),
	@mpptype4 			VARCHAR(254),
	@teamleader 		VARCHAR(254),
	@domicile 			VARCHAR(254),
	@drv_status 		varchar(254),
	@carhandling		tinyint,
	@cartype1 			VARCHAR(254),
	@cartype2 			VARCHAR(254),
	@cartype3 			VARCHAR(254),
	@cartype4 			VARCHAR(254),
	@cmp_othertype1		VARCHAR(254)	/* 02/25/2008 MDH PTS 39077: Added */
	)
AS
DECLARE @hoursoutdate DATETIME, 
        @trc VARCHAR(10), 
        @drv VARCHAR(8), 
        @trl VARCHAR(13), 
        @trl2 VARCHAR(13), 
        @carrier VARCHAR(8), 
        @date DATETIME, 
        @datetime DATETIME, 
        @buildstring VARCHAR(1000), 
        @hold VARCHAR(1000), 
        @counter INT, 
        @stops INT, 
        @neardate DATETIME, 
        @drvneardate DATETIME, 
        @trcneardate DATETIME, 
        @id INT, 
        @layoutmode INT, 
        @lgh INT, 
        @string VARCHAR(1000),
	--PTS 30270 10/19/2005 - Display 'Dispatched:' for dispatched trips.
	@lgh_outstatus varchar(6),
	@InDispatchedGroup tinyint

--PTS 31953 JJF 3/1/06 
declare @linebuffer varchar(255)
declare @linebuffer_last varchar(255)
declare @DoExpirationCheck int
declare @id_exp int
declare @addcr varchar(1)
declare @exp_assettype varchar(8)
declare @exp_expirationdate datetime
declare @exp_compldate datetime
declare @exp_priority varchar(6)
declare @PrefixMessagesAdded int
--END PTS 31953 JJF 3/1/06 

--PTS 31946 JJF 3/2/06
declare @DoAssignmentConflictCheck int
declare @id_lgh int
declare @drvconflict varchar(8)
declare @trcconflict varchar(8)
declare @trlconflict varchar(13)
declare @drvconflict_last varchar(8)
declare @trcconflict_last varchar(8)
declare @trlconflict_last varchar(13)
declare @ord_number_conflict varchar(12)
declare @addcomma varchar(2)
--END PTS 31946 JJF 3/2/06

--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510

--PTS 31156 JJF 1/20/06 - made explicit null declarations
CREATE TABLE #work_trcplan 
	(id int identity (1, 1) NOT NULL,
	lgh_sequence INT NULL, 
	lgh_tractor VARCHAR(8) NULL, 
	lgh_driver1 VARCHAR(8) NULL, 
	lgh_primary_trailer VARCHAR(13) NULL, 
	lgh_primary_pup VARCHAR(13) NULL, 
	lgh_startdate DATETIME NULL, 
	lgh_enddate DATETIME NULL, 
	lgh_number INT NULL, 
	lgh_outstatus varchar(6) NULL, --PTS 30270 10/19/2005 - Display 'Dispatched:' for dispatched trips.
	lgh_carrier varchar(8) NULL,
	lgh_drvname VARCHAR(45) NULL,
	lgh_drvsenioritydate DATETIME NULL, 
	formatedstring VARCHAR(1000) NULL,
	mfh_number INT NULL,
	--PTS 33274 JJF 6/12/06 -mfh_number is valid on a per date basis...so must sort initially on date
	lgh_startdateonly DATETIME NULL,
	trc_dailyflag char(1) NULL)

CREATE TABLE #trc_plan 
	(id int identity (1, 1) NOT NULL,
	trc_number VARCHAR(10) NOT NULL, 
	drv_id VARCHAR(8) NULL,
	trl_number VARCHAR(13) NULL, 
	trl_number2 VARCHAR(13) NULL,
	car_id VARCHAR(8) NULL,
	drv_name VARCHAR(45) NULL,
	drv_senioritydate DATETIME NULL,
	--PTS 31953 JJF 3/1/06 
	cfiltflag CHAR(1) NULL,
	pri1exp SMALLINT NULL DEFAULT 0,  
	pri2exp SMALLINT NULL DEFAULT 0, 
	--END PTS 31953 JJF 3/1/06 
	day1 varchar (4000) NULL, 
	day1_date DATETIME NULL, 
	day2 varchar (4000) NULL, 
	day2_date DATETIME NULL, 
	day3 varchar (4000) NULL, 
	day3_date DATETIME NULL, 
	day4 varchar (4000) NULL, 
	day4_date DATETIME NULL, 
	day5 varchar (4000) NULL, 
	day5_date DATETIME NULL, 
	day6 varchar (4000) NULL, 
	day6_date DATETIME NULL, 
	day7 varchar (4000) NULL, 
	day7_date DATETIME NULL,
	trc_dailyflag char(1) NULL)
	/* PTS 31953 JJF 3/1/06 - These were never in use...removed 
	trc_exp1_date DATETIME NULL,
	trc_exp2_date DATETIME NULL,
	mpp_exp1_date DATETIME NULL,
	mpp_exp2_date DATETIME NULL,
	trl_exp1_date DATETIME NULL,
	trl_exp2_date DATETIME NULL,
	pri1exp SMALLINT NULL,  
	pri2exp SMALLINT NULL, 
	pri1expsoon SMALLINT NULL,  
	pri2expsoon SMALLINT NULL,  
	drvpri1exp SMALLINT NULL,  
	drvpri2exp SMALLINT NULL,  
	drvpri1expsoon SMALLINT NULL,  
	drvpri2expsoon SMALLINT NULL,  
	trcpri1exp SMALLINT NULL,  
	trcpri2exp SMALLINT NULL,  
	trcpri1expsoon SMALLINT NULL,  
	trcpri2expsoon SMALLINT NULL*/
	-- END PTS 31953 JJF 3/1/06 - These were never in use...removed 

--PTS 41618 JJF/JGUO 20080229
CREATE INDEX dk_#trc_plan_id on #trc_plan(id)
CREATE INDEX dk_#trc_plan_trc_number on #trc_plan(trc_number)
--PTS 41618 JJF/JGUO 20080229

--PTS 31953 JJF 3/1/06
CREATE TABLE #expiration
	(id_exp			int identity (1, 1)	NOT NULL,
	exp_idtype		char(3)			NULL,
	exp_id			varchar(13)		NULL,
	exp_code		varchar(6)		NULL,
	exp_expirationdate	datetime		NULL,
	exp_priority		varchar(6)		NULL,
	exp_compldate		datetime		NULL)
--END PTS 31953 JJF 3/1/06

--PTS 31946 JJF 3/2/06
DECLARE @legheader TABLE
	(id_lgh			int identity (1, 1)	NOT NULL,
	lgh_driver1		varchar(8)		NULL,
	lgh_tractor		varchar(8)		NULL,
	lgh_primary_trailer	varchar(13)		NULL,
	lgh_startdate		datetime		NULL,
	lgh_enddate		datetime		NULL,
	ord_number		varchar(12)		NULL) 
--END PTS 31946 JJF 3/2/06

--PTS 31946 JJF 3/2/06
--PTS 31953 JJF 3/1/06
SELECT 	@layoutmode = CASE gi_string3 WHEN 'ADVANCED' THEN 1 ELSE 0 END,
	@DoExpirationCheck = CASE gi_integer2 WHEN 1 THEN 1 WHEN 2 THEN 2 ELSE 0 END,
	@DoAssignmentConflictCheck = CASE gi_integer3 WHEN 1 THEN 1 ELSE 0 END
  FROM generalinfo 
 WHERE gi_name = 'TractorPlan'
--END PTS 31946 JJF 3/2/06
--END PTS 31953 JJF 3/1/06

-- Get the hoursback and  hoursout into variables
IF @hoursbackdate IS NULL
   SELECT @hoursbackdate = getdate()
SELECT @hoursoutdate = DATEADD(dd, @days, @hoursbackdate)

IF @startend <> 'YES'
   SET @startend = 'NO'
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

SELECT @cmpids = ',' + LTRIM(RTRIM(ISNULL(@cmpids, ''))) + ',' 
SELECT @trctype1 = ',' + LTRIM(RTRIM(ISNULL(@trctype1, ''))) + ',' 
SELECT @trctype2 = ',' + LTRIM(RTRIM(ISNULL(@trctype2, ''))) + ',' 
SELECT @trctype3 = ',' + LTRIM(RTRIM(ISNULL(@trctype3, ''))) + ',' 
SELECT @trctype4 = ',' + LTRIM(RTRIM(ISNULL(@trctype4, ''))) + ',' 
SELECT @fleet = ',' + LTRIM(RTRIM(ISNULL(@fleet, ''))) + ',' 
SELECT @division = ',' + LTRIM(RTRIM(ISNULL(@division, ''))) + ',' 
SELECT @company = ',' + LTRIM(RTRIM(ISNULL(@company, ''))) + ',' 
SELECT @terminal = ',' + LTRIM(RTRIM(ISNULL(@terminal, ''))) + ',' 
SELECT @mpptype1 = ',' + LTRIM(RTRIM(ISNULL(@mpptype1, ''))) + ',' 
SELECT @mpptype2 = ',' + LTRIM(RTRIM(ISNULL(@mpptype2, ''))) + ',' 
SELECT @mpptype3 = ',' + LTRIM(RTRIM(ISNULL(@mpptype3, ''))) + ',' 
SELECT @mpptype4 = ',' + LTRIM(RTRIM(ISNULL(@mpptype4, ''))) + ',' 
SELECT @teamleader = ',' + LTRIM(RTRIM(ISNULL(@teamleader, ''))) + ',' 
SELECT @domicile = ',' + LTRIM(RTRIM(ISNULL(@domicile, ''))) + ',' 
SELECT @drv_status = ',' + LTRIM(RTRIM(ISNULL(@drv_status, ''))) + ',' 
SELECT @reg1 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg1, '') WHEN '' THEN 'UNK' ELSE @reg1 END))  + ','
SELECT @reg2 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg2, '') WHEN '' THEN 'UNK' ELSE @reg2 END))  + ','
SELECT @reg3 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg3, '') WHEN '' THEN 'UNK' ELSE @reg3 END))  + ','
SELECT @reg4 = ',' + LTRIM(RTRIM(CASE ISNULL(@reg4, '') WHEN '' THEN 'UNK' ELSE @reg4 END))  + ','
SELECT @d_reg1 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg1, '') WHEN '' THEN 'UNK' ELSE @d_reg1 END))  + ','
SELECT @d_reg2 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg2, '') WHEN '' THEN 'UNK' ELSE @d_reg2 END))  + ','
SELECT @d_reg3 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg3, '') WHEN '' THEN 'UNK' ELSE @d_reg3 END))  + ','
SELECT @d_reg4 = ',' + LTRIM(RTRIM(CASE ISNULL(@d_reg4, '') WHEN '' THEN 'UNK' ELSE @d_reg4 END))  + ','
SELECT @d_cmpids = ',' + LTRIM(RTRIM(ISNULL(@d_cmpids, ''))) + ',' 

--PTS 29929 11/1/05 JJF
SELECT @cartype1 = ',' + LTRIM(RTRIM(ISNULL(@cartype1, ''))) + ',' 
SELECT @cartype2 = ',' + LTRIM(RTRIM(ISNULL(@cartype2, ''))) + ',' 
SELECT @cartype3 = ',' + LTRIM(RTRIM(ISNULL(@cartype3, ''))) + ',' 
SELECT @cartype4 = ',' + LTRIM(RTRIM(ISNULL(@cartype4, ''))) + ',' 
--END PTS 29929 11/1/05 JJF

/* 02/25/2008 MDH PTS 39077: Added to check new cmp_othertype1 parameters <<BEGIN>> */
SELECT @cmp_othertype1 = ',' + LTRIM(RTRIM(CASE ISNULL(@cmp_othertype1, '') WHEN '' THEN 'UNK' ELSE @cmp_othertype1 END))  + ','
/* 02/25/2008 MDH PTS 39077: <<END>> */

--PTS 29929 11/1/05 JJF - add carhandling condition
--PTS 30270 10/19/2005 - add lgh_outstatus to Display 'Dispatched:' for dispatched trips.
IF @carhandling is null or @carhandling <> 2 BEGIN
	INSERT INTO #work_trcplan (lgh_sequence, lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup, 
				lgh_startdate, lgh_enddate, lgh_number, lgh_outstatus, lgh_carrier, lgh_drvname, lgh_drvsenioritydate, formatedstring, mfh_number, lgh_startdateonly, trc_dailyflag)
	SELECT DISTINCT  
		ISNULL(drvplan_number, 0) drvplan_number, 
		lgh_tractor, 
		lgh_driver1, 
		lgh_primary_trailer, 
		lgh_primary_pup, 
		lgh_startdate, 
		lgh_enddate,
		lgh_number,  
		lgh_outstatus,
		lgh_carrier,
		mpp_lastfirst,
		mpp_senioritydate,
		case when lgh_outstatus <> 'DSP' then
			CONVERT(VARCHAR(1000), 'Order # ' + CONVERT(VARCHAR(12), ord_hdrnumber) +
				' From ' + case when ISNULL(cmp_id_start, '') = 'UNKNOWN' then '' 
				else ISNULL(cmp_id_start, '') end + ' ' + 
				case when lgh_startcity = 0 then '' 
				else ISNULL(startcity.cty_nmstct, '') end + 
				' to '  + case when ISNULL(cmp_id_end, '') = 'UNKNOWN' then '' 
				else ISNULL(cmp_id_end, '') end + ' ' + 
				case when lgh_endcity = 0 then '' 
				else ISNULL(endcity.cty_nmstct, '') end) 
		else
			CONVERT(VARCHAR(1000), ord_hdrnumber) end formatedstring,
		mfh_number,
		--PTS 33274 JJF 6/12/06 -mfh_number is valid on a per date basis...so must sort initially on date
		CONVERT(VARCHAR(10), lgh_startdate, 102) as lgh_startdateonly,
        case when convert(datetime,convert(varchar(2),(datepart(mm,getdate()))) + '/' + convert(varchar(2),(datepart(dd,getdate()))) + '/' + convert(varchar(4),datepart(yyyy,getdate()))) <> trc_dailyflagdate or trc_dailyflagdate is null then 'N' else trc_dailyflag end as trc_dailyflag
	FROM legheader_active legheader
		INNER JOIN tractorprofile ON lgh_tractor = tractorprofile.trc_number
		INNER JOIN manpowerprofile ON lgh_driver1 = manpowerprofile.mpp_id
		LEFT OUTER JOIN city startcity ON lgh_startcity = startcity.cty_code
		LEFT OUTER JOIN city endcity ON lgh_endcity = endcity.cty_code
	WHERE lgh_tractor <> 'UNKNOWN' AND 
		((lgh_startdate BETWEEN @hoursbackdate AND @hoursoutdate) OR
			(lgh_enddate BETWEEN @hoursbackdate AND @hoursoutdate)) AND 
		(@tractor = 'UNKNOWN' OR lgh_tractor = @tractor) AND
		(@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @reg1) > 0) AND
		(@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @reg2) > 0) AND
		(@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @reg3) > 0) AND 
		(@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @reg4) > 0) AND
		(@cmp_othertype1 = ',UNK,' OR 
		  CHARINDEX(',' + isNull ((SELECT cmp_othertype1 
		  							FROM company 
		  							WHERE company.cmp_id = legheader.cmp_id_end), 'UNK') + ',', @cmp_othertype1) > 0) AND      /* 02/25/2008 MDH PTS 39077: Added */
		lgh_instatus <> 'HST' AND 
		lgh_outstatus IN ('PLN', 'DSP', 'STD') AND 
		(@states = '' OR CHARINDEX(lgh_endstate, @states) > 0) AND 
		(@cmpids = ',,' OR CHARINDEX(',' + cmp_id_end + ',', @cmpids) > 0) AND 
		(@trctype1 = ',,' OR CHARINDEX(',' + legheader.trc_type1 + ',', @trctype1) > 0) AND 
		(@trctype2 = ',,' OR CHARINDEX(',' + legheader.trc_type2 + ',', @trctype2) > 0) AND 
		(@trctype3 = ',,' OR CHARINDEX(',' + legheader.trc_type3 + ',', @trctype3) > 0) AND 
		(@trctype4 = ',,' OR CHARINDEX(',' + legheader.trc_type4 + ',', @trctype4) > 0) AND 
		(@fleet = ',,' OR CHARINDEX(',' + legheader.trc_fleet + ',', @fleet) > 0) AND 
		(@division = ',,' OR CHARINDEX(',' + legheader.trc_division + ',', @division) > 0) AND 
		(@company = ',,' OR CHARINDEX(',' + legheader.trc_company + ',', @company) > 0) AND 
		(@terminal = ',,' OR CHARINDEX(',' + legheader.trc_terminal + ',', @terminal) > 0) AND
		(@mpptype1 = ',,' OR CHARINDEX(',' + legheader.mpp_type1 + ',', @mpptype1) > 0) AND 
		(@mpptype2 = ',,' OR CHARINDEX(',' + legheader.mpp_type2 + ',', @mpptype2) > 0) AND 
		(@mpptype3 = ',,' OR CHARINDEX(',' + legheader.mpp_type3 + ',', @mpptype3) > 0) AND 
		(@mpptype4 = ',,' OR CHARINDEX(',' + legheader.mpp_type4 + ',', @mpptype4) > 0) AND 
		(@teamleader = ',,' OR CHARINDEX(',' + legheader.mpp_teamleader + ',', @teamleader) > 0) AND 
		(@domicile = ',,' OR CHARINDEX(',' + legheader.mpp_domicile + ',', @domicile) > 0) AND
		(@drv_status = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_status + ',', @drv_status) > 0)
	--PTS 33274 JJF 6/12/06 -mfh_number is valid on a per date basis...so must sort initially on date
	--ORDER BY mfh_number, drvplan_number, lgh_startdate, lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup 
	ORDER BY lgh_startdateonly, mfh_number, drvplan_number, lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup 
END

--Carrier records added here
--PTS 29929 11/1/05 JJF - add carhandling condition 
--PTS 30270 10/19/2005 - add lgh_outstatus to Display 'Dispatched:' for dispatched trips.
IF @carhandling is null or @carhandling <> 1 BEGIN
	INSERT INTO #work_trcplan (lgh_sequence, lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup, 
				lgh_startdate, lgh_enddate, lgh_number, lgh_outstatus, lgh_carrier, lgh_drvname, lgh_drvsenioritydate, formatedstring, mfh_number, lgh_startdateonly, trc_dailyflag)
	SELECT DISTINCT  
		ISNULL(drvplan_number, 0) drvplan_number, 
		lgh_tractor, 
		lgh_driver1, 
		lgh_primary_trailer, 
		lgh_primary_pup, 
		lgh_startdate, 
		lgh_enddate,
		legheader.lgh_number,
		legheader.lgh_outstatus,
		lgh_carrier,
		--PTS 32061 03/09/06 JJF/BCY
		lgh_drvname = car.car_name,
		'12/31/2049',
		--PTS 32061 03/09/06 JJF/BCY
		case when lgh_outstatus <> 'DSP' then
			CONVERT(VARCHAR(1000), 'Order # ' + CONVERT(VARCHAR(12), ord_hdrnumber) +
				' From ' + case when ISNULL(cmp_id_start, '') = 'UNKNOWN' then '' 
				else ISNULL(cmp_id_start, '') end + ' ' + 
				case when lgh_startcity = 0 then '' 
				else ISNULL(startcity.cty_nmstct, '') end + 
				' to '  + case when ISNULL(cmp_id_end, '') = 'UNKNOWN' then '' 
				else ISNULL(cmp_id_end, '') end + ' ' + 
				case when lgh_endcity = 0 then '' 
				else ISNULL(endcity.cty_nmstct, '') end)
		else
			CONVERT(VARCHAR(1000), ord_hdrnumber) end formatedstring,
		mfh_number,
		--PTS 33274 JJF 6/12/06 -mfh_number is valid on a per date basis...so must sort initially on date
		CONVERT(VARCHAR(10), lgh_startdate, 102) as lgh_startdateonly,
		NULL as trc_dailyflag
	FROM legheader_active legheader
		INNER JOIN assetassignment aa ON lgh_carrier = aa.asgn_id AND 
						aa.asgn_type = 'CAR' AND 
						legheader.mov_number = aa.mov_number
		LEFT OUTER JOIN city startcity ON lgh_startcity = startcity.cty_code
		LEFT OUTER JOIN city endcity ON lgh_endcity = endcity.cty_code
		LEFT OUTER JOIN carrier car ON lgh_carrier = car.car_id
	WHERE ((lgh_startdate BETWEEN @hoursbackdate AND @hoursoutdate) OR
			(lgh_enddate BETWEEN @hoursbackdate AND @hoursoutdate)) AND 
		(@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @reg1) > 0) AND
		(@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @reg2) > 0) AND
		(@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @reg3) > 0) AND 
		(@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @reg4) > 0) AND
		(@cmp_othertype1 = ',UNK,' OR 
		  CHARINDEX(',' + isNull ((SELECT cmp_othertype1 
		  							FROM company 
		  							WHERE company.cmp_id = legheader.cmp_id_end), 'UNK') + ',', @cmp_othertype1) > 0) AND      /* 02/25/2008 MDH PTS 39077: Added */
		lgh_outstatus IN ('PLN', 'DSP', 'STD') AND 
		(@states = '' OR CHARINDEX(lgh_endstate, @states) > 0) AND 
		(@cmpids = ',,' OR CHARINDEX(',' + cmp_id_end + ',', @cmpids) > 0) AND 
/* 31574 
	* Removing TRC and DRV restrictions for loads with Carriers - BYoung

		(@trctype1 = ',,' OR CHARINDEX(',' + legheader.trc_type1 + ',', @trctype1) > 0) AND 
		(@trctype2 = ',,' OR CHARINDEX(',' + legheader.trc_type2 + ',', @trctype2) > 0) AND 
		(@trctype3 = ',,' OR CHARINDEX(',' + legheader.trc_type3 + ',', @trctype3) > 0) AND 
		(@trctype4 = ',,' OR CHARINDEX(',' + legheader.trc_type4 + ',', @trctype4) > 0) AND 
		(@fleet = ',,' OR CHARINDEX(',' + legheader.trc_fleet + ',', @fleet) > 0) AND 
		(@division = ',,' OR CHARINDEX(',' + legheader.trc_division + ',', @division) > 0) AND 
		(@company = ',,' OR CHARINDEX(',' + legheader.trc_company + ',', @company) > 0) AND 
		(@terminal = ',,' OR CHARINDEX(',' + legheader.trc_terminal + ',', @terminal) > 0) AND
		(@mpptype1 = ',,' OR CHARINDEX(',' + legheader.mpp_type1 + ',', @mpptype1) > 0) AND 
		(@mpptype2 = ',,' OR CHARINDEX(',' + legheader.mpp_type2 + ',', @mpptype2) > 0) AND 
		(@mpptype3 = ',,' OR CHARINDEX(',' + legheader.mpp_type3 + ',', @mpptype3) > 0) AND 
		(@mpptype4 = ',,' OR CHARINDEX(',' + legheader.mpp_type4 + ',', @mpptype4) > 0) AND 
		(@teamleader = ',,' OR CHARINDEX(',' + legheader.mpp_teamleader + ',', @teamleader) > 0) AND 
		(@domicile = ',,' OR CHARINDEX(',' + legheader.mpp_domicile + ',', @domicile) > 0) AND
*/
		(@cartype1 = ',,' OR CHARINDEX(',' + car.car_type1 + ',', @cartype1) > 0) AND 
		(@cartype2 = ',,' OR CHARINDEX(',' + car.car_type2 + ',', @cartype2) > 0) AND 
		(@cartype3 = ',,' OR CHARINDEX(',' + car.car_type3 + ',', @cartype3) > 0) AND 
		(@cartype4 = ',,' OR CHARINDEX(',' + car.car_type4 + ',', @cartype4) > 0) 
	--PTS 33274 JJF 6/12/06 -mfh_number is valid on a per date basis...so must sort initially on date
	--ORDER BY mfh_number, drvplan_number, lgh_startdate, lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup 
	ORDER BY lgh_startdateonly, mfh_number, drvplan_number, lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup 

END
/* StringBuilder is not functioning yet
IF @layoutmode = 1
BEGIN
	SELECT	@lgh = MIN(id) 
	FROM	#work_trcplan
	WHILE	@lgh > 0
	BEGIN
		SET	@string = NULL
		EXEC inbound_view_trcplan_stringbuild @lgh, @detail, @string OUTPUT
             
		UPDATE	#work_trcplan 
		SET		formatedstring = @string 
		WHERE	id = @lgh
             
		SELECT	@lgh = MIN(id) 
		FROM	#work_trcplan 
		WHERE	id > @lgh
	END
END
*/

INSERT INTO #trc_plan (trc_number, drv_id, trl_number, trl_number2, car_id, drv_name, drv_senioritydate, trc_dailyflag)
	SELECT DISTINCT lgh_tractor, lgh_driver1, lgh_primary_trailer, lgh_primary_pup, lgh_carrier, lgh_drvname, lgh_drvsenioritydate, trc_dailyflag
	FROM #work_trcplan

--PTS 29929 11/1/05 JJF - add carhandling condition
IF @carhandling is null or @carhandling <> 2 BEGIN
	INSERT INTO #trc_plan (trc_number, drv_id, trl_number, trl_number2, car_id, drv_name, drv_senioritydate, trc_dailyflag)
		SELECT	trc_number, mpp_id, ISNULL(trc_trailer1, 'UNKNOWN'), ISNULL(trc_trailer2, 'UNKNOWN'), 'UNKNOWN', mpp_lastfirst, mpp_senioritydate, case when convert(datetime,convert(varchar(2),(datepart(mm,getdate()))) + '/' + convert(varchar(2),(datepart(dd,getdate()))) + '/' + convert(varchar(4),datepart(yyyy,getdate()))) <> trc_dailyflagdate or trc_dailyflagdate is null then 'N' else trc_dailyflag end
		FROM	tractorprofile
		INNER JOIN manpowerprofile ON trc_number = mpp_tractornumber
		WHERE	(@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) AND 
				(@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) AND 
				(@trctype3 = ',,' OR CHARINDEX(',' + trc_type3 + ',', @trctype3) > 0) AND 
				(@trctype4 = ',,' OR CHARINDEX(',' + trc_type4 + ',', @trctype4) > 0) AND 
				(@fleet = ',,' OR CHARINDEX(',' + trc_fleet + ',', @fleet) > 0) AND 
				(@division = ',,' OR CHARINDEX(',' + trc_division + ',', @division) > 0) AND 
				(@company = ',,' OR CHARINDEX(',' + trc_company + ',', @company) > 0) AND 
				(@terminal = ',,' OR CHARINDEX(',' + trc_terminal + ',', @terminal) > 0) AND
				(trc_number <> 'UNKNOWN') AND
				(@mpptype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @mpptype1) > 0) AND 
				(@mpptype2 = ',,' OR CHARINDEX(',' + mpp_type2 + ',', @mpptype2) > 0) AND 
				(@mpptype3 = ',,' OR CHARINDEX(',' + mpp_type3 + ',', @mpptype3) > 0) AND 
				(@mpptype4 = ',,' OR CHARINDEX(',' + mpp_type4 + ',', @mpptype4) > 0) AND 
				(@teamleader = ',,' OR CHARINDEX(',' + mpp_teamleader + ',', @teamleader) > 0) AND 
				(@domicile = ',,' OR CHARINDEX(',' + mpp_domicile + ',', @domicile) > 0) AND 
				(@drv_status = ',,' OR CHARINDEX(',' + mpp_status + ',', @drv_status) > 0) AND 
				NOT EXISTS (SELECT 1 FROM #trc_plan t WHERE t.trc_number = tractorprofile.trc_number AND
										--PTS 31156 JJF 1/19/06
										t.drv_id = manpowerprofile.mpp_id AND
										--END PTS 31156 JJF 1/19/06
										t.trl_number = ISNULL(trc_trailer1, 'UNKNOWN') AND
										t.trl_number2 = ISNULL(trc_trailer2, 'UNKNOWN'))
END

--PTS 29929 11/1/05 JJF add carhandling conditions and cartype restrictions
IF @carhandling IS NULL or @carhandling <> 1 BEGIN
	INSERT INTO #trc_plan (trc_number, drv_id, trl_number, trl_number2, car_id, drv_name, drv_senioritydate)
		--PTS 32061 03/09/06 JJF/BCY		
		--SELECT	'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', car_id, NULL, NULL
		SELECT	'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', car_id, car_name, '12/31/2049' --bcy
		--END PTS 32061 03/09/06 JJF/BCY
		FROM	carrier
		WHERE	NOT EXISTS (SELECT 1 FROM #trc_plan t WHERE t.car_id = carrier.car_id) AND
			--PTS 32027 JJF 3/7/06
			(car_id <> 'UNKNOWN') AND
			--END PTS 32027 JJF 3/7/06
			(@cartype1 = ',,' OR CHARINDEX(',' + car_type1 + ',', @cartype1) > 0) AND 
			(@cartype2 = ',,' OR CHARINDEX(',' + car_type2 + ',', @cartype2) > 0) AND 
			(@cartype3 = ',,' OR CHARINDEX(',' + car_type3 + ',', @cartype3) > 0) AND 
			(@cartype4 = ',,' OR CHARINDEX(',' + car_type4 + ',', @cartype4) > 0) 
END

delete from #trc_plan
 where trc_number in (select trc_number 
                        from tractorprofile 
                       where trc_status = 'OUT')

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
	
--	delete #trc_plan
--	from #trc_plan tp inner join tractorprofile trc on tp.trc_number = trc.trc_number
--	where NOT ((isnull(trc.trc_terminal, 'UNK') = 'UNK' 
--			or EXISTS(SELECT * 
--						FROM UserTypeAssignment
--						WHERE usr_userid = @tmwuser	
--								and (uta_type1 = trc.trc_terminal
--										or uta_type1 = 'UNK'))))

--	delete #trc_plan
--	from #trc_plan tp inner join manpowerprofile mpp on tp.drv_id = mpp.mpp_id
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
	delete #trc_plan
	from #trc_plan tp inner join tractorprofile trc on tp.trc_number = trc.trc_number
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_tractorprofile_fn() rsva 
							WHERE	trc.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)

	delete #trc_plan
	from #trc_plan tp inner join manpowerprofile mpp on tp.drv_id = mpp.mpp_id
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_manpowerprofile_fn() rsva 
							WHERE	mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)
END
--END  PTS 51570 JJF 20100510

UPDATE	#trc_plan 
SET		day1_date = @hoursbackdate 

UPDATE	#trc_plan 
SET		day2_date = DATEADD(d, 1, day1_date), 
		day3_date = DATEADD(d, 2, day1_date), 
		day4_date = DATEADD(d, 3, day1_date), 
		day5_date = DATEADD(d, 4, day1_date), 
		day6_date = DATEADD(d, 5, day1_date), 
		day7_date = DATEADD(d, 6, day1_date) 

SELECT @id = MIN(id) 
FROM #trc_plan

WHILE @id > 0
BEGIN
	SELECT	@trc = trc_number, 
			@drv = drv_id, 
			@trl = trl_number, 
			@trl2 = trl_number2,
			@carrier = car_id
	FROM	#trc_plan 
	WHERE	id = @id

	--END PTS 31946 JJF 3/2/06
	IF @DoAssignmentConflictCheck = 1 BEGIN
		DELETE @legheader

		IF @carrier = 'UNKNOWN' BEGIN			
			INSERT INTO @legheader(lgh_driver1, lgh_tractor, lgh_primary_trailer, lgh_startdate, lgh_enddate, ord_number) 
			SELECT	l.lgh_driver1, l.lgh_tractor, l.lgh_primary_trailer, CONVERT(VARCHAR(10), l.lgh_startdate, 102), CONVERT(VARCHAR(10), l.lgh_enddate, 102), o.ord_number
			FROM	legheader_active l LEFT OUTER JOIN orderheader o ON l.ord_hdrnumber = o.ord_hdrnumber
			WHERE   (((l.lgh_driver1 = @drv) AND ((l.lgh_tractor <> @trc) OR (l.lgh_primary_trailer <> @trl))) OR
				((l.lgh_tractor = @trc) AND ((l.lgh_driver1 <> @drv) OR (l.lgh_primary_trailer <> @trl))) OR 
				((l.lgh_primary_trailer = @trl) AND (@trl <> 'UNKNOWN') AND ((l.lgh_driver1 <> @drv) OR (l.lgh_tractor <> @trc)))) AND
				((l.lgh_startdate <= dateadd(day, 0, @hoursoutdate)) AND 
				(l.lgh_enddate >= dateadd(day, 0, @hoursbackdate)))
			ORDER BY l.lgh_driver1, l.lgh_tractor, l.lgh_primary_trailer, o.ord_number
		END
	END
	--END PTS 31946 JJF 3/2/06

	--PTS 31953 JJF 3/1/06
	IF @DoExpirationCheck > 0 BEGIN
		--PTS 31953 JJF 3/1/06 -Now get expirations 
		DELETE #expiration
	
		INSERT INTO #expiration
		SELECT	exp_idtype, exp_id, exp_code, exp_expirationdate, exp_priority, exp_compldate
		FROM	expiration
		WHERE	(exp_expirationdate <= dateadd(day, 0, @hoursoutdate)) AND 
			(exp_compldate >= dateadd(day, 0, @hoursbackdate)) AND
			(exp_completed = 'N') AND 
			((exp_priority = '1') OR (@DoExpirationCheck > 1)) AND 
			(((exp_idtype = 'DRV') AND (exp_id = @drv)) OR 
				((exp_idtype = 'TRC') AND (exp_id = @trc)) OR
				((exp_idtype = 'TRL') AND (exp_id = @trl)) OR
				((exp_idtype = 'CAR') AND (exp_id = @carrier)))
		ORDER BY exp_idtype, exp_priority, exp_expirationdate, exp_compldate

	END	
	--END PTS 31953 JJF 3/1/06

	SET @counter = 0
	--PTS 32022 JJF 3/7/06 found that this caused problems when displayed.
	--			if a string at day 7 was large and all prior days were small,
	--			the autosize would still take the hidden test size into account,
	--			resulting in a row larger than it needed to be
	--WHILE @counter < 8
	WHILE @counter < @days 
	--END PTS 32022 JJF 3/7/06 
	BEGIN 
		SET @buildstring = NULL
		SET @InDispatchedGroup = 0
		SET @counter = @counter + 1
		--PTS 41618 JJF/JGUO 20080229
		--SELECT	@date = CASE @counter WHEN 1 THEN day1_date WHEN 2 THEN day2_date WHEN 3 THEN day3_date 
		SELECT	top 1 @date = CASE @counter WHEN 1 THEN day1_date WHEN 2 THEN day2_date WHEN 3 THEN day3_date 
		--END PTS 41618 JJF/JGUO 20080229
						WHEN 4 THEN day4_date WHEN 5 THEN day5_date WHEN 6 THEN day6_date
						WHEN 7 THEN day7_date END
		FROM	#trc_plan 
		SET @stops = 0


		--PTS 31953 JJF 3/1/06
		SET @PrefixMessagesAdded = 0

		IF @DoExpirationCheck > 0 BEGIN

			SET @linebuffer_last = ''

			SELECT @id_exp = MIN(id_exp)
			FROM #expiration
			WHERE 		(exp_expirationdate <= dateadd(day, 1, @date)) AND 
					(exp_compldate >= dateadd(day, 0, @date))
	
			WHILE @id_exp > 0 BEGIN
				SELECT 	@exp_assettype = CASE exp_idtype
								WHEN 'DRV' THEN 'Driver'
								WHEN 'TRC' THEN 'Tractor'	
								WHEN 'TRL' THEN 'Trailer'
								WHEN 'CAR' THEN 'Carrier'
							END,
					@exp_expirationdate = exp_expirationdate,
					@exp_compldate = exp_compldate,
					@exp_priority = exp_priority
				FROM #expiration
				WHERE id_exp = @id_exp
	
				IF @exp_priority = '1' BEGIN
					SET @linebuffer =  'P1'

					UPDATE #trc_plan 
					SET pri1exp = 1  
					WHERE id = @id
				END 
				ELSE BEGIN
					SET @linebuffer =  'P2'

					UPDATE #trc_plan 
					SET pri2exp = 1 
					WHERE id = @id
				END
				SET @linebuffer = @linebuffer + '('+ @exp_assettype 
				
				IF CONVERT(VARCHAR(10), @exp_expirationdate, 102) = CONVERT(VARCHAR(10), @date, 102) BEGIN
					SET @linebuffer = @linebuffer + ' from ' + convert(varchar(5), @exp_expirationdate, 8)
				END 
				IF CONVERT(VARCHAR(10), @exp_compldate, 102) = CONVERT(VARCHAR(10), @date, 102) BEGIN
					SET @linebuffer = @linebuffer + + ' until ' + convert(varchar(5), @exp_compldate, 8)
				END 
	
				SET @linebuffer = @linebuffer + ')' 
	
				IF @linebuffer <> @linebuffer_last BEGIN	
					SET @buildstring = ISNULL(@buildstring, '') + @addcr + @linebuffer
					SET @linebuffer_last = @linebuffer
					SET @PrefixMessagesAdded = 1	
					SET @addcr = CHAR(10)
				END			
				SELECT @id_exp = MIN(id_exp)
				FROM #expiration
				WHERE id_exp > @id_exp AND 
					(exp_expirationdate <= dateadd(day, 1, @date)) AND 
					(exp_compldate >= dateadd(day, 0, @date))
			END
		END
		--END PTS 31953 JJF 3/1/06

		--PTS 31946 JJF 3/2/06
		SET @addcr = ''

		IF @DoAssignmentConflictCheck = 1 BEGIN
			SET @linebuffer = ''
			SET @addcomma = ''
			SET @drvconflict_last = ''
			SET @trcconflict_last = ''
			SET @trlconflict_last = ''

			SELECT @id_lgh = MIN(id_lgh)
			FROM @legheader
			WHERE 	(lgh_startdate <= dateadd(second, -1, dateadd(day, 1, @date))) AND 
				(lgh_enddate >= dateadd(day, 0, @date))

			IF @id_lgh > 0 AND @PrefixMessagesAdded = 1 BEGIN
				SET @buildstring = @buildstring + CHAR(10) + CHAR(10) + CHAR(10) 
			END	

			WHILE @id_lgh > 0 BEGIN
				SELECT 	@drvconflict = lgh_driver1,
					@trcconflict = lgh_tractor,
					@trlconflict = lgh_primary_trailer,
					@ord_number_conflict = ord_number
				FROM @legheader
				WHERE id_lgh = @id_lgh

				IF @drvconflict <> @drvconflict_last or @trcconflict <> @trcconflict_last or @trlconflict <> @trlconflict_last BEGIN
					IF @linebuffer <> '' BEGIN
						SET @buildstring = ISNULL(@buildstring, '') + @addcr + @linebuffer
						SET @addcr = CHAR(10)
						SET @PrefixMessagesAdded = 1	
						SET @linebuffer = ''
					END

					SET @drvconflict_last = @drvconflict
					SET @trcconflict_last = @trcconflict
					SET @trlconflict_last = @trlconflict

					IF @drvconflict = @drv BEGIN
						SET @linebuffer = 'OTHER ORDERS Driver ' + @drv + ' Tractor ' + @trcconflict + ' Trailer ' + @trlconflict + ': '
					END
					ELSE IF @trcconflict = @trc BEGIN 
						SET @linebuffer = 'OTHER ORDERS Tractor ' + @trc + ' Driver ' + @drvconflict + ' Trailer ' + @trlconflict + ': '
					END
					ELSE IF @trlconflict = @trl BEGIN 
						SET @linebuffer = 'OTHER ORDERS Trailer ' + @trl + ' Driver ' + @drvconflict + ' Tractor ' + @trcconflict + ': '
					END
					SET @addcomma = ''
				END
				SET @linebuffer = @linebuffer + @addcomma + @ord_number_conflict
				SET @addcomma = ', '
									


				SELECT @id_lgh = MIN(id_lgh)
				FROM @legheader
				WHERE 		id_lgh > @id_lgh AND 
						(lgh_startdate <= dateadd(second, -1, dateadd(day, 1, @date))) AND 
						(lgh_enddate >= dateadd(day, 0, @date))

				IF @id_lgh IS NULL BEGIN
					SET @buildstring = ISNULL(@buildstring, '') + @addcr + @linebuffer
					SET @PrefixMessagesAdded = 1	
				END

			END

		END
		--END PTS 31946 JJF 3/2/06		

		SELECT	@lgh = MIN(id) 
		FROM	#work_trcplan 
		WHERE	lgh_tractor = @trc AND 
				lgh_driver1 = @drv AND 
				lgh_primary_trailer = @trl AND 
				lgh_primary_pup = @trl2 AND
				lgh_carrier = @carrier AND
				--PTS 31125 JJF 1/3/06 (102 instead of 101)
				(CONVERT(VARCHAR(10), lgh_startdate, 102) <= CONVERT(VARCHAR(10), @date, 102) AND 
				CONVERT(VARCHAR(10), lgh_enddate, 102) >= CONVERT(VARCHAR(10), @date, 102)) 
		WHILE @lgh > 0
		BEGIN
			--PTS 31953 JJF 3/2/06
			IF @PrefixMessagesAdded = 1 BEGIN
				SET @buildstring = @buildstring + CHAR(10) + CHAR(10)
				SET @PrefixMessagesAdded = 0
			END
			--END PTS 31953 JJF 3/2/06

			--PTS 30270 10/19/2005 - add lgh_outstatus to Display 'Dispatched:' for dispatched trips.
			SELECT	@hold = ISNULL(formatedstring, ''), @lgh_outstatus = lgh_outstatus
			FROM	#work_trcplan 
			WHERE	id = @lgh

			IF @stops = 0 OR @startend = 'NO'
			BEGIN
				--PTS 30270 10/19/2005 - add lgh_outstatus to Display 'Dispatched:' for dispatched trips.
				IF @lgh_outstatus = 'DSP' BEGIN
					IF @InDispatchedGroup = 1 BEGIN
						SET @hold = ', ' + @hold 
					END
					ELSE BEGIN
						SET @hold = 'Dispatched: ' + @hold 
						SET @InDispatchedGroup = 1 
						IF LEN(@buildstring) > 0 AND LEN(@hold) > 0
							SET @buildstring = @buildstring + CHAR(10)
					END
					IF LEN(@hold) > 0 
						SET @buildstring = ISNULL(@buildstring, '') + @hold

				END
				ELSE BEGIN
					SET @InDispatchedGroup = 0
					IF LEN(@buildstring) > 0 AND LEN(@hold) > 0
						SET @buildstring = @buildstring + CHAR(10)
					IF LEN(@hold) > 0 
						SET @buildstring = ISNULL(@buildstring, '') + @hold
				END
				/*IF LEN(@buildstring) > 0 AND LEN(@hold) > 0
					SET @buildstring = @buildstring + CHAR(10)
				IF LEN(@hold) > 0 
					SET @buildstring = ISNULL(@buildstring, '') + @hold
				*/
				--END PTS 30270 10/19/2005 - add lgh_outstatus to Display 'Dispatched:' for dispatched trips.
			END

			SET @stops = @stops + 1
			SELECT	@lgh = MIN(id) 
			FROM	#work_trcplan 
			WHERE	lgh_tractor = @trc AND 
					lgh_driver1 = @drv AND 
					lgh_primary_trailer = @trl AND 
					lgh_primary_pup = @trl2 AND
					lgh_carrier = @carrier AND
					--PTS 31125 JJF 1/3/06 (102 instead of 101)
					(CONVERT(VARCHAR(10), lgh_startdate, 102) <= CONVERT(VARCHAR(10), @date, 102) AND 
					CONVERT(VARCHAR(10), lgh_enddate, 102) >= CONVERT(VARCHAR(10), @date, 102)) AND 
					id > @lgh 
		END

		

		--PTS 31953 JJF 3/1/06 - remove plan here
		UPDATE	#trc_plan 
		SET		day1 = CASE @counter WHEN 1 THEN ISNULL(@buildstring, '') ELSE day1 END, 
				day2 = CASE @counter WHEN 2 THEN ISNULL(@buildstring, '') ELSE day2 END, 
				day3 = CASE @counter WHEN 3 THEN ISNULL(@buildstring, '') ELSE day3 END, 
				day4 = CASE @counter WHEN 4 THEN ISNULL(@buildstring, '') ELSE day4 END, 
				day5 = CASE @counter WHEN 5 THEN ISNULL(@buildstring, '') ELSE day5 END, 
				day6 = CASE @counter WHEN 6 THEN ISNULL(@buildstring, '') ELSE day6 END, 
				day7 = CASE @counter WHEN 7 THEN ISNULL(@buildstring, '') ELSE day7 END
		WHERE	trc_number = @trc and
				drv_id = @drv and 
				trl_number = @trl and 
				trl_number2 = @trl2 and
				car_id = @carrier

		/*
		UPDATE	#trc_plan 
		SET		day1 = CASE @counter WHEN 1 THEN ISNULL(@buildstring, 'Plan Here') ELSE day1 END, 
				day2 = CASE @counter WHEN 2 THEN ISNULL(@buildstring, 'Plan Here') ELSE day2 END, 
				day3 = CASE @counter WHEN 3 THEN ISNULL(@buildstring, 'Plan Here') ELSE day3 END, 
				day4 = CASE @counter WHEN 4 THEN ISNULL(@buildstring, 'Plan Here') ELSE day4 END, 
				day5 = CASE @counter WHEN 5 THEN ISNULL(@buildstring, 'Plan Here') ELSE day5 END, 
				day6 = CASE @counter WHEN 6 THEN ISNULL(@buildstring, 'Plan Here') ELSE day6 END, 
				day7 = CASE @counter WHEN 7 THEN ISNULL(@buildstring, 'Plan Here') ELSE day7 END
		WHERE	trc_number = @trc and
				drv_id = @drv and 
				trl_number = @trl and 
				trl_number2 = @trl2 and
				car_id = @carrier
		*/
		--END PTS 31953 JJF 3/1/06 - remove plan here
	END 
	SELECT	@id = MIN(id) 
	FROM	#trc_plan 
	WHERE	id > @id
END

--PTS 31953 JJF 3/1/06 return expiration info
SELECT	trc_number, drv_id, drv_name, drv_senioritydate, trl_number, trl_number2, car_id, 
	cfiltflag, pri1exp, pri2exp,
	day1, day1_date, day2, day2_date, day3, day3_date, day4, day4_date, 
	day5, day5_date, day6, day6_date, day7, day7_date, trc_dailyflag
FROM	#trc_plan 
--END PTS 31953 JJF 3/1/06
GO
GRANT EXECUTE ON  [dbo].[inbound_view_trcplan] TO [public]
GO

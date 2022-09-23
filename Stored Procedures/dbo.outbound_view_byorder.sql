SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.outbound_view_byorder2   Script Date: 6/24/98 10:15:30 AM ******/
/* MF 11/12/97 PTS 3215 changed to use newly populated fields on LGH including lgh_active */
/* LOR	5/12/98	PTS# 3905	add shipper/consignee states, drivers' id's */
/* LOR	5/12/98	PTS# 3908	add ref type and number */
/* JET	6/3/98	PTS# 3991	modified lgh_schdtearliest, lgh_schdtlatest to reflect ord_origin_earliestdate andord_origin_latestdate*/
/* MF 10/22/98 pts 4175 add extra cols*/
/* JET 10/20/99 PTS #6490	changed the where clause on the select */
/* DSK 3/20/00 PTS 7566		add columns for total orders, total count, total weight, total volume */
/* KMM 7/10/00 PTS 8339		allow MPN records to be returned */
/* RJE 7/14/00 added ld_can_expires for CAN */
/* DPETE 12599 add origin and dest company geoloc feilds to return set fro Gibsons SR */
/* BDH 9/12/06 PTS 33890 	Returning next_ndrp_cmpid, next_ndrp_cmpname, next_ndrp_ctyname, next_ndrp_state, next_ndrp_arrivaldate from legheader_active */

CREATE PROCEDURE [dbo].[outbound_view_byorder]
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
	@orderedby varchar(254),
	@o_servicearea		varchar(256),
	@o_servicezone		varchar(256),
	@o_servicecenter	varchar(256),
	@o_serviceregion	varchar(256),
	@dest_servicearea	varchar(256),
	@dest_servicezone	varchar(256),
	@dest_servicecenter	varchar(256),
	@dest_serviceregion	varchar(256),
	@lgh_route		varchar(256),
	@lgh_booked_revtype1	varchar(256),
	@lgh_permit_status	varchar(256),
	@cmp_othertype1		varchar(256),
	@d_cmp_othertype1	varchar(256),
    @startdate			datetime,
	@daysout			int, 
	@ord_booked_revtype1	varchar(256), 
	@pyt_linehaul			varchar (6), 	/* 08/04/2009 MDH PTS 42293: Added */
	@pyt_fuelcost			varchar (6), 	/* 08/04/2009 MDH PTS 42293: Added */
	@pyt_accessorial		varchar (6) 	/* 08/04/2009 MDH PTS 42293: Added */
AS

/* 08/10/2009 MDH PTS 42293: <<BEGIN>> */
DECLARE @temp_sums TABLE
	(
	ord_hdrnumber			integer	not null,
	lgh_number				integer not null,
	mov_number				integer not null,
	evt_carrier				varchar (8) null,
	ord_booked_revtype1 	varchar (12) null,
	lgh_miles				integer null,
	lgh_total_mov_miles 	integer null,
	num_legs				integer null,
	num_ords				integer null, 
	pyt_linehaul			varchar (6) null,
	pyd_linehaul			money null,
	ord_or_leg				varchar (10) null,
	ord_percent				decimal (8,4) null,  -- 100% for one order/leg, otherwise computed based on miles
	pyd_total				money			null, /* 09/08/2009 MDH PTS 42293: Added */
	all_ord_revenue_pay		money			null, /* 09/08/2009 MDH PTS 42293: Added */
	all_ord_totalcharge		money			null,  /* 09/08/2009 MDH PTS 42293: Added */
	ud_column1	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column1_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column2	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column2_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column3	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column3_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column4	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column4_t varchar(30)		 --	PTS 51911 SGB User Defined column header	
	)   
/* 08/10/2009 MDH PTS 42293: <<END>> */	

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
	@PWExtraInfoLocation varchar(20), 
	@v_LocalCityTZAdjMinutes	int,	
	@InDSTFactor				int,
	@DSTCountryCode				int ,
	@V_LocalGMTDelta			smallint,
	@v_LocalDSTCode				smallint,
	@V_LocalAddnlMins			smallint,
	@ud_column1 char(1), --PTS 51911 SGB
	@ud_column2 char(1),  --PTS 51911 SGB
	@ud_column3 char(1), --PTS 51911 SGB
	@ud_column4 char(1),  --PTS 51911 SGB
	@procname varchar(255), --PTS 51911 SGB
	@udheader varchar(30) --PTS 51911 SGB    

DECLARE @ACSInfo char (1)				/* 08/28/2009 MDH PTS 42293: Added */

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

/* 04/23/2012 MDH PTS 60772: <<BEGIN>> */
select @DSTCountryCode = 0 /* if you want to work outside North America, set this value see proc ChangeTZ */
select @InDSTFactor = case dbo.InDst(getdate(),@DSTCountryCode) when 'Y' then 1 else 0 end
exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
select @v_LocalCityTZAdjMinutes =
   ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
/* 04/23/2012 MDH PTS 60772: <<END>> */

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
		    OR	 usr_windows_userid = @TMWUser)
  
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

IF @hoursback = 0
	SELECT @hoursback= 1000000

IF @hoursout = 0
	SELECT @hoursout = 1000000
/* Get the hoursback and  hoursout into variables
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

-- PTS 25895 JLB need to add the ability to determine where extrainfo comes from
Select @PWExtraInfoLocation = UPPER(isnull(gi_string1,'ORDERHEADER'))
  from generalinfo
 where gi_name = 'PWExtraInfoLocation'

-- LOR
If @miles_min = 0 select @miles_min = -1000

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
if @ord_booked_revtype1 IS NULL or LTRIM(RTRIM(@ord_booked_revtype1)) = ''
   SELECT @ord_booked_revtype1 = ''

/* 08/28/2009 MDH PTS 42293: Get ACS Info setting */
SELECT @ACSInfo = LEFT (gi_string1, 1) FROM generalinfo WHERE gi_name = 'ACSInfoInWorksheet' 
IF @ACSInfo IS NULL 
	SELECT @ACSInfo = 'N'

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
SELECT @billto = ',' + LTRIM(RTRIM(ISNULL(@billto, '')))  + ',' --vjh 21520 put in by CGK in 23162
SELECT @lgh_route = ',' + LTRIM(RTRIM(ISNULL(@lgh_route, '')))  + ','
SELECT @lgh_booked_revtype1 = ',' + LTRIM(RTRIM(ISNULL(@lgh_booked_revtype1, '')))  + ','
SELECT @ord_booked_revtype1 = ',' + LTRIM(RTRIM(ISNULL(@ord_booked_revtype1, '')))  + ','
/*PTS 23162 CGK 9/1/2004*/
SELECT @lgh_hzd_cmd_classes = ',' + LTRIM(RTRIM(ISNULL(@lgh_hzd_cmd_classes, '')))  + ','

-- DELETE rows if filtering to @ord_booked_revtype1 (47850)
If @ord_booked_revtype1 <> ',,'
  BEGIN
      DELETE @temp_sums where CHARINDEX(',' + ISNULL(ord_booked_revtype1, 'UNKNOWN') + ',', @ord_booked_revtype1) < 1 
  END

/* 08/10/2009 MDH PTS 42293: <<BEGIN>> */
/* Create a temp table to hold some values that need to be calculated over several updates. */
INSERT INTO @temp_sums 
	SELECT	distinct stops.ord_hdrnumber, 
	    stops.lgh_number, 	
		stops.mov_number, 
		orderheader.ord_carrier,
		orderheader.ord_booked_revtype1,  
		lgh_miles, 
		lgh_total_mov_miles,
		(SELECT COUNT (*) FROM legheader_active (nolock) WHERE legheader_active.mov_number = legheader.mov_number) num_legs,
		(SELECT COUNT (*) FROM orderheader o (nolock) WHERE o.mov_number = orderheader.mov_number) num_ords,
		(CASE @ACSInfo WHEN 'Y' THEN (CASE (SELECT COUNT(pyd_number) FROM paydetail (nolock) WHERE asgn_id = orderheader.ord_carrier
									AND asgn_type = 'CAR' AND lgh_number= legheader.lgh_number 
									AND mov_number = legheader.mov_number AND pyt_itemcode = @pyt_linehaul)
			WHEN 0 THEN (SELECT MIN(pyt_itemcode) FROM paydetail (nolock) WHERE asgn_id = orderheader.ord_carrier
								AND asgn_type = 'CAR' AND lgh_number= legheader.lgh_number 
								AND mov_number= legheader.mov_number AND pyt_itemcode IN (SELECT pyt_itemcode 
						  						FROM paytype (nolock)
			 			 						WHERE pyt_basis = 'LGH'))
			ELSE @pyt_linehaul END) ELSE NULL END) pyt_linehaul,
		(CASE @ACSInfo WHEN 'Y' THEN 0.0 ELSE NULL END) pyd_linehaul, 
		(CASE @ACSInfo WHEN 'Y' THEN 'Order' ELSE NULL END),
		(CASE @ACSInfo WHEN 'Y' THEN 1.0 ELSE NULL END), 
		(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (pyd_amount) FROM paydetail (nolock) WHERE paydetail.mov_number = legheader.mov_number AND paydetail.ord_hdrnumber <> 0) ELSE NULL END) pyd_total, 
		(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (ISNULL (ord_revenue_pay, 0)) FROM orderheader o WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops (nolock) WHERE stops.mov_number = legheader.mov_number AND ord_hdrnumber <> 0)) ELSE NULL END) ord_revenue_pay, /* all_ord_revenue_pay */
		(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (ISNULL (ord_totalcharge, 0)) FROM orderheader o WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops (nolock) WHERE stops.mov_number = legheader.mov_number AND ord_hdrnumber <> 0)) ELSE NULL END) ord_totalcharge /* all_ord_totalcharge */
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column1' 	--	PTS 51911 SGB User Defined column header
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column2'		--	PTS 51911 SGB User Defined column header
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column3' 	--	PTS 51911 SGB User Defined column header
		,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
		,'UD Column4'		--	PTS 51911 SGB User Defined column header
	FROM	legheader_active legheader
				INNER JOIN stops ON legheader.lgh_number = stops.lgh_number 
				INNER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE 	(@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0)  AND   
	                       (@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0)  AND   
	                       (@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0)  AND   
	                       (@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0) AND
	        lgh_startdate >= @hoursbackdate AND 
	        lgh_startdate <= @hoursoutdate AND 
		(@city = 0 OR lgh_startcity = @city)
	  AND   (@includedrvplan='Y' or legheader.drvplan_number is null or legheader.drvplan_number = 0) 
	  AND	(@d_city = 0 OR lgh_endcity = @d_city) 
	  AND (@cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + isNull ((SELECT cmp_othertype1 FROM company WHERE company.cmp_id = legheader.cmp_id_start), 'UNK') + ',', @cmp_othertype1) > 0)
	  AND	(@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_startregion1 + ',', @reg1) > 0) 
	  AND	(@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_startregion2 + ',', @reg2) > 0)  
	  AND	(@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_startregion3 + ',', @reg3) > 0)  
	  AND	(@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_startregion4 + ',', @reg4) > 0)  
	  AND	(@d_reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @d_reg1) > 0) 
	  AND	(@d_reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @d_reg2) > 0) 
	  AND	(@d_reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @d_reg3) > 0) 
	  AND	(@d_reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @d_reg4) > 0) 
	  AND (@d_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + isNull ((SELECT cmp_othertype1 FROM company WHERE company.cmp_id = legheader.cmp_id_end), 'UNK') + ',', @d_cmp_othertype1) > 0)
	  AND	lgh_outstatus IN ( 'AVL', 'DSP', 'PLN', 'STD', 'MPN')
	  AND   (@status = '' OR CHARINDEX(lgh_outstatus, @status) > 0) 
	  AND   (@states = '' OR CHARINDEX(lgh_startstate, @states) > 0)
	  AND   (@d_states = '' OR CHARINDEX(lgh_endstate, @d_states) > 0)
	  AND   (@cmpids = ',,' OR CHARINDEX(',' + cmp_id_start + ',', @cmpids) > 0)
	  AND   (@d_cmpids = ',,' OR CHARINDEX(',' + cmp_id_end + ',', @d_cmpids) > 0) 
	  AND   (@teamleader = ',,' OR CHARINDEX(',' + mpp_teamleader + ',', @teamleader) > 0) 
	  AND   (@tm_status = ',,' OR lgh_tm_status is null or CHARINDEX(lgh_tm_status, @tm_status) > 0) 
	  AND   (@lgh_type1 = ',,' OR lgh_type1 is null or CHARINDEX(',' + lgh_type1 + ',', @lgh_type1) > 0 or @lgh_type1 = ',UNK,') 
	  AND   (@lgh_type2 = ',,' OR lgh_type2 is null or CHARINDEX(',' + lgh_type2 + ',', @lgh_type2) > 0 or @lgh_type2 = ',UNK,')
	  AND   (@company = ',,' OR CHARINDEX(',' + legheader.ord_ord_subcompany + ',', @company) > 0) AND
	        (@bookedby = ',ALL,' OR CHARINDEX(',' + legheader.ord_bookedby + ',', @bookedby) > 0) AND 
	          (@trltype1 = ',,' OR CHARINDEX(',' + legheader.ord_trl_type1 + ',', @trltype1) > 0) and 
	    	(ISNULL(legheader.ord_totalmiles, -1) between @miles_min and @miles_max)
	  AND   (@billto = ',,' OR CHARINDEX(',' + legheader.ord_billto + ',', @billto) > 0)
	  AND   (@lgh_hzd_cmd_classes = ',UNK,' OR CHARINDEX(',' + lgh_hzd_cmd_class + ',', @lgh_hzd_cmd_classes) > 0)/*PTS 23162 CGK 9/1/2004*/
	  AND   (@lgh_permit_status = ',UNK,' OR CHARINDEX(',' + legheader.lgh_permit_status + ',', @lgh_permit_status) > 0)

-- DELETE rows if filtering to @ord_booked_revtype1 (47850)
If @ord_booked_revtype1 <> ',,'
  BEGIN
      DELETE @temp_sums where CHARINDEX(',' + ISNULL(ord_booked_revtype1, 'UNKNOWN') + ',', @ord_booked_revtype1) < 1 
  END

/* 08/28/2009 MDH PTS 42293: If ACS is enabled, update the values */
IF @ACSInfo = 'Y' 
BEGIN
	-- Update the percentage column
	UPDATE @temp_sums
	SET ord_percent = CASE WHEN lgh_total_mov_miles > 0 
							THEN CAST (lgh_miles AS DECIMAL (9,4)) / CAST (lgh_total_mov_miles AS DECIMAL (9,4)) 
						ELSE 1 END,
			ord_or_leg = CASE WHEN num_legs > 1 THEN 'Segment' 
							WHEN num_ords = 0 THEN '' 
							ELSE 'Order' END
	-- Update the pay detail line haul column
	UPDATE @temp_sums
		SET pyd_linehaul = COALESCE ((SELECT SUM (paydetail.pyd_amount) 
		                                FROM paydetail  
		                                WHERE paydetail.asgn_id = x.evt_carrier
		                                  AND paydetail.asgn_type = 'CAR'
		                                  AND paydetail.lgh_number = x.lgh_number
		                                  AND paydetail.mov_number = x.mov_number
		                                  AND paydetail.pyt_itemcode = pyt_linehaul), 0)
		 FROM @temp_sums x
		 WHERE pyt_linehaul is not null and pyt_linehaul <> ''
END
/* 08/05/2009 MDH PTS 42293: <<END>> */
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
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',1)
			UPDATE @temp_sums
			set ud_column1 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'LS',1),
			ud_column1_t = @udheader
			from @temp_sums t

		END
 
END 

IF @ud_column2 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',2)
			UPDATE @temp_sums
			set ud_column2 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'LE',2),
			ud_column2_t = @udheader
			from @temp_sums t

		END
 
END 

IF @ud_column3 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',3)
			UPDATE @temp_sums
			set ud_column3 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',3),
			ud_column3_t = @udheader
			from @temp_sums t

		END
 
END 

IF @ud_column4 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',4)
			UPDATE @temp_sums
			set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',4),
			ud_column4_t = @udheader
			from @temp_sums t

		END
 
END 



  
SELECT	distinct stops.lgh_number, 
	legheader.cmp_id_start o_cmpid, 
	o_cmpname, 
	lgh_startcty_nmstct o_ctyname, 
	legheader.cmp_id_end d_cmpid, 
	d_cmpname, 
	lgh_endcty_nmstct d_ctyname, 
	ord_shipper f_cmpid,
	shipper.cmp_name f_cmpname,
	shipper.cty_nmstct f_ctyname,
	ord_consignee l_cmpid,
	consignee.cmp_name l_cmpname,
	consignee.cty_nmstct l_ctyname,
	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	lgh_startstate o_state, 
	lgh_endstate d_state, 
	orderheader.ord_origin_earliestdate lgh_schdtearliest, 
	orderheader.ord_origin_latestdate lgh_schdtlatest,
	orderheader.cmd_code,         /* 07/24/2007 MDH PTS 37842: Changed from legheader.cmd_code, */
	orderheader.ord_description,  /* 07/24/2007 MDH PTS 37842: Changed from legheader.fgt_description, */
	cmd_count,
	stops.ord_hdrnumber, 
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
	lgh_startcity o_city, 
	lgh_endcity d_city,
	legheader.lgh_priority, 
	lgh_outstatus_name lgh_outstatus,				/* 043 */
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
	washstatus,										/* 073 */
	f_state,	
	l_state,
	legheader.lgh_driver1 evt_driver1_id,
	legheader.lgh_driver2 evt_driver2_id,
	orderheader.ord_reftype,
	orderheader.ord_refnum,
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
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo1 ELSE lgh_extrainfo1 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo2 ELSE lgh_extrainfo2 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo3 ELSE lgh_extrainfo3 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo4 ELSE lgh_extrainfo4 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo5 ELSE lgh_extrainfo5 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo6 ELSE lgh_extrainfo6 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo7 ELSE lgh_extrainfo7 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo8 ELSE lgh_extrainfo8 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo9 ELSE lgh_extrainfo9 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo10 ELSE lgh_extrainfo10 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo11 ELSE lgh_extrainfo11 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo12 ELSE lgh_extrainfo12 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo13 ELSE lgh_extrainfo13 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo14 ELSE lgh_extrainfo14 END),
	(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo15 ELSE lgh_extrainfo15 END),
   --end 25895
	o_cmp_geoloc,
	d_cmp_geoloc,
	legheader.mpp_fleet,
	mpp_fleet_name,
	s1.stp_schdtearliest   lgh_earliest_pu,
	s1.stp_schdtlatest   lgh_latest_pu,
	s2.stp_schdtearliest   lgh_earliest_unl,
	s2.stp_schdtlatest   lgh_latest_unl,
	legheader.lgh_miles,
	lgh_linehaul,
	lgh_hzd_cmd_class, /*PTS 23162 CGK 9/1/2004*/
	ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
	labelfile_headers.LghPermitStatus lgh_permit_status_t,
	(select max(fgt_length)
		from freightdetail, stops 
	  where freightdetail.stp_number = stops.stp_number
       and orderheader.ord_hdrnumber = stops.ord_hdrnumber
       and stops.ord_hdrnumber > 0) as fgt_length,
	(select max(fgt_width)
		from freightdetail, stops 
	  where freightdetail.stp_number = stops.stp_number
       and orderheader.ord_hdrnumber = stops.ord_hdrnumber
       and stops.ord_hdrnumber > 0) as fgt_width,
	(select max(fgt_height)
		from freightdetail, stops 
	  	where freightdetail.stp_number = stops.stp_number
       and orderheader.ord_hdrnumber = stops.ord_hdrnumber
       and stops.ord_hdrnumber > 0) as fgt_height,
	-- 33890 BDH 9/12/06 start
	next_ndrp_cmpid,
	next_ndrp_cmpname,
	next_ndrp_ctyname,
	next_ndrp_state,
	next_ndrp_arrivaldate ,
	-- 33890 BDH 9/12/06 end
	legheader.lgh_total_mov_bill_miles,   /* 07/31/2009 MDH PTS 42281: Added */
	legheader.lgh_total_mov_miles,        /* 07/31/2009 MDH PTS 42281: Added */
	/* 08/10/2009 MDH PTS 42293: <<BEGIN>> */
	ts.num_legs, ts.num_ords, ts.pyt_linehaul,
	(CASE @ACSInfo WHEN 'Y' THEN ISNULL((SELECT SUM(ISNULL (pyd_amount, 0))
				FROM PayDetail (nolock)
				WHERE asgn_id = orderheader.ord_carrier
				AND asgn_type = 'CAR' AND lgh_number= legheader.lgh_number 
				AND mov_number= legheader.mov_number AND pyt_itemcode = @pyt_accessorial), 0) ELSE NULL END) pyd_accessorial,
	(CASE @ACSInfo WHEN 'Y' THEN ISNULL((SELECT SUM(ISNULL (pyd_amount, 0))
				FROM PayDetail (nolock)
				WHERE asgn_id = orderheader.ord_carrier
				AND asgn_type = 'CAR' AND lgh_number= legheader.lgh_number 
				AND mov_number= legheader.mov_number AND pyt_itemcode = @pyt_fuelcost), 0) ELSE NULL END) pyd_fuel,
	ts.pyd_linehaul, 
	(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (ISNULL (ord_accessorial_chrg, 0)) FROM orderheader o WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops (nolock) WHERE stops.mov_number = legheader.mov_number AND ord_hdrnumber <> 0)) ELSE NULL END) ord_accessorial_chrg, /* ord_accessorials */
	(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (ivd_charge)
			FROM invoicedetail (nolock) JOIN fuelchargetypes (nolock) ON invoicedetail.cht_itemcode = fuelchargetypes.cht_itemcode
			     JOIN orderheader o (nolock) ON invoicedetail.ord_hdrnumber = o.ord_hdrnumber
			WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops (nolock) WHERE stops.mov_number = legheader.mov_number AND ord_hdrnumber <> 0)) ELSE NULL END), /* ord_fuel		    */
	(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (ISNULL (ord_charge, 0)) FROM orderheader o (nolock) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops (nolock) WHERE stops.mov_number = legheader.mov_number AND ord_hdrnumber <> 0)) ELSE NULL END) ord_charge, /* ord_linehaul	    */
	(CASE @ACSInfo WHEN 'Y' THEN (SELECT SUM (ISNULL (ord_totalcharge, 0)) FROM orderheader o (nolock) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops (nolock) WHERE stops.mov_number = legheader.mov_number AND ord_hdrnumber <> 0)) ELSE NULL END) ord_totalcharge, /* ord_total_charge */
	ts.ord_or_leg, 
	ts.ord_percent,
	/* 08/10/2009 MDH PTS 42293: <<END>> */
	@ma_transaction_id ma_transaction_id,											-- RE - PTS #52017
	CASE																			-- RE - PTS #52017
		WHEN @ma_transaction_id IS NULL THEN @null_int								-- RE - PTS #52017
		ELSE dbo.Load_MATourNumber_fn(@DefaultCompanyID, @ma_transaction_id , legheader.lgh_number)		-- RE - PTS #52017
	END ma_tour_number,																-- RE - PTS #52017
	@null_varchar8,																	-- RE - PTS #52017
	@null_varchar8,																	-- RE - PTS #52017
	CASE																			-- RE - PTS #52017
		WHEN @ma_transaction_id IS NULL THEN @null_varchar100						-- RE - PTS #52017
		ELSE dbo.Load_MAReccomendation_fn(@DefaultCompanyID, @ma_transaction_id, legheader.lgh_number)	-- RE - PTS #52017
	END ma_advice,																	-- RE - PTS #52017
	lgh_mile_overage_message,				/* 08/31/2009 MDH PTS 42281: Added */
	ts.pyd_total,							/* 09/08/2009 MDH PTS 42293: Added */
	ts.all_ord_totalcharge * ord_percent,	/* 09/08/2009 MDH PTS 42293: Added */
	ts.all_ord_revenue_pay	* ord_percent, 	/* 09/08/2009 MDH PTS 42293: Added */
	0 'org_distfrom',  -- PTS 45271 - DJM  
	0 'dest_distfrom',  -- PTS 45271 - DJM  
	legheader.lgh_chassis,
	legheader.lgh_chassis2,
	legheader.lgh_dolly,
	legheader.lgh_dolly2,
	legheader.lgh_trailer3,
	legheader.lgh_trailer4, 
	legheader.lgh_outstatus,				/* 188 */		/* 04/15/2010 MDH PTS 50207: Added */
	legheader.lgh_instatus,					/* 189 */		/* 04/15/2010 MDH PTS 50207: Added */
	orderheader.ord_order_source,			/* 190 */       /* 08/19/2010 MDH PTS 52714: Added */
	/* 04/23/2012 MDH PTS 60772: <<BEGIN>> */
	@v_LocalCityTZAdjMinutes - ((isnull(c1.cty_GMTDelta,5) +
		(@InDSTFactor * (case c1.cty_DSTApplies when 'Y' then 0 else +1 end))) * 60) + 
		isnull(c1.cty_TZMins,0),
	@v_LocalCityTZAdjMinutes - ((isnull(c2.cty_GMTDelta,5) +
		(@InDSTFactor * (case c2.cty_DSTApplies when 'Y' then 0 else +1 end))) * 60) + 
		isnull(c2.cty_TZMins,0),
	/* 04/23/2012 MDH PTS 60772: <<END>> */
	ts.ud_column1,		 -- PTS 51911 SGB User Defined column
	ts.ud_column1_t ,		 --	PTS 51911 SGB User Defined column header
	ts.ud_column2,		 -- PTS 51911 SGB User Defined column
	ts.ud_column2_t,		 --	PTS 51911 SGB User Defined column header
	ts.ud_column3,		 -- PTS 51911 SGB User Defined column
	ts.ud_column3_t,		 --	PTS 51911 SGB User Defined column header
	ts.ud_column4,		 -- PTS 51911 SGB User Defined column
	ts.ud_column4_t		
FROM	legheader_active legheader
			INNER JOIN stops ON legheader.lgh_number = stops.lgh_number 
			INNER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
			INNER JOIN labelfile_headers ON 1=1
			INNER JOIN stops s1 ON legheader.stp_number_start = s1.stp_number
			INNER JOIN stops s2 ON legheader.stp_number_end = s2.stp_number
			INNER JOIN company shipper ON orderheader.ord_shipper = shipper.cmp_id
			INNER JOIN company consignee ON orderheader.ord_consignee = consignee.cmp_id 
			INNER JOIN city c1 ON orderheader.ord_origincity = c1.cty_code
			INNER JOIN city c2 ON orderheader.ord_destcity = c2.cty_code
			JOIN @temp_sums ts ON (ts.lgh_number = stops.lgh_number AND ts.ord_hdrnumber = stops.ord_hdrnumber)
GO
GRANT EXECUTE ON  [dbo].[outbound_view_byorder] TO [public]
GO

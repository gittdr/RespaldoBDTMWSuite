SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_lgh_mpp2_sp]
(  @ai_lgh_number          INT
,  @as_driver_id           VARCHAR(8)
,  @as_resourceTypeOnLeg   CHAR(1)
,  @lgh_type1              VARCHAR(6)  OUTPUT
,  @lgh_type2              VARCHAR(6)  OUTPUT
,  @lgh_type3              VARCHAR(6)  OUTPUT
,  @lgh_type4              VARCHAR(6)  OUTPUT
,  @mpp_type1              VARCHAR(6)  OUTPUT
,  @mpp_type2              VARCHAR(6)  OUTPUT
,  @mpp_type3              VARCHAR(6)  OUTPUT
,  @mpp_type4              VARCHAR(6)  OUTPUT
,  @mpp_terminal           VARCHAR(6)  OUTPUT
,  @mpp_senioritydate      DATETIME    OUTPUT
,  @mpp_company            VARCHAR(6)  OUTPUT
,  @mpp_fleet              VARCHAR(6)  OUTPUT
,  @mpp_division           VARCHAR(6)  OUTPUT
,  @mpp_domicile           VARCHAR(6)  OUTPUT
,  @mpp_teamleader         VARCHAR(6)  OUTPUT
,  @lgh_ratemode           VARCHAR(6)  OUTPUT   -- NQIAO 11/18/11 PTS 58978
,  @lgh_servicelevel       VARCHAR(6)  OUTPUT   -- NQIAO 11/18/11 PTS 58978
,  @lgh_servicedays        INT         OUTPUT   -- NQIAO 11/18/11 PTS 58978
,  @asgn_branch            VARCHAR(12) OUTPUT   -- vjh pts63018
) AS
SET NOCOUNT ON

/**
 *
 * NAME:
 * dbo.get_lgh_mpp2_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *    Returns to nvo_autotrippay.f_getpaytariff:
 *    The lgh_types, driver1, driver2, mpp_driver types and
 *    for Driver2: mpp2_driver types from legheader.
 *    WHEN ini setting passed in@as_resourceTypeOnLeg = Y values returned from legheader.
 *    When N, values returned from manpowerprofile.
 *
 * RETURNS:
 * Output variables to nvo_autotrippay.f_getpaytariff.
 * Values if they exist or "UNK" if no data exists.
 *
 * RESULT SET as output          variables:
 *       @lgh_type1              varchar(6)
 *       @lgh_type2              varchar(6)
 *       @lgh_type3              varchar(6)
 *       @lgh_type4              varchar(6)
 *       @mpp1_type1             varchar(6)
 *       @mpp1_type2             varchar(6)
 *       @mpp1_type3             varchar(6)
 *       @mpp1_type4             varchar(6)
 *       @mpp1_terminal          varchar(6)
 *       @mpp_senioritydate      datetime
 *       @mpp_company            varchar(6)
 *       @mpp_fleet              varchar(6)
 *       @mpp_division           varchar(6)
 *       @mpp_domicile           varchar(6)
 *       @mpp_teamleader         varchar(6)
 *       @lgh_ratemode           varchar(6)           -- NQIAO 11/18/11 PTS 58978
 *       @lgh_servicelevel       varchar(6)           -- NQIAO 11/18/11 PTS 58978
 *       @lgh_servicedays        int                  -- NQIAO 11/18/11 PTS 58978
 *       @asgn_branch            varchar(12)
 *
 * PARAMETERS:
 * 001 - @ai_lgh_number          int                  -- the legheader number [Input]
 * 002 - @as_driver_id           varchar(6)           -- the driver id being considered in nvo_autotrippay [Input]
 * 003 - @as_resourceTypeOnLeg   char(1)              -- the value of the ini setting UseResourceTypeOnTrip [Input]
 * 004 - @lgh_type1              varchar(6) OUTPUT    -- legheader types(1-4)
 * 005 - @lgh_type2              varchar(6) OUTPUT
 * 006 - @lgh_type3              varchar(6) OUTPUT
 * 007 - @lgh_type4              varchar(6) OUTPUT
 * 008 - @mpp_type1              varchar(6) OUTPUT    -- Driver types (1-4)
 * 009 - @mpp_type2              varchar(6) OUTPUT
 * 010 - @mpp_type3              varchar(6) OUTPUT
 * 011 - @mpp_type4              varchar(6) OUTPUT
 * 012 - @mpp_terminal           varchar(6) OUTPUT    -- Driver terminal
 * 013 - @mpp_senioritydate      datetime   OUTPUT
 * 014 - @mpp_company            varchar(6)
 * 015 - @mpp_fleet              varchar(6)
 * 016 - @mpp_division           varchar(6)
 * 017 - @mpp_domicile           varchar(6)
 * 018 - @mpp_teamleader         varchar(6)
 * 019 - @lgh_ratemode           varchar(6)           -- NQIAO 11/18/11 PTS 58978
 * 020 - @lgh_servicelevel       varchar(6)           -- NQIAO 11/18/11 PTS 58978
 * 021 - @lgh_servicedays        int                  -- NQIAO 11/18/11 PTS 58978
 * 022 - @asgn_branch            varchar(12) OUTPUT   -- vjh pts63018
 *
 * REFERENCES:   None
 * REVISION HISTORY:
 * Date        PTS#  AuthorName  Revision Description
 * ----------  ----- ----------  ----------------------------------------------------------------------------------------------------------
 * 10/31/2007  36985 SLM/JDS     Original Code  (PTS 36985 - this part of the code consolidated w/ PTS: 38805 due to PB7 to PB10 cut-over.)
 * 11/28/2007  38805 JDS         Change OR's to AND's
 * 02/22/2008  41535 SGB         Changed @as_driver_id to varchar(8)         Changed @driver1 and @driver2 to varchar(8)
 * 05/15/2009        DJM         Modified to use Driver ID passed in if no driver is found on the Trip.
 * 01/14/2010  47878 vjh         Get Driver 1 terminal from leg mpp_terminal if in use leg mode
 * 01/20/2010  50616 vjh         Get Driver 2 terminal from profile mpp_terminal even if in use leg mode
 * 04/12/2010  50616 vjh         don't override useresourceontrip unless 4 types AND terminal on leg are UNK
 *             54602 LOR         added @mpp_company, @mpp_fleet, @mpp_division, @mpp_domicile, @mpp_teamleader
 * 11/18/2011  58978 NQIAO
 * 03/28/2013  66514 SPN         by default get @mpp_company, @mpp_fleet, @mpp_division, @mpp_domicile, @mpp_teamleader from leg then overwrite if needed
 * 10/26/2012  63018 vjh         add branch
 * 2/18/2013   67360 vjh         correct branch logic for missing assignment value
 * 05/07/2015  90001 SPN         mpp2_types issues fixed
 */

DECLARE @driver1           VARCHAR(8)
DECLARE @driver2           VARCHAR (8)
DECLARE @temp_asgn_branch  VARCHAR(12)

SELECT @driver1 = IsNull(lgh_driver1,'UNKNOWN')
     , @driver2 = isNull(lgh_driver2,'UNKNOWN')
  FROM legheader
 WHERE lgh_number = @ai_lgh_number

-- WHEN @as_resourceTypeOnLeg = Y - retrieve values from legheader.  When N, retrieve values from manpowerprofile.

CREATE TABLE #temp_types
( lgh_type1          varchar(6) NULL
, lgh_type2          varchar(6) NULL
, lgh_type3          varchar(6) NULL
, lgh_type4          varchar(6) NULL
, mpp_type1          varchar(6) NULL
, mpp_type2          varchar(6) NULL
, mpp_type3          varchar(6) NULL
, mpp_type4          varchar(6) NULL
, mpp_terminal       varchar(6) NULL
, mpp_senioritydate  datetime   NULL
, mpp_company        varchar(6) NULL
, mpp_fleet          varchar(6) NULL
, mpp_division       varchar(6) NULL
, mpp_domicile       varchar(6) NULL
, mpp_teamleader     varchar(6) NULL
, lgh_ratemode       varchar(6) NULL        -- NQIAO 11/18/11 PTS 58978
, lgh_servicelevel   varchar(6) NULL        -- NQIAO 11/18/11 PTS 58978
, lgh_servicedays    int        NULL        -- NQIAO 11/18/11 PTS 58978
, asgn_branch      varchar(12) null         --vjh 63018
)


INSERT INTO #temp_types
( lgh_type1
, lgh_type2
, lgh_type3
, lgh_type4
, mpp_type1
, mpp_type2
, mpp_type3
, mpp_type4
, mpp_terminal
, mpp_company
, mpp_fleet
, mpp_division
, mpp_domicile
, mpp_teamleader
, lgh_ratemode
, lgh_servicelevel
, lgh_servicedays
)
SELECT IsNull(lgh_type1, 'UNK')                                                                                AS lgh_type1
     , IsNull(lgh_type2, 'UNK')                                                                                AS lgh_type2
     , IsNull(lgh_type3, 'UNK')                                                                                AS lgh_type3
     , IsNull(lgh_type4, 'UNK')                                                                                AS lgh_type4
     , (CASE WHEN @as_driver_id = @driver2 THEN IsNull(mpp2_type1, 'UNK') ELSE IsNull(mpp_type1, 'UNK') END)   AS mpp_type1
     , (CASE WHEN @as_driver_id = @driver2 THEN IsNull(mpp2_type2, 'UNK') ELSE IsNull(mpp_type2, 'UNK') END)   AS mpp_type2
     , (CASE WHEN @as_driver_id = @driver2 THEN IsNull(mpp2_type3, 'UNK') ELSE IsNull(mpp_type3, 'UNK') END)   AS mpp_type3
     , (CASE WHEN @as_driver_id = @driver2 THEN IsNull(mpp2_type4, 'UNK') ELSE IsNull(mpp_type4, 'UNK') END)   AS mpp_type4
     , (CASE WHEN @as_driver_id = @driver1 THEN mpp_terminal ELSE 'UNK' END)                                   AS mpp_terminal
     , IsNull(mpp_company, 'UNK')                                                                              AS mpp_company
     , IsNull(mpp_fleet, 'UNK')                                                                                AS mpp_fleet
     , IsNull(mpp_division, 'UNK')                                                                             AS mpp_division
     , IsNull(mpp_domicile, 'UNK')                                                                             AS mpp_domicile
     , IsNull(mpp_teamleader, 'UNK')                                                                           AS mpp_teamleader
     , lgh_ratemode                                                                                            AS lgh_ratemode
     , lgh_servicelevel                                                                                        AS lgh_servicelevel
     , lgh_servicedays                                                                                         AS lgh_servicedays
  FROM legheader
 WHERE lgh_number = @ai_lgh_number

UPDATE #temp_types
   SET mpp_senioritydate = (SELECT IsNull(mpp_senioritydate, mpp_hiredate)
                              FROM manpowerprofile
                             WHERE mpp_id = @as_driver_id
                           )

--Resource Type On Leg, so default to Profile.
IF @as_resourceTypeOnLeg = 'N'
BEGIN
   UPDATE #temp_types
      SET mpp_type1        = m.mpp_type1
        , mpp_type2        = m.mpp_type2
        , mpp_type3        = m.mpp_type3
        , mpp_type4        = m.mpp_type4
        , mpp_terminal     = m.mpp_terminal
        , mpp_company      = m.mpp_company
        , mpp_fleet        = m.mpp_fleet
        , mpp_division     = m.mpp_division
        , mpp_domicile     = m.mpp_domicile
        , mpp_teamleader   = m.mpp_teamleader
     FROM manpowerprofile m
    WHERE m.mpp_id = @as_driver_id
END

--Although Resource Type On Leg but default to Profile when all Empty
IF @as_resourceTypeOnLeg = 'Y'
BEGIN
   IF (SELECT mpp_type1 FROM #temp_types )      = 'UNK' AND
      (SELECT mpp_type2 FROM #temp_types )      = 'UNK' AND
      (SELECT mpp_type3 FROM #temp_types )      = 'UNK' AND
      (SELECT mpp_type4 FROM #temp_types )      = 'UNK' AND
      (SELECT mpp_terminal FROM #temp_types )   = 'UNK' AND
      (SELECT mpp_company FROM #temp_types )    = 'UNK' AND
      (SELECT mpp_fleet FROM #temp_types )      = 'UNK' AND
      (SELECT mpp_division FROM #temp_types )   = 'UNK' AND
      (SELECT mpp_domicile FROM #temp_types )   = 'UNK' AND
      (SELECT mpp_teamleader FROM #temp_types ) = 'UNK'
   BEGIN
      UPDATE #temp_types
         SET mpp_type1        = m.mpp_type1
           , mpp_type2        = m.mpp_type2
           , mpp_type3        = m.mpp_type3
           , mpp_type4        = m.mpp_type4
           , mpp_terminal     = m.mpp_terminal
           , mpp_company      = m.mpp_company
           , mpp_fleet        = m.mpp_fleet
           , mpp_division     = m.mpp_division
           , mpp_domicile     = m.mpp_domicile
           , mpp_teamleader   = m.mpp_teamleader
        FROM manpowerprofile m
       WHERE m.mpp_id = @as_driver_id
   END
END

--Always read following properties from manpowerprofile for co-driver because they don't exist in legheader
IF @as_driver_id = @driver2
BEGIN
   UPDATE #temp_types
      SET mpp_terminal     = m.mpp_terminal
        , mpp_company      = m.mpp_company
        , mpp_fleet        = m.mpp_fleet
        , mpp_division     = m.mpp_division
        , mpp_domicile     = m.mpp_domicile
        , mpp_teamleader   = m.mpp_teamleader
     FROM manpowerprofile m
    WHERE m.mpp_id = @as_driver_id
END


--vjh 63018
IF  @as_resourceTypeOnLeg = 'Y'
   SELECT @temp_asgn_branch = aa.asgn_branch
     FROM assetassignment aa
    WHERE aa.asgn_type='DRV'
      AND aa.asgn_id = @as_driver_id
      AND aa.lgh_number = @ai_lgh_number

IF @temp_asgn_branch IS NULL
   SELECT @temp_asgn_branch = mpp_branch
     FROM manpowerprofile
    WHERE mpp_id = @as_driver_id

UPDATE #temp_types
   SET asgn_branch = @temp_asgn_branch


------ Return Output:

SELECT @lgh_type1          = t.lgh_type1
     , @lgh_type2          = t.lgh_type2
     , @lgh_type3          = t.lgh_type3
     , @lgh_type4          = t.lgh_type4
     , @mpp_type1          = t.mpp_type1
     , @mpp_type2          = t.mpp_type2
     , @mpp_type3          = t.mpp_type3
     , @mpp_type4          = t.mpp_type4
     , @mpp_terminal       = t.mpp_terminal
     , @mpp_senioritydate  = t.mpp_senioritydate
     , @mpp_company        = t.mpp_company
     , @mpp_fleet          = t.mpp_fleet
     , @mpp_division       = t.mpp_division
     , @mpp_domicile       = t.mpp_domicile
     , @mpp_teamleader     = t.mpp_teamleader
     , @lgh_ratemode       = t.lgh_ratemode         -- NQIAO 11/18/11 PTS 58978
     , @lgh_servicelevel   = t.lgh_servicelevel     -- NQIAO 11/18/11 PTS 58978
     , @lgh_servicedays    = t.lgh_servicedays      -- NQIAO 11/18/11 PTS 58978
     , @asgn_branch        = t.asgn_branch          -- vjh 63018
  FROM #temp_types t

GO
GRANT EXECUTE ON  [dbo].[get_lgh_mpp2_sp] TO [public]
GO

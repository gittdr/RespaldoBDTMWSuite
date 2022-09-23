SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_AssetCards] @ASGN_TYPE      VARCHAR(10),
                                        @KEYWORDSEARCH  VARCHAR(250),
                                        @PAGESIZE       INT,
                                        @PAGEINDEX      INT,
                                        @PAYHISTORYDAYS INT
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search for asset cards

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/19/2017   Chip Ciminero    WE-207809   Created
  10/09/2017   Chase Plante     WE-211090   Modified proc to trim any string data
*******************************************************************************************************************/

     --SP PARAMS / TEST DATA
     --VALID ASGN_TYPE'S ARE DRV, CAR, TRL, TRC
     --DECLARE @ASGN_TYPE VARCHAR(10), @KEYWORDSEARCH VARCHAR(250),@PAGESIZE INT, @PAGEINDEX INT, @PAYHISTORYDAYS INT
     --SELECT @ASGN_TYPE ='DRV', @KEYWORDSEARCH = 'GRARON', @PAGESIZE = 10, @PAGEINDEX = 1, @PAYHISTORYDAYS = 200

     DECLARE @DATA TABLE (ID VARCHAR(30), RowNum INT);
     DECLARE @ACTUALDATA TABLE (ID VARCHAR(30), RowNum INT, TotalRows INT);
     DECLARE @CHECKCALLDATA TABLE (AsgnType VARCHAR(10), AsgnId VARCHAR(30), Number INT, Date DATETIME, CityName VARCHAR(250), State CHAR(2), Latitude INT, Longitude INT);
     DECLARE @LASTPAYDATA TABLE (AsgnType VARCHAR(10), AsgnId VARCHAR(30), Number INT, Date DATETIME, Amount MONEY);
     DECLARE @HISTORYPAYDATA TABLE (AsgnType VARCHAR(10), AsgnId VARCHAR(30), Amount MONEY);
     DECLARE @LEGDATA TABLE (AsgnType VARCHAR(10), AsgnId VARCHAR(30), LegNumber INT);

     IF @ASGN_TYPE = 'DRV'
         BEGIN
             INSERT INTO @DATA
                    SELECT M.mpp_id 'ID', ROW_NUMBER() OVER(ORDER BY M.mpp_id) AS RowNum
                    FROM manpowerprofile M WITH (NOLOCK)
                    WHERE LTRIM(M.mpp_id) LIKE @KEYWORDSEARCH + '%'
                       OR LTRIM(M.mpp_firstname) LIKE @KEYWORDSEARCH + '%'
                       OR LTRIM(M.mpp_lastname) LIKE @KEYWORDSEARCH + '%';
         END;
     ELSE
     IF @ASGN_TYPE = 'TRC'
         BEGIN
             INSERT INTO @DATA
                    SELECT T.trc_number 'ID', ROW_NUMBER() OVER(ORDER BY T.trc_number) AS RowNum
                    FROM tractorprofile T WITH (NOLOCK)
                    WHERE LTRIM(T.trc_number) LIKE @KEYWORDSEARCH + '%';
         END;
     ELSE
     IF @ASGN_TYPE = 'CAR'
         BEGIN
             INSERT INTO @DATA
                    SELECT C.car_id 'ID', ROW_NUMBER() OVER(ORDER BY C.car_id) AS RowNum
                    FROM carrier C WITH (NOLOCK)
                    WHERE LTRIM(C.car_id) LIKE @KEYWORDSEARCH + '%'
                       OR LTRIM(C.car_name) LIKE @KEYWORDSEARCH + '%';
         END;
     ELSE
     IF @ASGN_TYPE = 'TRL'
         BEGIN
             INSERT INTO @DATA
                    SELECT T.trl_number 'ID', ROW_NUMBER() OVER(ORDER BY T.trl_number) AS RowNum
                    FROM trailerprofile T WITH (NOLOCK)
                    WHERE LTRIM(T.trl_number) LIKE @KEYWORDSEARCH + '%';
         END;
     INSERT INTO @ACTUALDATA
            SELECT *
            FROM (SELECT *, TotalRows = COUNT(*) OVER() FROM @DATA) A
            WHERE RowNum > +@PAGESIZE * (@PAGEINDEX - 1)
              AND RowNum <= @PAGESIZE * @PAGEINDEX;
     INSERT INTO @CHECKCALLDATA
            SELECT ckc_asgntype 'AsgnType',
                   LTRIM(ckc_asgnid) 'AsgnId',
                   ckc_number 'Number',
                   ckc_date 'Date',
                   LTRIM(CI.cty_name) 'CityName',
                   LTRIM(RTRIM(CI.cty_state)) 'State',
                   COALESCE(ckc_latseconds, '') 'Latitude',
                   COALESCE(ckc_longseconds, '') 'Longitude'
            FROM
            (
                SELECT ckc_asgntype,
                       ckc_asgnid,
                       ckc_number,
                       ckc_date,
                       ckc_city,
                       ckc_latseconds,
                       ckc_longseconds,
                       ROW_NUMBER() OVER(PARTITION BY ckc_asgnid ORDER BY ckc_date DESC) AS rn
                FROM checkcall C WITH (NOLOCK)
                     INNER JOIN @ACTUALDATA D ON C.ckc_asgnid = D.ID
                WHERE ckc_asgntype = @ASGN_TYPE
            ) A
            LEFT OUTER JOIN city CI ON A.ckc_city = CI.cty_code
            WHERE rn = 1;
     INSERT INTO @LASTPAYDATA
            SELECT asgn_type 'AsgnType',
                   LTRIM(asgn_id) 'AsgnId',
                   pyd_number 'Number',
                   pyd_transdate 'Date',
                   pyd_amount 'Amount'
            FROM
            (
                SELECT asgn_id,
                       asgn_type,
                       PD.pyd_number,
                       PD.pyd_transdate,
                       PD.pyd_amount,
                       ROW_NUMBER() OVER(PARTITION BY asgn_id ORDER BY pyd_transdate DESC) AS rn
                FROM paydetail PD WITH (NOLOCK)
                     INNER JOIN paytype PT WITH (NOLOCK) ON PD.pyt_itemcode = PT.pyt_itemcode
                     INNER JOIN @ACTUALDATA A ON PD.asgn_id = A.ID
                WHERE PYT_FSERVPROCESS IN('A', 'I', 'H', 'M', 'E')
                     AND PD.asgn_type = @ASGN_TYPE
            ) AS T
            WHERE rn = 1;
     INSERT INTO @HISTORYPAYDATA
            SELECT asgn_type 'AsgnType',
                   LTRIM(asgn_id) 'AsgnId',
                   pyd_amount 'Amount'
            FROM
            (
                SELECT asgn_id,
                       asgn_type,
                       SUM(PD.pyd_amount) 'pyd_amount'
                FROM paydetail PD WITH (NOLOCK)
                     INNER JOIN paytype PT WITH (NOLOCK) ON PD.pyt_itemcode = PT.pyt_itemcode
                     INNER JOIN @ACTUALDATA A ON PD.asgn_id = A.ID
                WHERE PYT_FSERVPROCESS IN('A', 'I', 'H', 'M', 'E')
                     AND PD.asgn_type = @ASGN_TYPE
                     AND pyd_transdate >= DATEADD(day, (@PAYHISTORYDAYS * -1), GETDATE()) -- TODO NEEDS TO BE UPDATED TO 4 DAYS
                GROUP BY asgn_id,
                         asgn_type
            ) AS T;
     INSERT INTO @LEGDATA
            SELECT AsgnType,
                   LTRIM(AsgnId),
                   LegNumber
            FROM
            (
                SELECT @ASGN_TYPE 'AsgnType',
                       AsgnId,
                       LegNumber,
                       ROW_NUMBER() OVER(PARTITION BY AsgnId ORDER BY StartDate DESC) AS rn
                FROM
                (
                    SELECT L.lgh_number 'LegNumber',
                           asgn_id 'AsgnId',
                           L.asgn_date 'StartDate'
                    FROM assetassignment L WITH (NOLOCK)
                         INNER JOIN @ACTUALDATA A ON L.asgn_id = A.ID
                    WHERE L.asgn_status IN('STD', 'DSP')
                ) B
            ) C
            WHERE rn = 1;
     IF @ASGN_TYPE = 'DRV'
         BEGIN
             SELECT LTRIM(M.mpp_id) 'ID',
                    LTRIM(COALESCE(M.mpp_firstname, '')) 'FirstName',
                    LTRIM(COALESCE(M.mpp_lastname, '')) 'LastName',
                    COALESCE(LTRIM(RTRIM(M.mpp_currentphone)), '') 'CurrentPhone',
                    COALESCE(C.Number, 0) 'LastCheckCallNumber',
                    COALESCE(C.CityName, '') 'LastCheckCallCityName',
                    COALESCE(C.State, '') 'LastCheckCallState',
                    C.Date 'LastCheckCallDate',
                    COALESCE(c.Latitude, 0) 'LastCheckCallLatitude',
                    COALESCE(c.Longitude, 0) 'LastCheckCallLongitude',
                    COALESCE(LP.Number, 0) 'LastAdvanceNumber',
                    LP.Date 'LastAdvanceDate',
                    COALESCE(LP.Amount, 0) 'LastAdvanceAmount',
                    COALESCE(HP.Amount, 0) 'PastAdvancesAmount',
                    COALESCE(L.LegNumber, 0) 'LegNumber'
             FROM manpowerprofile M WITH (NOLOCK)
                  INNER JOIN @ACTUALDATA A ON M.mpp_id = A.ID
                  LEFT OUTER JOIN @CHECKCALLDATA C ON A.ID = C.AsgnId
                  LEFT OUTER JOIN @LASTPAYDATA LP ON A.ID = LP.AsgnId
                  LEFT OUTER JOIN @HISTORYPAYDATA HP ON A.ID = HP.AsgnId
                  LEFT OUTER JOIN @LEGDATA L ON A.ID = L.AsgnId;
         END;
     ELSE
     IF @ASGN_TYPE = 'TRC'
         BEGIN
             SELECT LTRIM(T.trc_number) 'ID',
                    LTRIM(COALESCE(M.mpp_firstname, '')) 'DriverFirstName',
                    LTRIM(COALESCE(M.mpp_lastname, '')) 'DriverLastName',
                    COALESCE(LTRIM(RTRIM(M.mpp_currentphone)), '') 'DriverCurrentPhone',
                    COALESCE(C.Number, 0) 'LastCheckCallNumber',
                    COALESCE(C.CityName, '') 'LastCheckCallCityName',
                    COALESCE(C.State, '') 'LastCheckCallState',
                    C.Date 'LastCheckCallDate',
                    COALESCE(c.Latitude, 0) 'LastCheckCallLatitude',
                    COALESCE(c.Longitude, 0) 'LastCheckCallLongitude',
                    COALESCE(LP.Number, 0) 'LastAdvanceNumber',
                    LP.Date 'LastAdvanceDate',
                    COALESCE(LP.Amount, 0) 'LastAdvanceAmount',
                    COALESCE(HP.Amount, 0) 'PastAdvancesAmount',
                    COALESCE(L.LegNumber, 0) 'LegNumber'
             FROM tractorprofile T WITH (NOLOCK)
                  INNER JOIN @ACTUALDATA A ON T.trc_number = A.ID
                  LEFT OUTER JOIN manpowerprofile M WITH (NOLOCK) ON T.trc_driver = m.mpp_id
                  LEFT OUTER JOIN @CHECKCALLDATA C ON A.ID = C.AsgnId
                  LEFT OUTER JOIN @LASTPAYDATA LP ON A.ID = LP.AsgnId
                  LEFT OUTER JOIN @HISTORYPAYDATA HP ON A.ID = HP.AsgnId
                  LEFT OUTER JOIN @LEGDATA L ON A.ID = L.AsgnId;
         END;
     ELSE
     IF @ASGN_TYPE = 'CAR'
         BEGIN
             SELECT LTRIM(M.car_id) 'ID',
                    LTRIM(M.car_name) 'Name',
                    LTRIM(COALESCE(M.car_phone1, '')) 'Phone1',
                    COALESCE(C.Number, 0) 'LastCheckCallNumber',
                    COALESCE(C.CityName, '') 'LastCheckCallCityName',
                    COALESCE(C.State, '') 'LastCheckCallState',
                    C.Date 'LastCheckCallDate',
                    COALESCE(c.Latitude, 0) 'LastCheckCallLatitude',
                    COALESCE(c.Longitude, 0) 'LastCheckCallLongitude',
                    COALESCE(LP.Number, 0) 'LastAdvanceNumber',
                    LP.Date 'LastAdvanceDate',
                    COALESCE(LP.Amount, 0) 'LastAdvanceAmount',
                    COALESCE(HP.Amount, 0) 'PastAdvancesAmount',
                    COALESCE(Y.ActiveLegs, 0) 'ActiveLegs'
             FROM Carrier M WITH (NOLOCK)
                  INNER JOIN @ACTUALDATA A ON M.car_id = A.ID
                  LEFT OUTER JOIN @CHECKCALLDATA C ON A.ID = C.AsgnId
                  LEFT OUTER JOIN @LASTPAYDATA LP ON A.ID = LP.AsgnId
                  LEFT OUTER JOIN @HISTORYPAYDATA HP ON A.ID = HP.AsgnId
                  LEFT OUTER JOIN
             (
                 SELECT X.ID,
                        COUNT(DISTINCT lgh_number) 'ActiveLegs'
                 FROM @ACTUALDATA X
                      INNER JOIN legheader_active L WITH (NOLOCK) ON X.ID = L.lgh_carrier
                 GROUP BY X.ID
             ) Y ON A.ID = Y.ID;
         END;
     ELSE
     IF @ASGN_TYPE = 'TRL'
         BEGIN
             SELECT LTRIM(T.trl_number) 'ID',
                    COALESCE(C.Number, 0) 'LastCheckCallNumber',
                    COALESCE(C.CityName, '') 'LastCheckCallCityName',
                    COALESCE(C.State, '') 'LastCheckCallState',
                    C.Date 'LastCheckCallDate',
                    COALESCE(c.Latitude, 0) 'LastCheckCallLatitude',
                    COALESCE(c.Longitude, 0) 'LastCheckCallLongitude',
                    COALESCE(LP.Number, 0) 'LastAdvanceNumber',
                    LP.Date 'LastAdvanceDate',
                    COALESCE(LP.Amount, 0) 'LastAdvanceAmount',
                    COALESCE(HP.Amount, 0) 'PastAdvancesAmount',
                    COALESCE(L.LegNumber, 0) 'LegNumber'
             FROM trailerprofile T WITH (NOLOCK)
                  INNER JOIN @ACTUALDATA A ON T.trl_number = A.ID
                  LEFT OUTER JOIN @CHECKCALLDATA C ON A.ID = C.AsgnId
                  LEFT OUTER JOIN @LASTPAYDATA LP ON A.ID = LP.AsgnId
                  LEFT OUTER JOIN @HISTORYPAYDATA HP ON A.ID = HP.AsgnId
                  LEFT OUTER JOIN @LEGDATA L ON A.ID = L.AsgnId;
         END;
GO
GRANT EXECUTE ON  [dbo].[SearchAPI_AssetCards] TO [public]
GO

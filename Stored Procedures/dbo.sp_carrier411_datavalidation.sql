SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411_datavalidation]
( @messagetext VARCHAR(4000) OUTPUT
)
AS
/**
 *
 * NAME:
 * dbo.sp_carrier411_datavalidation
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for validating Carrier411 setup
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * 001 @messagetext  VARCHAR(100) OUTPUT
 *
 * REVISION HISTORY:
 * PTS 62931 SPN 05/11/12 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @msg            VARCHAR(500)
   DECLARE @count          INT
   DECLARE @id             INT

   DECLARE @gi_name        VARCHAR(30)
   DECLARE @abbr           VARCHAR(6)
   DECLARE @lbl_exp        CHAR(1)
   DECLARE @exp_retired    CHAR(1)
   DECLARE @exp_code       INT
   DECLARE @lbl_status     CHAR(1)
   DECLARE @status_retired CHAR(1)
   DECLARE @status_code    INT

   DECLARE @car_id         VARCHAR(8)
   DECLARE @docket         VARCHAR(12)

   DECLARE @temp_gi TABLE
   ( id              INT IDENTITY   NOT NULL
   , gi_name         VARCHAR(30)    NOT NULL
   , abbr            VARCHAR(6)     NULL
   , lbl_exp         CHAR(1)        NULL
   , exp_retired     CHAR(1)        NULL
   , exp_code        INT            NULL
   , lbl_status      CHAR(1)        NULL
   , status_retired  CHAR(1)        NULL
   , status_code     INT            NULL
   , PRIMARY KEY CLUSTERED (id)
   )

   DECLARE @temp_docket01 TABLE
   ( id              INT IDENTITY   NOT NULL
   , car_id          VARCHAR(8)     NOT NULL
   , docket          VARCHAR(12)    NOT NULL
   , PRIMARY KEY CLUSTERED (id)
   )
   DECLARE @temp_docket02 TABLE
   ( id              INT IDENTITY   NOT NULL
   , car_id          VARCHAR(8)     NOT NULL
   , docket          VARCHAR(12)    NOT NULL
   , PRIMARY KEY CLUSTERED (id)
   )

   SELECT @messagetext = ''

   --Validate GI and LabelFile Entries for Carrier Expiration and Status
   INSERT INTO @temp_gi
   ( gi_name
   , abbr
   , lbl_exp
   , exp_retired
   , exp_code
   , lbl_status
   , status_retired
   , status_code
   )
   SELECT gi.gi_name    AS gi_name
        , gi.abbr       AS abbr
        , (CASE IsNull(ex.name,'IsNull') WHEN 'IsNull' THEN 'N' ELSE 'Y' END) AS lbl_exp
        , ex.Retired    AS exp_retired
        , ex.code       AS exp_code
        , (CASE IsNull(st.name,'IsNull') WHEN 'IsNull' THEN 'N' ELSE 'Y' END) AS lbl_exp
        , st.Retired    AS status_retired
        , st.code       AS status_code
     FROM ( SELECT gi_name                            AS gi_name
                 , substring(LTRIM(gi_string2),1,6)   AS abbr
              FROM generalinfo
             WHERE gi_name IN ('Carrier411OverallExpiration','Carrier411AuthExpiration','Carrier411InsuranceExpiration',
                               'Carrier411SafetyExpiration','Carrier411smsOverallExpiration','Carrier411smsCSAExpiration',
                               'Carrier411smsFatigueExpiration','Carrier411smsFitnessExpiration','Carrier411smsUnsafeExpiration',
                               'Carrier411smsVehicleExpiration','Carrier411smsCargoExpiration'
                              )
               AND IsNull(substring(LTRIM(gi_string1),1,1),'N') = 'Y'
          ) gi
   LEFT OUTER JOIN ( SELECT name                AS name
                          , abbr                AS abbr
                          , IsNull(code,0)      AS code
                          , IsNull(Retired,'N') AS Retired
                       FROM labelfile
                      WHERE labeldefinition = 'CarExp'
                   ) ex ON gi.abbr = ex.abbr
   LEFT OUTER JOIN ( SELECT name                AS name
                          , abbr                AS abbr
                          , IsNull(code,0)      AS code
                          , IsNull(Retired,'N') AS Retired
                      FROM labelfile
                     WHERE labeldefinition = 'CarStatus'
                   ) st ON gi.abbr = st.abbr
   SELECT @count = @@ROWCOUNT

   SELECT @id = 0
   WHILE @id < @count
   BEGIN
      SELECT @msg = ''
      SELECT @id = @id + 1

      SELECT @gi_name         = gi_name
           , @abbr            = abbr
           , @lbl_exp         = lbl_exp
           , @exp_retired     = exp_retired
           , @exp_code        = exp_code
           , @lbl_status      = lbl_status
           , @status_retired  = status_retired
           , @status_code     = status_code
        FROM @temp_gi
       WHERE id = @id

      BEGIN
         IF @abbr IS NULL
            SELECT @msg = @msg + 'No Expiration code defined.  '
         ELSE
            BEGIN
               IF @lbl_exp = 'N'
                  SELECT @msg = @msg + 'No matching LabelFile CarExp found for ' + @abbr + '.  '
               ELSE
                  IF @exp_retired = 'Y'
                     SELECT @msg = @msg + 'LabelFile CarExp(' + @abbr + ') is currently Retired.  '

               IF @lbl_status = 'N'
                  SELECT @msg = @msg + 'No matching LabelFile CarStatus found for ' + @abbr + '.  '
               ELSE
                  IF @status_retired = 'Y'
                     SELECT @msg = @msg + 'LabelFile CarStatus(' + @abbr + ') is currently Retired.  '

               IF @lbl_exp = 'Y' AND @exp_retired = 'N' AND @lbl_status = 'Y' AND @status_retired = 'N'
                  IF @exp_code <> @status_code
                     SELECT @msg = @msg + 'LabelFile CarExp and CarStatus (' + @abbr + ') currently using two different codes (' + convert(varchar,@exp_code) + ' vs ' + convert(varchar,@status_code) + ')'
            END

         IF @msg <> ''
         BEGIN
            IF @messagetext = ''
               SELECT @messagetext = '*** GeneralInfo and LabelFile: ' + CHAR(13)

            SELECT @msg = @gi_name + ': ' + @msg
            SELECT @messagetext = @messagetext + @msg + CHAR(13)
         END

      END

   END
   --LOOP
   IF @messagetext <> ''
      SELECT @messagetext = @messagetext + CHAR(13)


   --Validate docket numbers in Carrier profile
   INSERT INTO @temp_docket01
   ( car_id
   , docket
   )
   SELECT car_id
        , car_iccnum
     FROM carrier
    WHERE car_iccnum IS NOT NULL
      AND LEN(car_iccnum) <> 8
   SELECT @count = @@ROWCOUNT

   SELECT @msg = ''
   SELECT @id = 0
   WHILE @id < @count
   BEGIN
      SELECT @id = @id + 1

      SELECT @car_id = car_id
           , @docket = docket
        FROM @temp_docket01
       WHERE id = @id
      SELECT @msg = @msg + @car_id + '(' + @docket + ')'
      IF @id < @count
         SELECT @msg = @msg + ', '
   END
   --LOOP
   IF @msg <> ''
      SELECT @messagetext = @messagetext + '*** Docket# length not 8 character: ' + CHAR(13) + @msg + CHAR(13) + CHAR(13)

   INSERT INTO @temp_docket02
   ( car_id
   , docket
   )
   SELECT car_id
        , car_iccnum
     FROM carrier
    WHERE car_iccnum IS NOT NULL
      AND LEN(car_iccnum) = 8
      AND SUBSTRING(car_iccnum,1,2) NOT IN ('MC','FF','MX')
   SELECT @count = @@ROWCOUNT

   SELECT @msg = ''
   SELECT @id = 0
   WHILE @id < @count
   BEGIN
      SELECT @id = @id + 1

      SELECT @car_id = car_id
           , @docket = docket
        FROM @temp_docket02
       WHERE id = @id
      SELECT @msg = @msg + @car_id + '(' + @docket + ')'
      IF @id < @count
         SELECT @msg = @msg + ', '
   END
   --LOOP
   IF @msg <> ''
      SELECT @messagetext = @messagetext + '*** Invalid format in Docket#: ' + CHAR(13) + @msg + CHAR(13) + CHAR(13)

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411_datavalidation] TO [public]
GO

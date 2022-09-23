SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadrecidbymanpowerprofile_with_inactive_sp]
(
  @rec      VARCHAR(40)
, @number   INT
)
AS

/**
 *
 * NAME:
 * dbo.d_loadrecidbymanpowerprofile_with_inactive_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure populates the recruit displayname field on w_recruitfolder.
 * It follows instant best match rules.
 *
 * RETURNS:
 * IsNull(recruitheader.rec_lastname, '') + ', ' + IsNull(recruitheader.rec_firstname, '') + ' (' + manpowerprofile.mpp_id + ')'
 *
 * RESULT SETS:
 * NONE
 *
 * PARAMETERS:
 * @rec      VARCHAR(40)
 * @number   INT
 *
 * REVISION HISTORY:
 * 08/06/2013 PTS69509 - SPN - Created Initial Version
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @Temp TABLE
   ( rec_displayname VARCHAR(100)
   )

   DECLARE @daysout  int
   DECLARE @date     datetime

   SELECT @daysout = -90

   IF EXISTS ( SELECT lbp_id
                 FROM ListBoxProperty
                WHERE lbp_id = @@spid
             )
      SELECT @daysout = lbp_daysout
           , @date = lbp_date
        FROM ListBoxProperty
       WHERE lbp_id = @@spid
   ELSE
      SELECT @daysout = gi_integer1
           , @date = gi_date1
        FROM generalinfo
       WHERE gi_name = 'GRACE'

   IF @daysout <> 999
      SELECT @date = dateadd (day, @daysout, getdate())

   IF @number = 1
      SET rowcount 1
   ELSE IF @number <= 8
      SET rowcount 8
   ELSE IF @number <= 16
      SET rowcount 16
   ELSE IF @number <= 24
      SET rowcount 24
   ELSE
      SET rowcount 8

   INSERT INTO @Temp
   ( rec_displayname
   )
   SELECT LEFT(IsNull(r.rec_lastname, '') + ', ' + IsNull(r.rec_firstname, '') + ' <' + IsNull(m.mpp_id,' ') + '>' + REPLICATE(' ',100), 84) + 'Seq#(' + CAST(r.rec_id AS VARCHAR(9)) + ')'
     FROM recruitheader r
     LEFT OUTER JOIN manpowerprofile m ON r.rec_id = m.rec_id
    WHERE rec_displayname LIKE @rec + '%'

   IF NOT EXISTS ( SELECT 1 FROM @Temp )
      INSERT INTO @Temp
      ( rec_displayname
      )
      VALUES
      (
      'Unknown'
      )


   SELECT rec_displayname
     FROM @Temp
   ORDER BY rec_displayname

END
GO
GRANT EXECUTE ON  [dbo].[d_loadrecidbymanpowerprofile_with_inactive_sp] TO [public]
GO

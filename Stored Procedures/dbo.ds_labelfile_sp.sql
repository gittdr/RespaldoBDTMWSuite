SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_labelfile_sp]
( @name                 VARCHAR(20)
, @retired              CHAR(1)     = NULL
, @RowSecurityOverride  CHAR(1)     = NULL
) AS

/**
 *
 * NAME:
 * dbo.ds_labelfile_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for selecting rows from labelfile table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @name                 VARCHAR(20)
 * @retired              CHAR(1)     = NULL
 * @RowSecurityOverride  CHAR(1)     = NULL
 *
 * REVISION HISTORY:
 * PTS 62530 SPN Created 06/22/12
 *
 **/

SET NOCOUNT ON

BEGIN

   IF @retired IS NULL
      SELECT @retired = 'Y'

   IF @RowSecurityOverride IS NULL
      SELECT @RowSecurityOverride = 'Y'

   IF @name IS NULL OR @name = ''
      BEGIN
         SELECT name
              , abbr
              , code
           FROM labelfile
          WHERE labeldefinition IS NULL
         ORDER BY name
         RETURN
      END

   --************--
   --** Select **--
   --************--
   EXEC dbo.load_label_bystatus_withrowsecurityoverride_sp @name, @retired, @RowSecurityOverride

END
GO
GRANT EXECUTE ON  [dbo].[ds_labelfile_sp] TO [public]
GO

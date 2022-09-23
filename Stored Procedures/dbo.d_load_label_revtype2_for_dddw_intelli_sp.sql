SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_load_label_revtype2_for_dddw_intelli_sp]
( @revtype1 VARCHAR(6)
) AS
/**
 *
 * NAME:
 * dbo.d_load_label_revtype2_for_dddw_intelli_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow d_load_cmdid_for_dddw_intelli
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @revtype1  VARCHAR(6)
 *
 * REVISION HISTORY:
 * PTS 69510 SPN 08/01/13 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN


   DECLARE @temp TABLE
   ( name   VARCHAR(20) NULL
   , abbr   VARCHAR(6)  NULL
   , code   INT         NULL
   )

   DECLARE @Restrict2Parent CHAR(1)

   SELECT @Restrict2Parent = 'Y'

   INSERT INTO @temp
   EXEC dbo.load_label_sp @name = 'RevType2'

   IF @Restrict2Parent = 'Y'
      BEGIN
         DELETE FROM @temp
          WHERE abbr <> 'UNK'
            AND abbr NOT IN (SELECT DISTINCT
                                    rtr.rtr_revtype2
                               FROM revtyperelation rtr
                              WHERE (rtr.rtr_revtype1 = IsNull(@revtype1,'UNK'))
                            )
      END
   ELSE
      BEGIN
         DELETE FROM @temp
          WHERE abbr <> 'UNK'
            AND abbr NOT IN (SELECT DISTINCT
                                    rtr.rtr_revtype2
                               FROM revtyperelation rtr
                              WHERE (rtr.rtr_revtype1 = IsNull(@revtype1,'UNK') OR @revtype1 IN ('UNK','UNKNOWN'))
                            )
      END

   SELECT *
     FROM @temp t

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[d_load_label_revtype2_for_dddw_intelli_sp] TO [public]
GO

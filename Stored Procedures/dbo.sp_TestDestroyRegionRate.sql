SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_TestDestroyRegionRate]
( @tar_number  INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_TestDestroyRegionRate
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for Deleting Region based Row/Column rate
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @tar_number  INT
 *
 * REVISION HISTORY:
 * PTS 63568 SPN Created 03/11/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   --Delete Row/Col Rate
   DELETE FROM tariffrate
    WHERE tar_number = @tar_number

   --Delete Row/Col Def
   DELETE FROM tariffrowcolumn
    WHERE tar_number = @tar_number

   --Delete Index
   DELETE FROM tariffkey
    WHERE tar_number = @tar_number

   --Delete Tariff
   DELETE FROM tariffheader
   WHERE tar_number = @tar_number

END
GO
GRANT EXECUTE ON  [dbo].[sp_TestDestroyRegionRate] TO [public]
GO

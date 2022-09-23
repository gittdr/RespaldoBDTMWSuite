SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_manpowerprofile_sp]
AS

/**
 *
 * NAME:
 * dbo.ds_manpowerprofile_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for selecting rows from manpowerprofile table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 *
 * REVISION HISTORY:
 * PTS 63639 SPN Created 08/16/2012
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @v_string1 char(1)
   DECLARE @v_string2 char(1)
   DECLARE @v_string3 char(1)
   DECLARE @v_string4 char(1)

   SELECT @v_string1 = isnull(gi_string1,'N')
        , @v_string2 = isnull(gi_string2,'N')
        , @v_string3 = isnull(gi_string3,'N')
        , @v_string4 = isnull(gi_string4,'N')
     FROM generalinfo
    WHERE gi_name = 'driverdropdowncontrol'

   SELECT mpp_id + ' ' + mpp_lastfirst AS mpp_lastfirst
        , mpp_id
        , mpp_otherid
        , RTRIM( CASE @v_string1 WHEN 'Y' THEN mpp_type1 + ' ' ELSE '' END +
                 CASE @v_string2 WHEN 'Y' THEN mpp_type2 + ' ' ELSE '' END +
                 CASE @v_string3 WHEN 'Y' THEN mpp_type3 + ' ' ELSE '' END +
                 CASE @v_string4 WHEN 'Y' THEN mpp_type4       ELSE '' END
               ) AS drivertypes
     FROM manpowerprofile
   ORDER BY mpp_id

END
GO
GRANT EXECUTE ON  [dbo].[ds_manpowerprofile_sp] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[dddw_profile_owner_ids_sp]
AS

/*
*
*
* NAME:
* dbo.dddw_profile_owner_ids_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to list PayTos
*
* PARAMETERS:
*
* RETURNS:
*
* NOTHING:
*
* 01/08/2013 PTS66469 SPN - Created Initial Version
*
*/

BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


CREATE TABLE #temp
( owner_id varchar(12)
, driver varchar(10)
, tractor varchar(10)
, trailer varchar(10)
, carrier varchar(10)
, thirdparty varchar(10)
)

--UNK
INSERT #temp(owner_id, driver)
VALUES ('UNK', 'All, ')

   IF EXISTS (SELECT 1
                FROM generalinfo
               WHERE gi_name = 'STL_RestrictByPTO'
                 AND IsNull(gi_string1,'N') = 'Y'
             )
   BEGIN

      --Driver
      INSERT #temp(owner_id, driver)
      SELECT mpp_payto, 'Driver, '
        FROM dbo.manpowerprofile
       WHERE mpp_payto IS NOT NULL
         AND mpp_payto <> 'UNKNOWN'
      GROUP BY mpp_payto

      --Tractor
      UPDATE #temp
         SET tractor = 'Tractor, '
        FROM #temp t
        INNER JOIN (SELECT trc_owner
                      FROM dbo.tractorprofile
                    GROUP BY trc_owner
                   ) AS tp ON t.owner_id = tp.trc_owner

      INSERT #temp (owner_id, tractor)
      SELECT trc_owner, 'Tractor, '
        FROM (SELECT trc_owner
                FROM dbo.tractorprofile
              GROUP BY trc_owner
             ) AS tp
       WHERE tp.trc_owner IS NOT NULL
         AND tp.trc_owner <> 'UNKNOWN'
         AND tp.trc_owner NOT IN (SELECT owner_id FROM #temp)

      --Trailer
      UPDATE #temp
         SET trailer = 'Trailer, '
        FROM #temp t
        INNER JOIN (SELECT trl_owner
                      FROM dbo.trailerprofile
                    GROUP BY trl_owner
                   ) AS tp ON t.owner_id = tp.trl_owner

      INSERT #temp (owner_id, trailer)
      SELECT trl_owner, 'Trailer, '
        FROM (SELECT trl_owner
                FROM dbo.trailerprofile
              GROUP BY trl_owner
             ) AS tp
       WHERE tp.trl_owner IS NOT NULL
         AND tp.trl_owner <> 'UNKNOWN'
         AND tp.trl_owner NOT IN (SELECT owner_id FROM #temp)

      --Carrier
      UPDATE #temp
         SET carrier = 'Carrier, '
        FROM #temp t
        INNER JOIN (SELECT pto_id
                      FROM dbo.carrier
                    GROUP BY pto_id
                   ) AS tp ON t.owner_id = tp.pto_id

      INSERT #temp (owner_id, carrier)
      SELECT pto_id, 'Carrier, '
        FROM (SELECT pto_id
                FROM dbo.carrier
              GROUP BY pto_id
             ) AS tp
       WHERE tp.pto_id IS NOT NULL
         AND tp.pto_id <> 'UNKNOWN'
         AND tp.pto_id NOT IN (SELECT owner_id FROM #temp)

      --ThirdParty
      UPDATE #temp
         SET thirdparty = '3rdParty, '
        FROM #temp t
        INNER JOIN (SELECT tpr_payto
                      FROM dbo.thirdpartyprofile
                    GROUP BY tpr_payto
                   ) AS tp ON t.owner_id = tp.tpr_payto

      INSERT #temp (owner_id, thirdparty)
      SELECT tpr_payto, '3rdParty, '
        FROM (SELECT tpr_payto
                FROM dbo.thirdpartyprofile
              GROUP BY tpr_payto
             ) AS tp
       WHERE tp.tpr_payto IS NOT NULL
         AND tp.tpr_payto <> 'UNKNOWN'
         AND tp.tpr_payto NOT IN (SELECT owner_id FROM #temp)
   END

   --Resultset
   SELECT owner_id
        , LEFT(IsNull(driver,'') + IsNull(tractor,'') + IsNull(trailer,'') + IsNull(carrier,'') + IsNull(thirdparty,''),
               LEN(IsNull(driver,'') + IsNull(tractor,'') + IsNull(trailer,'') + IsNull(carrier,'') + IsNull(thirdparty,'')) -1
              ) AS profile_types
     FROM #temp
   ORDER BY owner_id

END
GO
GRANT EXECUTE ON  [dbo].[dddw_profile_owner_ids_sp] TO [public]
GO

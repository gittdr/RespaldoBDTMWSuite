SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_unit_lifetime_mileage_sp]
AS
/**
 * 
 * NAME:
 * dbo.d_unit_lifetime_mileage_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

SELECT 'TRC' AS unit_type, CONVERT(VARCHAR(13), trc_number) AS unit_id, 
       trc_company AS company, trc_division AS division, trc_fleet AS fleet, trc_terminal AS terminal, 
       trc_type1 AS type1, trc_type2 AS type2, trc_type3 AS type3, trc_type4 AS type4, 
       ISNULL((SELECT MAX(udl_last_updated) FROM UnitDistancebyLeg WHERE udl_unittype = 'TRC' AND udl_unitid = trc_number AND udl_verified = 1), GetDate()) AS last_update,
       ISNULL(trc_lifetimemileage, 0) AS verified_miles, 
       ISNULL((SELECT SUM(ISNULL(udl_distance, 0)) FROM UnitDistancebyLeg WHERE udl_unittype = 'TRC' AND udl_unitid = trc_number AND udl_verified = 0), 0) AS projected_miles 
  FROM tractorprofile 
 WHERE trc_number <> 'UNKNOWN' 
UNION 
SELECT 'TRL' AS unit_type, CONVERT(VARCHAR(13), trl_id) AS unit_id, 
       trl_company AS company, trl_division AS division, trl_fleet AS fleet, trl_terminal AS terminal, 
       trl_type1 AS type1, trl_type2 AS type2, trl_type3 AS type3, trl_type4 AS type4, 
       ISNULL((SELECT MAX(udl_last_updated) FROM UnitDistancebyLeg WHERE udl_unittype = 'TRL' AND udl_unitid = trl_id AND udl_verified = 1), GetDate()) AS last_update,
       ISNULL(trl_lifetimemileage, 0) AS verified_miles, 
       ISNULL((SELECT SUM(ISNULL(udl_distance, 0)) FROM UnitDistancebyLeg WHERE udl_unittype = 'TRL' AND udl_unitid = trl_id AND udl_verified = 0), 0) AS projected_miles 
  FROM trailerprofile 
 WHERE trl_id <> 'UNKNOWN' 

GO
GRANT EXECUTE ON  [dbo].[d_unit_lifetime_mileage_sp] TO [public]
GO

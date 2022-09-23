SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_gp_payf]
( @pyhnumber INT
)
AS

/*
*
*
* NAME:
* dbo.d_gp_payf
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure
*
* RETURNS:
*
* RESULTSET
*
* 07/16/2014 PTS80433 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   DECLARE @Setting  CHAR(1)

   SELECT @Setting = dbo.fn_GetSetting('CalculateLegMiles','C1')

   IF @Setting = 'Y'
      BEGIN
         SELECT payheader.pyh_pyhnumber         AS payheader_pyh_pyhnumber
              , paydetail.lgh_number            AS paydetail_lgh_number
              , legheader.lgh_class1            AS legheader_lgh_class1
              , legheader.lgh_class2            AS legheader_lgh_class2
              , legheader.lgh_class3            AS legheader_lgh_class3
              , legheader.lgh_class4            AS legheader_lgh_class4
              , legheader.trl_type1             AS legheader_trl_type1
              , legheader.trl_type2             AS legheader_trl_type2
              , legheader.trl_type3             AS legheader_trl_type3
              , legheader.trl_type4             AS legheader_trl_type4
              , legheader.mpp_type1             AS legheader_mpp_type1
              , legheader.mpp_type2             AS legheader_mpp_type2
              , legheader.mpp_type3             AS legheader_mpp_type3
              , legheader.mpp_type4             AS legheader_mpp_type4
              , payheader.asgn_id               AS payheader_asgn_id
              , payheader.asgn_type             AS payheader_asgn_type
              , legheader.trc_type1             AS legheader_trc_type1
              , legheader.trc_type2             AS legheader_trc_type2
              , legheader.trc_type3             AS legheader_trc_type3
              , legheader.trc_type4             AS legheader_trc_type4
              , legheader.lgh_tractor           AS legheader_lgh_tractor
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass1
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass2
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass3
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass4
              , legheader.trc_company           AS legheader_trc_company
              , legheader.trc_division          AS legheader_trc_division
              , legheader.trc_fleet             AS legheader_trc_fleet
              , legheader.trc_terminal          AS legheader_trc_terminal
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type1
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type2
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type3
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type4
              , legheader.lgh_acttransfer       AS lgh_acttransfer
              , legheader.lgh_acttransferdate   AS lgh_acttransferdate
              , legheader.lgh_fuelburned        AS lgh_fuelburned
              , legheader.lgh_actualmiles       AS lgh_actualmiles
              , (SELECT SUM (stp_trip_mileage) FROM stops WHERE stops.lgh_number = paydetail.lgh_number) AS trip_miles
              , (SELECT SUM (CASE stp_loadstatus WHEN 'MT' THEN stp_trip_mileage ELSE 0 END) FROM stops WHERE stops.lgh_number = paydetail.lgh_number) AS mt_miles
              , (SELECT SUM (CASE stp_loadstatus WHEN 'LD' THEN stp_trip_mileage ELSE 0 END) FROM stops WHERE stops.lgh_number = paydetail.lgh_number) AS ld_miles
              , gpunit_a.account                AS am_account
              , gpunit_b.account                AS tm_account
              , gpunit_c.account                AS lm_account
              , gpunit_d.account                AS em_account
              , gpunit_e.account                AS fb_account
              , legheader.mpp_teamleader        AS legheader_mpp_teamleader
              , legheader.mpp_fleet             AS legheader_mpp_fleet
              , legheader.mpp_division          AS legheader_mpp_division
              , legheader.mpp_domicile          AS legheader_mpp_domicile
              , legheader.mpp_company           AS legheader_mpp_company
              , legheader.mpp_terminal          AS legheader_mpp_terminal
              , legheader.lgh_type1             AS legheader_lgh_type1
              , legheader.lgh_type2             AS legheader_lgh_type2
              , (SELECT orderheader.ord_subcompany FROM orderheader WHERE legheader.ord_hdrnumber = orderheader.ord_hdrnumber) AS ord_subcompany
              , legheader.trl_company           AS legheader_trl_company
              , legheader.trl_division          AS legheader_trl_division
              , legheader.trl_fleet             AS legheader_trl_fleet
              , legheader.trl_terminal          AS legheader_trl_terminal
              , legheader.lgh_booked_revtype1   AS legheader_lgh_booked_revtype1
              , orderheader.ord_booked_revtype1 AS ord_booked_revtype1
           FROM paydetail
           JOIN payheader ON paydetail.pyh_number = payheader.pyh_pyhnumber
           JOIN legheader ON paydetail.lgh_number = Legheader.lgh_number
           LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber= orderheader.ord_hdrnumber
           LEFT OUTER JOIN stops ON paydetail.lgh_number = stops.lgh_number
           LEFT OUTER JOIN gpunit AS gpunit_a ON legheader.trc_company = gpunit_a.company
                                             AND gpunit_a.type = 'AM'
           LEFT OUTER JOIN gpunit AS gpunit_b ON legheader.trc_company = gpunit_b.company
                                             AND gpunit_b.type = 'TM'
           LEFT OUTER JOIN gpunit AS gpunit_c ON legheader.trc_company = gpunit_c.company
                                             AND gpunit_c.type = 'LD'
           LEFT OUTER JOIN gpunit AS gpunit_d ON legheader.trc_company = gpunit_d.company
                                             AND gpunit_d.type = 'MT'
           LEFT OUTER JOIN gpunit AS gpunit_e ON legheader.trc_company = gpunit_e.company
                                             AND gpunit_e.type = 'FB'
          WHERE pyh_number = @pyhnumber
         GROUP BY payheader.pyh_pyhnumber
                , paydetail.lgh_number
                , legheader.lgh_class1
                , legheader.lgh_class2
                , legheader.lgh_class3
                , legheader.lgh_class4
                , legheader.lgh_type1
                , legheader.lgh_type2
                , legheader.trl_type1
                , legheader.trl_type2
                , legheader.trl_type3
                , legheader.trl_type4
                , legheader.mpp_teamleader
                , legheader.mpp_fleet
                , legheader.mpp_division
                , legheader.mpp_domicile
                , legheader.mpp_company
                , legheader.mpp_terminal
                , legheader.mpp_type1
                , legheader.mpp_type2
                , legheader.mpp_type3
                , legheader.mpp_type4
                , payheader.asgn_type
                , payheader.asgn_id
                , legheader.trc_type1
                , legheader.trc_type2
                , legheader.trc_type3
                , legheader.trc_type4
                , legheader.lgh_tractor
                , legheader.trc_company
                , legheader.trc_division
                , legheader.trc_fleet
                , legheader.trc_terminal
                , legheader.lgh_acttransfer
                , legheader.lgh_acttransferdate
                , legheader.lgh_fuelburned
                , legheader.lgh_actualmiles
                , gpunit_a.account
                , gpunit_b.account
                , gpunit_c.account
                , gpunit_d.account
                , gpunit_e.account
                , legheader.ord_hdrnumber
                , legheader.trl_company
                , legheader.trl_division
                , legheader.trl_fleet
                , legheader.trl_terminal
                , legheader.lgh_booked_revtype1
                , orderheader.ord_booked_revtype1
         UNION
         SELECT paydetail.pyh_number            AS payheader_pyh_pyhnumber
              , paydetail.lgh_number            AS paydetail_lgh_number
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class1
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class2
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class3
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class4
              , convert (varchar (6), 'UNK')    AS legheader_trl_type1
              , convert (varchar (6), 'UNK')    AS legheader_trl_type2
              , convert (varchar (6), 'UNK')    AS legheader_trl_type3
              , convert (varchar (6), 'UNK')    AS legheader_trl_type4
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type1
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type2
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type3
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type4
              , paydetail.asgn_id               AS payheader_asgn_id
              , paydetail.asgn_type             AS payheader_asgn_type
              , convert (varchar (6), 'UNK')    AS legheader_trc_type1
              , convert (varchar (6), 'UNK')    AS legheader_trc_type2
              , convert (varchar (6), 'UNK')    AS legheader_trc_type3
              , convert (varchar (6), 'UNK')    AS legheader_trc_type4
              , convert (varchar (8), 'UNK')    AS legheader_lgh_tractor
              , convert (varchar (6), 'UNK')    AS tprclass1
              , convert (varchar (6), 'UNK')    AS tprclass2
              , convert (varchar (6), 'UNK')    AS tprclass3
              , convert (varchar (6), 'UNK')    AS tprclass4
              , convert (varchar (6), 'UNK')    AS legheader_trc_company
              , convert (varchar (6), 'UNK')    AS legheader_trc_division
              , convert (varchar (6), 'UNK')    AS legheader_trc_fleet
              , convert (varchar (6), 'UNK')    AS legheader_trc_terminal
              , convert (varchar (6), 'UNK')    AS car_type1
              , convert (varchar (6), 'UNK')    AS car_type2
              , convert (varchar (6), 'UNK')    AS car_type3
              , convert (varchar (6), 'UNK')    AS car_type4
              , convert (varchar (6), '')       AS lgh_acttransfer
              , convert (datetime, '19500101')  AS lgh_acttransferdate
              , convert (decimal (8,2), 0)      AS lgh_fuelburned
              , convert (decimal (8,2), 0)      AS lgh_actualmiles
              , convert (decimal (8,2), 0)      AS trip_miles
              , convert (decimal (8,2), 0)      AS mt_miles
              , convert (decimal (8,2), 0)      AS ld_miles
              , convert (varchar (75), '')      AS am_account
              , convert (varchar (75), '')      AS tm_account
              , convert (varchar (75), '')      AS lm_account
              , convert (varchar (75), '')      AS em_account
              , convert (varchar (75), '')      AS fb_account
              , convert (varchar (6), 'UNK')    AS legheader_mpp_teamleader
              , convert (varchar (6), 'UNK')    AS legheader_mpp_fleet
              , convert (varchar (6), 'UNK')    AS legheader_mpp_division
              , convert (varchar (6), 'UNK')    AS legheader_mpp_domicile
              , convert (varchar (6), 'UNK')    AS legheader_mpp_company
              , convert (varchar (6), 'UNK')    AS legheader_mpp_terminal
              , convert (varchar (6), 'UNK')    AS legheader_lgh_type1
              , convert (varchar (6), 'UNK')    AS legheader_lgh_type2
              , convert (varchar (6), 'UNK')    AS ord_subcompany
              , convert (varchar (6), 'UNK')    AS legheader_trl_company
              , convert (varchar (6), 'UNK')    AS legheader_trl_division
              , convert (varchar (6), 'UNK')    AS legheader_trl_fleet
              , convert (varchar (6), 'UNK')    AS legheader_trl_terminal
              , convert (varchar (6), 'UNK')    AS legheader_lgh_booked_revtype1
              , convert (varchar (6), 'UNK')    AS ord_booked_revtype1
           FROM paydetail
          WHERE paydetail.lgh_number = 0
            AND paydetail.pyh_number = @pyhnumber
      END
   ELSE
      BEGIN
         SELECT payheader.pyh_pyhnumber         AS payheader_pyh_pyhnumber
              , paydetail.lgh_number            AS paydetail_lgh_number
              , legheader.lgh_class1            AS legheader_lgh_class1
              , legheader.lgh_class2            AS legheader_lgh_class2
              , legheader.lgh_class3            AS legheader_lgh_class3
              , legheader.lgh_class4            AS legheader_lgh_class4
              , legheader.trl_type1             AS legheader_trl_type1
              , legheader.trl_type2             AS legheader_trl_type2
              , legheader.trl_type3             AS legheader_trl_type3
              , legheader.trl_type4             AS legheader_trl_type4
              , legheader.mpp_type1             AS legheader_mpp_type1
              , legheader.mpp_type2             AS legheader_mpp_type2
              , legheader.mpp_type3             AS legheader_mpp_type3
              , legheader.mpp_type4             AS legheader_mpp_type4
              , payheader.asgn_id               AS payheader_asgn_id
              , payheader.asgn_type             AS payheader_asgn_type
              , legheader.trc_type1             AS legheader_trc_type1
              , legheader.trc_type2             AS legheader_trc_type2
              , legheader.trc_type3             AS legheader_trc_type3
              , legheader.trc_type4             AS legheader_trc_type4
              , legheader.lgh_tractor           AS legheader_lgh_tractor
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass1
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass2
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass3
              , CONVERT (VARCHAR(6), 'UNK')     AS tprclass4
              , legheader.trc_company           AS legheader_trc_company
              , legheader.trc_division          AS legheader_trc_division
              , legheader.trc_fleet             AS legheader_trc_fleet
              , legheader.trc_terminal          AS legheader_trc_terminal
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type1
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type2
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type3
              , CONVERT (VARCHAR(6), 'UNK')     AS car_type4
              , legheader.lgh_acttransfer       AS lgh_acttransfer
              , legheader.lgh_acttransferdate   AS lgh_acttransferdate
              , legheader.lgh_fuelburned        AS lgh_fuelburned
              , legheader.lgh_actualmiles       AS lgh_actualmiles
              , (SELECT SUM (stp_lgh_mileage) FROM stops WHERE stops.lgh_number = paydetail.lgh_number) AS trip_miles
              , (SELECT SUM (CASE stp_loadstatus WHEN 'MT' THEN stp_lgh_mileage ELSE 0 END) FROM stops WHERE stops.lgh_number = paydetail.lgh_number) AS mt_miles
              , (SELECT SUM (CASE stp_loadstatus WHEN 'LD' THEN stp_lgh_mileage ELSE 0 END) FROM stops WHERE stops.lgh_number = paydetail.lgh_number) AS ld_miles
              , gpunit_a.account                AS am_account
              , gpunit_b.account                AS tm_account
              , gpunit_c.account                AS lm_account
              , gpunit_d.account                AS em_account
              , gpunit_e.account                AS fb_account
              , legheader.mpp_teamleader        AS legheader_mpp_teamleader
              , legheader.mpp_fleet             AS legheader_mpp_fleet
              , legheader.mpp_division          AS legheader_mpp_division
              , legheader.mpp_domicile          AS legheader_mpp_domicile
              , legheader.mpp_company           AS legheader_mpp_company
              , legheader.mpp_terminal          AS legheader_mpp_terminal
              , legheader.lgh_type1             AS legheader_lgh_type1
              , legheader.lgh_type2             AS legheader_lgh_type2
              , (SELECT orderheader.ord_subcompany FROM orderheader WHERE legheader.ord_hdrnumber = orderheader.ord_hdrnumber) AS ord_subcompany
              , legheader.trl_company           AS legheader_trl_company
              , legheader.trl_division          AS legheader_trl_division
              , legheader.trl_fleet             AS legheader_trl_fleet
              , legheader.trl_terminal          AS legheader_trl_terminal
              , legheader.lgh_booked_revtype1   AS legheader_lgh_booked_revtype1
              , orderheader.ord_booked_revtype1 AS ord_booked_revtype1
           FROM paydetail
           JOIN payheader ON paydetail.pyh_number = payheader.pyh_pyhnumber
           JOIN legheader ON paydetail.lgh_number = Legheader.lgh_number
           LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber= orderheader.ord_hdrnumber
           LEFT OUTER JOIN stops ON paydetail.lgh_number = stops.lgh_number
           LEFT OUTER JOIN gpunit AS gpunit_a ON legheader.trc_company = gpunit_a.company
                                             AND gpunit_a.type = 'AM'
           LEFT OUTER JOIN gpunit AS gpunit_b ON legheader.trc_company = gpunit_b.company
                                             AND gpunit_b.type = 'TM'
           LEFT OUTER JOIN gpunit AS gpunit_c ON legheader.trc_company = gpunit_c.company
                                             AND gpunit_c.type = 'LD'
           LEFT OUTER JOIN gpunit AS gpunit_d ON legheader.trc_company = gpunit_d.company
                                             AND gpunit_d.type = 'MT'
           LEFT OUTER JOIN gpunit AS gpunit_e ON legheader.trc_company = gpunit_e.company
                                             AND gpunit_e.type = 'FB'
          WHERE pyh_number = @pyhnumber
         GROUP BY payheader.pyh_pyhnumber
                , paydetail.lgh_number
                , legheader.lgh_class1
                , legheader.lgh_class2
                , legheader.lgh_class3
                , legheader.lgh_class4
                , legheader.lgh_type1
                , legheader.lgh_type2
                , legheader.trl_type1
                , legheader.trl_type2
                , legheader.trl_type3
                , legheader.trl_type4
                , legheader.mpp_teamleader
                , legheader.mpp_fleet
                , legheader.mpp_division
                , legheader.mpp_domicile
                , legheader.mpp_company
                , legheader.mpp_terminal
                , legheader.mpp_type1
                , legheader.mpp_type2
                , legheader.mpp_type3
                , legheader.mpp_type4
                , payheader.asgn_type
                , payheader.asgn_id
                , legheader.trc_type1
                , legheader.trc_type2
                , legheader.trc_type3
                , legheader.trc_type4
                , legheader.lgh_tractor
                , legheader.trc_company
                , legheader.trc_division
                , legheader.trc_fleet
                , legheader.trc_terminal
                , legheader.lgh_acttransfer
                , legheader.lgh_acttransferdate
                , legheader.lgh_fuelburned
                , legheader.lgh_actualmiles
                , gpunit_a.account
                , gpunit_b.account
                , gpunit_c.account
                , gpunit_d.account
                , gpunit_e.account
                , legheader.ord_hdrnumber
                , legheader.trl_company
                , legheader.trl_division
                , legheader.trl_fleet
                , legheader.trl_terminal
                , legheader.lgh_booked_revtype1
                , orderheader.ord_booked_revtype1
         UNION
         SELECT paydetail.pyh_number            AS payheader_pyh_pyhnumber
              , paydetail.lgh_number            AS paydetail_lgh_number
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class1
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class2
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class3
              , convert (varchar (6), 'UNK')    AS legheader_lgh_class4
              , convert (varchar (6), 'UNK')    AS legheader_trl_type1
              , convert (varchar (6), 'UNK')    AS legheader_trl_type2
              , convert (varchar (6), 'UNK')    AS legheader_trl_type3
              , convert (varchar (6), 'UNK')    AS legheader_trl_type4
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type1
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type2
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type3
              , convert (varchar (6), 'UNK')    AS legheader_mpp_type4
              , paydetail.asgn_id               AS payheader_asgn_id
              , paydetail.asgn_type             AS payheader_asgn_type
              , convert (varchar (6), 'UNK')    AS legheader_trc_type1
              , convert (varchar (6), 'UNK')    AS legheader_trc_type2
              , convert (varchar (6), 'UNK')    AS legheader_trc_type3
              , convert (varchar (6), 'UNK')    AS legheader_trc_type4
              , convert (varchar (8), 'UNK')    AS legheader_lgh_tractor
              , convert (varchar (6), 'UNK')    AS tprclass1
              , convert (varchar (6), 'UNK')    AS tprclass2
              , convert (varchar (6), 'UNK')    AS tprclass3
              , convert (varchar (6), 'UNK')    AS tprclass4
              , convert (varchar (6), 'UNK')    AS legheader_trc_company
              , convert (varchar (6), 'UNK')    AS legheader_trc_division
              , convert (varchar (6), 'UNK')    AS legheader_trc_fleet
              , convert (varchar (6), 'UNK')    AS legheader_trc_terminal
              , convert (varchar (6), 'UNK')    AS car_type1
              , convert (varchar (6), 'UNK')    AS car_type2
              , convert (varchar (6), 'UNK')    AS car_type3
              , convert (varchar (6), 'UNK')    AS car_type4
              , convert (varchar (6), '')       AS lgh_acttransfer
              , convert (datetime, '19500101')  AS lgh_acttransferdate
              , convert (decimal (8,2), 0)      AS lgh_fuelburned
              , convert (decimal (8,2), 0)      AS lgh_actualmiles
              , convert (decimal (8,2), 0)      AS trip_miles
              , convert (decimal (8,2), 0)      AS mt_miles
              , convert (decimal (8,2), 0)      AS ld_miles
              , convert (varchar (75), '')      AS am_account
              , convert (varchar (75), '')      AS tm_account
              , convert (varchar (75), '')      AS lm_account
              , convert (varchar (75), '')      AS em_account
              , convert (varchar (75), '')      AS fb_account
              , convert (varchar (6), 'UNK')    AS legheader_mpp_teamleader
              , convert (varchar (6), 'UNK')    AS legheader_mpp_fleet
              , convert (varchar (6), 'UNK')    AS legheader_mpp_division
              , convert (varchar (6), 'UNK')    AS legheader_mpp_domicile
              , convert (varchar (6), 'UNK')    AS legheader_mpp_company
              , convert (varchar (6), 'UNK')    AS legheader_mpp_terminal
              , convert (varchar (6), 'UNK')    AS legheader_lgh_type1
              , convert (varchar (6), 'UNK')    AS legheader_lgh_type2
              , convert (varchar (6), 'UNK')    AS ord_subcompany
              , convert (varchar (6), 'UNK')    AS legheader_trl_company
              , convert (varchar (6), 'UNK')    AS legheader_trl_division
              , convert (varchar (6), 'UNK')    AS legheader_trl_fleet
              , convert (varchar (6), 'UNK')    AS legheader_trl_terminal
              , convert (varchar (6), 'UNK')    AS legheader_lgh_booked_revtype1
              , convert (varchar (6), 'UNK')    AS ord_booked_revtype1
           FROM paydetail
          WHERE paydetail.lgh_number = 0
            AND paydetail.pyh_number = @pyhnumber
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[d_gp_payf] TO [public]
GO

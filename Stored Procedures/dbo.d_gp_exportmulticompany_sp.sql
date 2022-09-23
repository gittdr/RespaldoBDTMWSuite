SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_gp_exportmulticompany_sp]
( @ord_hdrnumber INT
)
AS

/*
*
*
* NAME:
* dbo.d_gp_exportmulticompany_sp
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
        SELECT 'TRC'                            AS asgn_type
             , legheader.lgh_tractor            AS asgn_id
             , legheader.lgh_number             AS lgh_number
             , legheader.lgh_startdate          AS asgn_date
             , tractorprofile.trc_actg_type     AS actg_type
             , (SELECT SUM(isnull (stp_trip_mileage, 0)) FROM stops WHERE stops.lgh_number = legheader.lgh_number) AS total_lgh_mileage
             , (SELECT SUM(isnull (stp_trip_mileage, 0)) FROM stops WHERE mov_number in (SELECT distinct mov_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber)) AS total_mileage
             , labelfile.acct_server            AS labelfile_acct_server
             , labelfile.acct_db                AS labelfile_acct_db
             , labelfile.ic_clear_glnum         AS labelfile_ic_clear_glnum
             , gpunit_a.account                 AS ar_icaccount
             , gpunit_b.account                 AS bm_account
             , legheader.trc_company            AS company
             , legheader.trc_division           AS division
             , legheader.trc_fleet              AS fleet
             , legheader.trc_terminal           AS terminal
             , legheader.trc_type1              AS type1
             , legheader.trc_type2              AS type2
             , legheader.trc_type3              AS type3
             , legheader.trc_type4              AS type4
             , legheader.lgh_type1              AS legheader_lgh_type1
             , legheader.lgh_type2              AS legheader_lgh_type2
             , manpowerprofile.mpp_type1        AS manpowerprofile_mpp_type1
             , manpowerprofile.mpp_type2        AS manpowerprofile_mpp_type2
             , manpowerprofile.mpp_type3        AS manpowerprofile_mpp_type3
             , manpowerprofile.mpp_type4        AS manpowerprofile_mpp_type4
             , manpowerprofile.mpp_company      AS manpowerprofile_mpp_company
             , orderheader.ord_subcompany       AS orderheader_subcompany
             , legheader.trl_company            AS legheader_trl_company
             , legheader.trc_company            AS legheader_company
             , legheader.trc_division           AS legheader_division
             , legheader.trc_fleet              AS legheader_fleet
             , legheader.trc_terminal           AS legheader_terminal
             , legheader.trc_type1              AS legheader_type1
             , legheader.trc_type2              AS legheader_type2
             , legheader.trc_type3              AS legheader_type3
             , legheader.trc_type4              AS legheader_type4
             , legheader.trl_company            AS legheader_trl_company1
             , legheader.mpp_type1              AS legheader_mpp_type1
             , legheader.mpp_type2              AS legheader_mpp_type2
             , legheader.mpp_type3              AS legheader_mpp_type3
             , legheader.mpp_type4              AS legheader_mpp_type4
             , legheader.mpp_fleet              AS legheader_mpp_fleet
             , legheader.mpp_division           AS legheader_mpp_division
             , legheader.mpp_domicile           AS legheader_mpp_domicile
             , legheader.mpp_company            AS legheader_mpp_company
             , legheader.mpp_terminal           AS legheader_mpp_terminal
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_primary_trailer    AS legheader_lgh_primary_trailer
             , legheader.lgh_primary_pup        AS legheader_lgh_primary_pup
             , legheader.trl_company            AS legheader_trl_company2
             , legheader.trl_division           AS legheader_trl_division
             , legheader.trl_fleet              AS legheader_trl_fleet
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_tractor            AS legheader_lgh_tractor
             , legheader.lgh_driver1            AS legheader_lgh_driver1
             , legheader.lgh_booked_revtype1    AS legheader_lgh_booked_revtype1
             , orderheader.ord_booked_revtype1  AS ord_booked_revtype1
             , legheader.lgh_carrier            AS lgh_carrier
             , lgh_class1                       AS lgh_class1
             , lgh_class2                       AS lgh_class2
             , lgh_class3                       AS lgh_class3
             , lgh_class4                       AS lgh_class4
          FROM orderheader
          JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
          JOIN legheader ON legheader.mov_number = stops.mov_number
          JOIN tractorprofile ON legheader.lgh_tractor = tractorprofile.trc_number
          LEFT OUTER JOIN gpunit AS gpunit_a ON tractorprofile.trc_company = gpunit_a.company
                                             AND gpunit_a.type = 'ARIC'
          LEFT OUTER JOIN gpunit AS gpunit_b ON tractorprofile.trc_company = gpunit_b.company
                                             AND gpunit_b.type = 'BM'
          JOIN labelfile ON tractorprofile.trc_company = labelfile.abbr
          JOIN manpowerprofile ON legheader.lgh_driver1 = manpowerprofile.mpp_id
         WHERE orderheader.ord_hdrnumber = @ord_hdrnumber
           AND labelfile.labeldefinition = 'Company'
           AND legheader.lgh_tractor <> 'UNKNOWN'
         GROUP BY legheader.lgh_tractor
                , labelfile.acct_server
                , labelfile.ic_clear_glnum
                , labelfile.acct_db
                , legheader.lgh_number
                , legheader.lgh_startdate
                , tractorprofile.trc_actg_type
                , gpunit_a.account
                , gpunit_b.account
                , legheader.trc_company
                , legheader.trc_division
                , legheader.trc_fleet
                , legheader.trc_terminal
                , legheader.trc_type1
                , legheader.trc_type2
                , legheader.trc_type3
                , legheader.trc_type4
                , legheader.lgh_type1
                , legheader.lgh_type2
                , manpowerprofile.mpp_type1
                , manpowerprofile.mpp_type2
                , manpowerprofile.mpp_type3
                , manpowerprofile.mpp_type4
                , manpowerprofile.mpp_company
                , orderheader.ord_subcompany
                , legheader.trl_company
                , legheader.trc_company
                , legheader.trc_division
                , legheader.trc_fleet
                , legheader.trc_terminal
                , legheader.trc_type1
                , legheader.trc_type2
                , legheader.trc_type3
                , legheader.trc_type4
                , legheader.trl_company
                , legheader.mpp_type1
                , legheader.mpp_type2
                , legheader.mpp_type3
                , legheader.mpp_type4
                , legheader.mpp_fleet
                , legheader.mpp_division
                , legheader.mpp_domicile
                , legheader.mpp_company
                , legheader.mpp_terminal
                , legheader.trl_terminal
                , legheader.lgh_primary_trailer
                , legheader.lgh_primary_pup
                , legheader.trl_company
                , legheader.trl_division
                , legheader.trl_fleet
                , legheader.trl_terminal
                , legheader.lgh_tractor
                , legheader.lgh_driver1
                , legheader.lgh_booked_revtype1
                , orderheader.ord_booked_revtype1
                , legheader.lgh_carrier
                , lgh_class1
                , lgh_class2
                , lgh_class3
                , lgh_class4
        UNION
        SELECT 'CAR'                            AS asgn_type
             , legheader.lgh_carrier            AS asgn_id
             , legheader.lgh_number             AS lgh_number
             , legheader.lgh_startdate          AS asgn_date
             , carrier.car_actg_type            AS actg_type
             , (SELECT SUM(isnull (stp_trip_mileage, 0)) FROM stops WHERE stops.lgh_number = legheader.lgh_number) AS total_lgh_mileage
             , (SELECT SUM(isnull (stp_trip_mileage, 0)) FROM stops WHERE mov_number in (SELECT distinct mov_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber)) AS total_mileage
             , ''                               AS labelfile_acct_server
             , ''                               AS labelfile_acct_db
             , ''                               AS labelfile_ic_clear_glnum
             , gpunit_a.account                 AS ar_icaccount
             , gpunit_b.account                 AS bm_account
             , 'UNK'                            AS company
             , 'UNK'                            AS division
             , 'UNK'                            AS fleet
             , 'UNK'                            AS terminal
             , carrier.car_type1                AS type1
             , carrier.car_type2                AS type2
             , carrier.car_type3                AS type3
             , carrier.car_type4                AS type4
             , legheader.lgh_type1              AS legheader_lgh_type1
             , legheader.lgh_type2              AS legheader_lgh_type2
             , manpowerprofile.mpp_type1        AS manpowerprofile_mpp_type1
             , manpowerprofile.mpp_type2        AS manpowerprofile_mpp_type2
             , manpowerprofile.mpp_type3        AS manpowerprofile_mpp_type3
             , manpowerprofile.mpp_type4        AS manpowerprofile_mpp_type4
             , manpowerprofile.mpp_company      AS manpowerprofile_mpp_company
             , orderheader.ord_subcompany       AS orderheader_subcompany
             , legheader.trl_company            AS legheader_trl_company
             , legheader.trc_company            AS legheader_company
             , legheader.trc_division           AS legheader_division
             , legheader.trc_fleet              AS legheader_fleet
             , legheader.trc_terminal           AS legheader_terminal
             , legheader.trc_type1              AS legheader_type1
             , legheader.trc_type2              AS legheader_type2
             , legheader.trc_type3              AS legheader_type3
             , legheader.trc_type4              AS legheader_type4
             , legheader.trl_company            AS legheader_trl_company1
             , legheader.mpp_type1              AS legheader_mpp_type1
             , legheader.mpp_type2              AS legheader_mpp_type2
             , legheader.mpp_type3              AS legheader_mpp_type3
             , legheader.mpp_type4              AS legheader_mpp_type4
             , legheader.mpp_fleet              AS legheader_mpp_fleet
             , legheader.mpp_division           AS legheader_mpp_division
             , legheader.mpp_domicile           AS legheader_mpp_domicile
             , legheader.mpp_company            AS legheader_mpp_company
             , legheader.mpp_terminal           AS legheader_mpp_terminal
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_primary_trailer    AS legheader_lgh_primary_trailer
             , legheader.lgh_primary_pup        AS legheader_lgh_primary_pup
             , legheader.trl_company            AS legheader_trl_company2
             , legheader.trl_division           AS legheader_trl_division
             , legheader.trl_fleet              AS legheader_trl_fleet
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_tractor            AS legheader_lgh_tractor
             , legheader.lgh_driver1            AS legheader_lgh_driver1
             , legheader.lgh_booked_revtype1    AS legheader_lgh_booked_revtype1
             , orderheader.ord_booked_revtype1  AS ord_booked_revtype1
             , legheader.lgh_carrier            AS lgh_carrier
             , lgh_class1                       AS lgh_class1
             , lgh_class2                       AS lgh_class2
             , lgh_class3                       AS lgh_class3
             , lgh_class4                       AS lgh_class4
          FROM orderheader
          JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
          JOIN legheader ON legheader.mov_number = stops.mov_number
          JOIN carrier ON legheader.lgh_carrier = carrier.car_id
          LEFT OUTER JOIN gpunit AS gpunit_a ON carrier.car_type2 = gpunit_a.company
                                            AND gpunit_a.type = 'ARIC'
          LEFT OUTER JOIN gpunit AS gpunit_b ON carrier.car_type2 = gpunit_b.company
                                            AND gpunit_b.type = 'BM'
          JOIN manpowerprofile ON legheader.lgh_driver1 = manpowerprofile.mpp_id
         WHERE orderheader.ord_hdrnumber = @ord_hdrnumber
           AND lgh_carrier <> 'UNKNOWN'
           AND lgh_tractor = 'UNKNOWN'
        GROUP BY legheader.lgh_carrier
               , legheader.lgh_number
               , legheader.lgh_startdate
               , carrier.car_actg_type
               , gpunit_a.account
               , gpunit_b.account
               , carrier.car_type1
               , carrier.car_type2
               , carrier.car_type3
               , carrier.car_type4
               , legheader.lgh_type1
               , legheader.lgh_type2
               , manpowerprofile.mpp_type1
               , manpowerprofile.mpp_type2
               , manpowerprofile.mpp_type3
               , manpowerprofile.mpp_type4
               , manpowerprofile.mpp_company
               , orderheader.ord_subcompany
               , legheader.trl_company
               , legheader.trc_company
               , legheader.trc_division
               , legheader.trc_fleet
               , legheader.trc_terminal
               , legheader.trc_type1
               , legheader.trc_type2
               , legheader.trc_type3
               , legheader.trc_type4
               , legheader.trl_company
               , legheader.mpp_type1
               , legheader.mpp_type2
               , legheader.mpp_type3
               , legheader.mpp_type4
               , legheader.mpp_fleet
               , legheader.mpp_division
               , legheader.mpp_domicile
               , legheader.mpp_company
               , legheader.mpp_terminal
               , legheader.trl_terminal
               , legheader.lgh_primary_trailer
               , legheader.lgh_primary_pup
               , legheader.trl_company
               , legheader.trl_division
               , legheader.trl_fleet
               , legheader.trl_terminal
               , legheader.lgh_tractor
               , legheader.lgh_driver1
               , legheader.lgh_booked_revtype1
               , orderheader.ord_booked_revtype1
               , legheader.lgh_carrier
               , lgh_class1
               , lgh_class2
               , lgh_class3
               , lgh_class4
      END
   ELSE
      BEGIN
        SELECT 'TRC'                            AS asgn_type
             , legheader.lgh_tractor            AS asgn_id
             , legheader.lgh_number             AS lgh_number
             , legheader.lgh_startdate          AS asgn_date
             , tractorprofile.trc_actg_type     AS actg_type
             , (SELECT SUM(isnull (stp_lgh_mileage, 0)) FROM stops WHERE stops.lgh_number = legheader.lgh_number) AS total_lgh_mileage
             , (SELECT SUM(isnull (stp_lgh_mileage, 0)) FROM stops WHERE mov_number in (SELECT distinct mov_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber)) AS total_mileage
             , labelfile.acct_server            AS labelfile_acct_server
             , labelfile.acct_db                AS labelfile_acct_db
             , labelfile.ic_clear_glnum         AS labelfile_ic_clear_glnum
             , gpunit_a.account                 AS ar_icaccount
             , gpunit_b.account                 AS bm_account
             , legheader.trc_company            AS company
             , legheader.trc_division           AS division
             , legheader.trc_fleet              AS fleet
             , legheader.trc_terminal           AS terminal
             , legheader.trc_type1              AS type1
             , legheader.trc_type2              AS type2
             , legheader.trc_type3              AS type3
             , legheader.trc_type4              AS type4
             , legheader.lgh_type1              AS legheader_lgh_type1
             , legheader.lgh_type2              AS legheader_lgh_type2
             , manpowerprofile.mpp_type1        AS manpowerprofile_mpp_type1
             , manpowerprofile.mpp_type2        AS manpowerprofile_mpp_type2
             , manpowerprofile.mpp_type3        AS manpowerprofile_mpp_type3
             , manpowerprofile.mpp_type4        AS manpowerprofile_mpp_type4
             , manpowerprofile.mpp_company      AS manpowerprofile_mpp_company
             , orderheader.ord_subcompany       AS orderheader_subcompany
             , legheader.trl_company            AS legheader_trl_company
             , legheader.trc_company            AS legheader_company
             , legheader.trc_division           AS legheader_division
             , legheader.trc_fleet              AS legheader_fleet
             , legheader.trc_terminal           AS legheader_terminal
             , legheader.trc_type1              AS legheader_type1
             , legheader.trc_type2              AS legheader_type2
             , legheader.trc_type3              AS legheader_type3
             , legheader.trc_type4              AS legheader_type4
             , legheader.trl_company            AS legheader_trl_company1
             , legheader.mpp_type1              AS legheader_mpp_type1
             , legheader.mpp_type2              AS legheader_mpp_type2
             , legheader.mpp_type3              AS legheader_mpp_type3
             , legheader.mpp_type4              AS legheader_mpp_type4
             , legheader.mpp_fleet              AS legheader_mpp_fleet
             , legheader.mpp_division           AS legheader_mpp_division
             , legheader.mpp_domicile           AS legheader_mpp_domicile
             , legheader.mpp_company            AS legheader_mpp_company
             , legheader.mpp_terminal           AS legheader_mpp_terminal
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_primary_trailer    AS legheader_lgh_primary_trailer
             , legheader.lgh_primary_pup        AS legheader_lgh_primary_pup
             , legheader.trl_company            AS legheader_trl_company2
             , legheader.trl_division           AS legheader_trl_division
             , legheader.trl_fleet              AS legheader_trl_fleet
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_tractor            AS legheader_lgh_tractor
             , legheader.lgh_driver1            AS legheader_lgh_driver1
             , legheader.lgh_booked_revtype1    AS legheader_lgh_booked_revtype1
             , orderheader.ord_booked_revtype1  AS ord_booked_revtype1
             , legheader.lgh_carrier            AS lgh_carrier
             , lgh_class1                       AS lgh_class1
             , lgh_class2                       AS lgh_class2
             , lgh_class3                       AS lgh_class3
             , lgh_class4                       AS lgh_class4
          FROM orderheader
          JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
          JOIN legheader ON legheader.mov_number = stops.mov_number
          JOIN tractorprofile ON legheader.lgh_tractor = tractorprofile.trc_number
          LEFT OUTER JOIN gpunit AS gpunit_a ON tractorprofile.trc_company = gpunit_a.company
                                             AND gpunit_a.type = 'ARIC'
          LEFT OUTER JOIN gpunit AS gpunit_b ON tractorprofile.trc_company = gpunit_b.company
                                             AND gpunit_b.type = 'BM'
          JOIN labelfile ON tractorprofile.trc_company = labelfile.abbr
          JOIN manpowerprofile ON legheader.lgh_driver1 = manpowerprofile.mpp_id
         WHERE orderheader.ord_hdrnumber = @ord_hdrnumber
           AND labelfile.labeldefinition = 'Company'
           AND legheader.lgh_tractor <> 'UNKNOWN'
         GROUP BY legheader.lgh_tractor
                , labelfile.acct_server
                , labelfile.ic_clear_glnum
                , labelfile.acct_db
                , legheader.lgh_number
                , legheader.lgh_startdate
                , tractorprofile.trc_actg_type
                , gpunit_a.account
                , gpunit_b.account
                , legheader.trc_company
                , legheader.trc_division
                , legheader.trc_fleet
                , legheader.trc_terminal
                , legheader.trc_type1
                , legheader.trc_type2
                , legheader.trc_type3
                , legheader.trc_type4
                , legheader.lgh_type1
                , legheader.lgh_type2
                , manpowerprofile.mpp_type1
                , manpowerprofile.mpp_type2
                , manpowerprofile.mpp_type3
                , manpowerprofile.mpp_type4
                , manpowerprofile.mpp_company
                , orderheader.ord_subcompany
                , legheader.trl_company
                , legheader.trc_company
                , legheader.trc_division
                , legheader.trc_fleet
                , legheader.trc_terminal
                , legheader.trc_type1
                , legheader.trc_type2
                , legheader.trc_type3
                , legheader.trc_type4
                , legheader.trl_company
                , legheader.mpp_type1
                , legheader.mpp_type2
                , legheader.mpp_type3
                , legheader.mpp_type4
                , legheader.mpp_fleet
                , legheader.mpp_division
                , legheader.mpp_domicile
                , legheader.mpp_company
                , legheader.mpp_terminal
                , legheader.trl_terminal
                , legheader.lgh_primary_trailer
                , legheader.lgh_primary_pup
                , legheader.trl_company
                , legheader.trl_division
                , legheader.trl_fleet
                , legheader.trl_terminal
                , legheader.lgh_tractor
                , legheader.lgh_driver1
                , legheader.lgh_booked_revtype1
                , orderheader.ord_booked_revtype1
                , legheader.lgh_carrier
                , lgh_class1
                , lgh_class2
                , lgh_class3
                , lgh_class4
        UNION
        SELECT 'CAR'                            AS asgn_type
             , legheader.lgh_carrier            AS asgn_id
             , legheader.lgh_number             AS lgh_number
             , legheader.lgh_startdate          AS asgn_date
             , carrier.car_actg_type            AS actg_type
             , (SELECT SUM(isnull (stp_lgh_mileage, 0)) FROM stops WHERE stops.lgh_number = legheader.lgh_number) AS total_lgh_mileage
             , (SELECT SUM(isnull (stp_lgh_mileage, 0)) FROM stops WHERE mov_number in (SELECT distinct mov_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber)) AS total_mileage
             , ''                               AS labelfile_acct_server
             , ''                               AS labelfile_acct_db
             , ''                               AS labelfile_ic_clear_glnum
             , gpunit_a.account                 AS ar_icaccount
             , gpunit_b.account                 AS bm_account
             , 'UNK'                            AS company
             , 'UNK'                            AS division
             , 'UNK'                            AS fleet
             , 'UNK'                            AS terminal
             , carrier.car_type1                AS type1
             , carrier.car_type2                AS type2
             , carrier.car_type3                AS type3
             , carrier.car_type4                AS type4
             , legheader.lgh_type1              AS legheader_lgh_type1
             , legheader.lgh_type2              AS legheader_lgh_type2
             , manpowerprofile.mpp_type1        AS manpowerprofile_mpp_type1
             , manpowerprofile.mpp_type2        AS manpowerprofile_mpp_type2
             , manpowerprofile.mpp_type3        AS manpowerprofile_mpp_type3
             , manpowerprofile.mpp_type4        AS manpowerprofile_mpp_type4
             , manpowerprofile.mpp_company      AS manpowerprofile_mpp_company
             , orderheader.ord_subcompany       AS orderheader_subcompany
             , legheader.trl_company            AS legheader_trl_company
             , legheader.trc_company            AS legheader_company
             , legheader.trc_division           AS legheader_division
             , legheader.trc_fleet              AS legheader_fleet
             , legheader.trc_terminal           AS legheader_terminal
             , legheader.trc_type1              AS legheader_type1
             , legheader.trc_type2              AS legheader_type2
             , legheader.trc_type3              AS legheader_type3
             , legheader.trc_type4              AS legheader_type4
             , legheader.trl_company            AS legheader_trl_company1
             , legheader.mpp_type1              AS legheader_mpp_type1
             , legheader.mpp_type2              AS legheader_mpp_type2
             , legheader.mpp_type3              AS legheader_mpp_type3
             , legheader.mpp_type4              AS legheader_mpp_type4
             , legheader.mpp_fleet              AS legheader_mpp_fleet
             , legheader.mpp_division           AS legheader_mpp_division
             , legheader.mpp_domicile           AS legheader_mpp_domicile
             , legheader.mpp_company            AS legheader_mpp_company
             , legheader.mpp_terminal           AS legheader_mpp_terminal
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_primary_trailer    AS legheader_lgh_primary_trailer
             , legheader.lgh_primary_pup        AS legheader_lgh_primary_pup
             , legheader.trl_company            AS legheader_trl_company2
             , legheader.trl_division           AS legheader_trl_division
             , legheader.trl_fleet              AS legheader_trl_fleet
             , legheader.trl_terminal           AS legheader_trl_terminal
             , legheader.lgh_tractor            AS legheader_lgh_tractor
             , legheader.lgh_driver1            AS legheader_lgh_driver1
             , legheader.lgh_booked_revtype1    AS legheader_lgh_booked_revtype1
             , orderheader.ord_booked_revtype1  AS ord_booked_revtype1
             , legheader.lgh_carrier            AS lgh_carrier
             , lgh_class1                       AS lgh_class1
             , lgh_class2                       AS lgh_class2
             , lgh_class3                       AS lgh_class3
             , lgh_class4                       AS lgh_class4
          FROM orderheader
          JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
          JOIN legheader ON legheader.mov_number = stops.mov_number
          JOIN carrier ON legheader.lgh_carrier = carrier.car_id
          LEFT OUTER JOIN gpunit AS gpunit_a ON carrier.car_type2 = gpunit_a.company
                                            AND gpunit_a.type = 'ARIC'
          LEFT OUTER JOIN gpunit AS gpunit_b ON carrier.car_type2 = gpunit_b.company
                                            AND gpunit_b.type = 'BM'
          JOIN manpowerprofile ON legheader.lgh_driver1 = manpowerprofile.mpp_id
         WHERE orderheader.ord_hdrnumber = @ord_hdrnumber
           AND lgh_carrier <> 'UNKNOWN'
           AND lgh_tractor = 'UNKNOWN'
        GROUP BY legheader.lgh_carrier
               , legheader.lgh_number
               , legheader.lgh_startdate
               , carrier.car_actg_type
               , gpunit_a.account
               , gpunit_b.account
               , carrier.car_type1
               , carrier.car_type2
               , carrier.car_type3
               , carrier.car_type4
               , legheader.lgh_type1
               , legheader.lgh_type2
               , manpowerprofile.mpp_type1
               , manpowerprofile.mpp_type2
               , manpowerprofile.mpp_type3
               , manpowerprofile.mpp_type4
               , manpowerprofile.mpp_company
               , orderheader.ord_subcompany
               , legheader.trl_company
               , legheader.trc_company
               , legheader.trc_division
               , legheader.trc_fleet
               , legheader.trc_terminal
               , legheader.trc_type1
               , legheader.trc_type2
               , legheader.trc_type3
               , legheader.trc_type4
               , legheader.trl_company
               , legheader.mpp_type1
               , legheader.mpp_type2
               , legheader.mpp_type3
               , legheader.mpp_type4
               , legheader.mpp_fleet
               , legheader.mpp_division
               , legheader.mpp_domicile
               , legheader.mpp_company
               , legheader.mpp_terminal
               , legheader.trl_terminal
               , legheader.lgh_primary_trailer
               , legheader.lgh_primary_pup
               , legheader.trl_company
               , legheader.trl_division
               , legheader.trl_fleet
               , legheader.trl_terminal
               , legheader.lgh_tractor
               , legheader.lgh_driver1
               , legheader.lgh_booked_revtype1
               , orderheader.ord_booked_revtype1
               , legheader.lgh_carrier
               , lgh_class1
               , lgh_class2
               , lgh_class3
               , lgh_class4
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[d_gp_exportmulticompany_sp] TO [public]
GO

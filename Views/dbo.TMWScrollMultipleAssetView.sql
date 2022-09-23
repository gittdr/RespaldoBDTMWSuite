SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollMultipleAssetView] AS

/*******************************************************************************************************************  
  Object Description:
  View to populate the Multiple Asset scroll.
  Revision History:
  Date         Name             Label/PTS     Description
  -----------  ---------------  -----------   ----------------------------------------
  10/04/2016   Matt Zerefos     PTS: 100610   Added trailers3-8 and brought view up to standards.
  11/16/2016   Matt Zerefos     NSUITE-100610 Pull trailer1-8 info from StopTrailer table instead of TractorProfile.
  01/06/2017   Mike Luoma       NSUITE-200430 Add trc_require_drvtrl to View
********************************************************************************************************************/
WITH trlList AS (SELECT 
						d.trc_number
					, MAX(CASE WHEN f.strl_bucket = 1 THEN f.trl_id ELSE '' END) AS trl1
					, MAX(CASE WHEN f.strl_bucket = 2 THEN f.trl_id ELSE '' END) AS trl2
					, MAX(CASE WHEN f.strl_bucket = 3 THEN f.trl_id ELSE '' END) AS trl3
					, MAX(CASE WHEN f.strl_bucket = 4 THEN f.trl_id ELSE '' END) AS trl4
					, MAX(CASE WHEN f.strl_bucket = 5 THEN f.trl_id ELSE '' END) AS trl5
					, MAX(CASE WHEN f.strl_bucket = 6 THEN f.trl_id ELSE '' END) AS trl6
					, MAX(CASE WHEN f.strl_bucket = 7 THEN f.trl_id ELSE '' END) AS trl7
					, MAX(CASE WHEN f.strl_bucket = 8 THEN f.trl_id ELSE '' END) AS trl8

      
    FROM (SELECT b.stp_number
          , ast.trc_number
          , ast.lgh_number
          , ROW_NUMBER() OVER (PARTITION BY b.lgh_number ORDER BY b.stp_mfh_sequence DESC) AS stpRowNum 
          
        FROM (SELECT 
        ROW_NUMBER() OVER (PARTITION BY a.asgn_id ORDER BY a.asgn_endDate DESC) AS theRowNum
          , a.lgh_number
          , a.asgn_id AS trc_number
        FROM assetassignment a
        WHERE a.asgn_type = 'TRC'
            AND a.asgn_status IN ('STD', 'CMP') ) AS ast
      INNER JOIN dbo.stops b ON ast.lgh_number = b.lgh_number
      WHERE ast.theRowNum = 1 ) d 
    INNER JOIN dbo.StopTrailer f ON d.stp_number = f.stp_number
          AND f.strl_dropped <> 'Y'
    WHERE d.stpRowNum = 1
    GROUP BY d.trc_number) 


SELECT
  LTRIM(RTRIM(mpp_tractornumber)) + '|' + LTRIM(RTRIM(mpp_id)) + '|' + LTRIM(RTRIM(trc_trailer1)) + '|' + LTRIM(RTRIM(trc_trailer2)) AS 'ID'

  -- DRIVER
  ,mpp_id
  ,mpp_lastname
  ,mpp_firstname
  ,mpp_middlename
  ,mpp_status
  ,mpp_otherid
  ,mpp_type1		
  ,mpp_type2
  ,mpp_type3
  ,mpp_type4
  ,mpp_misc1
  ,mpp_misc2
  ,mpp_misc3
  ,mpp_misc4
  ,mpp_PlannedCity.cty_nmstct AS 'mpp_planned_cty_nmstct'
  ,mpp_AvailableCity.cty_state AS 'mpp_avail_cty_state'
  ,mpp_zip
  ,mpp_AvailableCity.cty_county AS 'mpp_avail_cty_county'
  ,mpp_company
  ,mpp_prior_region1
  ,mpp_prior_region2
  ,mpp_prior_region3
  ,mpp_prior_region4
  ,mpp_terminal
  ,mpp_division
  ,mpp_teamleader
  ,mpp_fleet
  ,COALESCE(mpp_gps_latitude, mpp_AvailableCity.cty_latitude) AS 'mpp_gps_latitude'
  ,COALESCE(mpp_gps_longitude, mpp_AvailableCity.cty_longitude) AS 'mpp_gps_longitude'

  -- TRACTOR
  ,COALESCE(tractorprofile.trc_number, 'UNKNOWN') AS 'trc_number'
  ,trc_type1
  ,trc_status
  ,trc_company
  ,trc_terminal
  ,trc_division
  ,trc_owner
  ,trc_fleet
  ,trc_licstate
  ,trc_licnum
  ,trc_serial
  ,trc_model  
  ,trc_make 
  ,trc_year 
  ,trc_type2
  ,trc_type3
  ,trc_type4
  ,trc_misc1
  ,trc_misc2
  ,trc_misc3
  ,trc_misc4
  ,trc_PlannedCity.cty_nmstct AS 'trc_planned_cty_nmstct' 
  ,trc_AvailableCity.cty_state AS 'trc_avail_cty_state'
  ,trc_AvailableCity.cty_zip AS 'trc_avail_cty_zip'
  ,trc_AvailableCity.cty_county AS 'trc_avail_cty_county'
  ,trc_avl_cmp_id
  ,trc_prior_region1
  ,trc_prior_region2
  ,trc_prior_region3
  ,trc_prior_region4
  ,COALESCE(trc_gps_latitude, trc_AvailableCity.cty_latitude) AS 'trc_gps_latitude'
  ,COALESCE(trc_gps_longitude, trc_AvailableCity.cty_longitude) AS 'trc_gps_longitude'
  ,trc_require_drvtrl

  -- TRAILER1
  ,COALESCE(trailer1.trl_number, 'UNKNOWN') AS 'trailer1_trl_number'
  ,trailer1.trl_id AS 'trailer1_trl_id'
  ,trailer1.cmp_id AS 'trailer1_cmp_id'
  ,trailer1.trl_company AS 'trailer1_trl_company'
  ,trailer1.trl_division AS 'trailer1_trl_division'
  ,trailer1.trl_fleet AS 'trailer1_trl_fleet'
  ,trailer1.trl_terminal AS 'trailer1_trl_terminal'
  ,trailer1.trl_owner AS 'trailer1_trl_owner'
  ,trailer1.trl_status AS 'trailer1_trl_status'
  ,trailer1.trl_licstate AS 'trailer1_trl_licstate'
  ,trailer1.trl_licnum AS 'trailer1_trl_licnum'
  ,trailer1.trl_serial AS 'trailer1_trl_serial'
  ,trailer1.trl_make AS 'trailer1_trl_make'
  ,trailer1.trl_model AS 'trailer1_trl_model'
  ,trailer1.trl_year AS 'trailer1_trl_year'
  ,trailer1.trl_type1 AS 'trailer1_trl_type1'
  ,trailer1.trl_type2 AS 'trailer1_trl_type2'
  ,trailer1.trl_type3 AS 'trailer1_trl_type3'
  ,trailer1.trl_type4 AS 'trailer1_trl_type4'
  ,trailer1.trl_misc1 AS 'trailer1_trl_misc1'
  ,trailer1.trl_misc2 AS 'trailer1_trl_misc2'
  ,trailer1.trl_misc3 AS 'trailer1_trl_misc3'
  ,trailer1.trl_misc4 AS 'trailer1_trl_misc4'
  ,trl1_PlannedCity.cty_nmstct AS 'trailer1_planned_cty_nmstct' 
  ,trl1_AvailableCity.cty_state AS 'trailer1_avail_cty_state'
  ,trl1_AvailableCity.cty_zip AS 'trailer1_avail_cty_zip'
  ,trl1_AvailableCity.cty_county AS 'trailer1_avail_cty_county'
  ,trailer1.trl_prior_region1 AS 'trailer1_trl_prior_region1'
  ,trailer1.trl_prior_region2 AS 'trailer1_trl_prior_region2'
  ,trailer1.trl_prior_region3 AS 'trailer1_trl_prior_region3'
  ,trailer1.trl_prior_region4 AS 'trailer1_trl_prior_region4'
  ,trailer1.trl_avail_cmp_id AS 'trailer1_trl_avail_cmp_id'
  ,COALESCE(trailer1.trl_gps_latitude, trl1_AvailableCity.cty_latitude) AS 'trailer1_trl_gps_latitude'
  ,COALESCE(trailer1.trl_gps_longitude, trl1_AvailableCity.cty_longitude) AS 'trailer1_trl_gps_longitude'

  -- TRAILER2
  ,COALESCE(trailer2.trl_number, 'UNKNOWN') AS 'trailer2_trl_number'
  ,trailer2.trl_id AS 'trailer2_trl_id'
  ,trailer2.cmp_id AS 'trailer2_cmp_id'
  ,trailer2.trl_company AS 'trailer2_trl_company'
  ,trailer2.trl_division AS 'trailer2_trl_division'
  ,trailer2.trl_fleet AS 'trailer2_trl_fleet'
  ,trailer2.trl_terminal AS 'trailer2_trl_terminal'
  ,trailer2.trl_owner AS 'trailer2_trl_owner'
  ,trailer2.trl_status AS 'trailer2_trl_status'
  ,trailer2.trl_licstate AS 'trailer2_trl_licstate'
  ,trailer2.trl_licnum AS 'trailer2_trl_licnum'
  ,trailer2.trl_serial AS 'trailer2_trl_serial'
  ,trailer2.trl_make AS 'trailer2_trl_make'
  ,trailer2.trl_model AS 'trailer2_trl_model'
  ,trailer2.trl_year AS 'trailer2_trl_year'
  ,trailer2.trl_type1 AS 'trailer2_trl_type1'
  ,trailer2.trl_type2 AS 'trailer2_trl_type2'
  ,trailer2.trl_type3 AS 'trailer2_trl_type3'
  ,trailer2.trl_type4 AS 'trailer2_trl_type4'
  ,trailer2.trl_misc1 AS 'trailer2_trl_misc1'
  ,trailer2.trl_misc2 AS 'trailer2_trl_misc2'
  ,trailer2.trl_misc3 AS 'trailer2_trl_misc3'
  ,trailer2.trl_misc4 AS 'trailer2_trl_misc4'
  ,trl2_PlannedCity.cty_nmstct AS 'trailer2_planned_cty_nmstct' 
  ,trl2_AvailableCity.cty_state AS 'trailer2_avail_cty_state'
  ,trl2_AvailableCity.cty_zip AS 'trailer2_avail_cty_zip'
  ,trl2_AvailableCity.cty_county AS 'trailer2_avail_cty_county'
  ,trailer2.trl_prior_region1 AS 'trailer2_trl_prior_region1'
  ,trailer2.trl_prior_region2 AS 'trailer2_trl_prior_region2'
  ,trailer2.trl_prior_region3 AS 'trailer2_trl_prior_region3'
  ,trailer2.trl_prior_region4 AS 'trailer2_trl_prior_region4'
  ,trailer2.trl_avail_cmp_id AS 'trailer2_trl_avail_cmp_id'
  ,COALESCE(trailer2.trl_gps_latitude, trl2_AvailableCity.cty_latitude) AS 'trailer2_trl_gps_latitude'
  ,COALESCE(trailer2.trl_gps_longitude, trl2_AvailableCity.cty_longitude) AS 'trailer2_trl_gps_longitude'

  -- TRAILER3
  ,COALESCE(trailer3.trl_number, 'UNKNOWN') AS 'trailer3_trl_number'
  ,trailer3.trl_id AS 'trailer3_trl_id'
  ,trailer3.cmp_id AS 'trailer3_cmp_id'
  ,trailer3.trl_company AS 'trailer3_trl_company'
  ,trailer3.trl_division AS 'trailer3_trl_division'
  ,trailer3.trl_fleet AS 'trailer3_trl_fleet'
  ,trailer3.trl_terminal AS 'trailer3_trl_terminal'
  ,trailer3.trl_owner AS 'trailer3_trl_owner'
  ,trailer3.trl_status AS 'trailer3_trl_status'
  ,trailer3.trl_licstate AS 'trailer3_trl_licstate'
  ,trailer3.trl_licnum AS 'trailer3_trl_licnum'
  ,trailer3.trl_serial AS 'trailer3_trl_serial'
  ,trailer3.trl_make AS 'trailer3_trl_make'
  ,trailer3.trl_model AS 'trailer3_trl_model'
  ,trailer3.trl_year AS 'trailer3_trl_year'
  ,trailer3.trl_type1 AS 'trailer3_trl_type1'
  ,trailer3.trl_type2 AS 'trailer3_trl_type2'
  ,trailer3.trl_type3 AS 'trailer3_trl_type3'
  ,trailer3.trl_type4 AS 'trailer3_trl_type4'
  ,trailer3.trl_misc1 AS 'trailer3_trl_misc1'
  ,trailer3.trl_misc2 AS 'trailer3_trl_misc2'
  ,trailer3.trl_misc3 AS 'trailer3_trl_misc3'
  ,trailer3.trl_misc4 AS 'trailer3_trl_misc4'
  ,trl3_PlannedCity.cty_nmstct AS 'trailer3_planned_cty_nmstct' 
  ,trl3_AvailableCity.cty_state AS 'trailer3_avail_cty_state'
  ,trl3_AvailableCity.cty_zip AS 'trailer3_avail_cty_zip'
  ,trl3_AvailableCity.cty_county AS 'trailer3_avail_cty_county'
  ,trailer3.trl_prior_region1 AS 'trailer3_trl_prior_region1'
  ,trailer3.trl_prior_region2 AS 'trailer3_trl_prior_region2'
  ,trailer3.trl_prior_region3 AS 'trailer3_trl_prior_region3'
  ,trailer3.trl_prior_region4 AS 'trailer3_trl_prior_region4'
  ,trailer3.trl_avail_cmp_id AS 'trailer3_trl_avail_cmp_id'
  ,COALESCE(trailer3.trl_gps_latitude, trl3_AvailableCity.cty_latitude) AS 'trailer3_trl_gps_latitude'
  ,COALESCE(trailer3.trl_gps_longitude, trl3_AvailableCity.cty_longitude) AS 'trailer3_trl_gps_longitude'

  -- TRAILER4
  ,COALESCE(trailer4.trl_number, 'UNKNOWN') AS 'trailer4_trl_number'
  ,trailer4.trl_id AS 'trailer4_trl_id'
  ,trailer4.cmp_id AS 'trailer4_cmp_id'
  ,trailer4.trl_company AS 'trailer4_trl_company'
  ,trailer4.trl_division AS 'trailer4_trl_division'
  ,trailer4.trl_fleet AS 'trailer4_trl_fleet'
  ,trailer4.trl_terminal AS 'trailer4_trl_terminal'
  ,trailer4.trl_owner AS 'trailer4_trl_owner'
  ,trailer4.trl_status AS 'trailer4_trl_status'
  ,trailer4.trl_licstate AS 'trailer4_trl_licstate'
  ,trailer4.trl_licnum AS 'trailer4_trl_licnum'
  ,trailer4.trl_serial AS 'trailer4_trl_serial'
  ,trailer4.trl_make AS 'trailer4_trl_make'
  ,trailer4.trl_model AS 'trailer4_trl_model'
  ,trailer4.trl_year AS 'trailer4_trl_year'
  ,trailer4.trl_type1 AS 'trailer4_trl_type1'
  ,trailer4.trl_type2 AS 'trailer4_trl_type2'
  ,trailer4.trl_type3 AS 'trailer4_trl_type3'
  ,trailer4.trl_type4 AS 'trailer4_trl_type4'
  ,trailer4.trl_misc1 AS 'trailer4_trl_misc1'
  ,trailer4.trl_misc2 AS 'trailer4_trl_misc2'
  ,trailer4.trl_misc3 AS 'trailer4_trl_misc3'
  ,trailer4.trl_misc4 AS 'trailer4_trl_misc4'
  ,trl4_PlannedCity.cty_nmstct AS 'trailer4_planned_cty_nmstct' 
  ,trl4_AvailableCity.cty_state AS 'trailer4_avail_cty_state'
  ,trl4_AvailableCity.cty_zip AS 'trailer4_avail_cty_zip'
  ,trl4_AvailableCity.cty_county AS 'trailer4_avail_cty_county'
  ,trailer4.trl_prior_region1 AS 'trailer4_trl_prior_region1'
  ,trailer4.trl_prior_region2 AS 'trailer4_trl_prior_region2'
  ,trailer4.trl_prior_region3 AS 'trailer4_trl_prior_region3'
  ,trailer4.trl_prior_region4 AS 'trailer4_trl_prior_region4'
  ,trailer4.trl_avail_cmp_id AS 'trailer4_trl_avail_cmp_id'
  ,COALESCE(trailer4.trl_gps_latitude, trl4_AvailableCity.cty_latitude) AS 'trailer4_trl_gps_latitude'
  ,COALESCE(trailer4.trl_gps_longitude, trl4_AvailableCity.cty_longitude) AS 'trailer4_trl_gps_longitude'

  -- TRAILER5
  ,COALESCE(trailer5.trl_number, 'UNKNOWN') AS 'trailer5_trl_number'
  ,trailer5.trl_id AS 'trailer5_trl_id'
  ,trailer5.cmp_id AS 'trailer5_cmp_id'
  ,trailer5.trl_company AS 'trailer5_trl_company'
  ,trailer5.trl_division AS 'trailer5_trl_division'
  ,trailer5.trl_fleet AS 'trailer5_trl_fleet'
  ,trailer5.trl_terminal AS 'trailer5_trl_terminal'
  ,trailer5.trl_owner AS 'trailer5_trl_owner'
  ,trailer5.trl_status AS 'trailer5_trl_status'
  ,trailer5.trl_licstate AS 'trailer5_trl_licstate'
  ,trailer5.trl_licnum AS 'trailer5_trl_licnum'
  ,trailer5.trl_serial AS 'trailer5_trl_serial'
  ,trailer5.trl_make AS 'trailer5_trl_make'
  ,trailer5.trl_model AS 'trailer5_trl_model'
  ,trailer5.trl_year AS 'trailer5_trl_year'
  ,trailer5.trl_type1 AS 'trailer5_trl_type1'
  ,trailer5.trl_type2 AS 'trailer5_trl_type2'
  ,trailer5.trl_type3 AS 'trailer5_trl_type3'
  ,trailer5.trl_type4 AS 'trailer5_trl_type4'
  ,trailer5.trl_misc1 AS 'trailer5_trl_misc1'
  ,trailer5.trl_misc2 AS 'trailer5_trl_misc2'
  ,trailer5.trl_misc3 AS 'trailer5_trl_misc3'
  ,trailer5.trl_misc4 AS 'trailer5_trl_misc4'
  ,trl5_PlannedCity.cty_nmstct AS 'trailer5_planned_cty_nmstct' 
  ,trl5_AvailableCity.cty_state AS 'trailer5_avail_cty_state'
  ,trl5_AvailableCity.cty_zip AS 'trailer5_avail_cty_zip'
  ,trl5_AvailableCity.cty_county AS 'trailer5_avail_cty_county'
  ,trailer5.trl_prior_region1 AS 'trailer5_trl_prior_region1'
  ,trailer5.trl_prior_region2 AS 'trailer5_trl_prior_region2'
  ,trailer5.trl_prior_region3 AS 'trailer5_trl_prior_region3'
  ,trailer5.trl_prior_region4 AS 'trailer5_trl_prior_region4'
  ,trailer5.trl_avail_cmp_id AS 'trailer5_trl_avail_cmp_id'
  ,COALESCE(trailer5.trl_gps_latitude, trl5_AvailableCity.cty_latitude) AS 'trailer5_trl_gps_latitude'
  ,COALESCE(trailer5.trl_gps_longitude, trl5_AvailableCity.cty_longitude) AS 'trailer5_trl_gps_longitude'

  -- TRAILER6
  ,COALESCE(trailer6.trl_number, 'UNKNOWN') AS 'trailer6_trl_number'
  ,trailer6.trl_id AS 'trailer6_trl_id'
  ,trailer6.cmp_id AS 'trailer6_cmp_id'
  ,trailer6.trl_company AS 'trailer6_trl_company'
  ,trailer6.trl_division AS 'trailer6_trl_division'
  ,trailer6.trl_fleet AS 'trailer6_trl_fleet'
  ,trailer6.trl_terminal AS 'trailer6_trl_terminal'
  ,trailer6.trl_owner AS 'trailer6_trl_owner'
  ,trailer6.trl_status AS 'trailer6_trl_status'
  ,trailer6.trl_licstate AS 'trailer6_trl_licstate'
  ,trailer6.trl_licnum AS 'trailer6_trl_licnum'
  ,trailer6.trl_serial AS 'trailer6_trl_serial'
  ,trailer6.trl_make AS 'trailer6_trl_make'
  ,trailer6.trl_model AS 'trailer6_trl_model'
  ,trailer6.trl_year AS 'trailer6_trl_year'
  ,trailer6.trl_type1 AS 'trailer6_trl_type1'
  ,trailer6.trl_type2 AS 'trailer6_trl_type2'
  ,trailer6.trl_type3 AS 'trailer6_trl_type3'
  ,trailer6.trl_type4 AS 'trailer6_trl_type4'
  ,trailer6.trl_misc1 AS 'trailer6_trl_misc1'
  ,trailer6.trl_misc2 AS 'trailer6_trl_misc2'
  ,trailer6.trl_misc3 AS 'trailer6_trl_misc3'
  ,trailer6.trl_misc4 AS 'trailer6_trl_misc4'
  ,trl6_PlannedCity.cty_nmstct AS 'trailer6_planned_cty_nmstct' 
  ,trl6_AvailableCity.cty_state AS 'trailer6_avail_cty_state'
  ,trl6_AvailableCity.cty_zip AS 'trailer6_avail_cty_zip'
  ,trl6_AvailableCity.cty_county AS 'trailer6_avail_cty_county'
  ,trailer6.trl_prior_region1 AS 'trailer6_trl_prior_region1'
  ,trailer6.trl_prior_region2 AS 'trailer6_trl_prior_region2'
  ,trailer6.trl_prior_region3 AS 'trailer6_trl_prior_region3'
  ,trailer6.trl_prior_region4 AS 'trailer6_trl_prior_region4'
  ,trailer6.trl_avail_cmp_id AS 'trailer6_trl_avail_cmp_id'
  ,COALESCE(trailer6.trl_gps_latitude, trl6_AvailableCity.cty_latitude) AS 'trailer6_trl_gps_latitude'
  ,COALESCE(trailer6.trl_gps_longitude, trl6_AvailableCity.cty_longitude) AS 'trailer6_trl_gps_longitude'

  -- TRAILER7
  ,COALESCE(trailer7.trl_number, 'UNKNOWN') AS 'trailer7_trl_number'
  ,trailer7.trl_id AS 'trailer7_trl_id'
  ,trailer7.cmp_id AS 'trailer7_cmp_id'
  ,trailer7.trl_company AS 'trailer7_trl_company'
  ,trailer7.trl_division AS 'trailer7_trl_division'
  ,trailer7.trl_fleet AS 'trailer7_trl_fleet'
  ,trailer7.trl_terminal AS 'trailer7_trl_terminal'
  ,trailer7.trl_owner AS 'trailer7_trl_owner'
  ,trailer7.trl_status AS 'trailer7_trl_status'
  ,trailer7.trl_licstate AS 'trailer7_trl_licstate'
  ,trailer7.trl_licnum AS 'trailer7_trl_licnum'
  ,trailer7.trl_serial AS 'trailer7_trl_serial'
  ,trailer7.trl_make AS 'trailer7_trl_make'
  ,trailer7.trl_model AS 'trailer7_trl_model'
  ,trailer7.trl_year AS 'trailer7_trl_year'
  ,trailer7.trl_type1 AS 'trailer7_trl_type1'
  ,trailer7.trl_type2 AS 'trailer7_trl_type2'
  ,trailer7.trl_type3 AS 'trailer7_trl_type3'
  ,trailer7.trl_type4 AS 'trailer7_trl_type4'
  ,trailer7.trl_misc1 AS 'trailer7_trl_misc1'
  ,trailer7.trl_misc2 AS 'trailer7_trl_misc2'
  ,trailer7.trl_misc3 AS 'trailer7_trl_misc3'
  ,trailer7.trl_misc4 AS 'trailer7_trl_misc4'
  ,trl7_PlannedCity.cty_nmstct AS 'trailer7_planned_cty_nmstct' 
  ,trl7_AvailableCity.cty_state AS 'trailer7_avail_cty_state'
  ,trl7_AvailableCity.cty_zip AS 'trailer7_avail_cty_zip'
  ,trl7_AvailableCity.cty_county AS 'trailer7_avail_cty_county'
  ,trailer7.trl_prior_region1 AS 'trailer7_trl_prior_region1'
  ,trailer7.trl_prior_region2 AS 'trailer7_trl_prior_region2'
  ,trailer7.trl_prior_region3 AS 'trailer7_trl_prior_region3'
  ,trailer7.trl_prior_region4 AS 'trailer7_trl_prior_region4'
  ,trailer7.trl_avail_cmp_id AS 'trailer7_trl_avail_cmp_id'
  ,COALESCE(trailer7.trl_gps_latitude, trl7_AvailableCity.cty_latitude) AS 'trailer7_trl_gps_latitude'
  ,COALESCE(trailer7.trl_gps_longitude, trl7_AvailableCity.cty_longitude) AS 'trailer7_trl_gps_longitude'

  -- TRAILER8
  ,COALESCE(trailer8.trl_number, 'UNKNOWN') AS 'trailer8_trl_number'
  ,trailer8.trl_id AS 'trailer8_trl_id'
  ,trailer8.cmp_id AS 'trailer8_cmp_id'
  ,trailer8.trl_company AS 'trailer8_trl_company'
  ,trailer8.trl_division AS 'trailer8_trl_division'
  ,trailer8.trl_fleet AS 'trailer8_trl_fleet'
  ,trailer8.trl_terminal AS 'trailer8_trl_terminal'
  ,trailer8.trl_owner AS 'trailer8_trl_owner'
  ,trailer8.trl_status AS 'trailer8_trl_status'
  ,trailer8.trl_licstate AS 'trailer8_trl_licstate'
  ,trailer8.trl_licnum AS 'trailer8_trl_licnum'
  ,trailer8.trl_serial AS 'trailer8_trl_serial'
  ,trailer8.trl_make AS 'trailer8_trl_make'
  ,trailer8.trl_model AS 'trailer8_trl_model'
  ,trailer8.trl_year AS 'trailer8_trl_year'
  ,trailer8.trl_type1 AS 'trailer8_trl_type1'
  ,trailer8.trl_type2 AS 'trailer8_trl_type2'
  ,trailer8.trl_type3 AS 'trailer8_trl_type3'
  ,trailer8.trl_type4 AS 'trailer8_trl_type4'
  ,trailer8.trl_misc1 AS 'trailer8_trl_misc1'
  ,trailer8.trl_misc2 AS 'trailer8_trl_misc2'
  ,trailer8.trl_misc3 AS 'trailer8_trl_misc3'
  ,trailer8.trl_misc4 AS 'trailer8_trl_misc4'
  ,trl8_PlannedCity.cty_nmstct AS 'trailer8_planned_cty_nmstct' 
  ,trl8_AvailableCity.cty_state AS 'trailer8_avail_cty_state'
  ,trl8_AvailableCity.cty_zip AS 'trailer8_avail_cty_zip'
  ,trl8_AvailableCity.cty_county AS 'trailer8_avail_cty_county'
  ,trailer8.trl_prior_region1 AS 'trailer8_trl_prior_region1'
  ,trailer8.trl_prior_region2 AS 'trailer8_trl_prior_region2'
  ,trailer8.trl_prior_region3 AS 'trailer8_trl_prior_region3'
  ,trailer8.trl_prior_region4 AS 'trailer8_trl_prior_region4'
  ,trailer8.trl_avail_cmp_id AS 'trailer8_trl_avail_cmp_id'
  ,COALESCE(trailer8.trl_gps_latitude, trl8_AvailableCity.cty_latitude) AS 'trailer8_trl_gps_latitude'
  ,COALESCE(trailer8.trl_gps_longitude, trl8_AvailableCity.cty_longitude) AS 'trailer8_trl_gps_longitude'

FROM dbo.manpowerprofile (NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', null) rsva ON (manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
		LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.manpowerprofile.mpp_city = dbo.city.cty_code 
		LEFT OUTER JOIN dbo.city AS mpp_AvailableCity (NOLOCK) ON dbo.manpowerprofile.mpp_avl_city = mpp_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS mpp_PlannedCity (NOLOCK) ON dbo.manpowerprofile.mpp_pln_city = mpp_PlannedCity.cty_code

		LEFT OUTER JOIN dbo.tractorprofile (NOLOCK) ON (dbo.manpowerprofile.mpp_tractornumber = dbo.tractorprofile.trc_number AND dbo.manpowerprofile.mpp_tractornumber <> 'UNKNOWN')
		LEFT OUTER JOIN dbo.city AS trc_AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = trc_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trc_PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = trc_PlannedCity.cty_code
    
		LEFT OUTER JOIN trlList tl ON manpowerprofile.mpp_tractornumber = tl.trc_number

    LEFT OUTER JOIN dbo.trailerprofile AS trailer1 (NOLOCK) ON trailer1.trl_id = tl.trl1
		LEFT OUTER JOIN dbo.city AS trl1_AvailableCity (NOLOCK) ON trailer1.trl_avail_city = trl1_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl1_PlannedCity (NOLOCK) ON trailer1.trl_next_city = trl1_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer2 (NOLOCK) ON trailer2.trl_id = tl.trl2
		LEFT OUTER JOIN dbo.city AS trl2_AvailableCity (NOLOCK) ON trailer2.trl_avail_city = trl2_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl2_PlannedCity (NOLOCK) ON trailer2.trl_next_city = trl2_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer3 (NOLOCK) ON trailer3.trl_id = tl.trl3
		LEFT OUTER JOIN dbo.city AS trl3_AvailableCity (NOLOCK) ON trailer3.trl_avail_city = trl3_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl3_PlannedCity (NOLOCK) ON trailer3.trl_next_city = trl3_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer4 (NOLOCK) ON trailer4.trl_id = tl.trl4
		LEFT OUTER JOIN dbo.city AS trl4_AvailableCity (NOLOCK) ON trailer4.trl_avail_city = trl4_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl4_PlannedCity (NOLOCK) ON trailer4.trl_next_city = trl4_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer5 (NOLOCK) ON trailer5.trl_id = tl.trl5
		LEFT OUTER JOIN dbo.city AS trl5_AvailableCity (NOLOCK) ON trailer5.trl_avail_city = trl5_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl5_PlannedCity (NOLOCK) ON trailer5.trl_next_city = trl5_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer6 (NOLOCK) ON trailer6.trl_id = tl.trl6
		LEFT OUTER JOIN dbo.city AS trl6_AvailableCity (NOLOCK) ON trailer6.trl_avail_city = trl6_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl6_PlannedCity (NOLOCK) ON trailer6.trl_next_city = trl6_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer7 (NOLOCK) ON trailer7.trl_id = tl.trl7
		LEFT OUTER JOIN dbo.city AS trl7_AvailableCity (NOLOCK) ON trailer7.trl_avail_city = trl7_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl7_PlannedCity (NOLOCK) ON trailer7.trl_next_city = trl7_PlannedCity.cty_code

    LEFT OUTER JOIN dbo.trailerprofile AS trailer8 (NOLOCK) ON trailer8.trl_id = tl.trl8
		LEFT OUTER JOIN dbo.city AS trl8_AvailableCity (NOLOCK) ON trailer8.trl_avail_city = trl8_AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city AS trl8_PlannedCity (NOLOCK) ON trailer8.trl_next_city = trl8_PlannedCity.cty_code	;
GO
GRANT SELECT ON  [dbo].[TMWScrollMultipleAssetView] TO [public]
GO

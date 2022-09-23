SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[DriverSeatTripPayView]
AS
     SELECT 
	   
     /*Required Columns*/

     ISNULL(assetassignment.lgh_number, 0) lgh_number,
     asgn_date,
     assetassignment.asgn_type,
     assetassignment.asgn_id,
	   
     /*End Required Columns*/

     /*Start Optional Columns*/

     (
         SELECT STUFF(
                     (
                         SELECT ','+CONVERT( VARCHAR(20), ord_number)
                         FROM orderHeader oh
                         WHERE oh.ord_hdrnumber = lh.ord_hdrnumber
                         FOR XML PATH('')
                     ), 1, 1, '')
     ) OrderNumbers,
     ISNULL(CONVERT( DECIMAL(8, 2),
                   (
                       SELECT SUM(ISNULL(sLoaded.stp_lgh_mileage, 0))
                       FROM stops sLoaded
                       WHERE sLoaded.lgh_number = assetassignment.lgh_number
                             AND ISNULL(sLoaded.stp_status, '') != ''
                             AND ISNULL(sLoaded.stp_loadstatus, '') = 'LD'
                   )), 0.0) LoadedMileage,
     ISNULL(CONVERT( DECIMAL(8, 2),
                   (
                       SELECT SUM(ISNULL(sLoaded.stp_lgh_mileage, 0))
                       FROM stops sLoaded
                       WHERE sLoaded.lgh_number = assetassignment.lgh_number
                             AND ISNULL(sLoaded.stp_status, '') != ''
                             AND ISNULL(sLoaded.stp_loadstatus, '') = 'MT'
                   )), 0.0) EmptyMileage,
     (
         SELECT ISNULL(SUM(pdCompensation.pyd_amount), 0)
         FROM payDetail pdCompensation
         WHERE pdCompensation.lgh_number = assetassignment.lgh_number
               AND ISNULL(pdCompensation.pyd_status, '') != 'HLD'
               AND ISNULL(pdCompensation.pyd_pretax, '') = 'Y'
     ) TotalCompensation,
     (
         SELECT ISNULL(SUM(pdDeductions.pyd_amount), 0)
         FROM payDetail pdDeductions
         WHERE pdDeductions.lgh_number = assetassignment.lgh_number
               AND ISNULL(pdDeductions.pyd_status, '') != 'HLD'
               AND ISNULL(pdDeductions.pyd_pretax, '') = 'N'
               AND pdDeductions.pyd_minus = -1
     ) TotalDeductions,
     (
         SELECT ISNULL(SUM(pdReimbursement.pyd_amount), 0)
         FROM payDetail pdReimbursement
         WHERE pdReimbursement.lgh_number = assetassignment.lgh_number
               AND ISNULL(pdReimbursement.pyd_status, '') != 'HLD'
               AND ISNULL(pdReimbursement.pyd_pretax, '') = 'N'
               AND pdReimbursement.pyd_minus = 1
     ) TotalReimbursement,
	   
     /*End Optional Columns*/

     estart.evt_driver1,
     estart.evt_tractor,
     sstart.stp_arrivaldate AS StartDate,
     (
         SELECT cty_nmstct
         FROM city
         WHERE(cty_code = sstart.stp_city)
     ) AS StartCity, 
     -- CONVERT(VARCHAR,sstart.stp_arrivaldate, 103) +' '+ CONVERT(VARCHAR,sstart.stp_arrivaldate, 108) + 
     -- + '\n' + 
     --(SELECT cty_nmstct FROM city WHERE  (cty_code = sstart.stp_city))  AS StartDateCity, 
     sstart.cmp_id AS StartCmpId,
     sstart.cmp_name AS StartName,
     send.stp_departuredate AS EndDate,
     (
         SELECT cty_nmstct
         FROM city
         WHERE(cty_code = send.stp_city)
     ) AS EndCity,
     send.cmp_id AS EndCmpId,
     send.cmp_name AS EndName,
     lh.lgh_outstatus
     FROM assetassignment
          INNER JOIN event AS estart ON assetassignment.evt_number = estart.evt_number
          INNER JOIN stops AS sstart ON estart.stp_number = sstart.stp_number
          INNER JOIN event AS eend ON assetassignment.last_evt_number = eend.evt_number
          INNER JOIN stops AS send ON eend.stp_number = send.stp_number
          INNER JOIN legheader lh ON assetassignment.lgh_number = lh.lgh_number
          INNER JOIN orderHeader oh ON oh.ord_hdrnumber = lh.ord_hdrnumber
     WHERE assetassignment.asgn_status = 'CMP'; --added to utilize idx_AsgnStatus_AsgnType_AsgnDate_AsgnId key. Should always be 'cmp' if they are looking for pay?
GO
GRANT INSERT ON  [dbo].[DriverSeatTripPayView] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverSeatTripPayView] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverSeatTripPayView] TO [public]
GO

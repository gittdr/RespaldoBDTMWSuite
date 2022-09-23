SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE VIEW [dbo].[OperationsTripViewDetailsWithRequiredHours]
AS     

SELECT	a.*,
		(SELECT SUM(ISNULL(mt.mt_hours, 0)) FROM stops s LEFT OUTER JOIN mileagetable mt ON mt.mt_identity = s.stp_lgh_mileage_mtid WHERE s.lgh_number = a.lgh_number) 'RequiredDriveHours',
		(SELECT SUM(ISNULL(mt.mt_hours, 0)) + SUM(DATEDIFF(mi, s.stp_arrivaldate, s.stp_departuredate))/60 FROM stops s LEFT OUTER JOIN mileagetable mt ON mt.mt_identity = s.stp_lgh_mileage_mtid WHERE s.lgh_number = a.lgh_number) 'RequiredDutyHours'
  FROM	OperationsTripViewDetails a WITH(NOLOCK)
GO
GRANT SELECT ON  [dbo].[OperationsTripViewDetailsWithRequiredHours] TO [public]
GO

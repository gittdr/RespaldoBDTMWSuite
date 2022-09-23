SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vTTSTMW_DriverTraining] 
AS 
SELECT     dbo.drivertraining.drr_traindate AS [Training Date], 
           dbo.drivertraining.drr_hours AS [Training Hours], 
           dbo.drivertraining.drr_type AS [Training Type], 
           dbo.drivertraining.drr_instructor AS [Training Instructor], 
           dbo.drivertraining.drr_description AS [Training Description], 
           dbo.drivertraining.drr_code AS [Training Code], 
	(Select dbo.labelfile.name from dbo.labelfile (nolock) where dbo.drivertraining.drr_code = dbo.labelfile.abbr and dbo.labelfile.labeldefinition = 'DrvTrnCd')as [Training Name],
           dbo.vTTSTMW_DriverProfile.* 
FROM       dbo.vTTSTMW_DriverProfile INNER JOIN 
           dbo.drivertraining (NOLOCK) ON dbo.vTTSTMW_DriverProfile.[Driver ID] = dbo.drivertraining.mpp_id 


GO

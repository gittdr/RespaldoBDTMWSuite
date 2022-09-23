SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VTTS_opabiinact] as
select 

[Tractor ID],	[Driver ID],	[Available Company ID],[DaysInactive],[Driver Status],[Team Leader Name],
[Fleet Name],	DrvType3, [GPS Date],	[GPS Description]


From VTTSTMW_inactivitybydriver


where
(DaysInactive > 1) And (DrvType3 = 'BAJ') And ([Driver Status] not in ( 'VAC','LIC','HOME','BAJAA','SIC'))

GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_lastpumptransac] as


select top 1 format(fp_date,'dd-MM-yyyy hh:mm:ss') +' - '  + format(GETDATE(),'dd-MM-yyyy HH:mm:ss') as lastdate
from fuelpurchased
where fp_enteredby = 'ExxiaWs'
 order by fp_date desc
GO

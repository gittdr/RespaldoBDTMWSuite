SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogInsertIntoWorkFlowQueue] (@WatchDogSN int, @WatchName varchar(255), @xml text )
AS
	if exists (select * from WatchDogParameter where Heading = 'System' and SubHeading = 'WorkCycle' and ParameterName = 'WorkCycleEnabledYN' and ParameterValue = 'Y')
		if exists (select * from dbo.sysobjects where id = object_id(N'[tblWatchDogWorkFlowQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) 
		BEGIN 
				insert into tblWatchDogWorkFlowQueue (WatchSn,WatchName,LastUpdate,WatchXMLData) Values 
				(@WatchDogSN, @WatchName, getdate(), @XML) 
        END 
        ELSE 
			SELECT NewSN = -1 
GO
GRANT EXECUTE ON  [dbo].[WatchdogInsertIntoWorkFlowQueue] TO [public]
GO

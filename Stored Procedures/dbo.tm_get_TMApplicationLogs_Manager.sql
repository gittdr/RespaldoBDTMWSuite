SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[tm_get_inbox2]    Script Date: 12/05/2009 17:58:44 ******/

CREATE PROCEDURE [dbo].[tm_get_TMApplicationLogs_Manager]	
					@LogEntrySN int,
					@MCSN int,
					@MCInstance varchar(50),
					@PollerInstance varchar(50),
					@AssemblyName varchar(256),
					@ModuleName varchar(256),
					@MethodName varchar(256),
					@StepDescription varchar(4000),
					@Message varchar(4000),
					@SessionID int,
					@MaxLogs int,
					@FromDate datetime,
					@ToDate datetime,
					@OrderByDateOrder varchar(20)
AS
/**
 * 
 * NAME:
 * dbo.[tm_get_TMApplicationLogs_Manager]
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	general functionality of this proc
 *   
 *
 * REVISION HISTORY:
 * 12/05/2009 - created
 * 02/13/2013 - PTS67024 - APC - remove lines setting db connection flags
 **/

/* [tm_get_TMApplicationLogs_Manager]
 **************************************************************
******************************************/
SET NOCOUNT ON

DECLARE @Temp datetime

--CREATE TABLE #T2 ( DTSent datetime NULL, SN int ) 
CREATE TABLE #T2 (SN int ) 

INSERT #T2 EXECUTE dbo.tm_get_TMApplicationLogs_Manager_help @LogEntrySN,
					@MCSN,
					@MCInstance,
					@PollerInstance,
					@AssemblyName,
					@ModuleName,
					@MethodName,
					@StepDescription,
					@Message,
					@SessionID,
					@MaxLogs,
					@FromDate,
					@ToDate,
					@OrderByDateOrder


-- Go collect and return the data.
SELECT tblTMApplicationLog.SN,
            tblTMApplicationLog.MCSN, 
            tblTMApplicationLog.MCInstance, 
            tblTMApplicationLog.PollerInstance, 
            tblTMApplicationLog.MessageDate, 
            tblTMApplicationLog.AssemblyName, 
            tblTMApplicationLog.ModuleName, 
            tblTMApplicationLog.MethodName, 
            tblTMApplicationLog.StepDescription, 
            tblTMApplicationLog.[Message], 
            tblTMApplicationLog.SessionID 
FROM #T2  
WITH (NOLOCK)
INNER JOIN tblTMApplicationLog (NOLOCK) ON #T2.SN = tblTMApplicationLog.SN 

GO
GRANT EXECUTE ON  [dbo].[tm_get_TMApplicationLogs_Manager] TO [public]
GO

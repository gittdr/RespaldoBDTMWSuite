SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE      Procedure [dbo].[sp_TTSTMWGetManagementReportingObjects]

As

Select ReportName,ObjectSource,ObjectName,ObjectType

from

(

Select   rao_reportname as ReportName,rao_source as ObjectSource,Min(name) as ObjectName,xtype as ObjectType
From     sysobjects Inner Join MR_CannedReportsAndObjects On sysobjects.name = MR_CannedReportsAndObjects.rao_object
Where    (name Like 'sp_TTSTMW%')
Group By rao_reportname,rao_source,xtype

Union

Select rl_name as ReportName,'ReportWizard' as ObjectSource,rl_reference as ObjectName,xtype as ObjectType
from   MR_ReportingLibrary,sysobjects
where  (name Like 'vTTSTMW%' and xtype = 'V') 
       And
       sysobjects.name = rl_reference
       And
       rl_type = 'View'

) as TempMRObjects

Order By ReportName








GO

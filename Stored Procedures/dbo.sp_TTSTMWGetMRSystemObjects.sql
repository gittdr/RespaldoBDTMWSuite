SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









Create     Procedure [dbo].[sp_TTSTMWGetMRSystemObjects]

As



Select   rao_reportname as ReportName,rao_source as ObjectSource,name as ObjectName,xtype as ObjectType
From     sysobjects Inner Join MR_CannedReportsAndObjects On sysobjects.name = MR_CannedReportsAndObjects.rao_object
Where    (name Like 'MR%')
Order By rao_reportname









GO

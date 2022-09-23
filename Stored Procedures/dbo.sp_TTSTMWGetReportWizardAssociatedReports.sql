SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Procedure [dbo].[sp_TTSTMWGetReportWizardAssociatedReports](@sqlobject varchar(400),@objectsource varchar(400))

as

Select rl_name as ReportName ,rl_reference as ObjectName,'ReportWizard' as ObjectSource
from   MR_ReportingLibrary
where  rl_reference = @sqlobject
       and 
       rl_type = 'custom'
       and
       @objectsource = 'ReportWizard'




GO

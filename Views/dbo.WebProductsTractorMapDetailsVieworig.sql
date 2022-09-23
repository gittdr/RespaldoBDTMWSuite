SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create VIEW [dbo].[WebProductsTractorMapDetailsVieworig] as
SELECT       trc_number AS number, trc_status AS status
FROM         dbo.tractorprofile
GO

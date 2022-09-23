SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebProductsTractorMapDetailsView] as
SELECT       trc_number AS number, trc_status AS status
FROM         dbo.tractorprofile 
GO
GRANT SELECT ON  [dbo].[WebProductsTractorMapDetailsView] TO [public]
GO

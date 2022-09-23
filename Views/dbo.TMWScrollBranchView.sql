SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollBranchView] AS
SELECT
dbo.branch.*
FROM dbo.Branch (nolock)

GO
GRANT DELETE ON  [dbo].[TMWScrollBranchView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollBranchView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollBranchView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollBranchView] TO [public]
GO

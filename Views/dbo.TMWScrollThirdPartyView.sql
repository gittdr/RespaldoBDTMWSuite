SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollThirdPartyView] AS

SELECT tpp.* 
FROM dbo.ThirdPartyProfileRowRestrictedView tpp (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[TMWScrollThirdPartyView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollThirdPartyView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollThirdPartyView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollThirdPartyView] TO [public]
GO

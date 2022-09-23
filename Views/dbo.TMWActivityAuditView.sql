SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMWActivityAuditView] as select * from expedite_audit_tbl with (nolock)
GO
GRANT SELECT ON  [dbo].[TMWActivityAuditView] TO [public]
GO

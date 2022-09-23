SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[expedite_audit] as select * from expedite_audit_tbl with (nolock)
GO
GRANT INSERT ON  [dbo].[expedite_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[expedite_audit] TO [public]
GO

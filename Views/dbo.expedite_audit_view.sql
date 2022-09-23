SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[expedite_audit_view]
AS
SELECT expedite_audit_tbl.*, eaad_datetime
  FROM expedite_audit_tbl WITH (NOLOCK) LEFT OUTER JOIN expedite_audit_arrival_departure ON
                                        expedite_audit_tbl.expedite_audit_ident = expedite_audit_arrival_departure.expedite_audit_ident
GO
GRANT SELECT ON  [dbo].[expedite_audit_view] TO [public]
GO

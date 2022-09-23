CREATE TABLE [dbo].[expedite_audit_arrival_departure]
(
[eaad_id] [int] NOT NULL IDENTITY(1, 1),
[expedite_audit_ident] [int] NOT NULL,
[eaad_datetime] [datetime] NOT NULL CONSTRAINT [DF_EAAD_last_updatedate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[expedite_audit_arrival_departure] ADD CONSTRAINT [prkey_expedite_audit_arrival_departure] PRIMARY KEY CLUSTERED ([eaad_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_expedite_audit_ident] ON [dbo].[expedite_audit_arrival_departure] ([expedite_audit_ident]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[expedite_audit_arrival_departure] TO [public]
GO
GRANT SELECT ON  [dbo].[expedite_audit_arrival_departure] TO [public]
GO

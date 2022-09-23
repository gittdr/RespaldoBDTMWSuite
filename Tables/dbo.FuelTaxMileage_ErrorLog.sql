CREATE TABLE [dbo].[FuelTaxMileage_ErrorLog]
(
[fte_recid] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[fte_entrytype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fte_errorcode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fte_errorline] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fte_createdate] [datetime] NOT NULL,
[fte_createdby] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelTaxMileage_ErrorLog] ADD CONSTRAINT [PK_fte_recid] PRIMARY KEY CLUSTERED ([fte_recid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_fte_createddate] ON [dbo].[FuelTaxMileage_ErrorLog] ([fte_createdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_fte_errorcode] ON [dbo].[FuelTaxMileage_ErrorLog] ([fte_errorcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_fte_lgh_number] ON [dbo].[FuelTaxMileage_ErrorLog] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelTaxMileage_ErrorLog] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelTaxMileage_ErrorLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelTaxMileage_ErrorLog] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelTaxMileage_ErrorLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelTaxMileage_ErrorLog] TO [public]
GO

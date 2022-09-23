CREATE TABLE [dbo].[FuelTaxMileageDetail]
(
[ftm_recid] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[ftm_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftm_freemiles] [decimal] (9, 4) NOT NULL,
[ftm_tollmiles] [decimal] (9, 4) NOT NULL,
[ftm_totalmiles] [decimal] (9, 4) NOT NULL,
[ftm_tollcost] [money] NULL,
[ftm_date] [datetime] NOT NULL,
[ftm_entrytype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ftm_reprocess] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftm_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ftm_createdate] [datetime] NOT NULL,
[ftm_createdby] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ftm_updatedate] [datetime] NULL,
[ftm_updatedby] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelTaxMileageDetail] ADD CONSTRAINT [PK_ftm_recid] PRIMARY KEY CLUSTERED ([ftm_recid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ftm_date] ON [dbo].[FuelTaxMileageDetail] ([ftm_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ftm_reprocess] ON [dbo].[FuelTaxMileageDetail] ([ftm_reprocess]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ftm_state] ON [dbo].[FuelTaxMileageDetail] ([ftm_state]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ftm_status] ON [dbo].[FuelTaxMileageDetail] ([ftm_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ftm_lgh_number] ON [dbo].[FuelTaxMileageDetail] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelTaxMileageDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelTaxMileageDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelTaxMileageDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelTaxMileageDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelTaxMileageDetail] TO [public]
GO

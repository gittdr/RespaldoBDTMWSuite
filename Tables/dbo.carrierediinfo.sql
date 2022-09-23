CREATE TABLE [dbo].[carrierediinfo]
(
[cei_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cei_effective_dt] [datetime] NULL,
[cei_edi_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_other1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_other2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_other3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_other4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_misc1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_misc2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_misc3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cei_edi_misc4] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierediinfo] ADD CONSTRAINT [pk_carrierediinfo_cei_id] PRIMARY KEY CLUSTERED ([cei_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierediinfo_car_id] ON [dbo].[carrierediinfo] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierediinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierediinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierediinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierediinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierediinfo] TO [public]
GO

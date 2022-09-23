CREATE TABLE [dbo].[carrier_d83]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[effective_dt] [datetime] NULL,
[expiration_dt] [datetime] NULL,
[origin_zip] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination_zip] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_between] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adj_pct] [decimal] (10, 2) NULL,
[min_charge] [decimal] (10, 2) NULL,
[sequence] [int] NULL,
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedt] [datetime] NULL,
[transfer_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[absolute_min] [decimal] (12, 2) NULL,
[absolute_min_cmp] [decimal] (12, 2) NULL,
[pickup_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier_d83] ADD CONSTRAINT [PK__carrier___3213E83F97B1F57F] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [carrierD83carid] ON [dbo].[carrier_d83] ([car_id], [effective_dt]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier_d83] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier_d83] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier_d83] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier_d83] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier_d83] TO [public]
GO

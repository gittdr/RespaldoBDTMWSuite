CREATE TABLE [dbo].[Pallet_tracking]
(
[pt_tractor_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_tractor_number] DEFAULT ('UNK'),
[pt_trailer_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_trailer_number] DEFAULT ('UNK'),
[pt_carrier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_carrier_id] DEFAULT ('UNK'),
[pt_company_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_company_id] DEFAULT ('UNK'),
[pt_pallets_in] [decimal] (8, 2) NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_pallets_in] DEFAULT (0),
[pt_pallets_out] [decimal] (8, 2) NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_pallets_out] DEFAULT (0),
[pt_hand_count] [decimal] (8, 2) NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_hand_count] DEFAULT (0),
[pt_pallet_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_pallet_type] DEFAULT ('UNK'),
[pt_activity_date] [datetime] NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_activity_date] DEFAULT (getdate()),
[pt_fgt_number] [int] NOT NULL CONSTRAINT [DF_Pallet_tracking_pt_fgt_number] DEFAULT (0),
[pt_identity] [int] NOT NULL IDENTITY(1, 1),
[pt_ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_comments] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pt_entry_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Pallet_tracking] ADD CONSTRAINT [pk_pallet_trk_ident] PRIMARY KEY CLUSTERED ([pt_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pt_carrier_id] ON [dbo].[Pallet_tracking] ([pt_carrier_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pt_company_id] ON [dbo].[Pallet_tracking] ([pt_company_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pt_fgt_number] ON [dbo].[Pallet_tracking] ([pt_fgt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pt_tractor_number] ON [dbo].[Pallet_tracking] ([pt_tractor_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pt_trailer_number] ON [dbo].[Pallet_tracking] ([pt_trailer_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Pallet_tracking] TO [public]
GO
GRANT INSERT ON  [dbo].[Pallet_tracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Pallet_tracking] TO [public]
GO
GRANT SELECT ON  [dbo].[Pallet_tracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[Pallet_tracking] TO [public]
GO

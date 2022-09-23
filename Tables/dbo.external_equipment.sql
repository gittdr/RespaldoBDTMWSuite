CREATE TABLE [dbo].[external_equipment]
(
[ete_id] [int] NOT NULL IDENTITY(1, 1),
[ete_source] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_sourcerefnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_origlocation] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_origcity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_origstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_origzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_origlatitude] [decimal] (8, 4) NULL,
[ete_origlongitude] [decimal] (8, 4) NULL,
[ete_destlocation] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_destcity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_deststate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_destzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_destlatitude] [decimal] (8, 4) NULL,
[ete_destlongitude] [decimal] (8, 4) NULL,
[ete_availabledate] [datetime] NULL,
[ete_postingdate] [datetime] NULL,
[ete_expirationdate] [datetime] NULL,
[ete_equipmenttype] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_loadtype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_equipmentlength] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_loadweight] [decimal] (12, 4) NULL,
[ete_carrierid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_carriername] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_carrierstate] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_carriermcnumber] [int] NULL,
[ete_contactname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_contactphone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_contactaltphone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_truckcount] [smallint] NULL,
[ete_truckid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_created] [datetime] NULL,
[ete_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_updated] [datetime] NULL,
[ete_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_truck_mcnum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_driver_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_original_truckcount] [int] NULL,
[ete_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_external_equipment_ete_status] DEFAULT ('AVL'),
[ete_remarks] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_mc] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_originradius] [int] NULL,
[ete_destradius] [int] NULL,
[ete_automatch] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ete_lgh_number] [int] NOT NULL CONSTRAINT [DF__external___ete_l__4B0C7EC0] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_equipment] ADD CONSTRAINT [pk_ete_id] PRIMARY KEY CLUSTERED ([ete_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ete_carrierid] ON [dbo].[external_equipment] ([ete_carrierid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ete_carriermcnumber] ON [dbo].[external_equipment] ([ete_carriermcnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ete_expirationdate] ON [dbo].[external_equipment] ([ete_expirationdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_external_equipment_expires] ON [dbo].[external_equipment] ([ete_expirationdate], [ete_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ete_source] ON [dbo].[external_equipment] ([ete_source]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ete_sourcerefnumber] ON [dbo].[external_equipment] ([ete_sourcerefnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ete_truckid] ON [dbo].[external_equipment] ([ete_truckid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[external_equipment] TO [public]
GO
GRANT INSERT ON  [dbo].[external_equipment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[external_equipment] TO [public]
GO
GRANT SELECT ON  [dbo].[external_equipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[external_equipment] TO [public]
GO

CREATE TABLE [dbo].[RailTemplateHeader]
(
[rth_id] [int] NOT NULL IDENTITY(1, 1),
[rth_masterbillid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rth_origin_ramp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rth_origin_ramp_actual] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_dest_ramp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rth_dest_ramp_actual] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_notifyparty] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_notifyfax] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_notifyphone] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_lastupdate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailTemplateHeader] ADD CONSTRAINT [pk_railtemplateheader_rth_id] PRIMARY KEY CLUSTERED ([rth_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_railtemplateheader_composite] ON [dbo].[RailTemplateHeader] ([car_id], [rth_origin_ramp], [rth_dest_ramp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_railtemplateheader_rth_masterbillid] ON [dbo].[RailTemplateHeader] ([rth_masterbillid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RailTemplateHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[RailTemplateHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RailTemplateHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[RailTemplateHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[RailTemplateHeader] TO [public]
GO

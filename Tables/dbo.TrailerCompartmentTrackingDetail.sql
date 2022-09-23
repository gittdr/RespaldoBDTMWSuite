CREATE TABLE [dbo].[TrailerCompartmentTrackingDetail]
(
[tctd_id] [int] NOT NULL IDENTITY(1, 1),
[tcth_id] [int] NOT NULL,
[fgt_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tctd_volume] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrailerCompartmentTrackingDetail] ADD CONSTRAINT [PK_TrailerCompartmentTrackingDetail] PRIMARY KEY CLUSTERED ([tctd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrailerCompartmentTrackingDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TrailerCompartmentTrackingDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrailerCompartmentTrackingDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TrailerCompartmentTrackingDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrailerCompartmentTrackingDetail] TO [public]
GO

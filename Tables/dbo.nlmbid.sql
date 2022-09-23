CREATE TABLE [dbo].[nlmbid]
(
[nlm_shipment_number] [int] NOT NULL,
[accid] [int] NOT NULL,
[shipmentresponse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[refusalreason] [int] NULL,
[spotbid] [money] NULL,
[etapickup] [datetime] NULL,
[etadestination] [datetime] NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_nlmbid_id] ON [dbo].[nlmbid] ([nlm_shipment_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmbid] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmbid] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmbid] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmbid] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmbid] TO [public]
GO

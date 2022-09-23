CREATE TABLE [dbo].[customercrossref]
(
[cxr_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cxr_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cxr_lastbusinessdt] [datetime] NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cxr_conship] ON [dbo].[customercrossref] ([cxr_consignee], [cxr_shipper]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cxr_shipcon] ON [dbo].[customercrossref] ([cxr_shipper], [cxr_consignee]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[customercrossref] TO [public]
GO
GRANT INSERT ON  [dbo].[customercrossref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[customercrossref] TO [public]
GO
GRANT SELECT ON  [dbo].[customercrossref] TO [public]
GO
GRANT UPDATE ON  [dbo].[customercrossref] TO [public]
GO

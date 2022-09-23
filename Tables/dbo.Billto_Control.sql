CREATE TABLE [dbo].[Billto_Control]
(
[fgt_shipper] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_consignee] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_terms] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_billto] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[masterord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Billto_Control] TO [public]
GO
GRANT INSERT ON  [dbo].[Billto_Control] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Billto_Control] TO [public]
GO
GRANT SELECT ON  [dbo].[Billto_Control] TO [public]
GO
GRANT UPDATE ON  [dbo].[Billto_Control] TO [public]
GO

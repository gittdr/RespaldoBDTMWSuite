CREATE TABLE [dbo].[capacityheader]
(
[cph_number] [int] NOT NULL IDENTITY(1, 1),
[cph_seq] [int] NULL,
[cph_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_wgt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_ldm] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_vol] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_calcwgt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[capacityheader] TO [public]
GO
GRANT INSERT ON  [dbo].[capacityheader] TO [public]
GO
GRANT SELECT ON  [dbo].[capacityheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[capacityheader] TO [public]
GO

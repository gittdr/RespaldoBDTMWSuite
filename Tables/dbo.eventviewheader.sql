CREATE TABLE [dbo].[eventviewheader]
(
[evh_number] [int] NOT NULL IDENTITY(1, 1),
[evh_seq] [int] NULL,
[evh_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evh_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventviewheader] TO [public]
GO
GRANT INSERT ON  [dbo].[eventviewheader] TO [public]
GO
GRANT SELECT ON  [dbo].[eventviewheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventviewheader] TO [public]
GO

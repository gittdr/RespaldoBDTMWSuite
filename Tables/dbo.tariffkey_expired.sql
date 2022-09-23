CREATE TABLE [dbo].[tariffkey_expired]
(
[tar_number] [int] NULL,
[trk_endate] [datetime] NULL,
[trk_billto] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

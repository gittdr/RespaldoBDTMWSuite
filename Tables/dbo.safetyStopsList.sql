CREATE TABLE [dbo].[safetyStopsList]
(
[ssl_Ident] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[ssl_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[srp_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stp_number] [int] NULL,
[scl_Ident] [int] NULL,
[fgt_number] [int] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[safetyStopsList] ADD CONSTRAINT [pk_ssl_ID] PRIMARY KEY CLUSTERED ([ssl_Ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[safetyStopsList] TO [public]
GO
GRANT INSERT ON  [dbo].[safetyStopsList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[safetyStopsList] TO [public]
GO
GRANT SELECT ON  [dbo].[safetyStopsList] TO [public]
GO
GRANT UPDATE ON  [dbo].[safetyStopsList] TO [public]
GO

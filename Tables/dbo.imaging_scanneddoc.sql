CREATE TABLE [dbo].[imaging_scanneddoc]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[isd_rollontrip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[isd_doctype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[isd_docdelivery] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isd_email_address] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[imaging_scanneddoc] ADD CONSTRAINT [PK__imaging_scannedd__28FB90B9] PRIMARY KEY CLUSTERED ([cmp_id], [isd_rollontrip], [isd_doctype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[imaging_scanneddoc] TO [public]
GO
GRANT INSERT ON  [dbo].[imaging_scanneddoc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[imaging_scanneddoc] TO [public]
GO
GRANT SELECT ON  [dbo].[imaging_scanneddoc] TO [public]
GO
GRANT UPDATE ON  [dbo].[imaging_scanneddoc] TO [public]
GO

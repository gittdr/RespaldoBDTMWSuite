CREATE TABLE [dbo].[m2msgqhdr]
(
[m2qhid] [int] NOT NULL,
[m2qhtype] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2qhcrtdte] [datetime] NULL,
[m2qhstatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2qhid] ON [dbo].[m2msgqhdr] ([m2qhid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2msgqhdr] TO [public]
GO
GRANT INSERT ON  [dbo].[m2msgqhdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2msgqhdr] TO [public]
GO
GRANT SELECT ON  [dbo].[m2msgqhdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2msgqhdr] TO [public]
GO

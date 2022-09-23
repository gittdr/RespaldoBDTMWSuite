CREATE TABLE [dbo].[dedbillingcustinvnums]
(
[dbh_id] [int] NOT NULL,
[dbh_custinvnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custinvnum_prefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custinvnum] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillingcustinvnums] ADD CONSTRAINT [PK__dedbillingcustin__6751F36A] PRIMARY KEY CLUSTERED ([dbh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillingcustinvnums] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillingcustinvnums] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillingcustinvnums] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillingcustinvnums] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillingcustinvnums] TO [public]
GO
